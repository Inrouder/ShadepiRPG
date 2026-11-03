class_name CombatRules
extends RefCounted

static func can_strike(origin: Vector2, direction: Vector2, target: Vector2, reach: float = 54.0) -> bool:
	var delta := target - origin
	return delta.length() <= reach and (delta.length() < 8.0 or direction.normalized().dot(delta.normalized()) >= 0.15)

static func damage(base: int, exposed: bool) -> int:
	return roundi(base * (1.6 if exposed else 0.7))
