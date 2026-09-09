extends Node

@onready var weapons_node = $"../Head/Vertical/Camera3D/SwayPivot/AimPivot";
@onready var hopup_label = $"../CanvasLayer/HUD/HopupLabel";
@onready var ammo_label = $"../CanvasLayer/HUD/AmmoLabel";

var primary_weapon: Weapon;
var secondary_weapon: Weapon;
var active_weapon: Weapon;

func _ready() -> void:
	if primary_weapon:
		primary_weapon.hide();
		active_weapon = primary_weapon;
	if secondary_weapon:
		secondary_weapon.hide();
	if active_weapon:
		active_weapon.show();

func coletar_arma(weapon_data: WeaponResource):
	var category = weapon_data.category;
	if category == WeaponResource.Category.PRIMARY and primary_weapon:
		pass;
	if category == WeaponResource.Category.SECONDARY and secondary_weapon:
		pass;
		
	var weapon: Weapon = weapon_data.weapon_scene.instantiate();
	if ammo_label:
		weapon.ammo_label = ammo_label;
	if hopup_label:
		weapon.hopup_label = hopup_label;
	weapons_node.add_child(weapon);
	if category == WeaponResource.Category.PRIMARY:
		primary_weapon = weapon;
		active_weapon = primary_weapon;
	if category == WeaponResource.Category.SECONDARY:
		secondary_weapon = weapon;
		active_weapon = secondary_weapon;
	sacar_arma();

func sacar_arma():
	if primary_weapon:
		primary_weapon.hide();
	if secondary_weapon:
		secondary_weapon.hide();
	if active_weapon:
		active_weapon.show();
