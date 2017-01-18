# funcs.rb

require 'yaml'
require './db/base.rb'
require './db/skills.rb'
require './db/weapons.rb'
require './db/armors.rb'
require './db/items.rb'
require './data/config.rb'
require './data/useralias.rb'
require './data/bot_dyn.rb'
require './helpers.rb'

# variables
@players = {}
@bots = []
@user_data = "./data/users"
@minimum_delay_between_pvp = Config::Times.between_hits
@common_crit_chance = Config::Game.common_crit_chance
@registered_pvp = []

# functions
def app_token
	if FileTest.exist?("./token.txt")
		File.open("./token.txt", "r").each { |line|
			return line
		}
	else
		return ENV['TOKEN']
	end
end

def load_locale(locale_symbol)
	begin
		@loc = YAML.load(File.read("./locales/#{locale_symbol.to_s}.yml"))
	rescue
		puts "Locale file doesn't exist!"
	end
end

def setup_counters
	
end

def setup_game(bot)
	load_skills
	setup_players(bot)
	setup_user_aliases
	setup_weapons
	setup_armors
	setup_items
end

def setup_players(bot)
	load_players
	
	bot.users.keys.each do | id |
		next if @players.keys.include? id
		if bot.users[ id ].bot_account?
			@bots.push id
		elsif id == Config::Bot.client_id
			@bots.push id
		else
			helper_new_player( id )
		end
	end

	puts "Setup players: %d player(s) registered" % @players.size

	save_all_players
end

def load_players
	Dir.entries(@user_data).each { |filename|
		next if ['.','..'].include? filename
		next unless filename =~ /\.dat$/
		content = nil
		open([@user_data,'/',filename].join, "rb"){|f|
			content = Marshal.load(f)
		}
		id = filename.gsub(/\.dat$/){""}
		helper_load_save_contents(id.to_i, content)
	}
end

def save_all_players
	return if @players.keys.empty?
	@players.each_key {|id| save_player(id) }
end

def save_player(id)
	content = helper_make_save_contents(id)
	open([@user_data,"#{id}.dat"].join("/"), "wb") { |io|
		io.write Marshal.dump(content)
	}
end

def setup_page(href)
	helper_generate_page(href)
end

# RESPOND CHANNEL SETTINGS
def respond_safezone(event,from)
	answer = @loc['bot']['here']['is']['safezone'][from].split(@crlf).sample.gsub!(/["']/){""}
	[
		helper_mention(event),
		answer
	].join(@crlf)
end

def respond_pvpzone(event,from)
	answer = @loc['bot']['here']['is']['pvpzone'][from].split(@crlf).sample.gsub!(/["']/){""}
	[
		helper_mention(event),
		answer
	].join(@crlf)
end

def respond_tradezone(event,from)
	answer = @loc['bot']['here']['is']['tradezone'][from].split(@crlf).sample.gsub!(/["']/){""}
	[
		helper_mention(event),
		answer
	].join(@crlf)
end

# RESPOND TO COMMANDS
def respond_pvp(bot,event)
	helper_new_player(event.user.id) unless @players.keys.include? event.user.id
	if @players[event.user.id].stats.hp <= 0
		return respond_you_are_dead(bot,event)
	end
	users = event.message.mentions
	hash = helper_status_users(bot,users)

	if users.size > 0
		if hash[:online].size > 0
			if hash[:idle].size > 0
				if hash[:offline].size > 0

				else

				end
			end
		else
			if users.size > 1
				group = @loc['bot']['register']['pvp']['no_online']['many']
			else
				group = @loc['bot']['register']['pvp']['no_online']['one']
			end

			answer = [
				format(
					@loc['bot']['register']['pvp']['list_caption'],
					users.size
				),
				group,
				@loc['bot']['register']['pvp']['status_canceled']
			].join(" ")
		end
	else
		answer = [
				@loc['bot']['register']['pvp']['no_players'],
				@loc['bot']['register']['pvp']['status_canceled']
			].join(" ")
	end

	[
		helper_mention(event),
		answer
	].join
end

def respond_hit(bot,event)
	helper_new_player(event.user.id) unless @players.keys.include? event.user.id
	if @players[event.user.id].stats.hp <= 0
		return respond_you_are_dead(bot,event)
	end
	answer = ""

	if (@players[event.user.id].pvp_timer.atk_time - Time.now.to_i).abs > @players[event.user.id].pvp_timer.delay
		# battle
		users = event.message.mentions
		if users.size > 1
			if @players[event.user.id].stats.fp < users.size * @skills['attack'].fpcost
				# hit at random
			else
				# hit all
			end
		else
			if users.size > 0
				if @bots.include? users[0].id
					return respond_is_bot(event)
				elsif users[0].status == :offline
					return respond_is_offline(event)
				end
				if event.user.id != users[0].id
					helper_new_player(users[0].id) unless @players.keys.include? users[0].id
					# hit mentioned player
					if @players[users[0].id].stats.hp > 0
						damage = helper_hit_player(event.user.id, users[0].id)
						if damage.nil?
							answer = [
								helper_mention(event),
								@loc['you']['are']['attacking']['noone']
							].join
						else
							emoji = ''
							if @players[users[0].id].stats.hp <= 0
								emoji = ' :skull: '
							elsif @players[users[0].id].stats.hp * 0.25 <= @players[users[0].id].stats.mhp
								emoji = ' :sob: '
							elsif @players[users[0].id].stats.hp * 0.5 <= @players[users[0].id].stats.mhp
								emoji = ' :persevere: '
							elsif @players[users[0].id].stats.hp * 0.75 <= @players[users[0].id].stats.mhp
								emoji = ' :weary: '
							elsif @players[users[0].id].stats.hp * 1.0 <= @players[users[0].id].stats.mhp
								emoji = ' :pensive: '
							end

							if damage.hp.abs > 0 && damage.mp.abs > 0
								if @players[event.user.id].stats.make_crit
									attacking = format(
										@loc['you']['are']['crit_attacking']['player']['both'], 
										Petrovich( user_alias( users[0].id ) ).to(:genitive).to_s,
										damage.hp.to_i.abs + damage.mp.to_i.abs,
										damage.hp.to_i.abs,
										damage.mp.to_i.abs
									)
								else
									attacking = format(
										@loc['you']['are']['attacking']['player']['both'], 
Petrovich( user_alias( users[0].id ) ).to(:genitive).to_s,
										damage.hp.abs + damage.mp.abs,
										damage.hp.abs,
										damage.mp.abs
									)
								end

								answer = [
									helper_mention(event),
									attacking,
									emoji,
									format(
										@loc['target']['has']['hp'],
										user_alias( users[0].id ),
										@players[users[0].id].stats.hp,
										@players[users[0].id].stats.mhp
									),
									format(
										@loc['target']['has']['mp'],
										user_alias( users[0].id ),
										@players[users[0].id].stats.mp,
										@players[users[0].id].stats.mmp
									)
								].join
							elsif damage.hp.abs > 0
								if @players[event.user.id].stats.make_crit
									attacking = format(
										@loc['you']['are']['crit_attacking']['player']['hp'], 
										Petrovich( user_alias( users[0].id ) ).to(:genitive).to_s,
										damage.hp.to_i.abs
									)
								else
									attacking = format(
										@loc['you']['are']['attacking']['player']['hp'], 
										Petrovich( user_alias( users[0].id ) ).to(:genitive).to_s,
										damage.hp.abs
									)
								end

								answer = [
									helper_mention(event),
									attacking,
									emoji,
									format(
										@loc['target']['has']['hp'],
										user_alias( users[0].id ),
										@players[users[0].id].stats.hp,
										@players[users[0].id].stats.mhp
									)
								].join
							elsif damage.mp.abs > 0
								if @players[event.user.id].stats.make_crit
									attacking = format(
										@loc['you']['are']['crit_attacking']['player']['mp'], 
										Petrovich( user_alias( users[0].id ) ).to(:genitive).to_s,
										damage.mp.to_i.abs
									)
								else
									attacking = format(
										@loc['you']['are']['attacking']['player']['mp'], 
										Petrovich( user_alias( users[0].id ) ).to(:genitive).to_s,
										damage.mp.abs
									)
								end

								answer = [
									helper_mention(event),
									attacking,
									emoji,
									format(
										@loc['target']['has']['mp'],
										user_alias( users[0].id ),
										@players[users[0].id].stats.mp,
										@players[users[0].id].stats.mmp
									)
								].join
							else
								answer = [
									helper_mention(event),
									format(
										@loc['you']['are']['attacking']['player']['no_damage'],
										Petrovich( user_alias( users[0].id ) ).to(:genitive).to_s
									)
								].join
							end
						end
					else
						answer = [
							helper_mention(event),
							format(
								helper_sample_answer( @loc['you']['are']['attacking']['dead_player'] ),
								Petrovich( user_alias( users[0].id ) ).to(:genitive).to_s
							)
						].join
					end
				else
					# yourself
					answer = [
						helper_mention(event),
						helper_sample_answer( @loc['you']['are']['attacking']['yourself'] )
					].join
				end
			else
				# no targets
				answer = [
					helper_mention(event),
					helper_sample_answer( @loc['you']['are']['attacking']['noone'] )
				].join
			end
		end
		# save states
		@players[event.user.id].stats.make_crit = false
		users.each {|user| save_player(user.id)}
		save_player(event.user.id)
	else # ~ of delay
		answer = [
			helper_mention(event),
			@loc['you']['are']['attacking']['delay']
		].join
	end
	# answer
	answer
end

def respond_stats(bot,event)
	helper_new_player(event.user.id) unless @players.keys.include? event.user.id
	users = event.message.mentions
	if users.empty?
		answer = helper_show_stats(event.user.id)
	else
		if users[0].id == bot.bot_app.id
			if users.size > 1
				player = users[1]
			else
				player = nil
				answer = helper_show_stats(event.user.id)
			end
		else
			player = users[0]
		end
		if player
			if @players.keys.include? player.id
				answer = helper_show_stats(player.id)
			else
				if @bots.include? player.id
					answer = [
						format(@loc['bot']['has']['no_player'],player.name),
						@loc['bot']['has']['player_bot']
					].join(@crlf)
				else
					answer = format(@loc['bot']['has']['no_player'],player.name)
				end
			end
		end
	end
	[
		helper_mention(event),
		answer
	].join(@crlf)
end

def respond_inv(event,symbol)
	helper_new_player(event.user.id) unless @players.keys.include? event.user.id
	items = helper_player_items(event,symbol)
	[
		helper_mention(event),
		items
	].join(@crlf)
end

def respond_grind(event)
	helper_new_player(event.user.id) unless @players.keys.include? event.user.id
	""
end

def respond_trade(event)
	helper_new_player(event.user.id) unless @players.keys.include? event.user.id
	""
end

def respond_you_are_dead(bot,event)
	answer = ""
	case @players[event.user.id].stats.death_counter.last_killer
	when :player
		answer = format(
			@loc['you']['are']['dead']['by_pvp'],
			bot.users[
				@players[event.user.id].stats.death_counter.last_player_killer
			].name
		)
	else
		answer = helper_sample_answer( @loc['you']['are']['dead']['respond'] )
	end
	[
		helper_mention(event),
		answer
	].join
end

def respond_is_bot(event)
	answer = helper_sample_answer( @loc['you']['are']['attacking']['bot'] )

	[
		helper_mention(event),
		answer
	].join
end
def respond_is_offline(event)
	answer = @loc['you']['are']['attacking']['offline'] 

	[
		helper_mention(event),
		answer
	].join
end

# RESPOND ADMIN
def respond_admin_revive(bot,event)
	users = event.message.mentions
	revived = []

	if users.size == 0 #["here","everyone"].include? users[0]
		bot.users.keys.each do |id|
			helper_revive_player( @players[ id ] )
			revived.push id
		end
	else
		users.each do |user|
			helper_revive_player( @players[ user.id ] )
			revived.push user.id
		end
	end

	puts "Revived %d user(s)" % revived.size

	answer = @loc['bot']['revive']['mentioned']
	[
		helper_mention(event),
		answer
	].join
end

def respond_admin_alias(bot,event,new_alias)
	users = event.message.mentions
	return "" unless users.size > 0

	target = users[0].id
	name = new_alias.gsub(/\@[\w\d]+\#[\d]+/){""}

	save_new_alias( target, name )
	
	answer = format(
		@loc['bot']['aliased'],
		bot.users[ Config::Bot.client_id ].name,
		bot.users[ target ].name,
		name.trim
	)

	[
		helper_mention(event),
		answer
	].join
end

def respond_hasnt_permissions(event)
	answer = @loc['bot']['hasnt']['permissions']

	[
		helper_mention(event),
		answer
	].join
end

# RESPOND BOT TALK
def process_talking(bot,event)
	message = event.message.content
	message.gsub!(/файтер/i){""}
	if message.empty?
		return respond_wut(event)
	end
	if message =~ /привет/i
		return respond_hello(event)
	end
	if message =~ /купи/i
		return respond_bot_trade(event)
	end
	if message =~ /как[\s]*дела/i
		return respond_wutsup(event)
	end
	if message =~ /покажи[\s]*слова/i
		return respond_сounters_stats(event)
	end
	if message =~ /покажи[\s]*статы/i
		return respond_stats(bot,event)
	end
	if message =~ /покажи[\s]*сиськи/i
		return respond_boobies(event)
	end
	if message =~ /ничего/i
		return ""
	end
	if message =~ /вс[её][\s]*хорошо/i
		return ""
	end
	return respond_wut(event)
end

def process_add_exp(event)
	helper_new_player(event.user.id) unless @players.keys.include? event.user.id
	@players[event.user.id].expeirience.message_count += 1
end

def respond_hello(event)
	[
		"Привет,",
		user_alias(event)
	].join(" ")
end

def respond_bot_trade(event)
	answer = "Пока Эльф не пропишет торговлю, я ничего не могу купить у тебя."
	[
		helper_mention(event),
		answer
	].join
end

def respond_wut(event)
	answer = helper_sample_answer( @loc['bot']['wut'] )
	[
		helper_mention(event),
		answer
	].join
end

def respond_wutsup(event)
	answer = helper_sample_answer( @loc['bot']['stats']['respond'] )
	[
		[helper_mention(event), answer].join,
		[@loc['bot']['stats']['player_count'], @players.size].join(": "),
	].join(@crlf)
end

def respond_сounters_stats(event)
	answer = @loc['bot']['counters']['respond']
	[
		[helper_mention(event), answer.to_s].join,
		show_counters
	].join(@crlf)
end

def respond_boobies(event)
	answer = helper_sample_answer( @loc['bot']['show']['boobies'] )
	[helper_mention(event), answer].join
end