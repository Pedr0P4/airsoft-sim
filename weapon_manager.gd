extends Node

@onready var weapons_node = $"../Head/Vertical/Camera3D/SwayPivot/AimPivot"
@onready var hopup_label = $"../CanvasLayer/HUD/HopupLabel"
@onready var ammo_label = $"../CanvasLayer/HUD/AmmoLabel"
@onready var firemode_label = $"../CanvasLayer/HUD/FiremodeLabel"

var inventory: Array[Weapon] = [null, null, null, null]
var active_weapon: Weapon = null

# Map the resource paths to indices for easy equipping
var default_weapons = {
	0: preload("res://resources/rifle.tres"),
	1: preload("res://resources/shotgun.tres"),
	2: preload("res://resources/sniper.tres"),
	3: preload("res://resources/pistol.tres")
}

func _ready() -> void:
	for index in default_weapons:
		_equip_weapon_from_resource(index, default_weapons[index])
	
	switch_weapon(0)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_1:
			switch_weapon(0)
		elif event.physical_keycode == KEY_2:
			switch_weapon(1)
		elif event.physical_keycode == KEY_3:
			switch_weapon(2)
		elif event.physical_keycode == KEY_4:
			switch_weapon(3)

func switch_weapon(index: int) -> void:
	if index < 0 or index >= inventory.size(): return
	if inventory[index] == null: return
	
	if active_weapon:
		active_weapon.hide()
		active_weapon.set_process(false)
		active_weapon.set_process_input(false)
		
	active_weapon = inventory[index]
	active_weapon.show()
	active_weapon.set_process(true)
	active_weapon.set_process_input(true)
	
	if active_weapon.has_method("update_ammo_label"):
		active_weapon.update_ammo_label()
	if active_weapon.has_method("update_hopup_label"):
		active_weapon.update_hopup_label()
	if active_weapon.has_method("update_firemode_label"):
		active_weapon.update_firemode_label()

func _equip_weapon_from_resource(index: int, weapon_data: WeaponResource) -> void:
	if not weapon_data: return
	
	var weapon: Weapon = weapon_data.weapon_scene.instantiate()
	if ammo_label:
		weapon.ammo_label = ammo_label
	if hopup_label:
		weapon.hopup_label = hopup_label
	if firemode_label:
		weapon.firemode_label = firemode_label
		
	weapons_node.add_child(weapon)
	weapon.hide()
	weapon.set_process(false)
	weapon.set_process_input(false)
	inventory[index] = weapon

func coletar_arma(weapon_data: WeaponResource):
	# Kept for compatibility with player.gd start_weapon parameter
	# But since we preload all 4, we could just switch to it if it matches
	pass
