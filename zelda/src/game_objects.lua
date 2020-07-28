--[[
	GD50
	Legend of Zelda

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

GAME_OBJECT_DEFS = {
	['switch'] = {
		type = 'switch',
		texture = 'switches',
		frame = 2,
		width = 16,
		height = 16,
		solid = false,
		defaultState = 'unpressed',
		states = {
			['unpressed'] = {
				frame = 2
			},
			['pressed'] = {
				frame = 1
			}
		}
	},
	['pot'] = {
		type = 'pot',
		texture = 'tiles',
		normal_frames = TILE_POTS['normal'],
		broke_frames = TILE_POTS['broke'],
		defaultState = 'normal',
		solid = true,
		frame = 14,
		width = 16,
		height = 16,
		states={
			['normal'] = {
				frame = 14
			},
			['broke'] = {
				frame = 53
			}
		}
	}
}