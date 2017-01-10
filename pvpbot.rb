# pvp bot for discord
# encoding: UTF-8

# requires
::RBNACL_LIBSODIUM_GEM_LIB_PATH = Dir.pwd + "/libsodium-18.dll"
require 'discordrb'
require 'yaml'
require './funcs.rb'

# settings
admin_id = 238398268583837696 # set your id
default_locale = :ru
current_locale = default_locale
channel_id = 238948416552435712

# common variables
@crlf = "\n"

# setup locale
load_locale current_locale

# setup the bot
bot = Discordrb::Commands::CommandBot.new(
	token: app_token,
	client_id: 267971013814255616,
	prefix: '!'
)

puts '-'*40
puts "PVP Bot is running."
puts "This bot's invite URL is #{bot.invite_url}."

bot.command(
	:pvp,
	description: "Атаковать упомянутого после команды участника чата.#{@crlf}"+
		"Если ни одного участника не указано, то атака уйдет в молоко."
) do |event|
	event.respond respond_pvp(event)
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
	event.respond respond_grind(event)
end

bot.command(
	:inv,
	min_args: 0, 
	max_args: 1, 
	usage: "inv [all|weapons|armors|всё|оружие|броня]",
	description: "Позволяет продать предмет из инвентаря.#{@crlf}"+
		"Укажите его номер в инвентаре (используйте команду **inv**, чтобы посмотреть свой инвентарь)#{@crlf}, чтобы продать."+
		"Упомяните в сообщении игрока, чтобы попробовать продать предмет ему."
) do |event,symbol|
	symbol = 'all' if symbol.nil?
	event.respond respond_inv(event,symbol)
end

bot.command(
	:trade,
	min_args: 1, 
	max_args: 2, 
	usage: "trade item[,player]",
	description: "Позволяет продать предмет из инвентаря.#{@crlf}"+
		"Укажите его номер в инвентаре (используйте команду **inv**, чтобы посмотреть свой инвентарь)#{@crlf}, чтобы продать."+
		"Упомяните в сообщении игрока, чтобы попробовать продать предмет ему."
) do |event,item,player|

end

bot.command(
	:trade_yes,
	description: "Если другой игрок предложил вам продать предмет, с помощью этой команды вы можете **принять предложение**."
) do |event|

end

bot.command(
	:trade_no,
	description: "Если другой игрок предложил вам продать предмет, с помощью этой команды вы можете **отказаться от предложения**."
) do |event|

end

# command aliases
# === ИНВЕНТАРЬ ===
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

# === ПВП ===
bot.message(containing: ["#{bot.prefix}пвп"]) do |event|
	event.respond respond_pvp(event)
end

bot.message(containing: ["#{bot.prefix}змз"]) do |event|
	event.respond respond_pvp(event)
end

bot.message(containing: ["#{bot.prefix}gdg"]) do |event|
	event.respond respond_pvp(event)
end

bot.message(containing: ["#{bot.prefix}ударить"]) do |event|
	event.respond respond_pvp(event)
end

bot.message(containing: ["#{bot.prefix}elfhbnm"]) do |event|
	event.respond respond_pvp(event)
end

# === РАЗГОВОР С БОТОМ ===
bot.message(containing: 'файтер') do |event|
	event.respond process_talking(bot,event)
end

bot.message(containing: 'Файтер') do |event|
	event.respond process_talking(bot,event)
end

bot.mention do |event|
	event.respond process_talking(bot,event)
end

# === СЧЕТЧИКИ ===
bot.message(containing: ["#{bot.prefix}сиськи"]) do |event|
	add_word('сиськи')
end

bot.message(containing: ["#{bot.prefix}cbcmrb"]) do |event|
	add_word('сиськи')
end

bot.message(containing: ["#{bot.prefix}fap"]) do |event|
	add_word('фап')
end

bot.message(containing: ["#{bot.prefix}фап"]) do |event|
	add_word('фап')
end

#-----------------------------------------------
# LAUNCH THE BOT
#-----------------------------------------------
bot.run :async
#bot.send_message(channel_id,@loc['bot']['greetings'])
setup_counters
setup_game(bot)
bot.sync