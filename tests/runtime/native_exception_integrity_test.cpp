#include <gtest/gtest.h>
#include <stdexcept>

TEST(StandaloneNativeExceptionIntegrity, StandardExceptionRetainsItsMessage)
{
    std::runtime_error error("standalone exception integrity sentinel");
    EXPECT_STREQ("standalone exception integrity sentinel", error.what());
    try {
        throw std::runtime_error("standalone exception integrity sentinel");
    } catch (const std::exception& caught) {
        EXPECT_STREQ("standalone exception integrity sentinel", caught.what());
    }
}
