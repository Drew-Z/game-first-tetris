extends RefCounted


static func create(selected_mode: StringName) -> Dictionary:
	match selected_mode:
		&"rogue":
			return {
				"mode_id": &"rogue",
				"display_name": "Rogue 模式",
				"mode_note": "当前只提供独立模式入口和状态壳子，玩法仍沿用经典模式；后续强化、选择与局间成长将从这里接入。",
				"uses_classic_rules": true,
			}
		_:
			return {
				"mode_id": &"classic",
				"display_name": "经典模式",
				"mode_note": "当前沿用已经完成的标准俄罗斯方块规则与体验。",
				"uses_classic_rules": true,
			}
