# data/useralias.rb

@useraliases = {
	238398268583837696 => 'Эльф',
	213903398842531842 => 'Стрелок',
	261903512756158464 => 'Стрелок',
	239448647207616512 => 'Бот-Стрелок',
	238673924383178752 => 'Демий',
	250272229202460672 => 'Луар',
	238048345715769345 => 'Сосед',
	248833431239262209 => 'Юриоль',
	238641376806436866 => 'Дескард',
	238366119763640321 => 'Липтон',
	169947096768577536 => 'Волк',
	154973127867236352 => 'Фокс',
	240166613351923712 => 'Пётр',
	170654095265234944 => 'Рен'
}

def user_alias(event)
	id = event.user.id
	if @useraliases.keys.include?(id)
		return @useraliases[id]
	else
		return "#{event.user.mention}"
	end
end