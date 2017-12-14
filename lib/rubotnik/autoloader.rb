module Rubotnik
  module Autoloader
    def self.root
      Dir.pwd
    end

    def self.load(folder)
      Dir[
        File.expand_path(
          File.join(root, folder)
        ) + "/**/*.rb"
      ].each do |file|
        require_relative file
      end
    end
  end
end
