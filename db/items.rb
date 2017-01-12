# db/items.rb

#variables
@items = {
	common: [],
	uncommon: [],
	rare: [],
	epic: [],
	legendary: []
}
@items_data = './db/items'

# functions
def setup_weapons
	Dir.entries(@items_data).each { |filename|
		next if ['.','..'].include? filename
		next unless filename =~ /\.yml$/
		yaml_item = YAML.load(File.read([@items_data,'/',filename].join, "r"))
		rarity = filename.gsub(/\-[\d]+\.yml$/){""}
		case rarity
		when 'common','uncommon','rare','epic','legendary'
			case Config::Locale.current
			when :ru
				name = yaml_item.name.ru
			end

			item = Weapon.new(
				Unique.new(
					yaml_item.unique.id
				),
				Equipable.new(
					yaml_item.type,
					yaml_item.cost,
					false
				),
				name
			)
			@items[ rarity.to_sym ].push item
		else
			@items[ common ].push item
		end
	}
	puts "Setup items: %d item(s) registered" % @items.size
end