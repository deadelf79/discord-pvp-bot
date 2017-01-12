# db/armors.rb

#variables
@armors = {
	common: [],
	uncommon: [],
	rare: [],
	epic: [],
	legendary: []
}

# functions
		next if ['.','..'].include? filename
		next unless filename =~ /\.yml$/
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
		else
		end
	}
end
