#ifndef COLOR_EXTRACTOR_H
#define COLOR_EXTRACTOR_H

#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif

    struct Color
    {
        uint8_t r, g, b;
    };

    void extract_dominant_colors(const uint8_t *image_data, int width, int height, struct Color *dominant_colors, int num_colors);

#ifdef __cplusplus
}
#endif

#endif