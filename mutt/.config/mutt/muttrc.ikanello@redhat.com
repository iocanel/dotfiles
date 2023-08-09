set imap_keepalive = 900
#set smtp_url = "smtps://smtp.gmail.com:465"
set move = no

set sendmail = "/usr/bin/msmtp -C /home/iocanel/.config/msmtp/config -a ikanello@redhat.com"
set use_from=yes
set realname="Ioannis Canellos"
set from=iocanel@redhat.com
set envelope_from=yes

set folder = "~/.mail/ikanello@redhat.com"
set spoolfile = "~/.mail/ikanello@redhat.com/Inbox"
set postponed = "~/.mail/ikanello@redhat.com/Drafts"
set record = "~/.mail/ikanello@redhat.com/'Sent Messages'"
set message_cachedir = "~/.mutt/cache/bodies"
set certificate_file = "~/.mutt/certificates"

mailboxes "ikanello@redhat.com" \
          +Inbox \
          +Drafts \
          +'Sent Messages' 
