# helpers.rb

# functions
def helper_mention(event)
	"#{event.user.mention} "
end

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
			Config::Game::NewPlayer::DEFAULT_MHP, # hp
			Config::Game::NewPlayer::DEFAULT_MHP, # mhp
			Config::Game::NewPlayer::DEFAULT_MMP, # mp
			Config::Game::NewPlayer::DEFAULT_MMP, # mmp
			Config::Game::NewPlayer::DEFAULT_MFP, # fp
			Config::Game::NewPlayer::DEFAULT_MFP, # mfp
			Config::Game::NewPlayer::DEFAULT_ATK,
			Config::Game::NewPlayer::DEFAULT_DEF,
			Config::Game::NewPlayer::DEFAULT_INT,
			Config::Game::NewPlayer::DEFAULT_DEX,
			@common_crit_chance,
			false,
			0,
			DeathCounter.new(0,0,0,:noone,0,0,0),
			PVPCounter.new(0,0,0,0,0)
		),
		Config::Game::NewPlayer::DEFAULT_SKILLS,
		Inventory.new( [], [], [] ),
		PVPTimer.new( 0, @minimum_delay_between_pvp ),
		Expeirience.new( 0, 0 ),
		0
	)
end

def helper_use_skill(skillname,player,target,target_role)
	skill = @skills[ skillname ]
	case skill.target
	when 'player'
		if target_role == 'player'
			# crit?
			crit_rand = rand(1.0..100.0)
			puts @players[player].stats.crit_chance, crit_rand
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
						helper_calc_player_crit_atk( player, skill, fpcost, mpcost ),
						skill.mpeff * mpcost * @players[player].stats.int * 1.5 + skill.mpeff * rand(5)
					)
				else
					effect = Damage.new(
						helper_calc_player_atk( player, skill, fpcost, mpcost ),
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
	@players[player].stats.make_crit = false

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
		last_killer: 			pl.stats.death_counter.last_enemy_killer,
		last_player_killer:  	pl.stats.death_counter.last_player_killer,
		last_enemy_killer: 		pl.stats.death_counter.last_enemy_killer,
		last_boss_killer: 		pl.stats.death_counter.last_boss_killer,
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

	# one-line stats
	pl.stats.hp									= helper_safe_load_content_value(content, :hp, 	Config::Game::NewPlayer::DEFAULT_MHP)
	pl.stats.mhp								= helper_safe_load_content_value(content, :mhp, Config::Game::NewPlayer::DEFAULT_MHP)
	pl.stats.mp									= helper_safe_load_content_value(content, :mp, 	Config::Game::NewPlayer::DEFAULT_MMP)
	pl.stats.mmp								= helper_safe_load_content_value(content, :mmp, Config::Game::NewPlayer::DEFAULT_MMP)
	pl.stats.fp									= helper_safe_load_content_value(content, :fp, 	Config::Game::NewPlayer::DEFAULT_MFP)
	pl.stats.mfp								= helper_safe_load_content_value(content, :mfp, Config::Game::NewPlayer::DEFAULT_MFP)
	pl.stats.atk								= helper_safe_load_content_value(content, :atk, Config::Game::NewPlayer::DEFAULT_ATK)
	pl.stats.def								= helper_safe_load_content_value(content, :def, Config::Game::NewPlayer::DEFAULT_DEF)
	pl.stats.int								= helper_safe_load_content_value(content, :int, Config::Game::NewPlayer::DEFAULT_INT)
	pl.stats.dex								= helper_safe_load_content_value(content, :dex, Config::Game::NewPlayer::DEFAULT_DEX)
	pl.stats.death_time							= helper_safe_load_content_value(content, :death_time, 0)
	pl.stats.death_counter.by_player			= helper_safe_load_content_value(content, :by_player, 0)
	pl.stats.death_counter.by_enemy				= helper_safe_load_content_value(content, :by_enemy, 0)
	pl.stats.death_counter.by_boss				= helper_safe_load_content_value(content, :by_boss, 0)
	pl.stats.death_counter.last_player_killer	= helper_safe_load_content_value(content, :last_player_killer, 0)
	pl.stats.pvp_counter.w_player				= helper_safe_load_content_value(content, :w_player, 0)
	pl.stats.pvp_counter.w_enemy				= helper_safe_load_content_value(content, :w_enemy, 0)
	pl.stats.pvp_counter.w_boss					= helper_safe_load_content_value(content, :w_boss, 0)
	pl.stats.pvp_counter.win_count				= helper_safe_load_content_value(content, :win_count, 0)
	pl.stats.pvp_counter.lose_count				= helper_safe_load_content_value(content, :lose_count, 0)
	pl.skills 									= helper_safe_load_content_value(content, :skills, Config::Game::NewPlayer::DEFAULT_SKILLS)
	pl.pvp_timer.atk_time						= helper_safe_load_content_value(content, :atk_time, 0)
	pl.pvp_timer.delay							= helper_safe_load_content_value(content, :delay, @minimum_delay_between_pvp)
	pl.gold										= helper_safe_load_content_value(content, :gold, 0)

	# arrays
	weapon_array 								= helper_safe_load_content_value(content, :weapons, [])
	if weapon_array.size > 0
		weapon_array.each do |weapon|
			pl.inventory.weapons.push @weapons.select{|some|some.unique.id == weapon}
		end
	else
		pl.inventory.weapons = []
	end
	armors_array 								= helper_safe_load_content_value(content, :armors, [])
	if armors_array.size > 0
		armors_array.each do |armor|
			pl.inventory.armors.push @armors.select{|some|some.unique.id == armor}
		end
	else
		pl.inventory.armors = []
	end
	items_array 								= helper_safe_load_content_value(content, :items, [])
	if items_array.size > 0
		items_array.each do |item|
			pl.inventory.items.push @items.select{|some|some.unique.id == item}
		end
	else
		pl.inventory.items = []
	end

	@players[id] = pl
end

def helper_safe_load_content_value(content, symbol, default)
	if content.include?(symbol)
		content[symbol]
	else
		default
	end
end

def helper_calc_player_atk(id,skill,fpcost,mpcost)
	# check equipped weapon
	weapon_atk = 0
	if @players[ id ].inventory.weapons.size > 0
		equipped = helper_equipped_weapon( id )
		if equipped.size > 0
			weapon_atk = equipped[0].atk
		end
	end
	# sum all
	skill.hpeff * fpcost * @players[ id ].stats.atk * 1.5 + skill.hpeff * rand(5) + weapon_atk
end

def helper_equipped_weapon(id)
	@players[ id ].inventory.weapons.select{|weapon|weapon.equipable.equipped}
end


def helper_calc_player_crit_atk(id,skill,fpcost,mpcost)
	helper_calc_player_atk(id,skill,fpcost,mpcost) * 1.5
end

def helper_calc_player_def(id)
	# check equipped armor

	# sum all
end

def helper_status_users(bot,users)
	hash = {
		online:[],
		idle:[],
		offline:[]
	}
	users.each do |user|
		case bot.users[user.id].status
		when :online; 	hash[:online].push(user)
		when :idle; 	hash[:idle].push(user)
		when :offline; 	hash[:offline].push(user)
		end
	end
	hash
end

def helper_sample_answer(string)
	string.split(@crlf).sample.gsub!(/["']/){""}
end

def helper_revive_player(player)
	player.stats.hp = player.stats.mhp
end

def helper_show_stats(player_id,is_another = false)
	answer = [
		format(
			"%-40s%s",
			format(@loc['you']['has']['stats']['hp'], @players[player_id].stats.hp, @players[player_id].stats.mhp),
			format(@loc['you']['has']['stats']['mp'], @players[player_id].stats.mp, @players[player_id].stats.mmp)
		),
		format(
			"%-40s%s",
			format(@loc['you']['has']['stats']['atk'], @players[player_id].stats.atk),
			format(@loc['you']['has']['stats']['def'], @players[player_id].stats.def)
		),
		format(
			"%-40s%s",
			format(@loc['you']['has']['stats']['int'], @players[player_id].stats.int),
			format(@loc['you']['has']['stats']['dex'], @players[player_id].stats.dex)
		),
		format(@loc['you']['has']['stats']['crit_chance'], @players[player_id].stats.crit_chance),
		format(@loc['you']['has']['expeirience']['exp'], @players[player_id].expeirience.exp),
		format(@loc['you']['has']['expeirience']['message_count'], @players[player_id].expeirience.message_count)
	].join(@crlf)
	if @players[player_id].stats.hp <= 0
		[
			answer,
			respond_you_are_dead
		].join(@crlf)
	end
	answer
end

def helper_generate_page(href)
	open("./index.html", "w") do |html| 
		html.write "<!DOCTYPE html>"
		html.write "<head><title>Discord PVP Bot</title></head>"
		html.write "<body><h1>Discord PVP Bot</h1>"
		html.write "<a href=#{href}>Invite this bot</a>"
		html.write "</body>"
		html.write "</html>"
	end
end

def helper_sample_weapon(rarity)
	@weapons[ rarity ].sample
end

def helper_prepare_pvp(users)
	answer = @loc['bot']['prepare']['pvp']['caption']
	list = []
	users.each{|user|list.push user.name}
	player_list = list.join(", ")
	@prepare_pvp = PreparePvp.new(
		Time.now.to_i,
		users,
		[], [], []
	)
	[
		answer,
		player_list,
		"",
		format(
			@loc['bot']['prepare']['pvp']['use_commands'],
			Config::Bot.prefix,
			Config::Bot.prefix
		),
		format(
			@loc['bot']['prepare']['pvp']['time'],
			Config::Game.time_to_pvp
		)
	].join(@crlf)
end