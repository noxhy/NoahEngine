extends Node
class_name NoahTools

static var _tween_options: Dictionary[StringName, Array] = {
	&"backin": [Tween.TRANS_BACK, Tween.EASE_IN],
	&"backinout": [Tween.TRANS_BACK, Tween.EASE_IN_OUT],
	&"backout": [Tween.TRANS_BACK, Tween.EASE_OUT],
	&"backoutin": [Tween.TRANS_BACK, Tween.EASE_OUT_IN],
	&"bouncein": [Tween.TRANS_BOUNCE, Tween.EASE_IN],
	&"bounceinout": [Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT],
	&"bounceout": [Tween.TRANS_BOUNCE, Tween.EASE_OUT],
	&"bounceoutin": [Tween.TRANS_BOUNCE, Tween.EASE_OUT_IN],
	&"circin": [Tween.TRANS_CIRC, Tween.EASE_IN],
	&"circinout": [Tween.TRANS_CIRC, Tween.EASE_IN_OUT],
	&"circout": [Tween.TRANS_CIRC, Tween.EASE_OUT],
	&"circoutin": [Tween.TRANS_CIRC, Tween.EASE_OUT_IN],
	&"cubein": [Tween.TRANS_CUBIC, Tween.EASE_IN],
	&"cubeinout": [Tween.TRANS_CUBIC, Tween.EASE_IN_OUT],
	&"cubeout": [Tween.TRANS_CUBIC, Tween.EASE_OUT],
	&"cubeoutin": [Tween.TRANS_CUBIC, Tween.EASE_OUT_IN],
	&"elasticin": [Tween.TRANS_ELASTIC, Tween.EASE_IN],
	&"elasticinout": [Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT],
	&"elasticout": [Tween.TRANS_ELASTIC, Tween.EASE_OUT],
	&"elasticoutin": [Tween.TRANS_ELASTIC, Tween.EASE_OUT_IN],
	&"expoin": [Tween.TRANS_EXPO, Tween.EASE_IN],
	&"expoinout": [Tween.TRANS_EXPO, Tween.EASE_IN_OUT],
	&"expoout": [Tween.TRANS_EXPO, Tween.EASE_OUT],
	&"expooutin": [Tween.TRANS_EXPO, Tween.EASE_OUT_IN],
	&"quadin": [Tween.TRANS_QUAD, Tween.EASE_IN],
	&"quadinout": [Tween.TRANS_QUAD, Tween.EASE_IN_OUT],
	&"quadout": [Tween.TRANS_QUAD, Tween.EASE_OUT],
	&"quadoutin": [Tween.TRANS_QUAD, Tween.EASE_OUT_IN],
	&"quartin": [Tween.TRANS_QUART, Tween.EASE_IN],
	&"quartinout": [Tween.TRANS_QUART, Tween.EASE_IN_OUT],
	&"quartout": [Tween.TRANS_QUART, Tween.EASE_OUT],
	&"quartoutin": [Tween.TRANS_QUART, Tween.EASE_OUT_IN],
	&"quintin": [Tween.TRANS_QUINT, Tween.EASE_IN],
	&"quintinout": [Tween.TRANS_QUINT, Tween.EASE_IN_OUT],
	&"quintout": [Tween.TRANS_QUINT, Tween.EASE_OUT],
	&"quintoutin": [Tween.TRANS_QUINT, Tween.EASE_OUT_IN],
	&"sinein": [Tween.TRANS_SINE, Tween.EASE_IN],
	&"sineinout": [Tween.TRANS_SINE, Tween.EASE_IN_OUT],
	&"sineout": [Tween.TRANS_SINE, Tween.EASE_OUT],
	&"sineoutin": [Tween.TRANS_SINE, Tween.EASE_OUT_IN],
	&"classic": [Tween.TRANS_CUBIC, Tween.EASE_IN_OUT],
	&"linear": [Tween.TRANS_LINEAR, Tween.EASE_IN]
}

## Sorts an array of nodes by their [code]id[/code]. If the nodes do not contain an [code]id[/code] var, sorting will not occur.
static func sort_array_by_id(arr: Array[Node]) -> Array[Node]:
	var sorter:Callable = func(a, b):
		if 'id' in a and 'id' in b:
			if a.id < b.id:
				return true
		return false
	arr.sort_custom(sorter)
	
	return arr

## Converts a float of seconds into a time format of [code]MM:SS.mmm[/code] or [code]MM:SS[/code] if [code]show_mili[/code] is false.
static func format_time(time: float, show_mili: bool = true) -> String:
	var minutes: int = floor(fmod(time, 3600.0) / 60.0)
	var seconds: int = floor(fmod(time, 60.0))
	var milliseconds: int = floor(fmod(time, 1.0) * 100.0)
	
	if show_mili:
		return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
	else:
		return "%02d:%02d" % [minutes, seconds]

static func get_bind_string(action: StringName, seperator: String = '/') -> String:
	var strings: PackedStringArray
	
	if Global.current_controller == -1:
		var keycodes: Array = SettingsManager.get_keybind(action)
		for keycode in keycodes:
			strings.append(OS.get_keycode_string(keycode))
	else:
		var actions: Array = SettingsManager.get_controller_bind(action)
		for _action in actions:
			strings.append(SettingsManager.translate_joy_bind(-1, _action))
	
	return seperator.join(strings)

## @deprecated: use [member fps_lerp]
static func frame_independent_lerp(a: Variant, b: Variant, decay: float, delta: float) -> Variant:
	return fps_lerp(a, b, decay, delta)

# referenced via https://youtu.be/LSNQuFEDOyQ
## A frame independent lerp. Primary purpose is for the camera
## your decay should be around 1 - 25
static func fps_lerp(a: Variant, b: Variant, decay: float, delta: float) -> Variant:
	return b + (a - b) * exp(-decay * delta)

## Returns an array containing an transition and ease type formatted as [code][TransType, EaseType][/code]
## [br][br]Do not modify the returned array as it will create future unexpected results with this function. If necessary duplicate it.
static func string_to_ease(tween: StringName) -> Array:
	tween = tween.to_lower()
	if _tween_options.has(tween):
		return _tween_options[tween]
	
	return _tween_options[&"linear"]

## Alternative to [member Input.get_axis] that supports [code]just_pressed[/code] actions
static func get_input_axis_just_pressed(negative_action: StringName, positive_action: StringName) -> int:
	return int(Input.is_action_just_pressed(positive_action)) - int(Input.is_action_just_pressed(negative_action))

## Provides a time from [String]. If the time ends with [code]b[/code] or [code]s[/code], it will be converterd to [code]Beats[/code] or [code]Steps[/code]
## [br][br] So [code]"4s"[/code] is equivalent to [code]4 Conductor steps[/code] in seconds
static func string_to_time(formatted_time: String) -> float:
	if formatted_time.ends_with("b"):
		return float(formatted_time.trim_suffix("b")) * GameManager.conductor.seconds_per_beat
	elif formatted_time.ends_with("s"):
		return float(formatted_time.trim_suffix("s")) * GameManager.conductor.seconds_per_step
	elif formatted_time.is_empty():
		return 0
	
	return float(formatted_time)


static func format_number(num: float) -> String: 
	var isNegative: bool = num < 0.0
	
	num = absf(num)
	
	var string: String = ''
	var comma: String = ''
	var amount: float = floorf(num)
	
	while amount > 0:
		if string.length() > 0 and comma.length() <= 0:
			comma = ','
		
		var zeroes = ''
		var helper = amount - floorf(amount / 1000) * 1000
		amount = floorf(amount / 1000)
		
		if amount > 0:
			if helper < 100:
				zeroes += '0'
			if helper < 10:
				zeroes += '0'
		string = zeroes + str(int(helper)) + comma + string
	
	if string == '':
		string = '0'
	
	if isNegative:
		string = "-" + string
	
	return string

## Binary searches for both notes and events. param [code]value_set[/code] 0 index must be its time value
static func bsearch_note_data_left_range(value_set: Array, left_range: float) -> int:
	var length = value_set.size()
	if length == 0:
		return -1
	if value_set[length - 1][0] < left_range:
		return -1
	
	var low: int = 0
	var high: int = length - 1
	
	while (low <= high):
		var mid: int = (low + high) / 2
		
		if (value_set[mid][0] >= left_range):
			high = mid - 1
		else:
			low = mid + 1
	
	return high + 1

## Binary searches for both notes and events. param [code]value_set[/code] 0 index must be its time value
static func bsearch_note_data_right_range(value_set: Array, right_range: float) -> int:
	var length: int = value_set.size()
	if length == 0:
		return -1
	
	var low: int = 0
	var high: int = length - 1
	
	while (low <= high):
		var mid: int = (low + high) / 2
		
		if value_set[mid][0] > right_range:
			high = mid - 1
		else:
			low = mid + 1
		
	return low - 1

## Tweens a [Object] property to and back to a value
static func bop_tween(object: Object, property: NodePath, start: Variant, end: Variant, duration: float, trans: Tween.TransitionType, root: Node = Global) -> void:
	var tween: Tween = root.create_tween()
	tween.set_trans(trans)
	
	tween.tween_property(object, property, end, duration * 0.0625).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(object, property, start, duration).set_ease(Tween.EASE_OUT).set_delay(duration * 0.0625)

## No different to [member ResourceSaver.save] but doesnt gut out uids
static func save_resource(resource: Resource, path: String, flags: int = ResourceSaver.FLAG_NONE) -> void:
	var uid = ResourceLoader.get_resource_uid(path)
	if uid == -1:
		uid = ResourceUID.create_id()
		ResourceUID.add_id(uid, path)
	
	ResourceSaver.save(resource, path, flags)
	
	if uid != -1:
		ResourceSaver.set_uid(path, uid)

## Returns an array of the filepaths of a resource type
static func get_resource_files(resource_type: GDScript, path: String = "res://") -> PackedStringArray:
	var results: PackedStringArray = []
	var dir: DirAccess = DirAccess.open(path)
	dir.list_dir_begin()
	var file: String = dir.get_next()
	var blacklist: PackedStringArray = [".", "..", ".godot", "addons", "script_templates"]
	while !file.is_empty():
		if blacklist.has(file):
			file = dir.get_next()
			continue
		
		var full_path: String = path.path_join(file)
		if dir.current_is_dir():
			results.append_array(get_resource_files(resource_type, full_path))
		else:
			full_path = full_path.trim_suffix(".remap").trim_suffix(".import")
			
			if full_path.ends_with(".tres") or full_path.ends_with(".res"): 
				# this wont support things that extend the base which we will likely need
				# we can make the dep search recursive later.
				# ok i did it now
				for dep in ResourceLoader.get_dependencies(full_path):
					if dep.contains("::"):
						dep = dep.get_slice("::", 2)
					
					if dep.ends_with(".gd"):
						if resource_type.resource_path == dep:
							results.append(full_path)
							break
						elif is_extending_from_base_script(load(dep), resource_type):
							results.append(full_path)
							break
					
		file = dir.get_next()
	
	return results

static func is_extending_from_base_script(a: GDScript, base: GDScript) -> bool:
	if a == base:
		return true
	
	var p = a.get_base_script()
	
	if not p:
		return false
		
	return is_extending_from_base_script(p, base)
