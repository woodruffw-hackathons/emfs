#!/usr/bin/env ruby

require 'net/imap'
require 'net/smtp'
require 'base64'

file = ARGV.shift or abort("Usage: emfs-mv <file>")

if File.file?(file)
	File.open(file, "r") do |f|
		data = "Subject: #{File.basename(file)}\r\n"
		data += Base64.encode64(f.read)

		smtp = Net::SMTP.new(ENV["EMFS_SMTP_SERVER"], 25)
		smtp.enable_starttls_auto

		smtp.start("emfs", ENV["EMFS_IMAP_USER"], ENV["EMFS_IMAP_PASS"], :login)

		smtp.send_message(data, ENV["EMFS_EMAIL_ADDR"], ENV["EMFS_EMAIL_ADDR"])
		
		smtp.finish
	end

	imap = Net::IMAP.new(ENV["EMFS_IMAP_SERVER"], {:ssl => true})
	imap.login(ENV["EMFS_IMAP_USER"], ENV["EMFS_IMAP_PASS"])
	imap.select("INBOX")

	uid = imap.search("ALL").max
	imap.copy(uid, "EMFS")
	imap.store(uid, "+FLAGS", [:Deleted])
	imap.expunge

	imap.logout
	imap.disconnect
else
	puts "EMFS: #{File.basename(file)}: no such file."
end
