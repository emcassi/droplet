from Xlib import display, X
import time
import sys

interval = float(sys.argv[1]) if len(sys.argv) > 1 else 0.3

d = display.Display()
root = d.screen().root

GET_IMAGE_FORMAT = X.ZPixmap  # 2 → ZPixmap format (raw pixel data)
PLANE_MASK_ALL = 0xFFFFFFFF  # Read all color planes (RGB, alpha if present)


def get_pixel_color():
    data = root.query_pointer()._data
    x, y = data["root_x"], data["root_y"]
    pixel = root.get_image(x, y, 1, 1, GET_IMAGE_FORMAT, PLANE_MASK_ALL).data
    r, g, b = pixel[2], pixel[1], pixel[0]
    return f"#{r:02x}{g:02x}{b:02x}"


while True:
    print(get_pixel_color(), flush=True)
    time.sleep(interval)
