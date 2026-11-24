class_name GameText
extends RefCounted
## v0.70.0 · CodexAI. Localize at presentation boundaries, before measuring/paging.
static func t(source: String) -> String:
	return String(TranslationServer.translate(source))
