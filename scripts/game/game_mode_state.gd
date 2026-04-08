extends RefCounted


static func get_rogue_upgrade_definition(rogue_upgrade_id: StringName) -> Dictionary:
	match rogue_upgrade_id:
		&"hard_drop_bonus":
			return {
				"id": &"hard_drop_bonus",
				"display_name": "硬降奖励",
				"note": "本局每次 Hard Drop 额外 +1 分。",
				"hard_drop_bonus_score": 1,
				"line_clear_bonus_per_row": 0,
				"spawn_protection_uses": 0,
			}
		&"line_clear_bonus":
			return {
				"id": &"line_clear_bonus",
				"display_name": "消行奖励",
				"note": "本局每清除 1 行额外 +1 分。",
				"hard_drop_bonus_score": 0,
				"line_clear_bonus_per_row": 1,
				"spawn_protection_uses": 0,
			}
		_:
			return {
				"id": &"spawn_protection",
				"display_name": "一次出生保护",
				"note": "本局可在出生位置被占用时触发 1 次出生保护，清掉本次出生格并继续。",
				"hard_drop_bonus_score": 0,
				"line_clear_bonus_per_row": 0,
				"spawn_protection_uses": 1,
			}


static func get_rogue_upgrade_options() -> Array[StringName]:
	return [
		&"hard_drop_bonus",
		&"line_clear_bonus",
		&"spawn_protection",
	]


static func create(selected_mode: StringName, rogue_upgrade_id: StringName = &"") -> Dictionary:
	match selected_mode:
		&"rogue":
			var upgrade_definition := get_rogue_upgrade_definition(rogue_upgrade_id)
			rogue_upgrade_id = upgrade_definition["id"]
			var upgrade_display_name: String = upgrade_definition["display_name"]
			var upgrade_note: String = upgrade_definition["note"]
			var hard_drop_bonus_score: int = upgrade_definition["hard_drop_bonus_score"]
			var line_clear_bonus_per_row: int = upgrade_definition["line_clear_bonus_per_row"]
			var spawn_protection_uses: int = upgrade_definition["spawn_protection_uses"]

			return {
				"mode_id": &"rogue",
				"display_name": "Rogue 模式",
				"mode_note": "当前是 Rogue 模式第一批强化入口。本局选择：%s。%s" % [
					upgrade_display_name,
					upgrade_note,
				],
				"uses_classic_rules": true,
				"rogue_upgrade_id": rogue_upgrade_id,
				"rogue_upgrade_display_name": upgrade_display_name,
				"hard_drop_bonus_score": hard_drop_bonus_score,
				"line_clear_bonus_per_row": line_clear_bonus_per_row,
				"spawn_protection_uses": spawn_protection_uses,
			}
		_:
			return {
				"mode_id": &"classic",
				"display_name": "经典模式",
				"mode_note": "当前沿用已经完成的标准俄罗斯方块规则与体验。",
				"uses_classic_rules": true,
				"rogue_upgrade_id": &"",
				"rogue_upgrade_display_name": "",
				"hard_drop_bonus_score": 0,
				"line_clear_bonus_per_row": 0,
				"spawn_protection_uses": 0,
			}