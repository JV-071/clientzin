#include <gtest/gtest.h>
#include "client/luavaluecasts_client.h"
#include "framework/luaengine/luainterface.h"

class RuntimeEventTest : public ::testing::Test {
protected:
    void SetUp() override { g_lua.init(); }
    void TearDown() override { g_lua.clearStack(); g_lua.terminate(); }
};

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
