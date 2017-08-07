require 'thor'
require 'rubotnik'

module Rubotnik
  class CLI < Thor
    desc "test WORD", "Echos argument to console"
    def test(*word)
      puts word.join(' ')
    end

    desc "generate", "Generate file structure"
    def generate
      generator = Rubotnik::Generator.new
      generator.destination_root = '~/tmp/test'
      generator.invoke_all
    end
  end
end
