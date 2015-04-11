#!/usr/bin/env ruby

require 'net/imap'

file = ARGV.shift or abort("Usage: emfs-rm <file>")

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
			imap.store(uid, "+FLAGS", [:Deleted])
			imap.expunge
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
