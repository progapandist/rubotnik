require 'thor'
require 'rubotnik'

module Rubotnik
  class CLI < Thor

    desc "new", "Generate bot project at PATH"
    def new(path = nil)
      generator = Rubotnik::Generator.new
      generator.destination_root = path
      generator.invoke_all
    end

  end
end
