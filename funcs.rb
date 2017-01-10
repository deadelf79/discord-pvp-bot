# funcs.rb

require 'yaml'
require './db/base.rb'
require './db/skills.rb'
require './data/useralias.rb'

# variables
@players = {}
@bots = []
@user_data = "./data/users"
@minimum_delay_between_pvp = 10
@maximum_crit_chance = 5
@registered_pvp = []

# functions
def app_token
	File.open("./token.txt", "r").each { |line|
		return line
	}
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
end

def setup_players(bot)
	load_players
	bot.users.keys.each do | id |
		next if @players.keys.include? id
		if bot.users[ id ].bot_account?
			@bots.push id
		else
			helper_new_player( id )
		end
	end
	puts @players.keys.size
	save_all_players
end

def load_players
	Dir.entries(@user_data).each { |filename|
		next if ['.','..'].include? filename
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

# RESPONDS
def mention(event)
	"#{event.user.mention} "
end

# RESPOND TO COMMANDS
def respond_pvp(event)
	helper_new_player(event.user.id) unless @players.keys.include? event.user.id
	if @players[event.user.id].stats.hp <= 0
		return respond_you_are_dead(event)
	end
	[
		mention(event),
		answer
	].join(@crlf)
end

def respond_hit(event)
	helper_new_player(event.user.id) unless @players.keys.include? event.user.id
	if @players[event.user.id].stats.hp <= 0
		return respond_you_are_dead(event)
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
				helper_new_player(users[0].id) unless @players.keys.include? users[0].id
				if event.user.id != users[0].id
					# hit mentioned player
					if @players[users[0].id].stats.hp > 0
						damage = helper_hit_player(event.user.id, users[0].id)
						if damage.nil?
							answer = [
								mention(event),
								@loc['you']['are']['attacking']['noone']
							].join
						else
							if damage.hp.abs > 0 && damage.mp.abs > 0
								if @players[event.user.id].stats.make_crit
									attacking = format(
										@loc['you']['are']['crit_attacking']['player']['both'], 
										users[0].name,
										damage.hp.to_i.abs + damage.mp.to_i.abs,
										damage.hp.to_i.abs,
										damage.mp.to_i.abs
									)
								else
									attacking = format(
										@loc['you']['are']['attacking']['player']['both'], 
										users[0].name,
										damage.hp.abs + damage.mp.abs,
										damage.hp.abs,
										damage.mp.abs
									)
								end

								answer = [
									mention(event),
									attacking,
									format(
										@loc['target']['has']['hp'],
										users[0].name,
										@players[users[0].id].stats.hp,
										@players[users[0].id].stats.mhp
									),
									format(
										@loc['target']['has']['mp'],
										users[0].name,
										@players[users[0].id].stats.mp,
										@players[users[0].id].stats.mmp
									)
								].join
							elsif damage.hp.abs > 0
								if @players[event.user.id].stats.make_crit
									attacking = format(
										@loc['you']['are']['crit_attacking']['player']['hp'], 
										users[0].name,
										damage.hp.to_i.abs
									)
								else
									attacking = format(
										@loc['you']['are']['attacking']['player']['hp'], 
										users[0].name,
										damage.hp.abs
									)
								end

								answer = [
									mention(event),
									attacking,
									format(
										@loc['target']['has']['hp'],
										users[0].name,
										@players[users[0].id].stats.hp,
										@players[users[0].id].stats.mhp
									)
								].join
							elsif damage.mp.abs > 0
								if @players[event.user.id].stats.make_crit
									attacking = format(
										@loc['you']['are']['crit_attacking']['player']['mp'], 
										users[0].name,
										damage.mp.to_i.abs
									)
								else
									attacking = format(
										@loc['you']['are']['attacking']['player']['mp'], 
										users[0].name,
										damage.mp.abs
									)
								end

								answer = [
									mention(event),
									attacking,
									format(
										@loc['target']['has']['mp'],
										users[0].name,
										@players[users[0].id].stats.mp,
										@players[users[0].id].stats.mmp
									)
								].join
							else
								answer = [
									mention(event),
									format(
										@loc['you']['are']['attacking']['player']['no_damage'],
										users[0].name
									)
								].join
							end
						end
					else
						answer = [
							mention(event),
							format(
								@loc['you']['are']['attacking']['dead_player'].split(@crlf).sample.gsub!(/["']/){""},
								users[0].name
							)
						].join
					end
				else
					# yourself
					answer = [
						mention(event),
						@loc['you']['are']['attacking']['yourself'].split(@crlf).sample.gsub!(/["']/){""}
					].join
				end
			else
				# no targets
				answer = [
					mention(event),
					@loc['you']['are']['attacking']['noone'].split(@crlf).sample.gsub!(/["']/){""}
				].join
			end
		end
		# save states
		@players[event.user.id].stats.make_crit = false
		users.each {|user| save_player(user.id)}
		save_player(event.user.id)
	else # ~ of delay
		answer = [
			mention(event),
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
		answer = [
			format(@loc['you']['has']['stats']['hp'], @players[event.user.id].stats.hp, @players[event.user.id].stats.mhp),
			format(@loc['you']['has']['stats']['mp'], @players[event.user.id].stats.mp, @players[event.user.id].stats.mmp),
			format(@loc['you']['has']['stats']['atk'], @players[event.user.id].stats.atk),
			format(@loc['you']['has']['stats']['def'], @players[event.user.id].stats.def)
		].join(@crlf)
		if @players[event.user.id].stats.hp <= 0
			case @players[target].stats.death_counter.last_killer
			when :player
				[
					answer,
					format(
						@loc['you']['are']['dead']['by_pvp'],
						bot.users[@players[target].stats.death_counter.last_player_killer]
					)
				].join(@crlf)
			when :enemy
			when :boss
			end
		end
	else
		if users[0].id == bot.bot_app.id
			if users.size > 1
				player = users[1]
			else
				player = nil
				answer = [
					format(@loc['you']['has']['stats']['hp'], @players[event.user.id].stats.hp, @players[event.user.id].stats.mhp),
					format(@loc['you']['has']['stats']['mp'], @players[event.user.id].stats.mp, @players[event.user.id].stats.mmp),
					format(@loc['you']['has']['stats']['atk'], @players[event.user.id].stats.atk),
					format(@loc['you']['has']['stats']['def'], @players[event.user.id].stats.def)
				].join(@crlf)
			end
		else
			player = users[0]
		end
		if player
			if @players.keys.include? player.id
				answer = [
					format(@loc['you']['has']['stats']['respond'], player.name),
					format(@loc['you']['has']['stats']['hp'], @players[player.id].stats.hp, @players[player.id].stats.mhp),
					format(@loc['you']['has']['stats']['mp'], @players[player.id].stats.mp, @players[player.id].stats.mmp),
					format(@loc['you']['has']['stats']['atk'], @players[player.id].stats.atk),
					format(@loc['you']['has']['stats']['def'], @players[player.id].stats.def)
				].join(@crlf)
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
		mention(event),
		answer
	].join(@crlf)
end

def respond_inv(event,symbol)
	helper_new_player(event.user.id) unless @players.keys.include? event.user.id
	items = helper_player_items(event,symbol)
	[
		mention(event),
		items
	].join(@crlf)
end

def respond_grind(event)
	helper_new_player(event.user.id) unless @players.keys.include? event.user.id

end

def respond_you_are_dead(event)
	case @players[event.user.id].stats.death_counter.last_killer
	when :player
		answer = format(
					@loc['you']['are']['dead']['by_pvp'],
					bot.users[@players[target].stats.death_counter.last_player_killer]
				)
	end

	[
		mention(event),
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
	if message =~ /как[\s]*дела/i
		return respond_wutsup(event)
	end
	if message =~ /покаж[иы][\s]*счетчики/i
		return respond_сounters_stats(event)
	end
	if message =~ /покаж[иы][\s]*статы/i
		return respond_stats(bot,event)
	end
	if message =~ /покаж[иы][\s]*сиськи/i
		return respond_boobies(event)
	end
	return respond_wut(event)
end

def respond_hello(event)
	[
		"Привет,",
		user_alias(event)
	].join(" ")
end

def respond_wut(event)
	answer = @loc['bot']['wut'].split(@crlf).sample.gsub!(/["']/){""}
	[
		mention(event),
		answer.to_s
	].join
end

def respond_wutsup(event)
	answer = @loc['bot']['stats']['respond'].split(@crlf).sample.gsub!(/["']/){""}
	[
		[mention(event), answer].join,
		[@loc['bot']['stats']['player_count'], @players.size].join(": "),
	].join(@crlf)
end

def respond_сounters_stats(event)
	answer = @loc['bot']['counters']['respond']
	[
		[mention(event), answer.to_s].join,
		show_counters
	].join(@crlf)
end

def respond_boobies(event)
	answer = @loc['bot']['show']['boobies'].split(@crlf).sample.gsub!(/["']/){""}
	[mention(event), answer].join
end

# RESPOND HELPERS
def helper_player_items(event,symbol)
	return @loc['you']['has']['no_item'] if @players.empty?
	unless @players.key.include? event.user.id
		helper_new_player( event.user.id )
	end
	sum = @players[ id ].inventory.weapons.size +
		@players[ id ].inventory.armors.size +
		@players[ id ].inventory.items.size
	if sum > 0
		format(
			@loc['you']['has']['stats']['inventory'],
			@players[ id ].inventory.weapons.size,
			@players[ id ].inventory.armors.size,
			@players[ id ].inventory.items.size
		)
	else
		@loc['you']['has']['no_item']
	end
end

def helper_new_player(id)
	return if @players.keys.include? id
	@players[ id ] = Player.new(
		Stats.new(
			100, 100,
			100, 100,
			100, 100,
			10, 10,
			10, 10,
			@maximum_crit_chance,
			false,
			0,
			DeathCounter.new(0,0,0,:noone,0,0),
			PVPCounter.new(0,0,0,0,0)
		),
		[
			'attack'
		],
		Inventory.new([],[],[]),
		PVPTimer.new(0,@minimum_delay_between_pvp)
	)
end

def helper_use_skill(skillname,player,target,target_role)
	skill = @skills[ skillname ]
	case skill.target
	when 'player'
		if target_role == 'player'
			# crit?
			crit_rand = rand(1..100)
			if @players[player].stats.crit_chance >= crit_rand
				@players[player].stats.make_crit = true
			end
			# player
			@players[player].stats.fp -= skill.fpcost
			@players[player].stats.mp -= skill.mpcost
			# target
			fpcost = skill.fpcost == 0 ? 1 : skill.fpcost
			mpcost = skill.mpcost == 0 ? 1 : skill.mpcost
			if skill.hpeff == 2 || skill.mpeff == 2
				effect = Damage.new(
					@players[target].stats.mhp * (skill.hpeff/2),
					@players[target].stats.mmp * (skill.mpeff/2)
				)
				@players[target].stats.hp = effect.hp
				@players[target].stats.mp = effect.mp
			else
				if @players[player].stats.make_crit
					effect = Damage.new(
						skill.hpeff * fpcost * @players[player].stats.atk * 1.5 + skill.hpeff * rand(5),
						skill.mpeff * mpcost * @players[player].stats.int * 1.5 + skill.mpeff * rand(5)
					)
				else
					effect = Damage.new(
						skill.hpeff * fpcost * @players[player].stats.atk + skill.hpeff * rand(5),
						skill.mpeff * mpcost * @players[player].stats.int + skill.mpeff * rand(5)
					)
				end
				@players[target].stats.hp += effect.hp.to_i
				@players[target].stats.mp += effect.mp.to_i
			end
		end
	when 'enemy'
	when 'boss'
	end
	return effect
end

def helper_hit_player( player, target )
	target_hp = @players[target].stats.hp

	result = helper_use_skill('attack', player, target, 'player')

	if target_hp > 0
		cur_target_hp = @players[target].stats.hp
		if cur_target_hp <= 0
			# player wins!
			@players[player].stats.pvp_counter.win_count = 1
			@players[target].stats.death_counter.by_player += 1
			@players[target].stats.death_counter.last_killer = :player
			@players[target].stats.death_counter.last_player_killer = player
		end
	end

	@players[player].stats.pvp_counter.w_player += 1
	@players[player].pvp_timer.atk_time = Time.now.to_i

	return result
end

def helper_make_save_contents(id)
	pl = @players[id]
	content = {
		hp: 					pl.stats.hp,
		mhp:					pl.stats.mhp,
		mp: 					pl.stats.mp,
		mmp:					pl.stats.mmp,
		fp: 					pl.stats.fp,
		mfp:					pl.stats.mfp,
		atk:					pl.stats.atk,
		def:					pl.stats.def,
		int:					pl.stats.int,
		dex:					pl.stats.dex,
		death_time: 			pl.stats.death_time,
		by_player:  			pl.stats.death_counter.by_player,
		by_enemy:  				pl.stats.death_counter.by_enemy,
		by_boss:  				pl.stats.death_counter.by_boss,
		last_player_killer:  	pl.stats.death_counter.last_player_killer,
		w_player: 				pl.stats.pvp_counter.w_player,
		w_enemy: 				pl.stats.pvp_counter.w_enemy,
		w_boss: 				pl.stats.pvp_counter.w_boss,
		win_count: 				pl.stats.pvp_counter.win_count,
		lose_count: 			pl.stats.pvp_counter.lose_count,
		skills: 				pl.skills,
		weapons: 				pl.inventory.weapons,
		armors: 				pl.inventory.armors,
		items: 					pl.inventory.items,
		atk_time: 				pl.pvp_timer.atk_time,
		delay: 					pl.pvp_timer.delay
	}
	content
end

def helper_load_save_contents(id, content)
	helper_new_player( id )
	pl = @players[id]
	pl.stats.hp									= content[:hp]
	pl.stats.mhp								= content[:mhp]
	pl.stats.mp									= content[:mp]
	pl.stats.mmp								= content[:mmp]
	pl.stats.fp									= content[:fp]
	pl.stats.mfp								= content[:mfp]
	pl.stats.atk								= content[:atk]
	pl.stats.def								= content[:def]
	pl.stats.int								= content[:int]
	pl.stats.dex								= content[:dex]
	pl.stats.death_time							= content[:death_time]
	pl.stats.death_counter.by_player			= content[:by_player]
	pl.stats.death_counter.by_enemy				= content[:by_enemy]
	pl.stats.death_counter.by_boss				= content[:by_boss]
	pl.stats.death_counter.last_player_killer	= content[:last_player_killer]
	pl.stats.pvp_counter.w_player				= content[:w_player]
	pl.stats.pvp_counter.w_enemy				= content[:w_enemy]
	pl.stats.pvp_counter.w_boss					= content[:w_boss]
	pl.stats.pvp_counter.win_count				= content[:win_count]
	pl.stats.pvp_counter.lose_count				= content[:lose_count]
	pl.skills 									= content[:skills]
	pl.inventory.weapons						= content[:weapons]
	pl.inventory.armors							= content[:armors]
	pl.inventory.items							= content[:items]
	pl.pvp_timer.atk_time						= content[:atk_time]
	pl.pvp_timer.delay							= content[:delay]

	@players[id] = pl
end

def helper_player_atk(id)

end