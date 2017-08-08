require 'thor'
require 'thor/group'
require 'rubotnik'

class Rubotnik::Generator < Thor::Group
  include Thor::Actions
  desc 'Generate a new filesystem structure'

  def self.source_root
    File.dirname(__FILE__) + '/../../templates'
  end

  def create_config_file
   copy_file 'config.ru', 'config.ru'
  end

  def create_bot_directory
    empty_directory 'bot'
  end

  def create_commands_directory
    empty_directory 'bot/commands'
  end

  def create_commands_module
    copy_file 'commands.rb', 'bot/commands/commands.rb'
  end

  #
  # def create_git_files
  #   copy_file 'gitignore', '.gitignore'
  #   create_file 'images/.gitkeep'
  #   create_file 'text/.gitkeep'
  # end

end
