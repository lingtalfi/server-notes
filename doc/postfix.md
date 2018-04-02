Postfix
=============
2018-04-02


Sources:

- https://poweruphosting.com/blog/install-configure-postfix-ubuntu/
- https://www.tutorialspoint.com/articles/install-and-configure-postfix-as-a-send-only-smtp-server-on-ubuntu
- https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-postfix-as-a-send-only-smtp-server-on-ubuntu-14-04
- https://www.opsview.com/resources/forums/basic-monitoring/how-do-i/changing-sender-address-using-postfix

In this tutorial, we install a send-only SMTP postfix server.
My main motivation for installing postfix is: not pay a third party service to send emails.

My server is ubuntu 16.04.


Prerequisites: check that a domain name is pointing to your server:


```bash
hostname
```


Install postfix
--------------------

```bash
sudo apt-get update
sudo apt install mailutils

# choose internet site
# then type the host, for instance ling-docs.com (should be one of your apache virtual hosts)
```


Configuring postfix
------------------

You have to configure the postfix to listen on the loopback interface.


```bash
sudo nano /etc/postfix/main.cf

mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = loopback-only



sudo systemctl restart postfix
```


Test the SMTP server
-----------------


```bash
echo "This is the body of the email" | mail -s "This is the subject line" lingtalfi@gmail.com
echo "This is the body of the email" | mail -s "This is the subject line" tlee4714@gmail.com
```



Forwarding
------------

Finally, we want to setup to perform email forwarding, so that these emails are sent to the root of the system to some other email address(es). To forward these emails, we need to configure the Postfix file as shown below.

```bash
sudo nano /etc/aliases

postmaster:    root
root:          your.name@somedomain.com


sudo newaliases
```


Now we can do this (not sure how usefult that is, but still...):

```bash
echo "This is the body of the email" | mail -s "This is the subject line" root
```


Change the name of the sender
------------------------------

```bash
sudo nano /etc/postfix/main.cf

# add the following line
sender_canonical_maps = hash:/etc/postfix/sender_canonical_maps
```

Then create the file:

```bash
/etc/postfix/sender_canonical_maps

# add the following line, now mails sent via user ling will have the from field set to ling@my_new_domain.com
ling ling@my_new_domain.com
```

Run the command

```bash
postmap hash:/etc/postfix/sender_canonical_maps
sudo systemctl restart postfix
```










Protect Your Domain from Spammers
-------------

This section is not finished yet...

(step 5) from  https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-postfix-as-a-send-only-smtp-server-on-ubuntu-14-04



https://www.digitalocean.com/community/tutorials/how-to-use-an-spf-record-to-prevent-spoofing-improve-e-mail-reliability




