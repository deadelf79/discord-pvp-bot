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
def setup_items
	Dir.entries(@items_data).each { |filename|
		next if ['.','..'].include? filename
		next unless filename =~ /\.yml$/
		path = [ @items_data, filename ].join("/")
		yaml_item = YAML.load( open( path, 'r' ) )
		rarity = filename.gsub(/\-[\d]+\.yml$/){""}
		case rarity
		when 'common','uncommon','rare','epic','legendary'
			case Config::Locale.current
			when :ru
				name = yaml_item['item']['name']['ru']
			end

			item = Weapon.new(
				Unique.new(
					yaml_item['item']['unique']['id']
				),
				Equipable.new(
					yaml_item['item']['type'],
					yaml_item['item']['cost'],
					false
				),
				name
			)
			@items[ rarity.to_sym ].push item
		else
			@items[ common ].push item
		end
	}
	sum = 	@items[ :common ].size +
			@items[ :uncommon ].size +
			@items[ :rare ].size +
			@items[ :epic ].size +
			@items[ :legendary ].size
	puts "Setup items: %d item(s) registered" % sum
end