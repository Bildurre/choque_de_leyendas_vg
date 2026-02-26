## Carga las traducciones desde archivos CSV al iniciar.
extends Node


func _ready() -> void:
	_load_csv("res://translations/ui.csv")


func _load_csv(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_warning("TranslationLoader: no se pudo abrir " + path)
		return

	var header := file.get_csv_line()
	var translations: Array[Translation] = []
	for i in range(1, header.size()):
		var t := Translation.new()
		t.locale = header[i]
		translations.append(t)

	while not file.eof_reached():
		var line := file.get_csv_line()
		if line.size() < 2 or line[0].is_empty():
			continue
		for i in range(1, mini(line.size(), header.size())):
			translations[i - 1].add_message(line[0], line[i])

	for t in translations:
		TranslationServer.add_translation(t)
