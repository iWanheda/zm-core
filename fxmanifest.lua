fx_version 'adamant'
game 'gta5'

author 'ShahZaM </>'
description 'Framework for FiveM'

version 'alpha'

ui_page 'html/index.html'

loadscreen 'html/loadscreen.html'
loadscreen_manual_shutdown 'yes'

files {
  'includes.lua', -- So we can use our Object without the need of triggering events

	'html/**/*.js',
	'html/**/*.css',
	'html/**/*.png',
	'html/**/*.mp3',
	'html/*.html'
}

client_scripts {
	'utils/**/client/*.lua',

  -- We can't use globbing here because ./framework needs to be loaded before everything else
	'framework/client/framework.lua',
	'framework/client/commands.lua',
	'framework/client/menu.lua',

  'framework/shared/**/client/*.lua',

	'client/*.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'utils/**/server/*.lua',

	'framework/server/classes/player.lua', -- Make sure this is loaded before anything else

  -- We can't use globbing here because ./framework needs to be loaded before everything else
  'framework/server/framework.lua',
	'framework/server/commands.lua',

  'framework/shared/**/server/*.lua',

	'server/base.lua'
}

shared_scripts {
	'config.lua',

	'utils/utils.lua',
	'utils/**/shared/*.lua',

	'framework/shared/*.lua'
}

dependency 'mysql-async'