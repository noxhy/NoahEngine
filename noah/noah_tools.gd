extends Node
class_name NoahTools

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

# referenced via https://youtu.be/LSNQuFEDOyQ
## A frame independent lerp. Primary purpose is for the camera
## your decay should be around 1 - 25
static func frame_independent_lerp(a: Variant, b: Variant, decay: float, delta: float) -> Variant: 
	return b + (a - b) * exp(-decay * delta)

## Returns an array containing an transition and ease type formatted as [code][TransType, EaseType][/code]
static func string_to_ease(tween: String) -> Array:
	match tween.to_lower():
		"backin": return [Tween.TRANS_BACK, Tween.EASE_IN]
		"backinout": return [Tween.TRANS_BACK, Tween.EASE_IN_OUT]
		"backout": return [Tween.TRANS_BACK, Tween.EASE_OUT]
		"backoutin": return [Tween.TRANS_BACK, Tween.EASE_OUT_IN]
		"bouncein": return [Tween.TRANS_BOUNCE, Tween.EASE_IN]
		"bounceinout": return [Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT]
		"bounceout": return [Tween.TRANS_BOUNCE, Tween.EASE_OUT]
		"bounceoutin": return [Tween.TRANS_BOUNCE, Tween.EASE_OUT_IN]
		"circin": return [Tween.TRANS_CIRC, Tween.EASE_IN]
		"circinout": return [Tween.TRANS_CIRC, Tween.EASE_IN_OUT]
		"circout": return [Tween.TRANS_CIRC, Tween.EASE_OUT]
		"circoutin": return [Tween.TRANS_CIRC, Tween.EASE_OUT_IN]
		"cubein": return [Tween.TRANS_CUBIC, Tween.EASE_IN]
		"cubeinout": return [Tween.TRANS_CUBIC, Tween.EASE_IN_OUT]
		"cubeout": return [Tween.TRANS_CUBIC, Tween.EASE_OUT]
		"cubeoutin": return [Tween.TRANS_CUBIC, Tween.EASE_OUT_IN]
		"elasticin": return [Tween.TRANS_ELASTIC, Tween.EASE_IN]
		"elasticinout": return [Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT]
		"elasticout": return [Tween.TRANS_ELASTIC, Tween.EASE_OUT]
		"elasticoutin": return [Tween.TRANS_ELASTIC, Tween.EASE_OUT_IN]
		"expoin": return [Tween.TRANS_EXPO, Tween.EASE_IN]
		"expoinout": return [Tween.TRANS_EXPO, Tween.EASE_IN_OUT]
		"expoout": return [Tween.TRANS_EXPO, Tween.EASE_OUT]
		"expooutin": return [Tween.TRANS_EXPO, Tween.EASE_OUT_IN]
		"quadin": return [Tween.TRANS_QUAD, Tween.EASE_IN]
		"quadinout": return [Tween.TRANS_QUAD, Tween.EASE_IN_OUT]
		"quadout": return [Tween.TRANS_QUAD, Tween.EASE_OUT]
		"quadoutin": return [Tween.TRANS_QUAD, Tween.EASE_OUT_IN]
		"quartin": return [Tween.TRANS_QUART, Tween.EASE_IN]
		"quartinout": return [Tween.TRANS_QUART, Tween.EASE_IN_OUT]
		"quartout": return [Tween.TRANS_QUART, Tween.EASE_OUT]
		"quartoutin": return [Tween.TRANS_QUART, Tween.EASE_OUT_IN]
		"quintin": return [Tween.TRANS_QUINT, Tween.EASE_IN]
		"quintinout": return [Tween.TRANS_QUINT, Tween.EASE_IN_OUT]
		"quintout": return [Tween.TRANS_QUINT, Tween.EASE_OUT]
		"quintoutin": return [Tween.TRANS_QUINT, Tween.EASE_OUT_IN]
		"sinein": return [Tween.TRANS_SINE, Tween.EASE_IN]
		"sineinout": return [Tween.TRANS_SINE, Tween.EASE_IN_OUT]
		"sineout": return [Tween.TRANS_SINE, Tween.EASE_OUT]
		"sineoutin": return [Tween.TRANS_SINE, Tween.EASE_OUT_IN]
		"classic": return [Tween.TRANS_CUBIC, Tween.EASE_IN_OUT]
		_: return [Tween.TRANS_LINEAR, Tween.EASE_IN]

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
