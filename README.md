EMFS
=====

Leveraging your email account(s) as cloud storage.

### What is EMFS?

EMFS is a filesystem, meaning that it can read, write, delete, and index files
as requested by the user. Unlike a normal filesystem, EMFS is not (directly)
backed by a physical storage device. Instead, EMFS is backed by a user's email
account, with individual files steganographically encoded in mailbox messages
for later retrieval.

### Why?

Cloud storage services are limited, and can come at a premium. EMFS allows
users to treat their run-of-the-mill email accounts as cloud storage accounts,
taking advantage of high email storage caps to steganographically store personal
files.

### How does it work?

EMFS relies on the Simple Mail Transfer Protocol (SMTP) for write operations,
and the Internet Message Access Protocol (IMAP) for read/index operations.

When storing a new file, EMFS base64 encodes its contents, attaches a subject
containing the filename, and sends the encoded email off to the user's inbox.
An IMAP connection is then established, which refiles the new email-file under
*EMFS* label and deletes the inbox copy. As a result, using EMFS will not
clobber or clog up the normal inbox.

When retrieving a file, EMFS uses an IMAP connection to determine the UID of the
message whose subject matches the filename (case sensitive). Once the UID is
determined, the body of that message is fetched and base64 decoded for saving on
a local filesystem.

Listing/indexing in EMFS simply involves retrieving all message UIDs in the *EMFS*
label and performing lookups on them for their subjects.

Removing files in EMFS, like the other IMAP actions, is a matter of associating
a subject line with a message UID. Once that association is made, the message in
question is marked with the `\Deleted` flag and expunged.
