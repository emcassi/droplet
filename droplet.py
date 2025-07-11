from Xlib import display, X
import signal, time, sys
from typing import NamedTuple


class RGB(NamedTuple):
    r: int
    g: int
    b: int


interval = float(sys.argv[1]) if len(sys.argv) > 1 else 0.3

d = display.Display()
root = d.screen().root
running = True

GET_IMAGE_FORMAT = X.ZPixmap  # 2 → ZPixmap format (raw pixel data)
PLANE_MASK_ALL = 0xFFFFFFFF  # Read all color planes (RGB, alpha if present)


def stop_gracefully(*_):
    global running
    running = False


signal.signal(signal.SIGINT, stop_gracefully)
signal.signal(signal.SIGTERM, stop_gracefully)


def get_pixel_color() -> RGB:
    data = root.query_pointer()._data
    x, y = data["root_x"], data["root_y"]
    try:
        pixel = root.get_image(x, y, 1, 1, GET_IMAGE_FORMAT, PLANE_MASK_ALL).data
    except:
        return RGB(0, 0, 0)
    r, g, b = pixel[2], pixel[1], pixel[0]
    return RGB(r, g, b)


def calculate_luminance(rgb: RGB) -> float:
    r_norm = rgb.r / 255.0
    g_norm = rgb.g / 255.0
    b_norm = rgb.b / 255.0
    return 0.2126 * r_norm + 0.7152 * g_norm + 0.0722 * b_norm


def get_contrast_color(rgb: RGB) -> RGB:
    luminance = calculate_luminance(rgb)

    if luminance > 0.5:
        return RGB(0, 0, 0)
    else:
        return RGB(255, 255, 255)


def get_hex_code(rgb: RGB) -> str:
    return f"#{rgb.r:02x}{rgb.g:02x}{rgb.b:02x}"


def main():
    while running:
        active_color = get_pixel_color()
        contrast_color = get_contrast_color(active_color)

        active_hex = get_hex_code(active_color)
        contrast_hex = get_hex_code(contrast_color)

        print(f"{active_hex} {contrast_hex}")
        time.sleep(interval)


if __name__ == "__main__":
    main()
