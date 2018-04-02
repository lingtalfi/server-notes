Ling apache
===================
2018-04-02





This is a reminder of how I setup apache related things.



First: create an access log
------------------------------

```bash
sudo su
mkdir /var/log/apache2/ling; touch /var/log/apache2/ling/all.log
chmod -R 710 /var/log/apache2/ling; chmod 640 /var/log/apache2/ling/all.log
```





Second: create your virtual host
--------------------------------


```bash
vim /etc/apache2/sites-available/ling-docs.ovh.conf
```


Tip: to replace all **ling-docs** instance by **mysite** (in the snippet below) in vim, use this:

```bash
:%s/ling-docs/mysite/g
```

```apache
<VirtualHost *:80>
        DocumentRoot /home/ling/websites/ling-docs/www
        ServerName www.ling-docs.ovh
        ServerAlias ling-docs.ovh *.ling-docs.ovh
        <Directory "/home/ling/websites/ling-docs/www">
                Options FollowSymlinks MultiViews
                AllowOverride All 
                Require all granted
        </Directory>
       ErrorLog /var/log/apache2/ling/all.log

</VirtualHost>
```


Third enable the virtual host
---------------------------------

```bash
a2ensite ling-docs.ovh
service apache2 reload
exit
```





