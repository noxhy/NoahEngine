extends VBoxContainer


# todo more fancy event params
func construct_from_event(ev_name: String, ev: Array):
	
	var params: Array = ev.get(2)
	
	var param_values: Array = Constants.EVENT_DATA[ev_name]["parameters"]
	
	var idx: int = 0
	
	for _param in param_values:
		
		var line_edit = LineEdit.new()
		
		line_edit.placeholder_text = _param
		if idx < params.size():
			line_edit.text = str(params[idx])
		
		%"Event Parameters".add_child(line_edit)
		
		idx += 1
	
	
	#%"Event Name".text = current_event.capitalize()
	#var parameter_names: Array = Constants.EVENT_DATA[current_event]["parameters"]
	#
	#var i: int = 0
	#for _name in parameter_names:
		#var line_edit: LineEdit = LineEdit.new()
		#
		#line_edit.placeholder_text = _name
		#if (i < parameters.size()):
			#line_edit.text = str(parameters[i])
		#
		#%"Event Parameters".add_child(line_edit)
		#i += 1
