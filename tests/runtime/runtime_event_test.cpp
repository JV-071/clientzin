#include <gtest/gtest.h>
#include "client/luavaluecasts_client.h"
#include "framework/luaengine/luainterface.h"

class RuntimeEventTest : public ::testing::Test {
protected:
    void SetUp() override { g_lua.init(); }
    void TearDown() override { g_lua.clearStack(); g_lua.terminate(); }
};

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
