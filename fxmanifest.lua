fx_version 'cerulean'
game 'gta5'

author 'ShahZaM </>'
description 'Framework for FiveM'
version 'alpha'

lua54 'yes'

ui_page 'html/index.html'

loadscreen 'html/loadscreen.html'
loadscreen_manual_shutdown 'yes'

files {
  'includes.lua', -- So we can use our Object without the need of triggering events
  'modules/**',
	'html/**'
}

client_scripts {
	'utils/**/client/*.lua',

  -- We can't use globbing here because /client/framework needs to be loaded before everything else
	'framework/client/framework.lua',
	'framework/client/commands.lua',

	'client/*.lua'
}

server_scripts {
	'utils/**/server/*.lua',

	'framework/server/classes/player.lua', -- Make sure this is loaded before anything else

  -- We can't use globbing here because /server/framework needs to be loaded before everything else
  'framework/server/framework.lua',
	'framework/server/commands.lua',

	'server/base.lua'
}

shared_scripts {
	'config.lua',

	'utils/utils.lua',
	'utils/**/shared/*.lua',
}

dependencies { 'zm-ui' }
server_dependency 'mongodb'