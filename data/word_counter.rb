# data/word_counter.rb

# variables
@word_counter = {}

# functions
def load_counters
	setup_counters if @word_counter.keys.empty?
end

def save_counters

end

def setup_counters
	add_counter('мейкер')
	add_counter('фап')
	add_counter('сиськи')
end

def show_counters
	answer = []
	# TODO: сформировать список самых используемых слов
	@word_counter.each_pair do |key,value|
		answer.push format(@loc['bot']['counters']['item'],key,value)
	end
	answer.join(@crlf)
end

def add_word(word)
	@word_counter[word] += 1
end

def add_counter(word,usage)
	@word_counter[word] = 0
end