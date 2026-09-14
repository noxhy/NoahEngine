extends Node

const FILE_PATH: String = 'user://test.cfg'


var data:RawSave


func _ready() -> void:
	data = RawSave.new()
	
	print('pre: one_thing ', data.one_thing)
	print('pre: number_test ', data.number_test)
	print('pre: string_test ', data.string_test)
	
	load_goobay()
	
	print('loaded: one_thing ', data.one_thing)
	print('loaded: number_test ', data.number_test)
	print('loaded: string_test ', data.string_test)
	
	
	print('setting: one_thing')
	print('setting: number_test')
	data.number_test = 20
	data.one_thing = true
	data.string_test = 'not goobster'
	
	flush_goobay()

func load_goobay():
	
	
	var dummy = RawSave.new()
	
	var conf: ConfigFile = ConfigFile.new()
	conf.load(FILE_PATH)
	
	var save_vars: Array = data.get_script().get_script_property_list()
	save_vars.remove_at(0)
	
	for v in save_vars:
		var val = conf.get_value("", v['name'], dummy.get(v['name']))
		data.set(v["name"], val)

func flush_goobay():
	
	var conf: ConfigFile = ConfigFile.new()
	
	
	var save_vars: Array = data.get_script().get_script_property_list()
	save_vars.remove_at(0)
	
	for v in save_vars:
		conf.set_value("", v["name"], data.get(v["name"]))
	
	conf.save(FILE_PATH)
