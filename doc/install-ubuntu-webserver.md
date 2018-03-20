Install Ubuntu web server
=========================================
2016-02-05



This document is my personal memo for installing a web server on a vps with ubuntu.
It assumes that you have a fresh new empty server with one linux distribution on it.

The version I used was:

```
Distributor ID:	Ubuntu
Description:	Ubuntu 14.04.3 LTS
Release:	14.04
Codename:	trusty
```

 
 
Summary
--------------
 
- [first connexion](https://github.com/lingtalfi/server-notes/blob/master/doc/install-ubuntu-webserver.md#first-connexion)
- [first update](https://github.com/lingtalfi/server-notes/blob/master/doc/install-ubuntu-webserver.md#first-update)
- [tree](https://github.com/lingtalfi/server-notes/blob/master/doc/install-ubuntu-webserver.md#tree)
- [security](https://github.com/lingtalfi/server-notes/blob/master/doc/install-ubuntu-webserver.md#security)
- [iptables](https://github.com/lingtalfi/server-notes/blob/master/doc/install-ubuntu-webserver.md#iptables)
- [fail2ban](https://github.com/lingtalfi/server-notes/blob/master/doc/install-ubuntu-webserver.md#fail2ban)
- [add an user](https://github.com/lingtalfi/server-notes/blob/master/doc/install-ubuntu-webserver.md#add-an-user)
- [create ssh access via ssh keys from your computer](https://github.com/lingtalfi/server-notes/blob/master/doc/install-ubuntu-webserver.md#create-ssh-access-via-ssh-keys-from-your-computer)
- [secure ssh access](https://github.com/lingtalfi/server-notes/blob/master/doc/install-ubuntu-webserver.md#secure-ssh-access)
- [security updates](https://github.com/lingtalfi/server-notes/blob/master/doc/install-ubuntu-webserver.md#security-updates)
- [install lamp](https://github.com/lingtalfi/server-notes/blob/master/doc/install-ubuntu-webserver.md#install-lamp)
 
 
 
 



 
First connexion (access depends on the internet provider)
---------------------- 
```bash
ssh root@XXX.XXX.XXX.XXX
# (type your password)
```



Before anything else
---------------------
```bash
# apt-get update
# apt-get upgrade
# apt-get install aptitude
```


First update
-----------------
```bash
aptitude update && aptitude dist-upgrade
```

Note: someone was trying to access the server after this command (I could spot her with netstat -ant),
I don't know if that's related with the fact that I updated the server or not.



Tree
---------

Easy to install, and we need it at some points later in this tuto.

```bash
apt-get install tree
tree -gapu
```



Security
-----------
### Display ip of other connected people

```bash
netstat -ant
# n: no reverse dns, display human ips
```

### If you have an undesirable established connection, kill it

```bash
tcpkill host 195.154.9.61
```

### Check for authentication tries
```bash
less /var/log/auth.log
# if the file is too big, you can check for failed attemps with:
grep 'Failed password' /var/log/auth.log

# and for successful connexions with:
grep 'Accepted password' /var/log/auth.log

```



Iptables
--------------

(be root)

### Create a firewall.sh script 

```bash
cd /root
vim firewall.sh
```

Put the contents of the [firewall](https://github.com/lingtalfi/server-notes/blob/master/doc/scripts/firewall.sh) script
in it.

You should then execute it to see if there is something wrong.
```bash
chmod u+x firewall.sh
./firewall.sh 
# if you're not kicked out, you're good
```



```bash
# checking your work
iptables -L -v
```


### create persistent rules (apply to ubuntu and debian)

```bash
apt-get install -y iptables-persistent
# answer yes and it's done
```

```bash
# check that rules are saved
cat /etc/iptables/rules.v4
# then you can test if rules survive the reboot
reboot
# then 
iptables -L -v
```


Note:
 
If you later want to update rules, do the following:

- update the firewall.sh script and execute it
- then do one of the following commands (the first is just one line)

```bash
dpkg-reconfigure iptables-persistent
```
Or

```bash
iptables-save > /etc/iptables/rules.v4
iptables-save > /etc/iptables/rules.v6
```



Fail2ban
-------------
(be root)

Fail2ban monitor logs and takes actions based on the monitoring.
Logs include **/var/log/auth.log**, which contains ssh connexion attempts.

```bash
apt-get install -y fail2ban
```

### configure fail2ban

```bash
cd /etc/fail2ban
cp jail.conf jail.local
vim jail.local
# Check that the default conf bans an ip after 6 failed ssh attempts
```

Notes: to ban a host, fail2ban use iptables.
You can verify it with the iptables -L -v command (fail2ban added its own target, which will be feed as users 
get banned).




Add an user
--------------------------
(be root)

```bash
adduser ling
# type enter everywhere
```

```bash
# check that the user exists
cat /etc/passwd | grep ling
```

Note: in general, users created manually have an id above or equal to 1000, 
while system users have an id below 1000.



### Check the sudoers
```bash
vim /etc/sudoers
```

Check that admin and sudo groups can use the sudo command,
by finding the following lines:

```bash
%admin ALL=(ALL) ALL
%sudo ALL=(ALL:ALL) ALL
...
The first ALL means from any machine.
If there is one ALL inside the parenthesis, it means for all users (but not for all groups).
If there is two ALL separated by a colon (:) inside the parenthesis, it means for all users and all groups.
The last ALL means all the commands.
```

### add your admin user to the sudo group

```bash
usermod -a -G sudo ling
# note: option -a adds a group rather that redefining the group
# option -G (upper case) means secondary group, 
# as opposed to option -g (lower case) which means primary group
```

```bash
# check your work
groups ling
```


Create ssh access via ssh keys from your computer
------------------------------------------

### Create a ssh key for user ling
(local)
```bash
cd ~/.ssh
ssh-keygen -t rsa -b 4096 -C ling@my_app.com -f id_myapp_ling
# type rsa, 4096 bytes, -C is a comment, -f is the output file of the private key,
# a public key will also be created, with the same name and extension .pub), check it:
ll
```

### add the public key to the authorized_keys file

```bash
cat id_myapp_ling.pub | ssh login@ip "cd /home/ling ; umask 077; test -d .ssh || mkdir .ssh ; cat >> .ssh/authorized_keys"
# you should be prompted for your password
```


Note: if you are on ubuntu (not tested), you can do the following:
```bash
ssh-copy-id -i id_myapp_ling.pub ling@123.456.789.123
# ssh-copy-id -i id_myapp_ling.pub "-p 14444 ling@123.456.789.123"
```

### check that you can connect with your user to the server


```bash
ssh login@ip
```


### also check for the authorized_keys file
cd /home/ling
tree -gapu
```

### secure access to your keys on the server

 ```bash
chown ling:ling -R .ssh
chmod 700 /home/ling/.ssh
chmod 600 /home/ling/.ssh/authorized_keys
 ```

Also check for the key content.

```bash
cat .ssh/authorized_keys
```

If you need to pre-configure your sshd config (but I'm explaining it in the next section)
  
```bash
vim /etc/ssh/sshd_config
# ...
service ssh restart
```

### Use ssh config 
(local)

Using ssh config allows you to use alias instead of long verbose ssh commands.

```bash
cd ~/.ssh
vim config

# Add the following lines
Host ling 
	HostName 123.456.789.123
	User ling
	IdentityFile /Users/myRealName/.ssh/id_myapp_ling
	IdentitiesOnly yes
	Port 22
```



Secure ssh access
--------------------------
(remote)

At this point you should be able to connect via ssh to you server, with a non root user.
Now let's enforce ssh security

```bash
vim /etc/ssh/sshd_config
```

You should be watching the following:

- PermitRootLogin, set it to no (no one should connect as root to your server)
- PasswordAuthentication: set it to no (force use of ssh key)
- Change the default port (DON'T FORGET TO CONFIGURE IPTABLES ACCORDINGLY!!)
- Limit the users allowed to connect with the following keywords: DenyUsers, DenyGroups, AllowUsers, AllowGroups, all of which accept a space separated user name list


When you are done, restart the ssh service. 

```bash
service ssh restart
```






Security updates
-------------------
(be root)

We will configure the server to automatically install security related updates.

```bash
apt-get update
apt-get install -y unattended-upgrades
# configure 
cd /etc/apt/apt.conf.d
sudo vim 50unattended-upgrades
# Check that only security sources are uncommented
```

If you want to, you can configure the service to automatically reboot the system after an update.
If so you wish (I don't do it), search for the Automatic-Reboot lines (Automatic-Reboot and Automatic-Reboot-Time).

Then configure the service to make one check per day

```bash 
vim 10periodic

(put the following lines in it)
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
``` 

The above configuration, amongst other things, clean packages every 7 days.

Now we are done.
If you are interested in, check how this service use cron under the hood.

```bash
cd /etc/cron.daily
vim apt
(search for periodic)
```



Install lamp
-----------------
(be root)

Let's install apache mysql php.


```bash
apt-get update
apt-get install -y vim tmux curl wget
# check the version you are going to install 
apt-cache show apache2
apt-cache show php5
apt-get install -y apache2 libapache2-mod-php5 mysql-server php5-cli php5-curl php5-mcrypt php5-gd php5-json php5-mysql
# mysql configuration screen should show up, choose a strong root password
```bash

Then check your work 

```bash
apache2 -v
php -v
```


### If you want more recent versions

If you want more recent versions, you can try to install them from ppa.
First, you need the add-apt-repository command, in order to add ppa.

```bash
apt-get -y install software-properties-common
# check 
which add-apt-repository
```

Then, install the ppa that you want

```bash
add-apt-repository -y ppa:ondrej/apache2
add-apt-repository -y ppa:ondrej/php5-5.6
```

Don't forget to update the packages list after adding a ppa 

```bash
apt-get update
```


Now check what new packages can be installed

```bash
apt-cache show apache2
# check for the version you're after
apt-cache show php5-cli
```

Since there is no ugrade command in ubuntu, we simply reinstall the packages over themselves:

```bash
apt-get install -y apache2 libapache2-mod-php5
# if prompted, use "install the package maintainer's version")
```

Now check your new software's versions

```bash
apache2 -v
php -v
```

And test the new webserver if you want.

```bash
curl localhost
```


### Configure apache 

Check the content of your sites-availables/enabled

```bash
cd /etc/apache2/sites-available
ll
ll ../sites-enabled

# create your own virtual host 
vim myapp.conf
```

Use the following default conf for your new virtual hosts.
Note that it uses xip.io service, which allows you to play with a real domain name (with sub-domains), rather than just an ip.

```
<VirtualHost *:80>
	ServerName my-site.com
	ServerAlias 123.456.789.456.xip.io

	DocumentRoot /var/www/my_app/public

	<Directory /var/www/my_app/public>
		# Don't show directory index
		Options -Indexes +FollowSymLinks +MultiViews

		# Allow .htaccess files
		AllowOverride All

		# Allow web access to this directory
		Require all granted
	</Directory>

	# Error and access logs
	ErrorLog ${APACHE_LOG_DIR}/my-site.error.log

	# Possible values include: debug, info, notice, warn, error, crit, alert, emerg.
	LogLevel warn
	CustomLog ${APACHE_LOG_DIR}/my-site.access.log combined
</VirtualHost>
```

Then create the log files that were just defined in the virtual host configuration, 
and apply the same permissions as other log files to your owns.
 
```bash
touch /var/log/apache2/my-site.error.log
touch /var/log/apache2/my-site.access.log
chmod 640 /var/log/apache2/my-site.access.log
chmod 640 /var/log/apache2/my-site.error.log
```


Tip: to know the real value of the ${APACHE_LOG_DIR} variable, it's **/var/log/apache2** by default, but you can check it with:
```bash
vim ../envvars
```

Now you can activate your application and start apache

```bash
a2ensite myapp
service apache2 reload
```

### Configure mysql

```bash
mysql -u root -p
```

```mysql
show databases;


# Create a database with the utf8mb4 character set, which is a little more complete than the mysql utf8
create database some_db default character set utf8mb4 collate utf8mb4_unicode_ci;

# Create an user, and grant him the rights to administrate her database
# use of the wildcard (%) means all hosts, including remote and local connexions
# I suggest that you create both accounts, one at localhost, and one for all hosts, see
# the mysql docs for more details: http://dev.mysql.com/doc/refman/5.7/en/adding-users.html

create user 'my_app_user'@'%' identified by 'my_password';
grant all privileges on some_db.* to 'my_app_user'@'%';

# if you need to, use this to drop an user
drop user my_user@'%';

# when finished, you should flush to take the changes into account (although I believe it works without)
flush privileges;
```




Sources
----------

- Best: https://serversforhackers.com
- http://code.tutsplus.com/tutorials/how-to-setup-a-dedicated-web-server-for-free--net-2043





