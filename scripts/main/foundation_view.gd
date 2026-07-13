extends Node2D

const NIGHT_INK := Color("0b0c14")
const COLD_WALL := Color("242936")
const MIST_TEAL := Color("40525a")
const OLD_PAPER := Color("c8bfae")
const SICK_LIGHT := Color("c29a5b")
const EMBER_RED := Color("8d3035")


func _ready() -> void:
	print("HELL_CYCLE_BOOT_OK")
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), NIGHT_INK)
	draw_rect(Rect2(16, 16, 608, 328), COLD_WALL, false, 1.0)
	draw_line(Vector2(240, 180), Vector2(400, 180), MIST_TEAL, 1.0)
	draw_line(Vector2(320, 100), Vector2(320, 260), MIST_TEAL, 1.0)
	draw_circle(Vector2(320, 180), 5.0, SICK_LIGHT)
	draw_rect(Rect2(308, 168, 24, 24), OLD_PAPER, false, 1.0)
	draw_line(Vector2(292, 212), Vector2(348, 212), EMBER_RED, 1.0)
