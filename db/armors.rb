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
		path = [ @armors_data, filename ].join("/")
		yaml_armor = YAML.load( open( path, 'r' ) )
		rarity = filename.gsub(/\-[\d]+\.yml$/){""}
		case rarity
		when 'common','uncommon','rare','epic','legendary'
			case Config::Locale.current
			when :ru
				name = yaml_armor['armor']['name']['ru']
			end

			armor = Weapon.new(
				Unique.new(
					yaml_armor['armor']['unique']['id']
				),
				Equipable.new(
					yaml_armor['armor']['type'],
					yaml_armor['armor']['cost'],
					false
				),
				name,
				yaml_armor['armor']['def']
			)
			@armors[ rarity.to_sym ].push armor
		else
			@armors[ :common ].push armor
		end
	}
	sum = 	@armors[ :common ].size +
			@armors[ :uncommon ].size +
			@armors[ :rare ].size +
			@armors[ :epic ].size +
			@armors[ :legendary ].size
	puts "Setup armors: %d armor(s) registered" % sum
end