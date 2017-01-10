# data/config.rb

require 'inifile'

# module
module Config
	module Channels
		class << self
			def pvp_id
				@pvp_id ||= 0
			end

			def pvp_id=(value)
				@pvp_id = value.to_i
			end

			def grind_id
				@grind_id ||= 0
			end

			def grind_id=(value)
				@grind_id = value.to_i
			end

			def trade_id
				@trade_id ||= 0
			end

			def trade_id=(value)
				@trade_id = value.to_i
			end
		end
	end
	module Times
		class << self
			DEFAULT_BETWEEN_HITS = 10
			DEFAULT_BOT_GREETINGS = 600

			def between_hits
				@between_hits ||= DEFAULT_BETWEEN_HITS
			end

			def between_bot_greetings
				@between_bot_greetings ||= DEFAULT_BOT_GREETINGS
			end

			def between_hits=(value)
				@between_hits = value
			end

			def between_bot_greetings=(value)
				@between_bot_greetings = value.to_i
			end
		end
	end
	module Locale
		class << self
			DEFAULT_LOCALE = :ru

			def current
				@current ||= DEFAULT_LOCALE
			end

			def current=(value)
				@current = value.to_sym
			end
		end
	end
	module Bot
		class << self
			DEFAULT_PREFIX = '!'

			def client_id
				@client_id ||= 0
			end

			def prefix
				@prefix ||= DEFAULT_PREFIX
			end

			def client_id=(value)
				@client_id = value
			end

			def prefix=(value)
				@prefix = value.to_i
			end

			def admin_id
				@admin_id ||= 0
			end

			def admin_id=(value)
				@admin_id = value
			end
		end
	end
end

# functions
def load_config
	myini = IniFile.load('config.ini')
	Config::Channels.pvp_id 			= myini['Channels']['PVP_ID']
	Config::Channels.grind_id 			= myini['Channels']['GRIND_ID']
	Config::Channels.trade_id 			= myini['Channels']['TRADE_ID']
	Config::Times.between_hits 			= myini['Times']['BetweenHits']
	Config::Times.between_bot_greetings = myini['Times']['BetweenBotGreetings']
	Config::Locale.current 				= myini['Locale']['Current']
	Config::Bot.client_id 				= myini['Bot']['CliendId']
	Config::Bot.prefix 					= myini['Bot']['Prefix']
	Config::Bot.admin_id 				= myini['Bot']['AdminId']
end 