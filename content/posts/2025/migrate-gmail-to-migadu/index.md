---
title: "Migrating from Gmail to Migadu"
date: 2025-02-28T13:31:28+07:00
tags:
  - Gmail
  - Migadu
---

I first joined Gmail back in 2003 when it was in an invite-only beta.
When Google for Work became available, I moved mroach.com there to get away
from my old Mailgun -> public Gmail forwarding which broke spam filtering.

Times have changed and I've had about enough of Google in my life and it's
time to make a move.
On Mastodon and Reddit I had seen [Migadu] mentioned several times as a simple,
affordable, no-nonsense email hosting provider. I took the plunge and setup an account there.

[Migadu]: https://migadu.com/

Initial Setup
-------------

The Migadu setup process was straight forward: sign-up, make DNS changes to your domain, get started.
Migadu won't mark your account as active until required DNS changes have been made.
Once the DNS records are updated, your Gmail inbox is stable as it won't receive new email.


Google Takeout
--------------

This is optional, but I wanted a snapshot of my inbox before making any changes.
Google Takeout allows you to to download a zip file of your whole inbox in `.mbox` format.

Once requested, it took me about 15 minutes to get the download link. I saved
this on my archive file server for safe keeping.

* Public Gmail: https://takeout.google.com/settings/takeout
* Google for Work: https://admin.google.com/ac/customertakeout

Pre-Migration
-------------
{{< figure
    src="images/gmail-categories.png"
    alt="Header in Gmail showing the default categories of Updates, Social, etc"
>}}

One thing Gmail is great at is automatically categorising emails into groups
like _Updates_, _Social_, _Forums_, and _Promotions_.
The problem is that these are not exposed in IMAP as folders, so a tool like
[`imapsync`](https://imapsync.lamiral.info/) ends up putting everything into your Inbox.

To take advantage of the work Gmail did to categorise my mail, I manually created
labels with similar names e.g. _Updates2_, _Social2_, etc.
Then, I "moved" all the messages from Gmail's categories to my new labels/folders.

Now when running the migration those emails will end up in a folder rather than in the inbox.

### Gmail IMAP Password

Logging-in to Gmail with IMAP does not work with your Google username and password
if you have 2FA switched on or other account protections. You have to create
an IMAP credential. See: https://myaccount.google.com/apppasswords

imapsync
--------

One of the most helpful flags is `--gmail1` which tells `imapsync` that Host1
is Gmail, and it activates a bunch of sane default settings for Gmail
and does helpful stuff like automatic folder mapping.
The [imapsync Gmail FAQ](https://imapsync.lamiral.info/FAQ.d/FAQ.Gmail.txt) has all the details.

One of its most important features though is helping to avoid message duplication.

Gmail doesn't have folders, only labels. When you "move" an email from your inbox
to a label, it just adds the label and hides it from your inbox. When you
access mail over IMAP, labels appear as folders and a message with multiple
labels will appear in every folder. The `--gmail1` option activates logic to deal with this.

Here's an excerpt from the FAQ that explains the situation well.
(Using the `--gmail1` flag activates `--skipcrossduplicates` and `--folderlast  "[Gmail]/All Mail"`)

> `--skipcrossduplicates` is optional but it can save Gigabytes of hard
disk memory. Within imap protocol, Gmail presents Gmail labels as
folders, so a message labelled "Work" "ProjectX" "Urgent" ends up in
three different imap folders "Work" "ProjectX" and "Urgent" after an
imap sync. Option `--skipcrossduplicates` prevent this behavior.
>
> An issue with `--skipcrossduplicates` is that the first label synced by
imapsync goes to its corresponding folder but other labels are then
ignored. You can choose what labels have priority by using the
`--folderfirst` option. For example, `--folderfirst "Work"` will sync
messages labelled "Work" before messages labelled "CanWait" or
"Urgent". By default imapsync syncs folders (Gmail labels) using the
classical alphanumeric order.
>
> Option `--folderlast "CanWait"` will sync only messages that only have
the label CanWait.
>
> Option `--folderlast "[Gmail]/All Mail"`, in conjunction with option
--skipcrossduplicates will only put in "[Gmail]/All Mail" the messages
that are not labelled at all.`

I wanted my _Inbox_ to remain as clean as possible. I probably could have used
`--folderlast INBOX`, but wasn't sure how that would play with `--folderlast "Gmail/All Mail`
so instead I used `--folderfirst` for each label I had in my Gmail.

```bash
docker run --name imapsync --rm gilleslamiral/imapsync imapsync \
  --dry \
  --host1 imap.gmail.com --user1 my_username@gmail.com --gmail1 --authmech1 LOGIN --ssl1 --sep1 . --password1 'GMAIL IMAP PASSWORD' \
  --prefix1 "" \
  --folderfirst "Travel Docs" --folderfirst Updates2 --folderfirst Promotions2 --folderfirst Forums2 --folderfirst Inbox \
  --f1f2 "[Gmail]/All Mail=Archive" --f1f2 "Updates2=Updates" --f1f2 "Promotions2=Promotions" --f1f2 "Forums2=Forums" \
  --host2 imap.migadu.com --user2 my_migadu_user@whatever.com --ssl2 --password2 'MIGADU PASSWORD'
```

Other interesting flags:

* `--sep1 .` Uses `.` as a separator/join character for naming folders that were nested
* `--f1f2` Remaps/renames folders during the migration

The `--dry` option does a dry run, providing a report of what the sync would do.
When you're happy with the results, remove it and run it.

Result
------

Gmail reported via IMAP that I had about 170,000 emails. Thanks to de-duplication
in `imapsync`, only 57,000 of those were actually transferred to Migadu.

So the total transfer time was about 8 hours. Not bad.

```
Transfer started on                     : Friday 28 February 2025-02-28 09:28:57 +0000 UTC
Transfer ended on                       : Friday 28 February 2025-02-28 17:24:06 +0000 UTC
Transfer time                           : 28509.9 sec
Folders synced                          : 16/16 synced
Folders deleted on host2                : 0
Messages transferred                    : 57313
Messages skipped                        : 110940
Messages found duplicate on host1       : 26
Messages found duplicate on host2       : 0
Messages found crossduplicate on host2  : 109851
Messages void (noheader) on host1       : 0
Messages void (noheader) on host2       : 1
Messages found in host1 not in host2    : 0 messages
Messages found in host2 not in host1    : 7 messages
Messages deleted on host1               : 0
Messages deleted on host2               : 0
Total bytes transferred                 : 4195475015 (3.907 GiB)
Total bytes skipped                     : 7997151925 (7.448 GiB)
Message rate                            : 2.0 messages/s
Average bandwidth rate                  : 143.7 KiB/s
Reconnections to host1                  : 0
Reconnections to host2                  : 0
Memory consumption at the end           : 391.6 MiB (*time 3101.3 MiB*h) (started with 161.2 MiB)
Load end is                             : 0.24 0.25 0.22 3/1533 on 6 cores
CPU time and %cpu                       : 1219.3 sec 4.3 %cpu 0.7 %allcpus
Biggest message transferred             : 31462465 bytes (30.005 MiB)
Memory/biggest message ratio            : 13.1
Start difference host2 - host1          : -167203 messages, -12169973659 bytes (-11.334 GiB)
Final difference host2 - host1          : -109883 messages, -7974007281 bytes (-7.426 GiB)
The sync looks good, all 58117 identified messages in host1 are on host2.
```
