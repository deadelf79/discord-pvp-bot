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
Expeirience = Struct.new(
	:exp,
	:message_count
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
	:expeirience,
	:gold
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
	:last_enemy_killer,
	:last_boss_killer
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
Unique = Struct.new(
	:id
)
Equipable = Struct.new(
	:type, # for weapons: sword, axe, spear or else; for armor: head, body, arms
	:cost,
	:equipped
)
Weapon = Struct.new(
	:unique,
	:equipable,
	:name,
	:atk,
	:inc_crit_chance,
	:inc_crit_atk
)
Armor = Struct.new(
	:unique,
	:equipable,
	:name,
	:def
)
Item = Struct.new(
	:unique,
	:name
)
Inventory = Struct.new(
	:weapons,
	:armors,
	:items,
	:gold
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