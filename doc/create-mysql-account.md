Create mysql account
=======================
2017-06-22




This is not a secure version because the password (step 3) is in clear in the history.

However, it does the job.

If you want to secure the password, use the mysql PASSWORD function.





1. Connect to the server.

```mysql
mysql -uroot -proot
```
	

2. Create the database 

```mysql
CREATE DATABASE mydb CHARACTER SET utf8 COLLATE utf8_general_ci;
```


3. Create the user

```mysql
create user 'myuser'@'localhost' identified by 'mypass';
```

4. Grant privileges 

```mysql
grant all on mydb.* to 'myuser'@'localhost';
```


4. Flush privileges 

```mysql
flush privileges;
```




Command memo
=============

```mysql
CREATE DATABASE mydb CHARACTER SET utf8 COLLATE utf8_general_ci;
show databases;

create user 'myuser'@'localhost' identified by 'mypass';
SELECT Host, User FROM mysql.user; 

grant all on mydb.* to 'myuser'@'localhost';
flush privileges;
```






