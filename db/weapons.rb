# db/weapons.rb

#variables
@weapons = {
	common: [],
	uncommon: [],
	rare: [],
	epic: [],
	legendary: []
}
@weapons_data = './db/weapons'

# functions
def setup_weapons
	Dir.entries(@weapons_data).each { |filename|
		next if ['.','..'].include? filename
		next unless filename =~ /\.yml$/
		path = [ @weapons_data, filename ].join("/")
		yaml_weapon = YAML.load( open( path, 'r' ) )
		rarity = filename.gsub(/\-[\d]+\.yml$/){""}
		case rarity
		when 'common','uncommon','rare','epic','legendary'
			case Config::Locale.current
			when :ru
				name = yaml_weapon['weapon']['name']['ru']
			end

			weapon = Weapon.new(
				Unique.new(
					yaml_weapon['weapon']['unique']['id']
				),
				Equipable.new(
					yaml_weapon['weapon']['type'],
					yaml_weapon['weapon']['cost'],
					false
				),
				name,
				yaml_weapon['weapon']['atk'],
				yaml_weapon['weapon']['inc_crit_chance'],
				yaml_weapon['weapon']['inc_crit_atk']
			)
			@weapons[ rarity.to_sym ].push weapon
		else
			@weapons[ :common ].push weapon
		end
	}
	sum = 	@weapons[ :common ].size +
			@weapons[ :uncommon ].size +
			@weapons[ :rare ].size +
			@weapons[ :epic ].size +
			@weapons[ :legendary ].size
	puts "Setup weapons: %d weapon(s) registered" % sum
end