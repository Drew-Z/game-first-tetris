extends RefCounted


static func create(selected_mode: StringName, rogue_upgrade_id: StringName = &"") -> Dictionary:
	match selected_mode:
		&"rogue":
			var upgrade_display_name := "一次出生保护"
			var upgrade_note := "本局可在出生位置被占用时触发 1 次出生保护，清掉本次出生格并继续。"
			var hard_drop_bonus_score := 0
			var line_clear_bonus_per_row := 0
			var spawn_protection_uses := 0

			match rogue_upgrade_id:
				&"hard_drop_bonus":
					upgrade_display_name = "硬降奖励"
					upgrade_note = "本局每次 Hard Drop 额外 +1 分。"
					hard_drop_bonus_score = 1
				&"line_clear_bonus":
					upgrade_display_name = "消行奖励"
					upgrade_note = "本局每清除 1 行额外 +1 分。"
					line_clear_bonus_per_row = 1
				&"spawn_protection":
					upgrade_display_name = "一次出生保护"
					upgrade_note = "本局可在出生位置被占用时触发 1 次出生保护，清掉本次出生格并继续。"
					spawn_protection_uses = 1
				_:
					rogue_upgrade_id = &"spawn_protection"
					spawn_protection_uses = 1

			return {
				"mode_id": &"rogue",
				"display_name": "Rogue 模式",
				"mode_note": "当前为 Rogue 模式第一批强化入口。本局选择：%s。%s" % [
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
