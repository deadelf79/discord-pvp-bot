# pvp bot for discord
# encoding: UTF-8

# requires
::RBNACL_LIBSODIUM_GEM_LIB_PATH = Dir.pwd + "/libsodium-18.dll"
require 'discordrb'
require 'yaml'
require './funcs.rb'

# load settings from 'config.ini'
load_config

# settings
admin_id = Config::Bot.admin_id
current_locale = Config::Locale.current
pvp_ch_id = Config::Channels.pvp_id
grind_ch_id = Config::Channels.grind_id
trade_ch_id = Config::Channels.trade_id

# common variables
@crlf = "\n"

# setup locale
load_locale current_locale

# setup the bot
bot = Discordrb::Commands::CommandBot.new(
	token: app_token,
	client_id: Config::Bot.client_id,
	prefix: Config::Bot.prefix,
	no_permission_message: "PVP Bot can't write any message on this channel!#{@crlf}"+
		"Check settings in 'config.ini' or in Discord server/channel settings."
)

puts '-'*40
puts "PVP Bot is running."
puts "This bot's invite URL is #{bot.invite_url}."

# COMMAND FOR EVERYONE
bot.command(
	:pvp,
	description: "Пригласить одного или нескольких участников чата к участию в PVP.#{@crlf}"+
		"Если ни одного участника не указано, то приглашение будет проигнорировано."
) do |event|
	if event.channel.id == pvp_ch_id
		event.respond respond_pvp(bot,event)
	elsif event.channel.id == trade_ch_id
		event.respond respond_tradezone(event,'pvp')
	else
		event.respond respond_safezone(event,'pvp')
	end
end

bot.command(
	:hit,
	description: "Атаковать упомянутого после команды участника чата.#{@crlf}"+
		"Если ни одного участника не указано, то атака уйдет в молоко.#{@crlf}"+
		"Вы не можете ударить участника, находящегося вне боя или не в сети."
) do |event|
	if event.channel.id == pvp_ch_id
		event.respond respond_hit(bot,event)
	elsif event.channel.id == trade_ch_id
		event.respond respond_tradezone(event,'pvp')
	else
		event.respond respond_safezone(event,'pvp')
	end
end

bot.command(
	:stats,
	description: "Показать статистику своего персонажа.#{@crlf}"+
		"Если упомянуть другого участника, будет показана его статистика."
) do |event|
	event.respond respond_stats(bot,event)
end

bot.command(
	:grind,
	description: "Отправиться убивать монстров, чтобы получить опыт и ценный лут."
) do |event|
	if event.channel.id == grind_ch_id
		event.respond respond_grind(event)
	elsif event.channel.id == trade_ch_id
		event.respond respond_tradezone(event,'grind')
	else
		event.respond respond_pvpzone(event,'grind')
	end
end

bot.command(
	:inv,
	min_args: 0, 
	max_args: 1, 
	usage: "inv [all|weapons|armors|всё|оружие|броня]",
	description: "Показывает инвентарь игрока.#{@crlf}"+
			"Упомяните в сообщении игрока, чтобы показать его инвентарь."
) do |event,symbol|
	symbol = 'all' if symbol.nil?
	event.respond respond_inv(event,symbol)
end

bot.command(
	:trade,
	description: "Позволяет продать предмет из инвентаря.#{@crlf}"+
		"Укажите его номер в инвентаре (используйте команду **inv**, чтобы посмотреть свой инвентарь)#{@crlf}, чтобы продать."+
		"Упомяните в сообщении игрока, чтобы попробовать продать предмет ему."
) do |event,item,player|
	if event.channel.id == trade_ch_id
		event.respond respond_trade(event)
	elsif event.channel.id == grind_ch_id
		event.respond respond_safezone(event,'trade')
	else
		event.respond respond_pvpzone(event,'trade')
	end
end

bot.command(
	:trade_yes,
	description: "Если другой игрок предложил вам **продать предмет**, с помощью этой команды вы можете **принять предложение**."
) do |event|

end

bot.command(
	:trade_no,
	description: "Если другой игрок предложил вам **продать предмет**, с помощью этой команды вы можете **отказаться от предложения**."
) do |event|

end

bot.command(
	:pvp_yes,
	description: "Если другой игрок предложил вам **подраться**, с помощью этой команды вы можете **принять предложение**."
) do |event|

end

bot.command(
	:pvp_no,
	description: "Если другой игрок предложил вам **подраться**, с помощью этой команды вы можете **отказаться от предложения**."
) do |event|

end

# ADMIN COMMANDS
# revive all mentioned users
bot.command(
	:revive,
	help_available: false
) do |event|
	if event.user.id == admin_id
		event.respond respond_admin_revive(bot,event)
	else
		event.respond respond_hasnt_permissions(event)
	end
end

bot.command(
	:alias,
	min_args: 1,
	max_args: 1,
	usage: "alias @mention name",
	help_available: false
) do |event,new_alias|
	if event.user.id == admin_id
		event.respond respond_admin_alias(bot,event,new_alias)
	else
		event.respond respond_hasnt_permissions(event)
	end	
end

# command aliases
# === inventory ===
bot.message(containing: ["#{bot.prefix}инв"]) do |event|
	symbol = 'all'
	event.respond respond_inv(event,symbol)
end

bot.message(containing: ["#{bot.prefix}инвентарь"]) do |event|
	symbol = 'all'
	event.respond respond_inv(event,symbol)
end

bot.message(containing: ["#{bot.prefix}bydtynfhm"]) do |event|
	symbol = 'all'
	event.respond respond_inv(event,symbol)
end

# === pvp ===
bot.message(containing: ["#{bot.prefix}пвп"]) do |event|
	if event.channel.id == pvp_ch_id
		event.respond respond_pvp(bot,event)
	elsif event.channel.id == trade_ch_id
		event.respond respond_tradezone(event,'pvp')
	else
		event.respond respond_safezone(event,'pvp')
	end
end

bot.message(containing: ["#{bot.prefix}змз"]) do |event|
	if event.channel.id == pvp_ch_id
		event.respond respond_pvp(bot,event)
	elsif event.channel.id == trade_ch_id
		event.respond respond_tradezone(event,'pvp')
	else
		event.respond respond_safezone(event,'pvp')
	end
end

bot.message(containing: ["#{bot.prefix}gdg"]) do |event|
	if event.channel.id == pvp_ch_id
		event.respond respond_pvp(bot,event)
	elsif event.channel.id == trade_ch_id
		event.respond respond_tradezone(event,'pvp')
	else
		event.respond respond_safezone(event,'pvp')
	end
end

# === hit ===
bot.message(containing: ["#{bot.prefix}ударить"]) do |event|
	if event.channel.id == pvp_ch_id
		event.respond respond_hit(bot,event)
	elsif event.channel.id == trade_ch_id
		event.respond respond_tradezone(event,'pvp')
	else
		event.respond respond_safezone(event,'pvp')
	end
end

bot.message(containing: ["#{bot.prefix}elfhbnm"]) do |event|
	if event.channel.id == pvp_ch_id
		event.respond respond_hit(bot,event)
	elsif event.channel.id == trade_ch_id
		event.respond respond_tradezone(event,'pvp')
	else
		event.respond respond_safezone(event,'pvp')
	end
end

# === start talking with bot ===
bot.message(containing: 'файтер') do |event|
	event.respond process_talking(bot,event)
end

bot.message(containing: 'Файтер') do |event|
	event.respond process_talking(bot,event)
end

bot.mention do |event|
	event.respond process_talking(bot,event)
end

# === count messages !TEST ===
bot.message() do |event|
	process_add_exp(event)
end

#-----------------------------------------------
# LAUNCH THE BOT
#-----------------------------------------------
bot.run :async
if check_greetings_timecode
	if pvp_ch_id != grind_ch_id
		if grind_ch_id != trade_ch_id
			#bot.send_message(pvp_ch_id,		@loc['bot']['greetings'])
			#bot.send_message(grind_ch_id,	@loc['bot']['greetings'])
			#bot.send_message(trade_ch_id,	@loc['bot']['greetings'])
		else
			#bot.send_message(pvp_ch_id,		@loc['bot']['greetings'])
			#bot.send_message(grind_ch_id,	@loc['bot']['greetings'])
		end
	else
		if pvp_ch_id != trade_ch_id
			#bot.send_message(pvp_ch_id,		@loc['bot']['greetings'])
			#bot.send_message(grind_ch_id,	@loc['bot']['greetings'])
		else
			#bot.send_message(pvp_ch_id,		@loc['bot']['greetings'])
		end
	end
	save_greetings_timecode
end
setup_counters
setup_game(bot)
setup_page(bot.invite_url)
puts '-'*40
bot.sync