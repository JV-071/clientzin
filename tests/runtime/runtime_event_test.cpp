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
#include "framework/core/eventdispatcher.h"
#include "framework/graphics/texturemanager.h"
#include "framework/ui/uiwidget.h"
#include "framework/ui/uimanager.h"
#include "client/protocolgame.h"
#include "client/game.h"
#include "client/gameconfig.h"
#include "client/localplayer.h"
#include "client/uiitem.h"
#include "client/uicreature.h"
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
    struct DispatcherSession {
        EventDispatcher previous{ std::move(g_dispatcher) };
        DispatcherSession() {
            g_dispatcher = EventDispatcher{};
            g_dispatcher.init();
        }
        ~DispatcherSession() {
            g_dispatcher.shutdown();
            g_dispatcher = std::move(previous);
        }
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
    Rect itemDrawRect(UIItem& widget, const int exactSize)
    {
        return widget.resolveItemDrawRect(exactSize);
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

TEST_F(RuntimeEventTest, CreaturePreviewSizeDoesNotChangeWidgetGeometry)
{
    g_lua.registerClass<UIWidget>();
    g_lua.registerClass<UICreature, UIWidget>();
    ForegroundPool foreground;
    DispatcherSession dispatcher;
    auto widget = std::make_shared<UICreature>();
    const Rect originalRect(50, 50, 40, 40);
    widget->setRect(originalRect);

    for (const uint8_t size : {uint8_t{100}, uint8_t{0}, uint8_t{32}}) {
        widget->setCreatureSize(size);
        EXPECT_EQ(size, widget->getCreatureSize());
        EXPECT_EQ(originalRect, widget->getRect());
    }
    widget->destroy();
}

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

TEST_F(RuntimeEventTest, ItemFixedSizeMatchesTheOriginalPreviewGeometry)
{
    g_lua.registerClass<UIWidget>();
    g_lua.registerClass<UIItem, UIWidget>();
    ForegroundPool foreground;
    DispatcherSession dispatcher;
    auto widget = std::make_shared<UIItem>();
    EXPECT_TRUE(widget->isFixedItemSize());
    widget->setRect(Rect(10, 20, 64, 64));
    EXPECT_EQ(Rect(26, 36, 32, 32), itemDrawRect(*widget, 32));
    for (const int side : {16, 32, 48, 64, 70, 96}) {
        const Rect slot(10, 20, side, side);
        widget->setRect(slot);
        widget->setFixedItemSize(true);
        EXPECT_EQ(side > 32 ? Rect(10 + (side - 32) / 2, 20 + (side - 32) / 2, 32, 32) : slot,
                  itemDrawRect(*widget, 32));
        widget->setFixedItemSize(false);
        EXPECT_EQ(side < 32 || side % 32 == 0 ? slot : Rect(10, 20, 32, 32),
                  itemDrawRect(*widget, 32));
        EXPECT_EQ(slot, widget->getRect());
    }
    // Original-engine captures include rectangular slots and undersized axes.
    widget->setRect(Rect(10, 20, 64, 48));
    widget->setFixedItemSize(true);
    EXPECT_EQ(Rect(26, 28, 32, 32), itemDrawRect(*widget, 32));
    widget->setFixedItemSize(false);
    EXPECT_EQ(Rect(10, 20, 32, 32), itemDrawRect(*widget, 32));
    widget->setRect(Rect(10, 20, 64, 8));
    EXPECT_EQ(widget->getRect(), itemDrawRect(*widget, 32));
    widget->setFixedItemSize(true);
    EXPECT_EQ(Rect(26, 8, 32, 32), itemDrawRect(*widget, 32));
    widget->setRect(Rect(10, 20, 8, 64));
    EXPECT_EQ(widget->getRect(), itemDrawRect(*widget, 32));
    widget->setFixedItemSize(false);
    EXPECT_EQ(widget->getRect(), itemDrawRect(*widget, 32));
    widget->setFixedItemSize(true);
    std::istringstream styleSource("FlexiblePreview\n  fixed-item-size: false\n");
    const auto style = OTMLDocument::parse(styleSource, "item-fixed-size-regression");
    widget->applyStyle(style->get("FlexiblePreview"));
    EXPECT_FALSE(widget->isFixedItemSize());
    widget->setRect(Rect(10, 20, 70, 70));
    widget->setFlipDirection(1);
    EXPECT_EQ(widget->getRect(), itemDrawRect(*widget, 32));
    widget->destroy();
}

TEST_F(RuntimeEventTest, CreatureStyleUpdatesThePreviewOutfitAndDirection)
{
    struct ThingLibrary {
        ThingLibrary() { g_things.init(); }
        ~ThingLibrary() { g_things.terminate(); }
    } library;
    ASSERT_TRUE(g_resources.addSearchPath(std::string(CLIENTZIN_SOURCE_DIR) + "/assets"));
    ASSERT_TRUE(g_things.loadAppearances("/things/assets/"));
    g_lua.registerClass<UIWidget>();
    g_lua.registerClass<UICreature, UIWidget>();
    g_lua.registerClass<Creature>();
    ForegroundPool foreground;
    DispatcherSession dispatcher;
    auto widget = std::make_shared<UICreature>();
    std::istringstream source(
        "Preview\n"
        "  outfit-id: 3\n"
        "  outfit-head: 10\n"
        "  outfit-body: 20\n"
        "  outfit-legs: 30\n"
        "  outfit-feet: 40\n"
        "  outfit-direction: 0\n");
    const auto document = OTMLDocument::parse(source, "creature-style-regression");
    widget->applyStyle(document->get("Preview"));
    ASSERT_NE(nullptr, widget->getCreature());
    const auto outfit = widget->getCreature()->getOutfit();
    EXPECT_EQ(3, outfit.getId());
    EXPECT_EQ(10, outfit.getHead());
    EXPECT_EQ(20, outfit.getBody());
    EXPECT_EQ(30, outfit.getLegs());
    EXPECT_EQ(40, outfit.getFeet());
    EXPECT_EQ(Otc::North, widget->getCreature()->getDirection());
    widget->destroy();
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

TEST_F(RuntimeEventTest, LuaStashTooltipTakesPriorityOverDuration)
{
    ASSERT_TRUE(g_resources.addSearchPath(std::string(CLIENTZIN_SOURCE_DIR)));
    const auto module = g_resources.readFileContents("/modules/game_interface/widgets/uiitem.lua");
    const std::string setup = R"lua(
UIItem = {}
UIWidget = {onHoverChange = function() end}
function signalcall(handler, ...) if handler then return handler(...) end end
)lua";
    const std::string scenario = R"lua(
local function check(stash, duration, expected)
  local seen
  local widget = {
    stashItemTooltip = stash,
    getParent = function() return nil end,
    getChildById = function()
      if duration then return {getText = function() return duration end} end
    end,
    setTooltip = function(_, text) seen = text end,
    isVirtual = function() return true end
  }
  UIItem.onHoverChange(widget, true)
  assert(seen == expected, tostring(seen))
end
check("25x potion", "Duration", "25x potion")
check("25x potion", nil, "25x potion")
check(nil, "Duration", "Duration")
check(nil, nil, nil)
check("", "Duration", "")
return true
)lua";
    g_lua.loadFunction(setup + module + scenario, "@stash-tooltip-contract");
    ASSERT_EQ(1, g_lua.safeCall());
    EXPECT_TRUE(g_lua.popBoolean());
}

TEST_F(RuntimeEventTest, LuaHotkeysSelectExplicitSubtypeInventoryItems)
{
    ASSERT_TRUE(g_resources.addSearchPath(std::string(CLIENTZIN_SOURCE_DIR)));
    const auto module = g_resources.readFileContents("/modules/client_options/custom_hotkey_manager.lua");
    const std::string setup = R"lua(
CHAT_MODE = {ON=1, OFF=2}
HOTKEY_ACTION = {USE_YOURSELF=1, USE_CROSSHAIR=2, USE_TARGET=3, EQUIP=4, USE=5, TEXT=6, TEXT_AUTO=7, SPELL=8}
trace = {}
g_clock = {millis=function() return 1000 end}
modules = {game_interface={startUseWith=function(item)
  table.insert(trace, "crosshair:" .. tostring(item.subType))
end}}
g_game = {
 getLocalPlayer=function() return {} end,
 findPlayerItem=function(id, subtype, tier)
   table.insert(trace, "find:" .. tostring(subtype))
   return found and {subType=subtype} or nil
 end,
 useInventoryItemWith=function() table.insert(trace, "inventoryWith") end,
 useWith=function(item) table.insert(trace, "useWith:" .. tostring(item.subType)) end,
 useInventoryItem=function() table.insert(trace, "inventory") end,
 use=function(item) table.insert(trace, "use:" .. tostring(item.subType)) end
}
Item = {create=function() return {
 setSubType=function(self, value) self.subType=value end,
 setTier=function() end
} end}
)lua";
    const std::string scenario = R"lua(
local function check(action, subtype, available, expected)
  trace = {}; found = available
  CustomHotkeyManager.hotkeys[1].test = {[1]={action=action, data={itemId=200, subType=subtype}}}
  CustomHotkeyManager.hotkeyCallback(1, 1, "test", true)
  assert(table.concat(trace, ",") == expected, table.concat(trace, ","))
end
check(1, nil, true, "inventoryWith")
check(1, 0, true, "find:0,useWith:0")
check(1, 7, false, "find:7")
check(2, 0, true, "find:0,crosshair:0")
check(2, 7, false, "find:7,crosshair:7")
check(5, nil, false, "inventory")
check(5, 0, true, "find:0,use:0")
check(5, 7, false, "find:7")
return true
)lua";
    g_lua.loadFunction(setup + module + scenario, "@hotkey-subtype-contract");
    ASSERT_EQ(1, g_lua.safeCall());
    EXPECT_TRUE(g_lua.popBoolean());
}

TEST_F(RuntimeEventTest, LuaTargetingKeepsReplacementCreatureAfterStaleDisappear)
{
    ASSERT_TRUE(g_resources.addSearchPath(std::string(CLIENTZIN_SOURCE_DIR)));
    const auto module = g_resources.readFileContents("/modules/game_helper/helper_target.lua");
    const std::string scenario = R"lua(
local function creature(name)
 return {getId=function() return 50 end, getName=function() return name end,
 isPlayer=function() return false end, isMonster=function() return true end,
 getHealthPercent=function() return 100 end}
end
local first = creature("First")
local replacement = creature("Replacement")
HelperTarget.onCreatureAppear(first)
HelperTarget.onCreatureAppear(replacement)
HelperTarget.onCreatureDisappear(first)
assert(HelperTarget.getSpectators()[50] == replacement)
HelperTarget.onCreatureDisappear(replacement)
assert(HelperTarget.getSpectators()[50] == nil)
return true
)lua";
    g_lua.loadFunction(module + scenario, "@targeting-creature-identity-contract");
    ASSERT_EQ(1, g_lua.safeCall());
    EXPECT_TRUE(g_lua.popBoolean());
}

TEST_F(RuntimeEventTest, LuaWheelModCatalogSearchesDescriptionsWithLiteralSubstrings)
{
    ASSERT_TRUE(g_resources.addSearchPath(std::string(CLIENTZIN_SOURCE_DIR)));
    const auto module = g_resources.readFileContents("/modules/game_wheel/classes/mod_catalog.lua");
    const auto scenario = g_resources.readFileContents("/tests/fixtures/lua/wheel_mod_catalog_contract.lua");
    g_lua.loadFunction(module + "\n" + scenario, "@wheel-mod-catalog-search-contract");
    ASSERT_EQ(1, g_lua.safeCall());
    EXPECT_TRUE(g_lua.popBoolean());
}

TEST_F(RuntimeEventTest, LuaKeybindKeepsItemSubtypesOutOfUseWithCallbacks)
{
    ASSERT_TRUE(g_resources.addSearchPath(std::string(CLIENTZIN_SOURCE_DIR)));
    const auto module = g_resources.readFileContents("/modules/corelib/keybind.lua");
    const auto scenario = g_resources.readFileContents("/tests/fixtures/lua/keybind_item_subtype_contract.lua");
    g_lua.loadFunction(module + "\n" + scenario, "@keybind-item-subtype-contract");
    ASSERT_EQ(1, g_lua.safeCall());
    EXPECT_TRUE(g_lua.popBoolean());
}

TEST_F(RuntimeEventTest, FocusedWidgetFollowsTheKeyboardReceiverAndFocusChain)
{
    DispatcherSession dispatcher;
    ForegroundPool pool;
    g_lua.registerClass<UIWidget>();
    UIManager manager;
    EXPECT_EQ(nullptr, manager.getFocusedWidget());

    auto root = std::make_shared<UIWidget>();
    auto panel = std::make_shared<UIWidget>();
    auto edit = std::make_shared<UIWidget>();
    root->addChild(panel);
    panel->addChild(edit);
    root->focusChild(panel, Fw::OtherFocusReason);
    panel->focusChild(edit, Fw::OtherFocusReason);
    manager.setKeyboardReceiver(root);
    EXPECT_EQ(edit, manager.getFocusedWidget());

    edit->setVisible(false);
    EXPECT_EQ(panel, manager.getFocusedWidget());
    edit->setVisible(true);
    panel->focusChild(edit, Fw::OtherFocusReason);
    edit->setEnabled(false);
    EXPECT_EQ(panel, manager.getFocusedWidget());

    auto modal = std::make_shared<UIWidget>();
    auto modalEdit = std::make_shared<UIWidget>();
    modal->addChild(modalEdit);
    modal->focusChild(modalEdit, Fw::OtherFocusReason);
    manager.setKeyboardReceiver(modal);
    EXPECT_EQ(modalEdit, manager.getFocusedWidget());
    modal->destroy();
    EXPECT_EQ(nullptr, manager.getFocusedWidget());
    root->destroy();
}

TEST_F(RuntimeEventTest, LuaModalTabNavigationRespectsNativeAndLegacyTextEdits)
{
    ASSERT_TRUE(g_resources.addSearchPath(std::string(CLIENTZIN_SOURCE_DIR)));
    const auto module = g_resources.readFileContents("/modules/corelib/ui/uimodalmanager.lua");
    const auto scenario = g_resources.readFileContents("/tests/fixtures/lua/modal_text_focus_contract.lua");
    g_lua.loadFunction("connect = function() end\n" + module + "\n" + scenario, "@modal-text-focus-contract");
    ASSERT_EQ(1, g_lua.safeCall());
    EXPECT_TRUE(g_lua.popBoolean());
}

TEST_F(RuntimeEventTest, LuaCreatureButtonPreviewsUseAvailableNativeApis)
{
    ASSERT_TRUE(g_resources.addSearchPath(std::string(CLIENTZIN_SOURCE_DIR)));
    const auto module = g_resources.readFileContents("/modules/gamelib/ui/uicreaturebutton.lua");
    const auto scenario = g_resources.readFileContents("/tests/fixtures/lua/creature_button_preview_api_contract.lua");
    g_lua.loadFunction("UIWidget = {}; function extends() return {} end\n" + module + "\n" + scenario,
                       "@creature-button-preview-api-contract");
    ASSERT_EQ(1, g_lua.safeCall());
    EXPECT_TRUE(g_lua.popBoolean());
}

TEST_F(RuntimeEventTest, LuaWheelInvestmentRespectsAvailablePointBudget)
{
    ASSERT_TRUE(g_resources.addSearchPath(std::string(CLIENTZIN_SOURCE_DIR)));
    const auto module = g_resources.readFileContents("/modules/game_wheel/classes/wheel_input.lua");
    const auto scenario = g_resources.readFileContents("/tests/fixtures/lua/wheel_point_budget_contract.lua");
    g_lua.loadFunction("WheelOfDestiny = {}\n" + module + "\n" + scenario, "@wheel-point-budget-contract");
    ASSERT_EQ(1, g_lua.safeCall());
    EXPECT_TRUE(g_lua.popBoolean());
}
