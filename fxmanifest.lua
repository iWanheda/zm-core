fx_version 'adamant'
game 'gta5'

author 'ShahZaM </>'
description 'Framework for FiveM'

version '0.1-alpha'

ui_page( 'html/index.html' )

loadscreen( 'html/loadscreen.html' )
loadscreen_manual_shutdown 'yes'

files {
	'html/**/*.js',
	'html/**/*.css',
	'html/**/*.png',
	'html/**/*.mp3',
	'html/*.html'
}

client_scripts {
	'utils/**/client/*.lua',

	'framework/client/classes/*.lua',
	'framework/client/*.lua',

	'client/*.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'utils/**/server/*.lua',

	'framework/server/classes/items.lua',
	'framework/server/classes/jobs.lua',
	'framework/server/classes/player.lua',
  'framework/server/*.lua',

	'server/*.lua'
}

shared_scripts {
	'config.lua',

	'utils/utils.lua',
	'utils/**/shared/*.lua',

	'framework/shared/*.lua'
}

dependency 'mysql-async'