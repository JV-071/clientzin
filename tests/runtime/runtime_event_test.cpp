#include <gtest/gtest.h>
#include "client/luavaluecasts_client.h"
#include "framework/luaengine/luainterface.h"
#include "framework/util/crypt.h"
#include "framework/otml/otmldocument.h"
#include "framework/graphics/coordsbuffer.h"
#include "framework/graphics/texture.h"
#include "framework/net/inputmessage.h"
#include "framework/ui/uiwidget.h"
#include "client/protocolgame.h"
#include "client/game.h"
#include "client/gameconfig.h"
#include "client/localplayer.h"
#include <sstream>
#ifdef _WIN32
#include <windows.h>
#endif

TEST(AssetIdentifier, Sha256MatchesKnownVectors)
{
    EXPECT_EQ("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", g_crypt.sha256(""));
    EXPECT_EQ("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad", g_crypt.sha256("abc"));
    EXPECT_NE(g_crypt.sha256("catalog v1"), g_crypt.sha256("catalog v2"));
}

TEST(InputMessageBounds, PreviewDoesNotTruncateAt256BytesAndEndIncludesHeader)
{
    InputMessage message;
    const int bodyStart = message.getReadPos();
    message.setBuffer(std::string(300, 'x'));
    message.setReadPos(bodyStart);
    EXPECT_EQ(300u, message.peekBytes(400).size());
    EXPECT_EQ(256u, message.peekBytes(256).size());
    EXPECT_TRUE(message.peekBytes(-1).empty());
    EXPECT_EQ(bodyStart, message.getReadPos());
    message.skipBytes(message.getUnreadSize());
    EXPECT_TRUE(message.eof());
    EXPECT_EQ(0, message.getUnreadSize());
}

#ifdef _WIN32
extern void Stacktrace(LPEXCEPTION_POINTERS, std::stringstream&);
TEST(WindowsCrashReport, WalkingTheStackDoesNotFreeStackMemory)
{
    CONTEXT context{};
    RtlCaptureContext(&context);
    EXCEPTION_RECORD record{};
    EXCEPTION_POINTERS pointers{&record, &context};
    std::stringstream output;
    EXPECT_NO_THROW(Stacktrace(&pointers, output));
}
#endif

TEST(TextureDimensions, RejectsUnsetAndEmptyDimensionsBeforeGraphicsCalls)
{
    Texture texture;
    EXPECT_FALSE(texture.setupSize(Size()));
    EXPECT_FALSE(texture.setupSize(Size(-1, 16)));
    EXPECT_FALSE(texture.setupSize(Size(16, -1)));
    EXPECT_FALSE(texture.setupSize(Size(0, 16)));
    EXPECT_FALSE(texture.setupSize(Size(16, 0)));
}

TEST(RepeatedImage, BottomAlignmentClipsTheTopOfTheFirstTile)
{
    CoordsBuffer coords;
    coords.addRepeatedRects(Rect(0, 0, 4, 6), Rect(10, 20, 4, 4), true);
    ASSERT_GT(coords.getVertexCount(), 0);
    float minY = 1000.f;
    float minTextureY = 1000.f;
    for (int i = 0; i < 6; ++i) {
        minY = (std::min)(minY, coords.getVertexArray()[2 * i + 1]);
        minTextureY = (std::min)(minTextureY, coords.getTextureCoordArray()[2 * i + 1]);
    }
    EXPECT_EQ(0.f, minY);
    EXPECT_EQ(22.f, minTextureY);
}

class RuntimeEventTest : public ::testing::Test {
protected:
    void SetUp() override { g_lua.init(); }
    void TearDown() override { g_lua.clearStack(); g_lua.terminate(); }
    void parseSkills(const InputMessagePtr& message)
    {
        g_lua.registerClass<LocalPlayer>();
        ProtocolGame protocol;
        protocol.m_localPlayer = std::make_shared<LocalPlayer>();
        protocol.parsePlayerSkills(message);
    }
};

TEST_F(RuntimeEventTest, LuaHtmlWhitespaceDoesNotRequireNativeNode)
{
    class TestWidget : public UIWidget {
    public:
        using UIWidget::applyWhiteSpace;
    };
    g_lua.registerClass<TestWidget>();
    auto widget = std::make_shared<TestWidget>();
    widget->setOnHtml(true);
    ASSERT_TRUE(widget->isOnHtml());
    ASSERT_EQ(nullptr, widget->getHtmlNode());
    EXPECT_NO_THROW(widget->applyWhiteSpace());
    widget->destroy();
}

TEST_F(RuntimeEventTest, ModernSkillsDoNotConsumeLegacyAdditionalSkillPairs)
{
    g_lua.loadBuffer("g_game = {}", "@skills-packet-test");
    g_lua.safeCall(0, 0);
    const auto previousSupportedVersion = g_gameConfig.getLastSupportedVersion();
    g_gameConfig.setLastSupportedVersion(1530);
    g_game.setClientVersion(1530);
    for (auto feature : {Otc::GameDoubleSkills, Otc::GameSkillsBase,
                         Otc::GameBaseSkillU16, Otc::GameAdditionalSkills,
                         Otc::GameConcotions, Otc::GameCharacterSkillStats})
        g_game.enableFeature(feature);

    // Server 15.30: magic + seven skills (64), list count (1), capacities
    // (8), attack/conversion (11), imbuements (25), defense (18), absorb
    // count (1), forge doubles (15). The following opcode must remain unread.
    auto message = std::make_shared<InputMessage>();
    const int start = message->getReadPos();
    message->setBuffer(std::string(143, '\0') + static_cast<char>(0x9c));
    message->setReadPos(start);
    EXPECT_NO_THROW(parseSkills(message));
    EXPECT_EQ(1, message->getUnreadSize());
    EXPECT_EQ(0x9c, message->getU8());
    g_game.setClientVersion(0);
    g_gameConfig.setLastSupportedVersion(previousSupportedVersion);
}

TEST_F(RuntimeEventTest, ColorUsesGlobalPaletteAtRequestedStackIndex)
{
    std::istringstream palette("$var-runtime-test-color: #123456\n");
    OTMLDocument::parse(palette, "runtime-test-palette");
    g_lua.pushString("$var-runtime-test-color");
    g_lua.pushBoolean(false);
    Color color;
    ASSERT_TRUE(luavalue_cast(1, color));
    EXPECT_EQ(Color(0x12, 0x34, 0x56), color);
    EXPECT_EQ(2, g_lua.getTop());
}

TEST_F(RuntimeEventTest, TracebackSurvivesModuleShadowingDebugLibrary)
{
    const int sandbox = g_lua.newSandboxEnv();
    g_lua.setGlobalEnvironment(sandbox);
    g_lua.loadBuffer("function debug() end", "@shadow-debug-test");
    g_lua.safeCall(0, 0);
    const auto message = g_lua.traceback("original Lua error", 0);
    EXPECT_NE(std::string::npos, message.find("original Lua error"));
    EXPECT_NE(std::string::npos, message.find("stack traceback"));
    EXPECT_EQ(0, g_lua.getTop());
    g_lua.resetGlobalEnvironment();
    g_lua.unref(sandbox);
}

TEST_F(RuntimeEventTest, PreservesNestedFieldsAndLuaArrayIndices)
{
    RuntimeEventTable event{{
        {"enabled", true}, {"price", 4294967295u},
        {"offers", nlohmann::json::array({{{"name", "Bundle"}, {"clientId2", 1234}}})}
    }};
    ASSERT_EQ(1, push_luavalue(event));
    ASSERT_EQ(1, g_lua.getTop());
    g_lua.getField("enabled");
    EXPECT_TRUE(g_lua.popBoolean());
    g_lua.getField("price");
    EXPECT_DOUBLE_EQ(4294967295.0, g_lua.popNumber());
    g_lua.getField("offers");
    g_lua.pushInteger(1);
    g_lua.getTable();
    g_lua.getField("name");
    EXPECT_EQ("Bundle", g_lua.popString());
    g_lua.getField("clientId2");
    EXPECT_EQ(1234, g_lua.popInteger());
}

TEST_F(RuntimeEventTest, EmptyArrayRemainsATable)
{
    EXPECT_EQ(1, push_luavalue(RuntimeEventTable{nlohmann::json::array()}));
    EXPECT_TRUE(g_lua.isTable());
}

TEST_F(RuntimeEventTest, ReadsPartyPricesWithoutChangingTheStack)
{
    using Price = std::pair<uint16_t, uint64_t>;
    const std::vector<Price> expected{{3031, 4294967296ULL}, {3035, 100}};
    push_luavalue(expected);
    std::vector<Price> actual;
    ASSERT_TRUE(luavalue_cast(-1, actual));
    EXPECT_EQ(expected, actual);
    EXPECT_EQ(1, g_lua.getTop());

    g_lua.rawGeti(1, 1);
    Price first{};
    ASSERT_TRUE(luavalue_cast(2, first));
    EXPECT_EQ(expected.front(), first);
    EXPECT_EQ(2, g_lua.getTop());
}
