set imap_keepalive = 900
#set smtp_url = "smtps://smtp.gmail.com:465"
set move = no

set sendmail = "/usr/bin/msmtp -C /home/iocanel/.config/msmtp/config -a iocanel@gmail.com"
set use_from=yes
set realname="Ioannis Canellos"
set from=iocanel@gmail.com
set envelope_from=yes
set folder = "~/.mail/iocanel@gmail.com"
set spoolfile = "~/.mail/iocanel@gmail.com/Inbox"
set postponed = "~/.mail/iocanel@gmail.com/Drafts"
set record = "~/.mail/iocanel@gmail.com/'Sent Messages'"
set message_cachedir = "~/.mutt/cache/bodies"
set certificate_file = "~/.mutt/certificates"

mailboxes "iocanel@gmail.com" \
          +Inbox \
          +Drafts \
          +'Sent Messages' 
