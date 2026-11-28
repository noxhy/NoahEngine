extends PanelContainer
class_name ChartEditorUpperUI

@onready var chart_editor: ChartEditor = get_tree().get_first_node_in_group(&"chart_editor")

@onready var file_button: MenuButton = %"File Button"
@onready var edit_button: MenuButton = %"Edit Button"
@onready var view_button: MenuButton = %"View Button"
@onready var audio_button: MenuButton = %"Audio Button"
@onready var test_button: MenuButton = %"Test Button"
@onready var window_button: MenuButton = %"Window Button"
@onready var help_button: MenuButton = %"Help Button"

@onready var open_song_window: ResourceFileDialog = $"HBoxContainer/File Button/Open Song Window"
@onready var export_external_popup: FileDialog = %"Export External Popup"
@onready var note_skin_window: ResourceFileDialog = %"Note Skin Window"
@onready var audios_window: Window = %"AudioWindow"
@onready var metadata_window: Window = %"Metadata Window"
@onready var note_type_window: Window = %"Note Type Window"
@onready var history_window: Window = %"History Window"
@onready var song_name_label: Label = $"HBoxContainer/Song Name Label"
@onready var time_change_window: Window = %"Time Change Editor"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	open_song_window.file_selected.connect(chart_editor.load_song_path)
	open_song_window.close_requested.connect(func():
		open_song_window.hide()
		chart_editor.close_popup()
	)
	
	file_button.get_popup().id_pressed.connect(file_button_item_pressed)
	file_button.get_popup().set_hide_on_checkable_item_selection(false)
	set_popup_checked(file_button, 3, SettingsManager.data.chart_auto_save)
	
	edit_button.get_popup().id_pressed.connect(chart_editor.edit_button_item_pressed)
	edit_button.get_popup().set_hide_on_checkable_item_selection(false)
	
	#audio button
	audio_button.get_popup().id_pressed.connect(chart_editor.audio_button_item_pressed)
	set_popup_checked(audio_button, 7, SettingsManager.data.chart_hit_sound_on_beat)
	set_popup_checked(audio_button, 8, SettingsManager.data.chart_hit_sound_on_step)
	set_popup_checked(audio_button, 10, !SettingsManager.data.chart_hit_sounds)
	set_popup_checked(audio_button, 11, ChartEditor.vocal_waveforms)
	set_popup_checked(audio_button, 12, ChartEditor.instrumental_waveforms)
	
	audio_button.get_popup().set_hide_on_checkable_item_selection(false)
	
	#view button
	view_button.get_popup().id_pressed.connect(chart_editor.view_button_item_pressed)
	view_button.get_popup().set_hide_on_checkable_item_selection(false)
	
	
	test_button.get_popup().id_pressed.connect(chart_editor.test_button_item_pressed)
	set_popup_checked(test_button, 3, SettingsManager.data.chart_start_at_current_position)
	
	test_button.get_popup().set_hide_on_checkable_item_selection(false)
	
	window_button.get_popup().id_pressed.connect(chart_editor.window_button_item_pressed)
	window_button.get_popup().set_hide_on_checkable_item_selection(false)
	
	#setup windows
	audios_window.close_requested.connect(func():
		window_button.get_popup().set_item_checked(3, false)
	)
	
	audios_window.updated_current_song.connect(func():
		if not chart_editor.music.stream_paused:
			chart_editor.toggle_audios()
		
		chart_editor.playback_manager.update_song_streams()
		chart_editor.auto_save()
	)
	
	time_change_window.close_requested.connect(func():
		window_button.get_popup().set_item_checked(4, false)
		SoundManager.tool_close_window.play()
	)
	
	export_external_popup.connect(&"file_selected", chart_editor._on_export_external_popup_file_selected)
	
	note_skin_window.connect(&"file_selected", chart_editor._on_note_skin_window_file_selected)
	
	history_window.connect(&"close_requested", chart_editor._on_history_window_close_requested)
	
	metadata_window.connect(&"updated_scroll_speed", chart_editor._on_metadata_window_updated_scroll_speed)
	metadata_window.connect(&"updated_song_artist", chart_editor._on_metadata_window_updated_song_artist)
	metadata_window.connect(&"updated_song_charter", chart_editor._on_metadata_window_updated_song_charter)
	metadata_window.connect(&"updated_song_name", chart_editor._on_metadata_window_updated_song_name)
	metadata_window.connect(&"updated_song_scene", chart_editor._on_metadata_window_updated_song_scene)
	metadata_window.connect(&"close_requested", chart_editor._on_metadata_window_close_requested)
	
	time_change_window.connect(&"add_time_change", chart_editor._on_metadata_window_add_time_change)
	time_change_window.connect(&"remove_time_change", chart_editor._on_metadata_window_remove_time_change)
	time_change_window.connect(&"selected_time_change", chart_editor._on_metadata_window_selected_time_change)
	
	note_type_window.connect(&"selected_type", chart_editor.selected_note_type)
	note_type_window.connect(&"close_requested", chart_editor._on_note_type_window_close_requested)
	
	setup_shortcuts()
	
	for child in find_children("*"):
		if child is MenuButton:
			child.get_popup().add_to_group(&"windows")
	
func setup_shortcuts():
	var shortcut:Shortcut
	
	#region file button
	shortcut = shortcut_from_keys([KEY_N])
	shortcut.events[0].ctrl_pressed = true
	set_popup_shortcut(file_button, 0, shortcut)
	
	shortcut = shortcut_from_keys([KEY_O])
	shortcut.events[0].ctrl_pressed = true
	set_popup_shortcut(file_button, 1, shortcut)
	
	set_popup_shortcut(file_button, 2, shortcut_from_events(InputMap.action_get_events(&"save")))
	#endregion
	
	#region edit button
	set_popup_shortcut(edit_button, 0, shortcut_from_events(InputMap.action_get_events(&"ui_undo")))
	set_popup_shortcut(edit_button, 1, shortcut_from_events(InputMap.action_get_events(&"ui_redo")))
	set_popup_shortcut(edit_button, 3, shortcut_from_events(InputMap.action_get_events(&"ui_cut")))
	set_popup_shortcut(edit_button, 15, shortcut_from_events(InputMap.action_get_events(&"ui_text_delete")))
	set_popup_shortcut(edit_button, 4, shortcut_from_events(InputMap.action_get_events(&"ui_copy")))
	set_popup_shortcut(edit_button, 5, shortcut_from_events(InputMap.action_get_events(&"ui_paste")))
	set_popup_shortcut(edit_button, 6, shortcut_from_events(InputMap.action_get_events(&"ui_text_delete_word")))
	set_popup_shortcut(edit_button, 8, shortcut_from_events(InputMap.action_get_events(&"flip_notes")))
	set_popup_shortcut(edit_button, 10, shortcut_from_events(InputMap.action_get_events(&"ui_text_select_all")))
	set_popup_shortcut(edit_button, 11, shortcut_from_events(InputMap.action_get_events(&"deselect")))
	
	shortcut = shortcut_from_keys([KEY_E])
	set_popup_shortcut(edit_button, 12, shortcut)
	
	shortcut = shortcut_from_keys([KEY_Q])
	set_popup_shortcut(edit_button, 13, shortcut)
	
	shortcut = shortcut_from_keys([KEY_C])
	shortcut.events[0].alt_pressed = true
	set_popup_shortcut(edit_button, 14, shortcut)
	
	shortcut = shortcut_from_keys([KEY_EQUAL])
	shortcut.events[0].alt_pressed = true
	set_popup_shortcut(edit_button, 17, shortcut)
	
	shortcut = shortcut_from_keys([KEY_MINUS])
	shortcut.events[0].alt_pressed = true
	set_popup_shortcut(edit_button, 18, shortcut)
	#endregion
	
	#audio button
	#region audio button
	shortcut = shortcut_from_keys([KEY_SPACE])
	set_popup_shortcut(audio_button, 0, shortcut)
	
	shortcut = shortcut_from_keys([KEY_EQUAL])
	shortcut.events[0].shift_pressed = true
	set_popup_shortcut(audio_button, 4, shortcut)
	
	shortcut = shortcut_from_keys([KEY_MINUS])
	shortcut.events[0].shift_pressed = true
	set_popup_shortcut(audio_button, 5, shortcut)
	
	shortcut = shortcut_from_keys([KEY_M])
	shortcut.events[0].shift_pressed = true
	set_popup_shortcut(audio_button, 10, shortcut)
	#endregion
	
	#region view button
	shortcut = shortcut_from_keys([KEY_TAB])
	set_popup_shortcut(view_button, 0, shortcut)
	
	shortcut = shortcut_from_keys([KEY_EQUAL, KEY_Z])
	shortcut.events[0].ctrl_pressed = true
	shortcut.events[0].command_or_control_autoremap = true
	
	set_popup_shortcut(view_button, 3, shortcut)
	
	shortcut = shortcut_from_keys([KEY_MINUS, KEY_X])
	shortcut.events[0].ctrl_pressed = true
	shortcut.events[0].command_or_control_autoremap = true
	
	set_popup_shortcut(view_button, 4, shortcut)
	#endregion
	
	#region WINDOW_BUTTON
	shortcut = shortcut_from_keys([KEY_M])
	shortcut.events[0].alt_pressed = true
	set_popup_shortcut(window_button, 1, shortcut)
	
	
	shortcut = shortcut_from_keys([KEY_N])
	shortcut.events[0].alt_pressed = true
	set_popup_shortcut(window_button, 2, shortcut)
	
	shortcut = shortcut_from_keys([KEY_A])
	shortcut.events[0].alt_pressed = true
	set_popup_shortcut(window_button, 3, shortcut)
	
	shortcut = shortcut_from_keys([KEY_T])
	shortcut.events[0].alt_pressed = true
	set_popup_shortcut(window_button, 4, shortcut)
	#endregion
	
	#region test button
	shortcut = shortcut_from_keys([KEY_ENTER])
	set_popup_shortcut(test_button, 0, shortcut)
	
	shortcut = shortcut_from_keys([KEY_ENTER])
	shortcut.events[0].shift_pressed = true
	set_popup_shortcut(test_button, 1, shortcut)
	#endregion
	

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
			file_dialog.theme = chart_editor.TOOL_THEME
			file_dialog.use_native_dialog = true
			file_dialog.mode_overrides_title = false
			file_dialog.title = 'Load a Song Zip'
			file_dialog.add_to_group(&"windows")
			
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
					
					var difficulty_data: SongDifficultyData = SongDifficultyData.new()
					difficulty_data.chart = ch_path
					
					temp_song.difficulties.set(key, difficulty_data)
				
				var inst_buffer = reader.read_file('Inst.' + misc_data.get('inst_key', 'ogg'))
				var inst: AudioStream
				
				if misc_data.get('inst_key', 'ogg') == 'res':
					inst = ZipTools.read_resource_from_zip(reader, 'Inst.res')
				else:
					inst = SoundManager.get_stream_from_buffer(inst_buffer, misc_data.get('inst_key', 'ogg'))
				
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
					
					var stream: AudioStream
					
					if key == 'res':
						stream = ZipTools.read_resource_from_zip(reader, 'Voices' + str(idx) + '.' + key)
					else:
						stream = SoundManager.get_stream_from_buffer(buffer, key)
					
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
			file_dialog.add_to_group(&"windows")
			
			file_dialog.about_to_popup.connect(chart_editor.open_popup)
			file_dialog.close_requested.connect(chart_editor.close_popup)
			file_dialog.close_requested.connect(file_dialog.queue_free)
			file_dialog.theme = chart_editor.TOOL_THEME
			
			add_child(file_dialog)
			file_dialog.popup()
			
			var export_zip = func(path: String) -> void:
				if not EditorResources.song:
					return
				
				var vocal_keys: Array = []
				var chart_keys: Array = []
				var inst_key: String = ''
				var misc_data: Dictionary = {}
				
				var zip = ZIPPacker.new()
				zip.open(path)
				
				var inst_path: String = EditorResources.song.instrumental
				print(inst_path)
				if not inst_path.is_empty():
					if inst_path.begins_with('uid://'):
						inst_path = ResourceUID.uid_to_path(inst_path)
					
					var _key = inst_path.get_extension() if OS.has_feature("editor") else 'res'
					
					ZipTools.write_snd_to_zip(zip, 'Inst.' + inst_key, inst_path)
				
				var idx: int = 0
				for vocal_path: String in EditorResources.song.vocals:
					if vocal_path.begins_with('uid://'):
						vocal_path = ResourceUID.uid_to_path(vocal_path)
					
					var _key = vocal_path.get_extension() if OS.has_feature("editor") else 'res'
					vocal_keys.append(_key)
					
					ZipTools.write_snd_to_zip(zip, 'Voices' + str(idx) + '.' + _key, vocal_path)
					idx += 1
				
				for diff in EditorResources.song.difficulties:
					var chart = EditorResources.song.difficulties.get(diff).get('chart')
					if chart:
						chart_keys.append(diff)
						ZipTools.write_resource_to_zip(zip, 'charts/' + diff, Chart.load(chart, EditorResources.song))
				
				
				misc_data.set('artist', EditorResources.song.artist)
				misc_data.set('charter', EditorResources.song.charter)
				misc_data.set('title', EditorResources.song.title)
				misc_data.set('tempo', EditorResources.song.tempo)
				misc_data.set('vocal_keys', vocal_keys)
				misc_data.set('chart_keys', chart_keys)
				misc_data.set('inst_key', inst_key)
				
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
			SoundManager.tool_open_window.play()
		
		1: # Open Song
			open_open_file_window()
		
		2: # Save Song
			chart_editor.save(true)
		7:
			chart_editor.can_chart = false
			
			var convert_chart_popup_instance = chart_editor.CONVERT_CHART_POPUP_PRELOAD.instantiate()
			
			add_child(convert_chart_popup_instance)
			convert_chart_popup_instance.popup()
			# convert_chart_popup_instance.connect("file_created", chart_editor._on_save_folder_dialog_dir_selected)
			convert_chart_popup_instance.connect("file_created", chart_editor.new_file)
			convert_chart_popup_instance.connect("close_requested", chart_editor.close_popup)
			SoundManager.tool_open_window.play()
		
		3: #Autosave
			SettingsManager.data.chart_auto_save = !SettingsManager.data.chart_auto_save
			
			SettingsManager.flush()
			file_button.get_popup().set_item_checked(
				file_button.get_popup().get_item_index(id), SettingsManager.data.chart_auto_save)
			SoundManager.tool_mouse_click.play()
		
		6: #Exit
			ChartEditor.song_position = 0.0
			chart_editor.set_chart_from_chart(chart_editor.backup_chart)
			Global.change_scene_to(Constants.START_MENU_SCENE)
			chart_editor.can_chart = false
		
		8: #Export External
			chart_editor.can_chart = false
			export_external_popup.popup()
			SoundManager.tool_open_window.play()
		
		9: #Save events
			chart_editor.can_chart = false
			SoundManager.tool_open_window.play()
			
			var export_window = FileDialog.new()
			export_window.current_file = 'events.tres'
			export_window.filters = PackedStringArray(['*.res','*.tres'])
			export_window.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			export_window.display_mode = FileDialog.DISPLAY_LIST
			export_window.add_to_group(&"windows")
			add_child(export_window)
			
			export_window.popup_centered()
			
			if EditorResources.song and !EditorResources.song.events.is_empty():
				if ResourceLoader.exists(EditorResources.song.events):
					export_window.current_path = ResourceUID.uid_to_path(EditorResources.song.events)
			
			var on_save = func(path:String):
				var event = ChartEvents.new()
				event.data = EditorResources.chart.events
				NoahTools.save_resource(event, path)
				export_window.hide()
			
			var on_close = func():
				export_window.queue_free()
			
			export_window.connect(&"file_selected", on_save)
			export_window.connect(&"close_requested", chart_editor.close_popup)
			export_window.connect(&"close_requested", on_close)
		10: #Load events
			chart_editor.can_chart = false
			SoundManager.tool_open_window.play()
			
			var export_window = FileDialog.new()
			export_window.filters = PackedStringArray(['*.res','*.tres'])
			export_window.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			export_window.display_mode = FileDialog.DISPLAY_LIST
			export_window.add_to_group(&"windows")
			add_child(export_window)
			
			export_window.popup_centered()
			if EditorResources.song and !EditorResources.song.events.is_empty():
				if ResourceLoader.exists(EditorResources.song.events):
					export_window.current_path = ResourceUID.uid_to_path(EditorResources.song.events)
			
			var on_open = func(path:String):
				if path.is_empty() and not ResourceLoader.exists(path): 
					printerr('File does not exist! [' + path + ']')
				if not EditorResources.chart:
					printerr("No chart is currenty loaded! Can't load events")
					export_window.hide()
					return
				
				var events_data = load(path)
				if events_data is not ChartEvents:
					printerr("Provided resource was not a chart event file!")
				
				EditorResources.chart.merge_events_into_this(events_data)
				chart_editor.load_section(chart_editor.song_position)
				export_window.hide()
			
			var on_close = func():
				export_window.queue_free()
			
			export_window.connect(&"file_selected", on_open)
			export_window.connect(&"close_requested", chart_editor.close_popup)
			export_window.connect(&"close_requested", on_close)
		
		_:
			print("id: ", id)

func open_open_file_window():
	chart_editor.can_chart = false
	
	open_song_window.popup_centered()
	open_song_window.tree.grab_focus(true)
	if open_song_window.tree.get_root() and open_song_window.tree.get_root().get_first_child():
		open_song_window.tree.set_selected(open_song_window.tree.get_root().get_first_child(), 0)
	SoundManager.tool_open_window.play()


func set_popup_checked(button: MenuButton, id: int, checked: bool) -> void:
	button.get_popup().set_item_checked(button.get_popup().get_item_index(id), checked)

func set_popup_shortcut(button: MenuButton, id: int, shortcut: Shortcut) -> void:
	button.get_popup().set_item_shortcut(button.get_popup().get_item_index(id), shortcut)

func shortcut_from_keys(keys: Array[Key]) -> Shortcut:
	var shortcut: Shortcut = Shortcut.new()
	shortcut.events = []
	for key in keys:
		var ev = InputEventKey.new()
		ev.keycode = key
		shortcut.events.append(ev)
	
	return shortcut

func shortcut_from_events(events: Array[InputEvent]) -> Shortcut:
	var shortcut: Shortcut = Shortcut.new()
	shortcut.events = events
	
	return shortcut
	
