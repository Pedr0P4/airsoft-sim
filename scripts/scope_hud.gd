extends Control

func _ready():
	set_anchors_preset(Control.PRESET_FULL_RECT)

func _draw():
	var center = size / 2.0
	var radius = min(size.x, size.y) * 0.45
	var thickness = max(size.x, size.y)
	
	# Draw inverted circle mask using a very thick arc (solid black outside)
	draw_arc(center, radius + thickness / 2.0 - 2.0, 0, TAU, 128, Color.BLACK, thickness)
	
	# Draw soft vignette (shadow inside the scope edges)
	var shadow_steps = 20
	for i in range(shadow_steps):
		var alpha = lerp(0.8, 0.0, float(i) / shadow_steps)
		var r = radius - (float(i) * 2.0)
		draw_arc(center, r, 0, TAU, 64, Color(0, 0, 0, alpha), 3.0)
	
	# Crosshair lines
	draw_line(Vector2(center.x, 0), Vector2(center.x, size.y), Color(0, 0, 0, 0.9), 2.0)
	draw_line(Vector2(0, center.y), Vector2(size.x, center.y), Color(0, 0, 0, 0.9), 2.0)
	
	# Draw a smaller circle in the middle for precision
	draw_arc(center, 5.0, 0, TAU, 16, Color(1, 0, 0, 0.8), 2.0)
	
	# Draw some mil-dots
	for i in range(1, 6):
		var spacing = radius / 5.0
		var offset = i * spacing
		draw_line(Vector2(center.x - 10, center.y + offset), Vector2(center.x + 10, center.y + offset), Color.BLACK, 2.0)
		draw_line(Vector2(center.x - 10, center.y - offset), Vector2(center.x + 10, center.y - offset), Color.BLACK, 2.0)
		draw_line(Vector2(center.x + offset, center.y - 10), Vector2(center.x + offset, center.y + 10), Color.BLACK, 2.0)
		draw_line(Vector2(center.x - offset, center.y - 10), Vector2(center.x - offset, center.y + 10), Color.BLACK, 2.0)

func _process(_delta):
	# Garantir que o HUD sempre tenha o tamanho da tela inteira
	if get_viewport():
		size = get_viewport().get_visible_rect().size
	queue_redraw()
