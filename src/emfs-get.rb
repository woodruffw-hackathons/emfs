#!/usr/bin/env ruby

require 'net/imap'
require 'base64'

file = ARGV.shift or abort("Usage: emfs-get <file> [destination]")
dest = ARGV.shift or file
file = File.basename(file)

imap = Net::IMAP.new(ENV["EMFS_IMAP_SERVER"], {:ssl => true})
imap.login(ENV["EMFS_IMAP_USER"], ENV["EMFS_IMAP_PASS"])
imap.select("EMFS")

size = imap.search('ALL').size
imap.store(1..size, "+FLAGS", [:Seen])
data = imap.fetch(1..size, "BODY[HEADER.FIELDS (SUBJECT)]")
uid = 0
found = false

if data
	data.each do |subj|
		subj_line = subj.attr.values[0].sub(/Subject: /, '').chomp('')
		uid += 1

		if subj_line == file
			File.open(dest, "w") do |f|
				decoded = Base64.decode64(imap.fetch(uid, "BODY[TEXT]")[0].attr.values[0])
				f.write(decoded)
			end
			found = true
			break
		end
	end

	if !found
		puts "EMFS: #{file}: not found."
	end
else
	puts "EMFS: No files."
end

imap.logout
imap.disconnect
