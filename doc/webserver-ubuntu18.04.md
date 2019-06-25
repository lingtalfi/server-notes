Installation guide for a webserver on ubuntu 18.04 (from a mac)
==================
2019-05-08





Things to replace:
- my_user: the name of the user on the server with administrative rights (sudo)
- my_mac_user: the name of your mac user account
- my_public_key_name: the name of your public key (my_vps_my_user for instance)
- server_ip: the ip address of the server
- my_ssh_alias: the ssh alias that you want to use (in the .ssh/config file)
- my_domain: the name of your main domain example: mysite.com
- path_to_my_site_webroot: the path to your website's web directory (for instance /var/www/mysite.com/www)





The general strategy:
- preparation on local machine
- first only allow one user to connect via ssh
- then configure the firewall
- then add the services
	- using nginx as a webserver
	- using apache as a webserver
- customization (optional)



Table of Contents
=================

  
* [Preparation on local machine](#preparation-on-local-machine)
* [Only allow one user to connect via ssh](#only-allow-one-user-to-connect-via-ssh)
* [Configure the firewall](#configure-the-firewall)
* [Add the services](#add-the-services)
  * [fail2ban](#fail2ban)
  * [Php](#php)
     * [FPM (for nginx)](#fpm-for-nginx)
        * [Important files](#important-files)
     * [As an apache module](#as-an-apache-module)
     * [Php extensions](#php-extensions)
  * [Universe](#universe)
  * [Composer](#composer)
  * [Nginx](#nginx)
     * [Important files](#important-files-1)
     * [Create the main domain](#create-the-main-domain)
     * [Configuring nginx server](#configuring-nginx-server)
     * [More nginx configuration for php](#more-nginx-configuration-for-php)
  * [Apache](#apache)
  * [Let's encrypt](#lets-encrypt)
     * [Configure nginx](#configure-nginx)
  * [Mysql](#mysql)
  * [Rkhunter](#rkhunter)
  * [Chkrootkit](#chkrootkit)
* [Customization](#customization)
  * [To make vim understand nginx files](#to-make-vim-understand-nginx-files)
      
      
      




Preparation on local machine
================

Create an ssh key for the user:
- cd
- cd .ssh
- ssh-keygen -t ed25519
	- /Users/$my_mac_user/.ssh/$my_public_key_name


Add an entry in ~/.ssh/config


```txt
Host $my_ssh_alias
    HostName $server_ip
    Port 22
    User $my_user
    IdentityFile ~/.ssh/$my_public_key_name
```
    


Only allow one user to connect via ssh
================

Connect to the server
- ssh root@server_ip


?Check that OpenSSH is running  
- service ssh status

Update the server with latest software versions (accept defaults in dialog)
- apt update
- apt upgrade


?Automatically install important security upgrades (normally it's already there)
- apt-get install unattended-upgrades

?Configure unattended-upgrades (accept defaults in dialog)
- dpkg-reconfigure unattended-upgrades


?Check whether a reboot is required
- cat /var/run/reboot-required

?Check why you need a reboot
- cat /var/run/reboot-required.pkgs

Configure unattended-upgrades so that it reboots automatically
- vim /etc/apt/apt.conf.d/50unattended-upgrades

```txt
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
```


?Remove the ubuntu account if any
- deluser ubuntu --remove-home


Create a user
- adduser $my_user


Add him/her to the sudo group
- adduser $my_user sudo


Create the .ssh directory for $my_user
- cd /home/$my_user
- mkdir .ssh
- cd .ssh
- vim authorized_keys (paste the content of the public key on your mac)




Secure the sshd_config
- vim /etc/ssh/sshd_config

```txt

MaxAuthTries 2
MaxSessions 3
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
AllowTcpForwarding no
GatewayPorts no
X11Forwarding no
PrintMotd no
PermitTunnel no
AcceptEnv LANG LC_*
Subsystem       sftp    /usr/lib/openssh/sftp-server
PermitRootLogin no
AllowStreamLocalForwarding no
Protocol 2
AllowUsers $my_user

```

Restart the ssh server
- service ssh restart (or systemctl reload ssh)


Now disconnect
- exit


And reconnect with your my_user 
- ssh $my_user@server_ip







Configure the firewall
================

Connect as root:
- sudo su

Create a firewall script:
- mkdir /root/firewall
- vim /root/firewall/my_firewall.sh (configure the ALLOWED_TCP and ALLOWED_SSH_IP as you want)

```bash
#!/bin/bash

# Ports recap:
# ---- web: 80, 443
# ---- mail: 25 (smtp), 465 (smtps), 143 (imap), 993 (imaps), 110 (pop), 995 (pops)
# ---- ssh: 22
# ---- ftp: 20


# Allowed tcp ports
ALLOWED_TCP="80 443 22 20 25 465 143 993 110 995"
ALLOWED_TCP="80 443 22"





# Flush the filter table from INPUT or OUTPUT
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F


# Permit loopback interface traffic (because our host is not a router)
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT


# Drop invalid traffic (good idea since we use the connexion track module)
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A OUTPUT -m state --state INVALID -j DROP


# Allow icmp traffic (ping)
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT



for port in $ALLOWED_TCP
do
    iptables -A INPUT -p tcp --dport $port -j ACCEPT
done



# https://ubuntuforums.org/showthread.php?t=1441483
# DNS
iptables -A INPUT -p tcp -m tcp --sport 53 -j ACCEPT
iptables -A INPUT -p udp -m udp --sport 53 -j ACCEPT

# apt-get
iptables -A INPUT -p tcp --sport 80 -j ACCEPT
iptables -A INPUT -p tcp --sport 443 -j ACCEPT




# Permit no more than 50 concurrent connections from the same ip address to our web server
iptables -A INPUT -p tcp -m multiport --dports 80,443 -m connlimit --connlimit-above 50 -j DROP


# Allow all outgoing valid traffic 
iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT


# Set the default policy to drop
iptables -P INPUT DROP
iptables -P OUTPUT DROP











```





Make the script executable
- chmod 700 /root/firewall/my_firewall.sh

Execute it to apply the firewall rules now
- /root/firewall/my_firewall.sh


Make the firewall rules persistent (this will actually execute the iptables-save command automatically)
- apt-get install iptables-persistent 


?Save the iptables rules for reboot manually (if you followed the steps above, it's already done by apt-get install iptables-persistent)
- iptables-save > /etc/iptables/rules.v4


Reboot now and reconnect to check that every is ok so far
- reboot




Add the services
===============

fail2ban
-----------


- apt install fail2ban
- vim /etc/fail2ban/jail.local

```bash
[DEFAULT]
bantime = 3h
maxretry = 3
ignoreip=127.0.0.1/8 
destemail = $my_user@localhost 

[sshd]
enabled = true

```


Restart the service 
- systemctl restart fail2ban.service
- fail2ban-client status
- fail2ban-client status sshd


Note: to unban
- fail2ban-client set sshd unbanip 123.456.789.123






Php 
--------


### FPM (for nginx)

Install the stand alone version of php (i.e. not a module of apache)
- apt install php-fpm
- php --version

Configure php to work with nginx
- vim /etc/php/7.2/fpm/php.ini

```bash
; To prevent a file without php extension to be executed as php
cgi.fix_pathinfo=0
```

Reload
- systemctl reload php7.2-fpm.service



#### Important files
- /etc/php
- /var/log/php7.2-fpm.log



### As an apache module


Install. Note: the command below will also install apache2 if not already installed.
- apt-get install php libapache2-mod-php




### Php extensions


List the current modules 
- php -m


Install some extensions
- apt install php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-zip




Universe
----------

Log as your user (just for this section)

Paste this in your terminal

- temp_file=$(mktemp); curl -fsSL https://raw.githubusercontent.com/lingtalfi/universe-naive-importer/master/installer.php > $temp_file; sudo php -f $temp_file;

- uni help



Composer
-------------

Log as your user (just for this section)

- cd

Paste all this:

```bash
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
```

Move it to your local bin
- sudo mv composer.phar /usr/local/bin/composer


Update 
- composer self-update









Nginx
----------

- apt install nginx


Check if the configuration of nginx is ok
- nginx -t

Reload nginx (after changing the conf)
- systemctl reload nginx.service



### Important files

- /etc/nginx
	- nginx.conf
	- sites-available
	- sites-enabled

- /var/log/nginx/access.log
- /var/log/nginx/error.log


### Create the main domain


Remove the symbolic link to the default website:
- rm /etc/nginx/sites-enabled/default

Create the main domain
- cd /etc/nginx/sites-available
- cp default $my_domain
- vim $my_domain

```nginx

server {

	listen 80 default_server;
	listen [::]:80 default_server;

	# Prevent site from being displayed under a different domain (by creating another domain pointing to our server)
	return 301 http://my_site.com;
}

server {

	# only change these two lines for non default servers
	listen 80;
	listen [::]:80;


	root $path_to_my_site_webroot;
	index index.php index.html;
	server_name $my_domain;

	location ~ \.php$ {
	       include snippets/fastcgi-php.conf;
	       fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
	}


	# Prevent access to .htaccess and .git
	location ~ /\.ht {
		deny all;
	}

	location ~ /\.git {
		deny all;
	}
}

```

Relink
- ln -s /etc/nginx/sites-available/$my_domain /etc/nginx/sites-enabled/

Reload
- nginx -t
- systemctl reload nginx.service





### Configuring nginx server


- vim /etc/nginx/nginx.conf

```nginx

http {

		# Hide nginx signature in http response
		server_tokens off;

		##
		# Security settings
		##

		# Avoid iframes for clickjacking attacks
		# add_header X-Frame-Options DENY;
		add_header X-Frame-Options SAMEORIGIN;

		# Avoid mime type sniffing
		add_header X-Content-Type-Options: nosniff;

		# Avoid certain type of XSS attacks (if browser understands it)
		add_header X-XSS-Protection "1;mode=block";


		gzip_vary on;
		# gzip_proxied any;
		gzip_comp_level 6;
		gzip_buffers 16 8k;
		gzip_http_version 1.1;
		gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

	    ##
	    # DoS and DDoS Protection Settings
	    ##

	    #Define limit connection zone called conn_limit_per_ip with memory size 15m based on the unique IP
	    limit_conn_zone $binary_remote_addr zone=conn_limit_per_ip:15m;

	    #Define limit request to 40/sec in zone called req_limit_per_ip memory size 15m based on IP
	    limit_req_zone $binary_remote_addr zone=req_limit_per_ip:15m rate=40r/s;

	    #Using the zone called conn_limit_per_ip with max 40 connections per IP
	    limit_conn conn_limit_per_ip 40;

	    #Using the zone req_limit_per_ip with an exceed queue of size 40 without delay for the 40 additonal
	    limit_req zone=req_limit_per_ip burst=40 nodelay;

	    #Do not wait for the client body or headers more than 5s (avoid slowloris attack)
	    client_body_timeout 5s;
	    client_header_timeout 5s;
	    send_timeout 5;

	    #Establishing body and headers max size to avoid overloading the server I/O
	    client_body_buffer_size 256k;
	    client_header_buffer_size 2k;
	    client_max_body_size 3m;
	    large_client_header_buffers 2 2k;



}

```

Reload
- nginx -t
- systemctl reload nginx.service



### More nginx configuration for php



Redirect all non existing traffic to /index.php:


```nginx
location / {
            try_files $uri $uri/ /index.php?$query_string;
}
```






Apache
-----------

- apt-get install apache2


Secure apache
- vim /etc/apache2/apache2.conf (a2enmod headers required)

```bash
ServerSignature Off
Header set X-Content-Type-Options nosniff
```

Reload
- service apache2 restart
- service apache2 status


Activate modules
- a2enmod rewrite
- a2enmod userdir
- a2enmod headers

Reload
- systemctl restart apache2
- systemctl status apache2


Check version
- apache2 -v

Enabled module list
- apachectl -M



Let's encrypt
----------


Note: the ssl certificates need to be renewed every 3 months,
but the acme.sh client takes care of the renewal for us automatically.



Install socat (a dependency of the acme.sh client)
- apt-get install socat


Install the acme.sh client

- https://github.com/Neilpang/acme.sh

- cd
- git clone https://github.com/Neilpang/acme.sh.git
- cd ./acme.sh
- ./acme.sh --install


Check that it installed a cronjob:
- crontab -e

Check that acme.sh is recognized
- source /root/.bashrc
- acme.sh



Issue a certificate
- acme.sh --issue -d example.com -w $path_to_my_site_webroot
- acme.sh --list



Install the certificate
- mkdir -p /etc/nginx/certs/$my_domain
- acme.sh --install-cert -d $my_domain --key-file /etc/nginx/certs/$my_domain/key.pem --fullchain-file /etc/nginx/certs/$my_domain/fullchain.pem --ca-file /etc/nginx/certs/$my_domain/ca.pem --reloadcmd "systemctl force-reload nginx.service"




### Configure nginx 



Paste and adapt the snippet below.

Note: in order to get this snippet, you can go to https://mozilla.github.io/server-side-tls/ssl-config-generator/, and check nginx, modern, enter your server version, and openssl version, and check hsts enabled (force the use of https) to generate the configuration block.

To get your software version:
- nginx -v
- openssl version


vim /etc/nginx/sites-available/$my_domain

```nginx




server {
    listen 80;
    listen [::]:80;

    server_name $my_domain;

    # Redirect all HTTP requests to HTTPS with a 301 Moved Permanently response.
    return 301 https://$my_domain$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    # certs sent to the client in SERVER HELLO are concatenated in ssl_certificate
    ssl_certificate /etc/nginx/certs/$my_domain/fullchain.pem;
    ssl_certificate_key /etc/nginx/certs/$my_domain/key.pem;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;


    # modern configuration. tweak to your needs.
    ssl_protocols TLSv1.2;
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256';
    ssl_prefer_server_ciphers on;


    ##
    # Security settings
    ##

    # Avoid iframes for clickjacking attacks
    # add_header X-Frame-Options DENY;
    add_header X-Frame-Options SAMEORIGIN;

    # Avoid mime type sniffing
    add_header X-Content-Type-Options: nosniff;

    # Avoid certain type of XSS attacks (if browser understands it)
    add_header X-XSS-Protection "1;mode=block";

    # HSTS (ngx_http_headers_module is required) (15768000 seconds = 6 months)
    add_header Strict-Transport-Security max-age=15768000;




    # OCSP Stapling ---
    # fetch OCSP records from URL in ssl_certificate and cache them
    ssl_stapling on;
    ssl_stapling_verify on;

    ## verify chain of trust of OCSP response using Root CA and Intermediate certs
    ssl_trusted_certificate /etc/nginx/certs/$my_domain/ca.pem;

    ## ... the rest of your configuration here
}


```


Reload
- nginx -t
- systemctl reload nginx.service



Check your result with ssllabs.com: https://www.ssllabs.com/ssltest/







Mysql
--------

Note: if you're not root, prefix all with sudo, including mysql calls.


- apt install mysql-server
- (or apt install mariadb-server)

- mysql --version
- mysql -u root -p (empty)


Secure the mysql installation (enter a password for root, say yes to all questions)
- mysql_secure_installation


Create a database (in mysql)
- create database my_database;

Create an user (in mysql)
- create user my_sql_user@localhost identified by 'myPassword';
- select User from mysql.user;
- grant all privileges on my_sql_user.* to my_database@localhost;
- flush privileges;


Start/Stop
- service mysql start
- service mysql stop
- service mysql restart



Rkhunter
----------

Install
- apt install rkhunter

Perform the check
- rkhunter --check


Chkrootkit
---------

Install
- apt install chkrootkit

Scan
- chkrootkit




Customization
=============

To make vim understand nginx files
------------------

Use the following script
https://gist.github.com/ralavay/c4c7750795ccfd72c2db

```bash
#!/bin/bash
#
# Highligh Nginx config file in Vim

# Download syntax highlight
mkdir -p ~/.vim/syntax/
wget http://www.vim.org/scripts/download_script.php?src_id=19394 -O ~/.vim/syntax/nginx.vim

# Set location of Nginx config file
cat > ~/.vim/filetype.vim <<EOF
au BufRead,BufNewFile /etc/nginx/*,/etc/nginx/conf.d/*,/usr/local/nginx/conf/* if &ft == '' | setfiletype nginx | endif
EOF
```


Fast navigation
--------
https://github.com/lingtalfi/cdd












