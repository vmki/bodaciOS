#include <stdarg.h>
#include <stddef.h>
#include <string.h>
#include <vga.h>
#include <limits.h>
#include <stdbool.h>
#include <fmt.h>

size_t vga_row;
size_t vga_col;

void vga_initialize() {
    vga_row = 0;
    vga_col = 0;

    // Clear out the buffer
    for (size_t y = 0; y < VGA_HEIGHT; y++) {
        for (size_t x = 0; x < VGA_WIDTH; x++) {
            size_t idx = y * VGA_WIDTH + x;

            vga_color_t black = vga_entry_color(VGA_COLOR_BLACK, VGA_COLOR_BLACK);
            VGA_BUFFER[idx] = vga_entry(' ', black);
        }
    }
}

void vga_print_char(vga_entry_t c) {
    if (vga_col + 1 > VGA_WIDTH) {
        vga_col = 0;
        vga_row += 1;
    }

    size_t index = (VGA_WIDTH * vga_row) + vga_col;

    VGA_BUFFER[index] = c;

    vga_col += 1;
}

void vga_print(const char* string) {
    for (size_t i = 0; i < strlen(string); i++) {
        uint8_t c = string[i];

        vga_entry_t entry = vga_entry(c, vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK));

        vga_print_char(entry);
    }
}

void vga_printf(const char* restrict format, ...) {
    va_list args;
    va_start(args, format);

    vga_print(fmt(format, args));
}
