#include <gtest/gtest.h>
#include "framework/graphics/bitmapfont.h"
#include "framework/graphics/image.h"
#include <fstream>
#include <iterator>

class BitmapFontTest : public ::testing::Test {
protected:
    BitmapFont font{"atlas-regression"};
    void name(const std::string& value) { font.m_name = value; }

    void scan(const ImagePtr& image, const Size& cell, int height, int first = 32)
    {
        font.m_firstGlyph = first;
        font.m_glyphHeight = height;
        font.calculateGlyphsWidthsAutomatically(image, cell);
    }
};

TEST_F(BitmapFontTest, SuppliedAtlasesUseElevenPixelRowsAndPreserveLineHeight)
{
    for (const auto* name : {"verdana-8px-outline.png", "verdana-8px-rounded.png"}) {
        SCOPED_TRACE(name);
        std::ifstream file(std::string(CLIENTZIN_SOURCE_DIR) + "/assets/fonts/" + name, std::ios::binary);
        ASSERT_TRUE(file.good());
        const std::string bytes{std::istreambuf_iterator<char>(file), std::istreambuf_iterator<char>()};
        const auto image = Image::loadPNG(bytes.data(), bytes.size());
        ASSERT_NE(nullptr, image);
        ASSERT_EQ(Size(192, 154), image->getSize());
        this->name(std::string(name) == "verdana-8px-outline.png" ? "Verdana-8px-outline" : "verdana-8px-rounded");
        scan(image, Size(12, 12), 12);
        EXPECT_EQ(12, font.getGlyphHeight());
        for (int glyph = 32; glyph < 256; ++glyph)
            EXPECT_EQ(11, font.getGlyphsSize()[glyph].height());
        EXPECT_GT(font.getGlyphsSize()[255].width(), 0);
    }
}

TEST_F(BitmapFontTest, RespectsPixelChannelsAndAlpha)
{
    for (int channels = 1; channels <= 4; ++channels) {
        SCOPED_TRACE(channels);
        auto image = std::make_shared<Image>(Size(3, 1), channels);
        image->getPixels()[channels - 1] = 255;
        scan(image, Size(3, 1), 1, 255);
        EXPECT_EQ((channels == 2 || channels == 4) ? 1 : 3,
                  font.getGlyphsSize()[255].width());
    }
}

TEST_F(BitmapFontTest, OtherTruncatedAtlasesRemainBoundsChecked)
{
    auto image = std::make_shared<Image>(Size(192, 154));
    scan(image, Size(12, 12), 12);
    EXPECT_EQ(12, font.getGlyphsSize()[223].height());
    EXPECT_EQ(10, font.getGlyphsSize()[239].height());
    EXPECT_EQ(Size(0, 0), font.getGlyphsSize()[255]);
}

TEST_F(BitmapFontTest, RejectsInvalidGeometryBeforeIndexing)
{
    auto image = std::make_shared<Image>(Size(12, 12));
    EXPECT_ANY_THROW(scan(image, Size(0, 12), 12));
    EXPECT_ANY_THROW(scan(image, Size(13, 12), 12));
    EXPECT_ANY_THROW(scan(image, Size(12, 12), 12, -1));
    EXPECT_ANY_THROW(scan(image, Size(12, 12), 12, 256));
}
