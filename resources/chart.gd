@icon("res://assets/sprites/nodes/chart_file.png")

extends Resource
class_name Chart

@export_group("Chart Data")

@export_range(0.0, 5.0, 0.1) var scroll_speed = 1.0
## Audio latency.
@export var offset = 0.0

# Actual Chart Storage
@export var chart_data = {
	
	"notes": [],
	"events": [],
	"tempos": {0.0: 60},
	"meters": {0.0: [4, 16]},
}

func get_notes_data() -> Array: return chart_data.get("notes")
func get_events_data() -> Array: return chart_data.get("events")
func get_tempos_data() -> Dictionary: return chart_data.get("tempos")
func get_meters_data() -> Dictionary:
	return chart_data.get("meters")

func get_tempo_at(time: float) -> float:
	time = max(0, time)
	var output: float = -1
	for point in get_tempos_data():
		if time >= point:
			output = get_tempos_data().get(point)
		else:
			continue
	
	return output


func get_meter_at(time: float) -> Array:
	time = max(0, time)
	var output: Array = []
	for point in get_meters_data():
		if time >= point:
			output = get_meters_data().get(point)
		else:
			continue
	
	return output

func get_tempo_time_at(time: float) -> float:
	time = max(0, time)
	var output: float = -1
	for point in get_tempos_data():
		if time >= point:
			output = point
	
	return output

enum ChartType {
	CODENAME,
	VSLICE,
	PSYCH,
	PSYCH_V1,
	UNDEFINED
}

static func load(path:String) -> Chart:
	
	if path.get_extension() == 'res': ##probably a chart already
		return load(path)
	elif path.get_extension() == 'json':
		
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var json = JSON.parse_string(file.get_as_text())
			if json and json is Dictionary:
				match resolve_chart_type(json):
					ChartType.PSYCH:
						
						return convert_psych(json, {}, false)
					ChartType.PSYCH_V1:
						return convert_psych(json)
						
					ChartType.VSLICE:
						
						var meta_path = path.replace('chart', 'metadata')
						
						assert(FileAccess.file_exists(meta_path), 'failed to find vslice chart metadata.json')
						
						var meta_file = FileAccess.open(meta_path, FileAccess.READ)
						var meta_json = JSON.parse_string(meta_file.get_as_text())
						if meta_json:
							return convert_vslice(json, meta_json)
					
					ChartType.CODENAME:
						
						var meta_path = path.get_base_dir() + '/meta.json'
						
						assert(FileAccess.file_exists(meta_path), 'failed to find cne chart meta.json')
						
						var meta_file = FileAccess.open(meta_path, FileAccess.READ)
						var meta_json = JSON.parse_string(meta_file.get_as_text())
						if meta_json:
							return convert_cne(json, meta_json)
					_:
						pass
	
	
	return null

static func resolve_chart_type(raw_json:Dictionary) -> ChartType:
	
	if raw_json.has('format'):
		var format:String = raw_json.get('format')
		if format.contains('psych_v1'):
			return ChartType.PSYCH_V1
	
	if raw_json.has('codenameChart'):
		return ChartType.CODENAME
	
	if raw_json.has('version') and raw_json.has('scrollSpeed'):
		return ChartType.VSLICE
	
	if raw_json.has('song') and raw_json.get('song') is Dictionary and raw_json.get('song').has('gfVersion'):
		return ChartType.PSYCH
	
	return ChartType.UNDEFINED


static func chart_type_to_str(type:ChartType) -> String:
	match type:
		ChartType.CODENAME: return "Codename"
		ChartType.VSLICE: return 'VSlice'
		ChartType.PSYCH: return 'Psych Legacy'
		ChartType.PSYCH_V1: return 'Psych V1'
	
	return "Undefined"

# Sorting notes
static func sort_notes(a, b) -> bool:
	return a[0] < b[0]

static func convert_psych(data:Dictionary,events:Dictionary = {}, v1:bool = true) -> Chart:
	
	var chart = Chart.new()
	
	var note_data = []
	var event_data = []
	var tempo_data = {}
	var meter_data = {0.0: [4, 16]}
	var section_time = 0.0
	
	if not v1:
		data = data.get('song')
	
	var current_bpm:int = data.get('bpm')
	
	chart.scroll_speed = data.get('speed')
	
	tempo_data[0.0] = current_bpm
	var index = 0
	
	for i in data.get("notes"):
		# Too lazy to make sure for BPM changes so
		var seconds_per_beat = 60.0 / current_bpm
		var seconds_per_measure = seconds_per_beat * i.get("sectionBeats", 4)
		
		# Checks if the tempo changes, then adds it to the tempos dictionary
		if i.has("changeBPM"):
			if i.changeBPM:
				tempo_data[section_time] = i.bpm
				current_bpm = i.bpm
		
		# Camera movement conversion
		var camera_position = 0 if i.mustHitSection else 1
		event_data.append([index * seconds_per_measure, "camera_position", [camera_position]])
		
		for j in i.sectionNotes:
			# Format: time, lane, length in notes, note type
			# Converts the ms length to how many beats the hold node lasts
			var ms_to_notes = (j[2] / 1000.0) / seconds_per_beat
			var note = []
			var lane = j[1]
			
			# Deals with the stupid FnF must hit section bullshit
			if not v1 and camera_position == 1:
				if lane > 3:
					lane -= 4
				else:
					lane += 4
			
			# Creates the note
			note = [j[0] / 1000.0, int(lane), ms_to_notes]
			
			# Deals with note types
			if j.size() == 4:
				note.append(j[3])
			else:
				note.append(0)
			
			note_data.append(note)
		
		note_data.sort_custom(sort_notes)
		
		index += 1
		section_time += seconds_per_measure
	
	# Psych event conversion # TODO re add events json support
	if data.has('events'):
		for i in data.get('events'):
			var time = i[0]
			# Event name conversion
			for j in i[1]:
				if ChartConverter.EVENT_NAMES.has(j[0]):
					j[0] = ChartConverter.EVENT_NAMES.get(j[0])
				
				if j[0] == "Adjust Camera":
					var split = j[2].split(",")
					if j[1] == "zoom":
						j[0] = "camera_zoom"
						j[1] = int(split[0])
						j[2] = split[1]
					else:
						j[0] = "bop_rate"
						j[1] = int(split[0])
						j[2] = ""
				
				# Creates the event
				## j[1] is the event name, j[2] is the event parameters
				event_data.append([time / 1000.0, j[0], [j[1], j[2]]])
	
	event_data.sort_custom(sort_notes)
	
	chart.chart_data = {
		"notes": note_data,
		"events": event_data,
		"tempos": tempo_data,
		"meters": meter_data
	}
	
	return chart

static func convert_vslice(data:Dictionary, meta:Dictionary) -> Chart:
	
	var chart = Chart.new()
	
	var note_data = []
	var event_data = []
	var tempo_data = {}
	var meter_data = {0.0: [4, 16]}
	var section_time = 0.0
	
	# Get tempo at certain time
	var get_temp_at_struct = func(time:float,tempo_dict:Dictionary) -> float:
		var output: float = -1
		for point in tempo_dict:
			if time >= point:
				output = tempo_dict.get(point)
			else:
				continue
		
		return output
	
	chart.scroll_speed = data.scrollSpeed[GameManager.difficulty]
	
	# Adding tempo data
	for i in meta.get('timeChanges'):
		if i.t < 0:
			i.t = 0.0
		tempo_data[i.t / 1000.0] = i.bpm
		meter_data[i.t / 1000.0] = [i.n, i.n * i.d]
	
	for i in data.get('notes').get(GameManager.difficulty):
		var time = i.t / 1000.0
		var lane = int(i.d)
		
		var tempo = get_temp_at_struct.call(time, tempo_data)
		var seconds_per_beat = 60.0 / tempo
		
		var length = 0
		if i.has("l"):
			length = i.l / 1000.0 / seconds_per_beat
		
		var note_type = i.get("k", 0)
		note_data.append([time, lane, length, note_type])
	
	note_data.sort_custom(sort_notes)
	
	# Adding event data.
	for i in data.get('events'):
		var time = i.t / 1000.0
		
		var tempo = get_temp_at_struct.call(time, tempo_data)
		var seconds_per_beat = 60.0 / tempo
		
		time = snapped(time, seconds_per_beat)
		
		var event = i.e
		var parameters = []
		
		var event_name = event
		if ChartConverter.EVENT_NAMES.has(event):
			event_name = ChartConverter.EVENT_NAMES.get(event)
		
		if i.v is Dictionary:
			parameters.append_array(i.v.values())
		else:
			parameters.append(str(i.v))
		
		if event == "FocusCamera":
			parameters = [str(i.v.char)]
		elif event == "ZoomCamera":
			parameters = [str(i.v.zoom), str(i.v.duration * (seconds_per_beat / 16.0)), i.get("ease", "CLASSIC")]
		elif event == "SetCameraBop":
			parameters = [str(i.v.rate * 4)]
		
		event_data.append([time, event_name, parameters])
	
	event_data.sort_custom(sort_notes)
	
	chart.chart_data = {
		"notes": note_data,
		"events": event_data,
		"tempos": tempo_data,
		"meters": meter_data
	}
	
	return chart

static func convert_cne(data:Dictionary, meta:Dictionary) -> Chart:
	
	var chart = Chart.new()
	
	var note_data = []
	var event_data = []
	var tempo_data = {}
	var meter_data = {0.0: [4, 16]}
	var section_time = 0.0
	
	# Get tempo at certain time
	var get_temp_at_struct = func(time:float,tempo_dict:Dictionary) -> float:
		var output: float = -1
		for point in tempo_dict:
			if time >= point:
				output = tempo_dict.get(point)
			else:
				continue
		
		return output
	
	chart.scroll_speed = data.get('scrollSpeed')
	
	var current_bpm = meta.get('bpm')
	tempo_data[0.0] = current_bpm
	
	var raw_events:Array = []
	if data.has('events'):
		raw_events.append_array(data.get('events'))
	
	for event_packet in raw_events:
		
		var event = []
		if event_packet.name == 'Camera Movement':
			pass
			
			if event_packet.params[0] == 1: event_packet.params[0] = 0
			elif event_packet.params[0] == 0: event_packet.params[0] = 1
			
			
			event = [event_packet.time / 1000.0, 'camera_position', event_packet.params]
			
		elif ChartConverter.EVENT_NAMES.has(event_packet.name):
			event = [event_packet.time / 1000.0, ChartConverter.EVENT_NAMES[event_packet.name], event_packet.params]
		elif event_packet.name == "BPM Change":
			tempo_data[event_packet.time / 1000.0] = event_packet.params[0]
		else:
			event = [event_packet.time / 1000.0, event_packet.name, event_packet.params]
		
		event_data.append(event)
	
	event_data.sort_custom(sort_notes)
	
	for strumline in data.get('strumLines'):
		for i in strumline.notes:
			# Format: time, lane, length in notes, note type
			# Converts the ms length to how many beats the hold node lasts
			
			var time = i.time / 1000.0
			current_bpm = get_temp_at_struct.call(time, tempo_data)
			var seconds_per_beat = 60.0 / current_bpm
			var ms_to_notes = 0
			if i.sLen:
				ms_to_notes = ((i.sLen / 1000.0) / seconds_per_beat)
			var lane = i.id
			
			if strumline.position == "dad":
				lane += 4
			
			# Creates the note
			var note = [time, lane, ms_to_notes, i.type]
			note_data.append(note)
	
	note_data.sort_custom(sort_notes)
	
	chart.chart_data = {
		"notes": note_data,
		"events": event_data,
		"tempos": tempo_data,
		"meters": meter_data
	}
	
	return chart
	
