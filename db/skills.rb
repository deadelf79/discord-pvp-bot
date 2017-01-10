# db/skills.rb

# variables
@skills_dir = "./db/skills"
@skills = {}

# functions
def load_skills
	Dir.entries(@skills_dir).each do |file|
		next if ['.','..'].include? file
		next unless file =~ /\.yml$/
		path = [ @skills_dir, file ].join("/")
		sf = YAML.load( File.read( path ) )
		skill = Skill.new(
			sf['mpcost'],
			sf['fpcost'],
			sf['target'],
			sf['hpeff'],
			sf['mpeff']
		)
		@skills[sf['name']] = skill
	end
end