Fresh vps box, new install from scratch to https webserver
===============================

https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-16-04
https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mysql-php-lamp-stack-on-ubuntu-16-04
https://www.digitalocean.com/community/tutorials/how-to-secure-apache-with-let-s-encrypt-on-ubuntu-16-04
https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-on-ubuntu-16-04
https://github.com/lingtalfi/server-notes/blob/master/doc/deploy-website.md



- Step One — Root Login
- Step Two — Create a New User
- Step Three — Root Privileges
- Step Four — Add Public Key Authentication
- Step Five — Disable Password Authentication 
- Step Six — Test Log In
- Step Seven — Set Up a Basic Firewall
- Step Eight — Install Apache and Allow in Firewall
- Step Nine — Install MySQL
- Step Ten - Install PHP
- Step Eleven - Install the Let's Encrypt Client
- Step Twelve - Set Up the SSL Certificate
- Step Thirteen - Set Up Auto Renewal
- Step Fourteen - Install phpMyAdmin
- Step Fifteen - Go further





Step One — Root Login
-----------------------

ssh root@your_server_ip


As root:

```bash
root@host:/# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 16.04.2 LTS
Release:	16.04
Codename:	xenial
```




Step Two — Create a New User
---------------
```bash
adduser ling
```


Step Three — Root Privileges
-------------------------------

### add ling to the sudo group
```bash
usermod -aG sudo ling
```




Step Four — Add Public Key Authentication
--------------------------------

### On local machine
```bash
ssh-keygen
```

Enter file in which to save the key (/Users/myuser/.ssh/id_rsa): /Users/myuser/.ssh/vps_rsa

It creates the following in /Users/myuser/.ssh:

- vps_rsa   
- vps_rsa.pub

```bash
ssh-copy-id -i /Users/myuser/.ssh/vps_rsa.pub ling@your_server_ip
```




Step Five — Disable Password Authentication 
-----------------------------
```bash
sudo nano /etc/ssh/sshd_config
```


```txt
PasswordAuthentication no
PubkeyAuthentication yes
ChallengeResponseAuthentication no
```

```bash
sudo systemctl reload sshd
```


Step Six — Test Log In
-------------------------
```bash
ssh ling@your_server_ip
```

Add this to your local machine /Users/myuser/.ssh/config:

```txt


Host vps
    HostName your_server_ip
    Port 22
    User ling
    IdentityFile ~/.ssh/vps_rsa

```

Now you can connect with:

```bash
ssh vps
```



Step Seven — Set Up a Basic Firewall
------------------------
### see registered profiles
```bash
sudo ufw app list
sudo ufw allow OpenSSH
sudo ufw enable
sudo ufw status
```

More info: https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands



Step Eight — Install Apache and Allow in Firewall
-------------------------------
```bash
sudo apt-get update
sudo apt-get install apache2
```

### restart
```bash
sudo systemctl restart apache2
```

```bash
sudo ufw app list
sudo ufw app info "Apache Full"
sudo ufw allow in "Apache Full"
```


Step Nine — Install MySQL
---------------------------
```bash
sudo apt-get install mysql-server
```


Step Ten - Install PHP
-------------------------
```bash
sudo apt-get install php libapache2-mod-php php-mcrypt php-mysql
```

```bash
sudo nano /etc/apache2/mods-enabled/dir.conf
```

```txt
<IfModule mod_dir.c>
    DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>
```


```bash
sudo systemctl restart apache2
sudo systemctl status apache2
```


### Php modules

```bash
apt-cache search php- | less
apt-cache show package_name
sudo apt-get install package_name package_name2 ...
```

### list installed modules
https://www.liquidweb.com/kb/how-to-list-compiled-php-modules-from-command-line/

```bash
php -m 
php -m | grep -i mongo
```



### Testing php

```bash
sudo nano /var/www/html/info.php
```

```php
<?php
phpinfo();
```


```bash
sudo rm /var/www/html/info.php
```





Step Eleven - Install the Let's Encrypt Client
----------------------------------
```bash
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install python-certbot-apache
```



Step Twelve - Set Up the SSL Certificate
------------------------------------------


```bash
sudo certbot --apache -d example.com
```

This will generate the following:

```txt
/etc/letsencrypt/live
└── example.com
    ├── cert.pem -> ../../archive/example.com/cert1.pem
    ├── chain.pem -> ../../archive/example.com/chain1.pem
    ├── fullchain.pem -> ../../archive/example.com/fullchain1.pem
    ├── privkey.pem -> ../../archive/example.com/privkey1.pem
    └── README
```


```txt

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at
   /etc/letsencrypt/live/example.com/fullchain.pem. Your cert will
   expire on 2017-09-24. To obtain a new or tweaked version of this
   certificate in the future, simply run certbot again with the
   "certonly" option. To non-interactively renew *all* of your
   certificates, run "certbot renew"
 - Your account credentials have been saved in your Certbot
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le


```


Step Thirteen - Set Up Auto Renewal
------------------------------


```bash
sudo crontab -e
```

Every day at 3:15am

```txt
15 3 * * * /usr/bin/certbot renew --quiet
```



Step Fourteen - Install phpMyAdmin
-------------------------

```bash
sudo apt-get install phpmyadmin php-mbstring php-gettext
```


### Enabling php extensions

```bash
sudo phpenmod mcrypt
sudo phpenmod mbstring
sudo systemctl restart apache2
```


### Configure apache

```bash
sudo nano /etc/apache2/apache2.conf
```

```txt
Include /etc/phpmyadmin/apache.conf
sudo systemctl restart apache2
```

### Change phpMyAdmin access url

```bash
sudo nano /etc/phpmyadmin/apache.conf
```

```txt
Alias /my_phpmyadmin_uri /usr/share/phpmyadmin
sudo systemctl restart apache2
```



Step Fifteen - Go further
----------------
https://github.com/lingtalfi/server-notes/blob/master/doc/deploy-website.md

### Transfer local dir to remote server

scp -rp sourceDirName username@server:destDirName
scp -rp cards vps:websites/leaderfit/leaderfit-images


### Apache redirect all non https traffic to https

Notice the last three configuration lines

```txt
<VirtualHost *:80>
        # The ServerName directive sets the request scheme, hostname and port that
        # the server uses to identify itself. This is used when creating
        # redirection URLs. In the context of virtual hosts, the ServerName
        # specifies what hostname must appear in the request's Host: header to
        # match this virtual host. For the default virtual host (this file) this
        # value is not decisive as it is used as a last resort host regardless.
        # However, you must set it for any further virtual host explicitly.
        #ServerName www.example.com

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html

        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
        # error, crit, alert, emerg.
        # It is also possible to configure the loglevel for particular
        # modules, e.g.
        #LogLevel info ssl:warn

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        # For most configuration files from conf-available/, which are
        # enabled or disabled at a global level, it is possible to
        # include a line for only one particular virtual host. For example the
        # following line enables the CGI configuration for this host only
        # after it has been globally disabled with "a2disconf".
        #Include conf-available/serve-cgi-bin.conf
        RewriteEngine on
        RewriteCond %{SERVER_NAME} =example.com
        RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>
```





