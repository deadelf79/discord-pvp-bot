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
			DeathCounter.new(0,0,0,:noone,0,0),
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
						helper_calc_player_crit_atk( players, skill, fpcost, mpcost ),
						skill.mpeff * mpcost * @players[player].stats.int * 1.5 + skill.mpeff * rand(5)
					)
				else
					effect = Damage.new(
						helper_calc_player_atk( players, skill, fpcost, mpcost ),
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