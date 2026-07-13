#!/usr/bin/env python3
"""Convert the generated 4x4 Qin Zheng sheet into Godot's 32x48 frame grid."""

from pathlib import Path
from collections import deque
from PIL import Image


SOURCE = Path("assets/game/generated_v3/characters/qin_zheng_sheet_alpha.png")
OUTPUT = Path("assets/game/generated_v3/characters/qin_zheng_spritesheet.png")
COLS = 4
ROWS = 4
FRAME_SIZE = (32, 48)
MAX_SPRITE_SIZE = (28, 44)
ALPHA_THRESHOLD = 8


def cell_edge(index: int, count: int, size: int) -> int:
    return round(index * size / count)


def keep_largest_component(cell: Image.Image) -> Image.Image:
    width, height = cell.size
    alpha = cell.getchannel("A")
    solid = bytearray(1 if value > ALPHA_THRESHOLD else 0 for value in alpha.get_flattened_data())
    visited = bytearray(width * height)
    largest: list[int] = []

    for start in range(width * height):
        if not solid[start] or visited[start]:
            continue
        component: list[int] = []
        queue = deque([start])
        visited[start] = 1
        while queue:
            index = queue.popleft()
            component.append(index)
            x, y = index % width, index // width
            for neighbor in (index - 1, index + 1, index - width, index + width):
                if neighbor < 0 or neighbor >= width * height or visited[neighbor] or not solid[neighbor]:
                    continue
                neighbor_x, neighbor_y = neighbor % width, neighbor // width
                if abs(neighbor_x - x) + abs(neighbor_y - y) != 1:
                    continue
                visited[neighbor] = 1
                queue.append(neighbor)
        if len(component) > len(largest):
            largest = component

    if not largest:
        raise SystemExit("character cell has no connected alpha component")
    keep = bytearray(width * height)
    for index in largest:
        keep[index] = 1
    pixels = list(cell.get_flattened_data())
    for index, pixel in enumerate(pixels):
        if not keep[index]:
            pixels[index] = (pixel[0], pixel[1], pixel[2], 0)
    cleaned = Image.new("RGBA", cell.size)
    cleaned.putdata(pixels)
    return cleaned


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    if any(source.getpixel(point)[3] != 0 for point in [(0, 0), (source.width - 1, 0), (0, source.height - 1), (source.width - 1, source.height - 1)]):
        raise SystemExit("source corners must be transparent")

    crops: list[Image.Image] = []
    bounds: list[tuple[int, int]] = []
    for row in range(ROWS):
        for col in range(COLS):
            box = (
                cell_edge(col, COLS, source.width),
                cell_edge(row, ROWS, source.height),
                cell_edge(col + 1, COLS, source.width),
                cell_edge(row + 1, ROWS, source.height),
            )
            cell = keep_largest_component(source.crop(box))
            alpha = cell.getchannel("A").point(lambda value: 255 if value > ALPHA_THRESHOLD else 0)
            bbox = alpha.getbbox()
            if bbox is None:
                raise SystemExit(f"empty character cell at row={row} col={col}")
            crop = cell.crop(bbox)
            crops.append(crop)
            bounds.append(crop.size)

    max_width = max(width for width, _ in bounds)
    max_height = max(height for _, height in bounds)
    scale = min(MAX_SPRITE_SIZE[0] / max_width, MAX_SPRITE_SIZE[1] / max_height)
    output = Image.new("RGBA", (FRAME_SIZE[0] * COLS, FRAME_SIZE[1] * ROWS), (0, 0, 0, 0))

    for index, crop in enumerate(crops):
        width = max(1, round(crop.width * scale))
        height = max(1, round(crop.height * scale))
        resized = crop.resize((width, height), Image.Resampling.LANCZOS)
        row, col = divmod(index, COLS)
        x = col * FRAME_SIZE[0] + (FRAME_SIZE[0] - width) // 2
        y = row * FRAME_SIZE[1] + FRAME_SIZE[1] - height - 2
        output.alpha_composite(resized, (x, y))

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    output.save(OUTPUT, optimize=True)
    print(f"Wrote {OUTPUT} ({output.width}x{output.height}); source bounds={bounds}; scale={scale:.4f}")


if __name__ == "__main__":
    main()
