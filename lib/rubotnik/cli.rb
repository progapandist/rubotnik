require 'thor'
module Rubotnik
  class CLI < Thor
    desc "test WORD", "Echos argument to console"
    def test(word)
      puts word
    end
  end
end
