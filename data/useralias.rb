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
	puts event.class
	if event.is_a? Discordrb::Events
		id = event.user.id
		if @useraliases.keys.include?(id)
			return @useraliases[id]
		else
			return "#{event.user.mention}"
		end
	elsif event.is_a? Discordrb::User
		id = event.id
		if @useraliases.keys.include?(id)
			puts @useraliases[id]
			return @useraliases[id]
		else
			return "#{event.mention}"
		end
	else
		puts "user_alias: 'event' is not a User or Event"
		return ""
	end
end

def save_new_alias(id,name)
	@useraliases[ id.to_i ] = name.trim
	open([@user_data,'/',id,'.txt'].join, "w") { |io| io.write name.trim }
end