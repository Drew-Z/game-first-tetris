extends RefCounted


static func create(selected_mode: StringName, rogue_upgrade_id: StringName = &"") -> Dictionary:
	match selected_mode:
		&"rogue":
			var upgrade_display_name := "稳定开局"
			var upgrade_note := "本局不追加额外强化，作为 3 选 1 里的安全选项。"
			var hard_drop_bonus_score := 0
			var line_clear_bonus_per_row := 0

			match rogue_upgrade_id:
				&"hard_drop_bonus":
					upgrade_display_name = "硬降奖励"
					upgrade_note = "本局每次 Hard Drop 额外 +1 分。"
					hard_drop_bonus_score = 1
				&"line_clear_bonus":
					upgrade_display_name = "消行奖励"
					upgrade_note = "本局每清除 1 行额外 +1 分。"
					line_clear_bonus_per_row = 1
				_:
					rogue_upgrade_id = &"steady_start"

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
			}
