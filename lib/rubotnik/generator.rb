require 'thor'
require 'thor/group'
require 'rubotnik'

class Rubotnik::Generator < Thor::Group
  include Thor::Actions
  desc 'Generate a new filesystem structure'

  def self.source_root
    File.dirname(__FILE__) + '/../../templates'
  end

  # def create_config_file
  #   copy_file 'config.yml', 'config/mygem.yml'
  # end
  #
  # def create_git_files
  #   copy_file 'gitignore', '.gitignore'
  #   create_file 'images/.gitkeep'
  #   create_file 'text/.gitkeep'
  # end

  def create_output_directory
    empty_directory 'output'
  end
end
