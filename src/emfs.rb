#!/usr/bin/env ruby

require 'rfusefs'

class EMFS
	def contents(path)
		`ruby ./emfs-ls.rb`.split("\n")
	end

	def file?(path)
		true
	end

	def read_file(path)
		`ruby ./emfs-get.rb #{File.basename(path)} /dev/stdout`
	end
end

FuseFS.main() { |options| EMFS.new }
