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
		yaml_weapon = YAML.load(File.read([@weapons_data,'/',filename].join, "r"))
		rarity = filename.gsub(/\-[\d]+\.yml$/){""}
		case rarity
		when 'common','uncommon','rare','epic','legendary'
			case Config::Locale.current
			when :ru
				name = yaml_weapon.name.ru
			end

			weapon = Weapon.new(
				Unique.new(
					yaml_weapon.unique.id
				),
				Equipable.new(
					yaml_weapon.type,
					yaml_weapon.cost,
					false
				),
				name,
				yaml_weapon.atk,
				yaml_weapon.inc_crit_chance,
				yaml_weapon.inc_crit_atk
			)
			@weapons[ rarity.to_sym ].push weapon
		else
			@weapons[ :common ].push weapon
		end
	}
	puts "Setup weapons: %d weapon(s) registered" % @weapons.size
end