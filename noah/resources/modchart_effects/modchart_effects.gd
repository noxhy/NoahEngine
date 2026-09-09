@icon("res://addons/at-icons/node/stars.svg")

extends Resource
class_name ModchartEffects

## Main handeler for a list of [ModchartEffect]

## Dictionary of [ModchartEffect]s, key is the name of the effect.
var effects: Dictionary[StringName, ModchartEffect] = {}

func add_effect(effect: ModchartEffect) -> void:
	effects[effect.name] = effect

func get_effect(name: StringName) -> ModchartEffect:
	return effects.get(name)

func back() -> ModchartEffect:
	if effects.is_empty():
		return null
	
	return get_effect(effects.keys().back())
