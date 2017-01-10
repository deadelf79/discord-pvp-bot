# data/bot_dyn.rb

# variables
@time_between_greetings = 600
@timecode_dir = "./data/bot_dyn"
@timecode_filename = "greetings_timecode"

# functions
def save_greetings_timecode
	timecode = Time.now.to_i
	open([@timecode_dir,'/',@timecode_filename].join, "w") { |io| io.write(timecode) }
end

def load_greetings_timecode
	file = open([@timecode_dir,'/',@timecode_filename].join, "r")
	file.readlines[0].to_i
end

def check_greetings_timecode
	timecode = Time.now.to_i
	last_timecode = load_greetings_timecode
	return true if (timecode - last_timecode).abs > @time_between_greetings
	false
end