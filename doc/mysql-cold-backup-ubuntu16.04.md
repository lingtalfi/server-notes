Mysql cold backup on ubuntu 16.04
===========
2019-05-11


I've two servers, an old one, corrupted, and a new one.
Both are running ubuntu16.04.

The corrupted server crashed, and thanks to the rescue mode I could retrieve the
content of /mnt/sda2/var/lib/mysql, and put it on the new server in /home/me/tmp/mysql


New server environment
============
The new server is clean.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.00 sec)

 
mysql> select Host, User from user;
+-----------+------------------+
| Host      | User             |
+-----------+------------------+
| localhost | debian-sys-maint |
| localhost | mysql.session    |
| localhost | mysql.sys        |
| localhost | root             |
+-----------+------------------+
4 rows in set (0.00 sec) 



Cold backup
============
source: https://www.linode.com/docs/databases/mysql/back-up-your-mysql-databases/


I'm root.

Stop mysql
- service mysql stop


Remove the mysql dir
- rm -R /var/lib/mysql/*

Copy the old mysql directory to the new one 
- cp -R /home/me/tmp/mysql/* /var/lib/mysql

Change the permissions:
- chown -R mysql:mysql /var/lib/mysql 

Start mysql
- service mysql start

