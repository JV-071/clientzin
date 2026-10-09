#include <gtest/gtest.h>
#include "client/luavaluecasts_client.h"
#include "framework/luaengine/luainterface.h"
#include "framework/util/crypt.h"
#include "framework/otml/otmldocument.h"
#include "framework/graphics/coordsbuffer.h"
#include "framework/graphics/drawpoolmanager.h"
#include "framework/graphics/texture.h"
#include "framework/net/inputmessage.h"
#include "framework/core/resourcemanager.h"
#include "framework/graphics/texturemanager.h"
#include "framework/ui/uiwidget.h"
#include "client/protocolgame.h"
#include "client/game.h"
#include "client/gameconfig.h"
#include "client/localplayer.h"
#include "client/uiitem.h"
#include "client/item.h"
#include "client/thingtypemanager.h"
#include <sstream>
#include "framework/platform/platformwindow.h"
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
    // Use the real CPU-side draw pool; preserve any prior singleton state.
    struct ForegroundPool {
        static constexpr auto index = static_cast<uint8_t>(DrawPoolType::FOREGROUND);
        DrawPool* previous{ g_drawPool.m_pools[index] };
        std::unique_ptr<DrawPool> owned{ DrawPool::create(DrawPoolType::FOREGROUND) };
        ForegroundPool() { g_drawPool.m_pools[index] = owned.get(); }
        ~ForegroundPool() { g_drawPool.m_pools[index] = previous; }
    };
    void SetUp() override
    {
        g_lua.init();
        // Creature construction resolves its typing icon through PhysicsFS,
        // just as in the map tests; Lua alone is not a complete environment.
        g_resources.init(".");
        g_resources.addSearchPath(".");
        g_textures.init();
    }
    void TearDown() override
    {
        g_lua.clearStack();
        g_lua.terminate();
        g_textures.terminate();
        g_resources.terminate();
    }
    ItemPtr displayItem(UIItem& widget)
    {
        return widget.resolveDisplayItem();
    }
    ItemPtr parseItem(const InputMessagePtr& message)
    {
        ProtocolGame protocol;
        return protocol.getItem(message);
    }
    void parsePrey(const InputMessagePtr& message)
    {
        ProtocolGame protocol;
        protocol.parsePreyData(message);
    }
    void parseSkills(const InputMessagePtr& message)
    {
        g_lua.registerClass<LocalPlayer>();
        std::cout << "[skills test] Creating protocol and local player" << std::endl;
        ProtocolGame protocol;
        protocol.m_localPlayer = std::make_shared<LocalPlayer>();
        std::cout << "[skills test] Parsing skills packet" << std::endl;
        protocol.parsePlayerSkills(message);
        std::cout << "[skills test] Skills packet parsed" << std::endl;
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

TEST_F(RuntimeEventTest, PreySelectionEventsMatchTheRecoveredModuleContract)
{
    const auto previousVersion = g_game.getClientVersion();
    const auto previousSupportedVersion = g_gameConfig.getLastSupportedVersion();
    g_gameConfig.setLastSupportedVersion(1530);
    g_game.setClientVersion(1530);
    g_lua.loadFunction(R"lua(
        preySelections = 0
        g_game = { onPreySelection = function(slot, bonusType, bonusValue, bonusGrade,
                                             names, outfits, freeReroll, lockType)
            assert(slot == 0)
            assert(type(names) == 'table' and #names == 0)
            assert(type(outfits) == 'table' and #outfits == 0)
            assert(freeReroll == 60 and lockType == 2)
            if preySelections == 0 then
                assert(bonusType == 0 and bonusValue == 0 and bonusGrade == 0)
            else
                assert(bonusType == 1 and bonusValue == 25 and bonusGrade == 3)
            end
            preySelections = preySelections + 1
        end }
    )lua", "@prey_contract_probe.lua");
    ASSERT_EQ(0, g_lua.safeCall());

    for (const bool changeMonster : {false, true}) {
        std::string packet;
        packet.push_back(0); // slot
        packet.push_back(changeMonster ? Otc::PREY_STATE_SELECTION_CHANGE_MONSTER : Otc::PREY_STATE_SELECTION);
        if (changeMonster) {
            packet.push_back(1); // bonus type
            packet.push_back(25); packet.push_back(0); // bonus value, U16
            packet.push_back(3); // bonus grade
        }
        packet.push_back(0); // empty monster list
        packet.push_back(60); packet.append(3, '\0'); // next free roll, U32
        packet.push_back(2); // option/lock state
        auto message = std::make_shared<InputMessage>();
        const auto start = message->getReadPos();
        message->setBuffer(packet);
        message->setReadPos(start);
        EXPECT_NO_THROW(parsePrey(message));
        EXPECT_TRUE(message->eof());
    }
    g_lua.loadFunction("return preySelections", "@prey_contract_result.lua");
    ASSERT_EQ(1, g_lua.safeCall());
    EXPECT_EQ(2, g_lua.popInteger());
    g_game.setClientVersion(previousVersion);
    g_gameConfig.setLastSupportedVersion(previousSupportedVersion);
}

TEST_F(RuntimeEventTest, DecoKitPreviewRetainsPacketContentWithoutChangingTheInventoryItem)
{
    struct ThingLibrary {
        ThingLibrary() { g_things.init(); }
        ~ThingLibrary() { g_things.terminate(); }
    } library;
    ASSERT_TRUE(g_resources.addSearchPath(std::string(CLIENTZIN_SOURCE_DIR) + "/assets"));
    ASSERT_TRUE(g_things.loadAppearances("/things/assets/"));
    g_lua.registerClass<UIWidget>();
    g_lua.registerClass<UIItem, UIWidget>();
    g_lua.registerClass<Item>();
    g_game.enableFeature(Otc::GameWrapKit);

    const auto northBounds = g_things.getCreatureBoundingBox(3, 0, Otc::North, 0);
    EXPECT_TRUE(northBounds.isValid());
    EXPECT_NE(northBounds, g_things.getCreatureBoundingBox(3, 0, Otc::East, 0));
    EXPECT_EQ(g_things.getCreatureBoundingBox(3, 0, Otc::East, 0),
              g_things.getCreatureBoundingBox(3, 0, Otc::NorthEast, 0));
    EXPECT_EQ(g_things.getCreatureBoundingBox(3, 0, Otc::West, 0),
              g_things.getCreatureBoundingBox(3, 0, Otc::NorthWest, 0));
    EXPECT_FALSE(g_things.getCreatureBoundingBox(0, 0, Otc::South, 0).isValid());
    EXPECT_FALSE(g_things.getCreatureBoundingBox(3, 0, -1, 0).isValid());

    // Actual asset IDs: decoration kit 23398, ground 7594 as a valid preview target.
    auto message = std::make_shared<InputMessage>();
    const auto start = message->getReadPos();
    std::string packet;
    for (const uint16_t id : {uint16_t(23398), uint16_t(7594)}) {
        packet.push_back(static_cast<char>(id & 0xff));
        packet.push_back(static_cast<char>(id >> 8));
    }
    message->setBuffer(packet);
    message->setReadPos(start);
    const auto kit = parseItem(message);
    ASSERT_NE(nullptr, kit);
    EXPECT_TRUE(message->eof());
    EXPECT_TRUE(kit->isDecoKit());
    EXPECT_EQ(7594, kit->getUnwrapId());

    ForegroundPool foreground;
    auto widget = std::make_shared<UIItem>();
    widget->setItem(kit);
    widget->setUseDecoKitContainerSprite(true);
    EXPECT_EQ(kit, displayItem(*widget));
    widget->setUseDecoKitContainerSprite(false);
    const auto preview = displayItem(*widget);
    ASSERT_NE(nullptr, preview);
    EXPECT_NE(kit, preview);
    EXPECT_EQ(7594, preview->getId());
    EXPECT_EQ(23398, kit->getId());
    EXPECT_EQ(kit, widget->getItem());
    widget->setUseDecoKitContainerSprite(true);
    EXPECT_EQ(kit, displayItem(*widget));
    kit->setUnwrapId(0);
    widget->setUseDecoKitContainerSprite(false);
    EXPECT_EQ(kit, displayItem(*widget));
    widget->destroy();
    g_game.disableFeature(Otc::GameWrapKit);
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

TEST(PlatformWindowKeyBounds, IncludesEveryKeyDeclaredByLua)
{
    EXPECT_EQ(151, static_cast<int>(Fw::KeyNumpadEnter));
    EXPECT_EQ(167, static_cast<int>(Fw::KeyNumpadDivide));
    EXPECT_EQ(168, static_cast<int>(Fw::KeyLast));
    for (int code = 0; code <= 167; ++code) {
        SCOPED_TRACE(code);
        EXPECT_NO_THROW(g_window.isKeyPressed(static_cast<Fw::Key>(code)));
    }
}

TEST(PlatformWindowKeyBounds, RejectsOutOfRangeQueriesWithoutIndexing)
{
    EXPECT_THROW(g_window.isKeyPressed(static_cast<Fw::Key>(-1)), std::out_of_range);
    EXPECT_THROW(g_window.isKeyPressed(Fw::KeyLast), std::out_of_range);
    EXPECT_THROW(g_window.isKeyPressed(static_cast<Fw::Key>(999)), std::out_of_range);
    EXPECT_NO_THROW(g_window.setKeyDelay(static_cast<Fw::Key>(-1), 30));
    EXPECT_NO_THROW(g_window.setKeyDelay(Fw::KeyLast, 30));
}

#ifdef FRAMEWORK_PROTOBUF
#include "client/appearancecatalog.h"
TEST(AppearanceCatalog, LoadsBaseAndSupplementInCatalogOrder)
{
    using otclient::protobuf::appearances::Appearances;
    Appearances base, supplement;
    auto* item = base.add_object();
    item->set_id(3349);
    item->mutable_flags()->mutable_upgradeclassification()->set_upgrade_classification(1);
    supplement.add_object()->set_id(60000);
    supplement.add_object()->set_id(3349);
    std::vector<std::string> reads;
    const auto merged = AppearanceCatalog::load({"base.dat", "custom.dat"}, [&](const std::string& name) {
        reads.push_back(name);
        return name == "base.dat" ? base.SerializeAsString() : supplement.SerializeAsString();
    });
    EXPECT_EQ((std::vector<std::string>{"base.dat", "custom.dat"}), reads);
    ASSERT_EQ(3, merged.object_size());
    EXPECT_EQ(3349u, merged.object(0).id());
    EXPECT_EQ(1u, merged.object(0).flags().upgradeclassification().upgrade_classification());
    EXPECT_EQ(60000u, merged.object(1).id());
    EXPECT_EQ(3349u, merged.object(2).id()); // supplement definitions override last
}
TEST(AppearanceCatalog, RejectsMissingAndMalformedLibraries)
{
    const auto invalid = [](const std::string&) { return std::string(1, '\xff'); };
    EXPECT_THROW(AppearanceCatalog::load({}, invalid), std::runtime_error);
    EXPECT_THROW(AppearanceCatalog::load({"broken.dat"}, invalid), std::runtime_error);
}
#endif
#include "framework/core/eventdispatcher.h"
TEST(EventSourceDiagnostics, SourceIsConsumedOnceAndDoesNotLeakToFollowingEvents)
{
    EventDispatcher dispatcher;
    dispatcher.shutdown();
    dispatcher.setNextEventSource("hitch:helper_target.lua:2587");
    EXPECT_TRUE(dispatcher.hasNextEventSource());
    EXPECT_EQ("hitch:helper_target.lua:2587", dispatcher.scheduleEvent([] {}, 1)->getFunction());
    EXPECT_FALSE(dispatcher.hasNextEventSource());
    EXPECT_EQ("ScheduledEvent", dispatcher.scheduleEvent([] {}, 1)->getFunction());
    dispatcher.setActiveEventSource("active callback");
    EXPECT_EQ("active callback", dispatcher.getActiveEventSource());
    dispatcher.setActiveEventSource("");
}

TEST_F(RuntimeEventTest, NativeExceptionRetainsCauseAndLuaCallsiteAndAllowsFollowingCalls)
{
    bool fail = true;
    g_lua.pushCppFunction([&](LuaInterface* lua) -> int {
        if (fail) {
            fail = false;
            {
                std::runtime_error nativeError("reconnect diagnostic sentinel");
                EXPECT_STREQ("reconnect diagnostic sentinel", nativeError.what());
            }
            try {
                throw std::runtime_error("reconnect diagnostic sentinel");
            } catch (const std::exception& error) {
                EXPECT_STREQ("reconnect diagnostic sentinel", error.what());
                throw;
            }
        }
        lua->pushInteger(7);
        return 1;
    });
    g_lua.setGlobal("nativeReconnectProbe");
    g_lua.loadFunction("local ok, err = pcall(nativeReconnectProbe); return ok, err, nativeReconnectProbe()",
                       "@reconnect_exception_probe.lua");
    ASSERT_EQ(3, g_lua.safeCall());
    EXPECT_EQ(7, g_lua.popInteger());
    const auto error = g_lua.popString();
    SCOPED_TRACE(error);
    EXPECT_NE(std::string::npos, error.find("reconnect diagnostic sentinel"));
    EXPECT_NE(std::string::npos, error.find("reconnect_exception_probe.lua"));
    EXPECT_FALSE(g_lua.popBoolean());
    EXPECT_EQ(0, g_lua.getTop());
}
TEST_F(RuntimeEventTest, UnknownNativeExceptionRetainsLuaCallsiteAndAllowsFollowingCalls)
{
    bool fail = true;
    g_lua.pushCppFunction([&](LuaInterface* lua) -> int {
        if (fail) { fail = false; throw 42; }
        lua->pushInteger(9);
        return 1;
    });
    g_lua.setGlobal("nativeReconnectProbe");
    g_lua.loadFunction("local ok, err = pcall(nativeReconnectProbe); return ok, err, nativeReconnectProbe()",
                       "@unknown_reconnect_exception_probe.lua");
    ASSERT_EQ(3, g_lua.safeCall());
    EXPECT_EQ(9, g_lua.popInteger());
    const auto error = g_lua.popString();
    SCOPED_TRACE(error);
    EXPECT_NE(std::string::npos, error.find("Unknown C++ exception"));
    EXPECT_NE(std::string::npos, error.find("unknown_reconnect_exception_probe.lua"));
    EXPECT_FALSE(g_lua.popBoolean());
    EXPECT_EQ(0, g_lua.getTop());
}

TEST(NativeExceptionIntegrity, StandardExceptionRetainsItsMessageWithoutLua)
{
    std::runtime_error error("native exception integrity sentinel");
    EXPECT_STREQ("native exception integrity sentinel", error.what());
    try {
        throw std::runtime_error("native exception integrity sentinel");
    } catch (const std::exception& caught) {
        EXPECT_STREQ("native exception integrity sentinel", caught.what());
    }
}
TEST_F(RuntimeEventTest, StandardExceptionRetainsItsMessageAfterLuaInitialization)
{
    std::runtime_error error("initialized exception integrity sentinel");
    EXPECT_STREQ("initialized exception integrity sentinel", error.what());
    try {
        throw std::runtime_error("initialized exception integrity sentinel");
    } catch (const std::exception& caught) {
        EXPECT_STREQ("initialized exception integrity sentinel", caught.what());
    }
}
