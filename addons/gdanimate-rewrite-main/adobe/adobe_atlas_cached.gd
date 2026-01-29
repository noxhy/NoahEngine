extends Resource
class_name AdobeAtlasCached


@export_storage var spritemap: Dictionary[StringName, AdobeAtlasSprite] = {}
@export_storage var symbols: Dictionary[StringName, AdobeSymbol] = {}
@export_storage var framerate: float = 24.0
@export_storage var stage_symbol: StringName = &""
@export_storage var stage_transform: Transform2D = Transform2D.IDENTITY
