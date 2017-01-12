# db/armors.rb

#variables
@armors = {
	common: [],
	uncommon: [],
	rare: [],
	epic: [],
	legendary: []
}
@armors_data = './db/armors'

# functions
def setup_armors
	Dir.entries(@armors_data).each { |filename|
		next if ['.','..'].include? filename
		next unless filename =~ /\.yml$/
		yaml_armor = YAML.load(File.read([@armors_data,'/',filename].join, "r"))
		rarity = filename.gsub(/\-[\d]+\.yml$/){""}
		case rarity
		when 'common','uncommon','rare','epic','legendary'
			case Config::Locale.current
			when :ru
				name = yaml_armor.name.ru
			end

			armor = Weapon.new(
				Unique.new(
					yaml_armor.unique.id
				),
				Equipable.new(
					yaml_armor.type,
					yaml_armor.cost,
					false
				),
				name,
				yaml_armor.def
			)
			@armors[ rarity.to_sym ].push armor
		else
			@armors[ :common ].push armor
		end
	}
	puts "Setup armors: %d armor(s) registered" % @armors.size
end