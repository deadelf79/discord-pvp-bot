# data/useralias.rb

# variables
@useraliases = {}
@aliasesdata = "./data/aliases"

# functions
def setup_user_aliases
	Dir.entries(@user_data).each { |filename|
		next if ['.','..'].include? filename
		next unless filename =~ /\.txt$/
		name = ""
		open([@user_data,'/',filename].join, "rb"){|f|
			name = f.readlines[0]
		}
		id = filename.gsub(/\.txt$/){""}
		@useraliases[ id.to_i ] = name
	}
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