#!/usr/bin/env ruby

require 'net/imap'

imap = Net::IMAP.new(ENV["EMFS_IMAP_SERVER"], {:ssl => true})
imap.login(ENV["EMFS_IMAP_USER"], ENV["EMFS_IMAP_PASS"])
imap.select("EMFS")

size = imap.search('ALL').size
imap.store(1..size, "+FLAGS", [:Seen])
data = imap.fetch(1..size, "BODY[HEADER.FIELDS (SUBJECT)]")

if data
	data.each do |subj|
		puts subj.attr.values[0].sub(/Subject: /, '').chomp('')
	end
end

imap.logout
imap.disconnect

exit 0
