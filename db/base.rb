# db/base.rb

Stats = Struct.new(
	:hp, :mhp,
	:mp, :mmp,
	:fp, :mfp,
	:atk, :def,
	:int, :dex,
	:crit_chance,
	:make_crit,
	:death_time,
	:death_counter,
	:pvp_counter
)
Expirience = Struct.new(
	:exp,
	:formula
)
EnemyStats = Struct.new(
	:hp, :mhp,
	:mp, :mmp,
	:fp, :mfp,
	:loots
)
Player = Struct.new(
	:stats,
	:skills,
	:inventory,
	:pvp_timer,
	:expirience
)
Enemy = Struct.new(
	:enemy_stats
)
Boss = Struct.new(
	:enemy_stats
)
DeathCounter = Struct.new(
	:by_player,
	:by_enemy,
	:by_boss,
	:last_killer,
	:last_player_killer,
	:last_enemy_killer
)
PVPCounter = Struct.new(
	:w_player,
	:w_enemy,
	:w_boss,
	:win_count,
	:lose_count
)
PVPTimer = Struct.new(
	:atk_time,
	:delay
)
Skill = Struct.new(
	:mpcost, :fpcost,
	:target,
	:hpeff, :mpeff
)
Equipable = Struct.new(
	:type,
	:cost,
	:dur, :mdur,
	:equipped
)
Weapon = Struct.new(
	:equipable,
	:atk
)
Armor = Struct.new(
	:equipable,
	:def
)
Item = Struct.new(
	:cost
)
Inventory = Struct.new(
	:weapons,
	:armors,
	:items
)
Loot = Struct.new(
	:chance,
	:item,
	:min_count,
	:max_count
)
Damage = Struct.new(
	:hp, :mp
)
RegisteredPVP = Struct.new(
	:timecode,
	:users
)