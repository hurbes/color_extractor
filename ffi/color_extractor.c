#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <float.h>

// Structure to represent an RGB color with red, green, and blue components.
struct RGB {
    uint8_t r, g, b;
};

// Structure to represent a color. It's similar to RGB and could be used for flexibility.
struct Color {
    uint8_t r, g, b;
};

/**
 * @brief Compare two RGB colors for sorting.
 * 
 * This function compares two RGB colors first by the red component, then green,
 * and finally blue. It's used for sorting an array of RGB colors.
 * 
 * @param a Pointer to the first RGB color.
 * @param b Pointer to the second RGB color.
 * @return An integer less than, equal to, or greater than zero if the first color is
 *         considered to be respectively less than, equal to, or greater than the second.
 */
int compareRGB(const void* a, const void* b) {
    const struct RGB* rgbA = (const struct RGB*)a;
    const struct RGB* rgbB = (const struct RGB*)b;
    
    if (rgbA->r != rgbB->r) return rgbA->r - rgbB->r;
    if (rgbA->g != rgbB->g) return rgbA->g - rgbB->g;
    return rgbA->b - rgbB->b;
}

/**
 * @brief Calculate the Euclidean distance between two RGB colors.
 * 
 * This function computes the distance between two RGB colors in 3D space
 * by treating the color components as coordinates.
 * 
 * @param c1 Pointer to the first RGB color.
 * @param c2 Pointer to the second RGB color.
 * @return The Euclidean distance between the two colors.
 */
double colorDistance(const struct RGB* c1, const struct RGB* c2) {
    long r = (long)c1->r - c2->r;
    long g = (long)c1->g - c2->g;
    long b = (long)c1->b - c2->b;
    return sqrt(r * r + g * g + b * b);
}

/**
 * @brief Quantize a color to reduce its complexity.
 * 
 * This function reduces the number of colors by quantizing each RGB component to
 * a specific level, effectively mapping the color to a smaller palette.
 * 
 * @param color Pointer to the original RGB color.
 * @param result Pointer to the RGB color where the quantized color will be stored.
 * @param levels The number of quantization levels for each color component.
 */
void quantizeColor(const struct RGB* color, struct RGB* result, int levels) {
    result->r = (color->r * levels / 256) * (256 / levels);
    result->g = (color->g * levels / 256) * (256 / levels);
    result->b = (color->b * levels / 256) * (256 / levels);
}

/**
 * @brief Perform k-means clustering on RGB pixels to find the dominant colors.
 * 
 * This function applies the k-means clustering algorithm to group similar colors
 * together and find `k` dominant colors in an image. The centroids represent the
 * most dominant colors.
 * 
 * @param pixels Array of RGB pixels.
 * @param pixelCount The number of pixels in the array.
 * @param centroids Array to store the resulting dominant colors (centroids).
 * @param k The number of dominant colors to find.
 * @param maxIterations Maximum number of iterations for the k-means algorithm.
 */
void kMeansClustering(struct RGB* pixels, int pixelCount, struct RGB* centroids, int k, int maxIterations) {
    // Sort pixels for consistent initialization of centroids.
    qsort(pixels, pixelCount, sizeof(struct RGB), compareRGB);
    
    // Initialize centroids evenly spaced among the sorted pixels.
    for (int i = 0; i < k; ++i) {
        centroids[i] = pixels[i * pixelCount / k];
    }

    // Allocate memory for clusters and cluster sizes.
    struct RGB** clusters = (struct RGB**)malloc(k * sizeof(struct RGB*));
    int* clusterSizes = (int*)calloc(k, sizeof(int));

    // Iterate through the k-means process.
    for (int iteration = 0; iteration < maxIterations; ++iteration) {
        // Clear previous clusters.
        for (int i = 0; i < k; ++i) {
            free(clusters[i]);
            clusters[i] = NULL;
            clusterSizes[i] = 0;
        }

        // Assign each pixel to the closest centroid.
        for (int i = 0; i < pixelCount; ++i) {
            double minDistance = DBL_MAX;
            int closestCentroid = 0;
            for (int j = 0; j < k; ++j) {
                double distance = colorDistance(&pixels[i], &centroids[j]);
                if (distance < minDistance || (distance == minDistance && j < closestCentroid)) {
                    minDistance = distance;
                    closestCentroid = j;
                }
            }
            clusterSizes[closestCentroid]++;
            clusters[closestCentroid] = realloc(clusters[closestCentroid], clusterSizes[closestCentroid] * sizeof(struct RGB));
            clusters[closestCentroid][clusterSizes[closestCentroid] - 1] = pixels[i];
        }

        // Recalculate centroids and check if they have changed.
        int changed = 0;
        for (int i = 0; i < k; ++i) {
            if (clusterSizes[i] > 0) {
                long sumR = 0, sumG = 0, sumB = 0;
                for (int j = 0; j < clusterSizes[i]; ++j) {
                    sumR += clusters[i][j].r;
                    sumG += clusters[i][j].g;
                    sumB += clusters[i][j].b;
                }
                struct RGB newCentroid = {
                    sumR / clusterSizes[i],
                    sumG / clusterSizes[i],
                    sumB / clusterSizes[i]
                };
                if (newCentroid.r != centroids[i].r || newCentroid.g != centroids[i].g || newCentroid.b != centroids[i].b) {
                    centroids[i] = newCentroid;
                    changed = 1;
                }
            }
        }

        // Stop early if centroids did not change.
        if (!changed) break;
    }

    // Sort the final centroids for consistency.
    qsort(centroids, k, sizeof(struct RGB), compareRGB);

    // Clean up memory.
    for (int i = 0; i < k; ++i) {
        free(clusters[i]);
    }
    free(clusters);
    free(clusterSizes);
}

/**
 * @brief Extract the dominant colors from an image.
 * 
 * This function processes the given image data to find the dominant colors using 
 * k-means clustering. The image is downsampled to optimize performance for large images.
 * 
 * @param image_data Pointer to the raw RGB image data.
 * @param width The width of the image.
 * @param height The height of the image.
 * @param dominant_colors Array to store the dominant colors.
 * @param num_colors The number of dominant colors to extract.
 */
void extract_dominant_colors(const uint8_t *image_data, int width, int height, struct Color *dominant_colors, int num_colors) {
    // Input validation.
    if (!image_data || width <= 0 || height <= 0 || !dominant_colors || num_colors <= 0) {
        memset(dominant_colors, 0, num_colors * sizeof(struct Color));
        return;
    }

    int total_pixels = width * height;
    // Downsample the image if there are more than 10,000 pixels.
    int step = total_pixels / 10000 > 0 ? total_pixels / 10000 : 1;
    int sample_size = total_pixels / step;

    // Allocate memory for the pixels to be sampled.
    struct RGB* pixels = (struct RGB*)malloc(sample_size * sizeof(struct RGB));
    int pixel_count = 0;

    // Sample pixels from the image, quantizing their colors.
    for (int i = 0; i < total_pixels && pixel_count < sample_size; i += step) {
        int index = i * 3;
        if (index + 2 >= total_pixels * 3) break;

        struct RGB color = {image_data[index], image_data[index + 1], image_data[index + 2]};
        struct RGB quantized;
        quantizeColor(&color, &quantized, 5);
        pixels[pixel_count++] = quantized;
    }

    // Perform k-means clustering to find dominant colors.
    struct RGB* dominant = (struct RGB*)malloc(num_colors * sizeof(struct RGB));
    kMeansClustering(pixels, pixel_count, dominant, num_colors, 10);

    // Copy the result to the output array.
    for (int i = 0; i < num_colors; ++i) {
        dominant_colors[i].r = dominant[i].r;
        dominant_colors[i].g = dominant[i].g;
        dominant_colors[i].b = dominant[i].b;
    }

    // Clean up memory.
    free(pixels);
    free(dominant);
}
