fx_version 'adamant'
game 'gta5'

author 'ShahZaM </>'
description 'Framework for FiveM'

version '0.1-alpha'

ui_page( 'html/index.html' )

loadscreen( 'html/loadscreen.html' )
loadscreen_manual_shutdown 'yes'

files {
  'imports.lua', -- So we can use our Object without the need of triggering events

	'html/**/*.js',
	'html/**/*.css',
	'html/**/*.png',
	'html/**/*.mp3',
	'html/*.html'
}

client_scripts {
	'utils/**/client/*.lua',

	'framework/client/framework.lua',
	'framework/client/**/*.lua',

  'framework/shared/**/client/*.lua',

	'client/*.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'utils/**/server/*.lua',

	'framework/server/classes/player.lua', -- Make sure this is loaded before anything else
	
  'framework/server/framework.lua',
	'framework/server/**/*.lua',

  'framework/shared/**/server/*.lua',

	'server/*.lua'
}

shared_scripts {
	'config.lua',

	'utils/utils.lua',
	'utils/**/shared/*.lua',

	'framework/shared/__ignore.lua',
  
	'framework/shared/*.lua'
}

dependency 'mysql-async'