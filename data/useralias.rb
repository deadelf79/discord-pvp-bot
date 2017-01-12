# data/useralias.rb

# variables
@useraliases = {}
@aliases_data = "./data/aliases"

# functions
def setup_user_aliases
	Dir.entries(@aliases_data).each { |filename|
		next if ['.','..'].include? filename
		next unless filename =~ /\.txt$/
		name = ""
		open([@aliases_data,'/',filename].join, "r"){|f|
			name = f.readlines[0]
		}
		id = filename.gsub(/\.txt$/){""}
		@useraliases[ id.to_i ] = name
	}
	puts "Setup user aliases: %d alias(es) registered" % @useraliases.size
end

def user_alias(event)
	id = event.user.id
	if @useraliases.keys.include?(id)
		return @useraliases[id]
	else
		return "#{event.user.mention}"
	end
end

def save_new_alias(id,name)
	@useraliases[ id.to_i ] = name.trim
	open([@user_data,'/',id,'.txt'].join, "w") { |io| io.write name.trim }
end