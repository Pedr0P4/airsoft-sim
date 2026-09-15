class_name WeaponResource
extends Resource

enum Category {
	PRIMARY,
	SECONDARY
};

@export var name: String = "Arma Desconhecida";
@export var category: Category;
@export var weapon_scene: PackedScene;
@export var weapon_type: Enums.WeaponType = Enums.WeaponType.RIFLE

