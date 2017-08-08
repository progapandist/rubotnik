require 'thor'
require 'rubotnik'

module Rubotnik
  class CLI < Thor

    desc "new", "Generate file structure"
    def new(path = nil)
      generator = Rubotnik::Generator.new
      generator.destination_root = path
      generator.invoke_all
    end

  end
end
