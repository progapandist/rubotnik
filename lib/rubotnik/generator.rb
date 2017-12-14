require 'thor'
require 'thor/group'
require 'rubotnik'

class Rubotnik::Generator < Thor::Group
  include Thor::Actions
  desc 'Generate a new filesystem structure'

  def self.source_root
    File.dirname(__FILE__) + '/../../templates'
  end

  def create_file_structure
   copy_file 'config.ru', 'config.ru'
   copy_file 'Gemfile', 'Gemfile'
   copy_file '.env', '.env'
   copy_file 'puma.rb', 'config/puma.rb'
   copy_file 'Procfile', 'Procfile'
   copy_file 'commands.rb', 'bot/commands/commands.rb'
   copy_file 'location.rb', 'bot/commands/location.rb'
   copy_file 'ui_examples.rb', 'bot/commands/ui_examples.rb'
   copy_file 'bot.rb', 'bot/bot.rb'
   copy_file 'profile.rb', 'bot/profile.rb'
   copy_file '.gitignore', '.gitignore'
  end

  #
  # def create_git_files
  #   copy_file 'gitignore', '.gitignore'
  #   create_file 'images/.gitkeep'
  #   create_file 'text/.gitkeep'
  # end

end
