extends HBoxContainer

var chart_editor: ChartEditor

@onready var file_button: MenuButton = %"File Button"
@onready var edit_button: MenuButton = %"Edit Button"
@onready var view_button: MenuButton = %"View Button"
@onready var audio_button: MenuButton = %"Audio Button"
@onready var test_button: MenuButton = %"Test Button"
@onready var help_button: MenuButton = %"Help Button"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chart_editor = get_parent().get_parent()
	
	file_button.get_popup().id_pressed.connect(file_button_item_pressed)
	file_button.get_popup().set_hide_on_checkable_item_selection(false)
	file_button.get_popup().set_item_checked(
		file_button.get_popup().get_item_index(3),
		SettingsManager.get_value(SettingsManager.SEC_CHART, "auto_save"))
	
	edit_button.get_popup().id_pressed.connect(chart_editor.edit_button_item_pressed)
	edit_button.get_popup().set_hide_on_checkable_item_selection(false)
	

func file_button_item_pressed(id):
	match id:
		21: # Load ZIP
			var file_dialog: FileDialog = FileDialog.new()
			file_dialog.filters = PackedStringArray(["*.zip"])
			file_dialog.access = FileDialog.ACCESS_FILESYSTEM
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			
			file_dialog.about_to_popup.connect(chart_editor.open_popup)
			file_dialog.close_requested.connect(chart_editor.close_popup)
			file_dialog.close_requested.connect(file_dialog.queue_free)
			file_dialog.gui_focus_changed.connect(chart_editor._on_gui_focus_changed)
			file_dialog.theme = chart_editor.TOOL_THEME
			file_dialog.use_native_dialog = true
			file_dialog.mode_overrides_title = false
			file_dialog.title = 'Load a Song Zip'
			
			add_child(file_dialog)
			file_dialog.popup()
			
			var load_zip = func(path: String) -> void:
				const TEMP_PATH: String = 'user://temp_song'
				
				if not DirAccess.dir_exists_absolute(TEMP_PATH):
					DirAccess.make_dir_absolute(TEMP_PATH)
				
				if not DirAccess.dir_exists_absolute(TEMP_PATH.path_join('charts')):
					DirAccess.make_dir_absolute(TEMP_PATH.path_join('charts'))
				
				var reader = ZIPReader.new()
				reader.open(path)
				
				var temp_song = Song.new()
				
				var misc_data = ZipTools.read_dict_from_zip(reader, 'misc_data.json')
				
				for key: String in misc_data.get('chart_keys', []):
					var chart = ZipTools.read_resource_from_zip(reader, 'charts/' + key + '.res')
					if not chart:
						chart = ZipTools.read_text_resource_from_zip(reader, 'charts/' + key + '.tres')
					var ch_path = TEMP_PATH.path_join('charts/' + key + '.res')
					ResourceSaver.save(chart, ch_path)
					
					temp_song.difficulties.set(key, {
						"chart": ch_path
					})
					
				
				var inst_buffer = reader.read_file('Inst.' + misc_data.get('inst_key', 'ogg'))
				var inst = SoundManager.get_stream_from_buffer(inst_buffer, misc_data.get('inst_key', 'ogg'))
				
				if inst:
					var inst_path = TEMP_PATH.path_join('inst.' + misc_data.get('inst_key', 'ogg'))
					var file = FileAccess.open(inst_path, FileAccess.WRITE)
					file.store_buffer(inst_buffer)
					file.close()
					temp_song.instrumental = inst_path
				
				
				var vocal_paths: Array[String] = []
				var idx: int = 0
				for key: String in misc_data.get('vocal_keys', []):
					var buffer = reader.read_file('Voices' + str(idx) + '.' + key)
					
					var stream: AudioStream = SoundManager.get_stream_from_buffer(buffer, key)
					
					if stream:
						var vocals_path = TEMP_PATH.path_join('Voices' + str(idx) + '.' + key)
						var file = FileAccess.open(vocals_path, FileAccess.WRITE)
						file.store_buffer(buffer)
						file.close()
						
						vocal_paths.append(vocals_path)
					
					idx += 1
				
				temp_song.vocals = vocal_paths
				
				temp_song.artist = misc_data.get('artist', 'unknown')
				temp_song.charter = misc_data.get('charter', 'unknown')
				temp_song.tempo = misc_data.get('tempo', 60)
				temp_song.title = misc_data.get('title', 'unknown')
				
				reader.close()
				chart_editor.load_song(temp_song, misc_data.get('chart_keys')[0])
			
			file_dialog.file_selected.connect(load_zip)
		20: #Export ZIP
			var file_dialog: FileDialog = FileDialog.new()
			file_dialog.filters = PackedStringArray(["*.zip"])
			file_dialog.access = FileDialog.ACCESS_FILESYSTEM
			file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			file_dialog.use_native_dialog = true
			file_dialog.mode_overrides_title = false
			file_dialog.title = 'Export a Song Zip'
			
			file_dialog.about_to_popup.connect(chart_editor.open_popup)
			file_dialog.close_requested.connect(chart_editor.close_popup)
			file_dialog.close_requested.connect(file_dialog.queue_free)
			file_dialog.gui_focus_changed.connect(chart_editor._on_gui_focus_changed)
			file_dialog.theme = chart_editor.TOOL_THEME
			
			add_child(file_dialog)
			file_dialog.popup()
			
			var export_zip = func(path: String) -> void:
				if not ChartManager.song:
					return
				
				var vocal_keys:Array = []
				var chart_keys:Array = []
				var misc_data:Dictionary = {}
				
				var zip = ZIPPacker.new()
				zip.open(path)
				
				var inst_path: String = ChartManager.song.instrumental
				if not inst_path.is_empty():
					if inst_path.begins_with('uid'):
						inst_path = ResourceUID.uid_to_path(inst_path)
					
					ZipTools.write_snd_to_zip(zip, 'Inst.' + inst_path.get_extension(), inst_path)
				
				var idx: int = 0
				for vocal_path: String in ChartManager.song.vocals:
					if vocal_path.begins_with('uid'):
						vocal_path = ResourceUID.uid_to_path(vocal_path)
					
					vocal_keys.append(vocal_path.get_extension())
					ZipTools.write_snd_to_zip(zip, 'Voices' + str(idx) + '.' + vocal_path.get_extension(), vocal_path)
					idx += 1
				
				for diff in ChartManager.song.difficulties:
					var chart = ChartManager.song.difficulties.get(diff).get('chart')
					if chart:
						chart_keys.append(diff)
						ZipTools.write_resource_to_zip(zip, 'charts/' + diff, Chart.load(chart))
					
				
				misc_data.set('artist', ChartManager.song.artist)
				misc_data.set('charter', ChartManager.song.charter)
				misc_data.set('title', ChartManager.song.title)
				misc_data.set('tempo', ChartManager.song.tempo)
				misc_data.set('vocal_keys', vocal_keys)
				misc_data.set('chart_keys', chart_keys)
				misc_data.set('inst_key', inst_path.get_extension())
				
				
				ZipTools.write_dict_to_zip(zip, 'misc_data.json', misc_data)
				
				zip.close()
			
			file_dialog.file_selected.connect(export_zip)
		0: # make a new song
			chart_editor.can_chart = false
			var new_file_popup_instance = chart_editor.NEW_FILE_POPUP_PRELOAD.instantiate()
			
			add_child(new_file_popup_instance)
			new_file_popup_instance.popup()
			new_file_popup_instance.connect("file_created", chart_editor.new_file)
			new_file_popup_instance.connect("close_requested", chart_editor.close_popup)
			new_file_popup_instance.connect(&"gui_focus_changed", chart_editor._on_gui_focus_changed)
			%"Open Window".play()
		
		1:
			chart_editor.can_chart = false
			var open_file_popup_instance = chart_editor.OPEN_FILE_POPUP_PRELOAD.instantiate()
			
			add_child(open_file_popup_instance)
			open_file_popup_instance.popup()
			open_file_popup_instance.connect("file_selected", chart_editor.load_song_path)
			open_file_popup_instance.connect("close_requested", chart_editor.close_popup)
			open_file_popup_instance.connect("canceled", chart_editor.close_popup)
			open_file_popup_instance.connect(&"gui_focus_changed", chart_editor._on_gui_focus_changed)
			%"Open Window".play()
		
		2:
			if ChartManager.song and ChartManager.chart:
				chart_editor.save()
		
		7:
			chart_editor.can_chart = false
			
			var convert_chart_popup_instance = chart_editor.CONVERT_CHART_POPUP_PRELOAD.instantiate()
			
			add_child(convert_chart_popup_instance)
			convert_chart_popup_instance.popup()
			# convert_chart_popup_instance.connect("file_created", self._on_save_folder_dialog_dir_selected)
			convert_chart_popup_instance.connect("file_created", chart_editor.new_file)
			convert_chart_popup_instance.connect("close_requested", chart_editor.close_popup)
			convert_chart_popup_instance.connect(&"gui_focus_changed", chart_editor._on_gui_focus_changed)
			%"Open Window".play()
		
		3:
			SettingsManager.set_value(SettingsManager.SEC_CHART, "auto_save",
			!SettingsManager.get_value(SettingsManager.SEC_CHART, "auto_save"))
			SettingsManager.flush()
			%"Upper UI".get_node("%File Button").get_popup().set_item_checked(
				%"Upper UI".get_node("%File Button").get_popup().get_item_index(id), SettingsManager.get_value(SettingsManager.SEC_CHART, "auto_save"))
			%"Mouse Click".play()
		
		6:
			chart_editor.set_chart_from_chart(chart_editor.backup_chart)
			Global.change_scene_to("uid://rc52vcn2m7ob")
			chart_editor.can_chart = false
		
		8:
			chart_editor.can_chart = false
			%"Upper UI".get_node("%Export External Popup").popup()
			%"Open Window".play()
		9: #Save events
			chart_editor.can_chart = false
			%"Open Window".play()
			
			var export_window = FileDialog.new()
			export_window.root_subfolder = 'playable_songs'
			export_window.current_file = 'events.tres'
			export_window.filters = PackedStringArray(['*.res','*.tres'])
			export_window.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			export_window.display_mode = FileDialog.DISPLAY_LIST
			$"UI/Upper UI".add_child(export_window)
			
			export_window.popup_centered()
			
			if ChartManager.song and !ChartManager.song.events.is_empty():
				if ResourceLoader.exists(ChartManager.song.events):
					export_window.current_path = ResourceUID.uid_to_path(ChartManager.song.events)
			
			var on_save = func(path:String):
				var event = ChartEvents.new()
				event.data = ChartManager.chart.get_events_data()
				ResourceSaver.save(event, path)
				export_window.hide()
			
			var on_close = func():
				export_window.queue_free()
			
			export_window.connect(&"file_selected", chart_editor.on_save)
			export_window.connect(&"close_requested", chart_editor.close_popup)
			export_window.connect(&"close_requested", chart_editor.on_close)
			export_window.connect(&"gui_focus_changed", chart_editor._on_gui_focus_changed)
		10: #Load events
			chart_editor.can_chart = false
			%"Open Window".play()
			
			var export_window = FileDialog.new()
			export_window.root_subfolder = 'playable_songs'
			export_window.filters = PackedStringArray(['*.res','*.tres'])
			export_window.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			export_window.display_mode = FileDialog.DISPLAY_LIST
			$"UI/Upper UI".add_child(export_window)
			
			export_window.popup_centered()
			if ChartManager.song and !ChartManager.song.events.is_empty():
				if ResourceLoader.exists(ChartManager.song.events):
					export_window.current_path = ResourceUID.uid_to_path(ChartManager.song.events)
			
			var on_open = func(path:String):
				if path.is_empty() and not ResourceLoader.exists(path): 
					printerr('File does not exist! [' + path + ']')
				if not ChartManager.chart:
					printerr("No chart is currenty loaded! Can't load events")
					export_window.hide()
					return
				
				var events_data = load(path)
				if events_data is not ChartEvents:
					printerr("Provided resource was not a chart event file!")
				
				ChartManager.chart.merge_events_into_this(events_data)
				chart_editor.load_section(chart_editor.song_position)
				export_window.hide()
			
			var on_close = func():
				export_window.queue_free()
			
			export_window.connect(&"file_selected", chart_editor.on_open)
			export_window.connect(&"close_requested", chart_editor.close_popup)
			export_window.connect(&"close_requested", chart_editor.on_close)
			export_window.connect(&"gui_focus_changed", chart_editor._on_gui_focus_changed)

		_:
			print("id: ", id)
