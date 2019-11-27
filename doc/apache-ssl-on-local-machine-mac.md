Configure apache for ssl on local machine (mac)
===============
2019-11-27



First find your apache root dir.
Use ps to help you.

```bash
ps aux | grep httpd 
```

It could be a lot of things (for instance mine is /usr/local/etc/httpd), but in the following section, for the sake of simplicity, I'll use /etc/apache2 as the root dir (i.e. change that to your dir).



Basically we are going to do this:

- create the certificate and keys
- configure apache and restart it
- make our browser accept our certificate



Create the certificate and keys
----------------------------

### 1. Create a ssl directory

```bash
mkdir /etc/apache2/ssl
cd /etc/apache2/ssl
```


### 2. Create the certificate and key and csr file

My domain is jindemo (i.e. in my /etc/hosts file I have a line 127.0.0.1 jindemo),
so replace jindemo with your domain.


```bash
openssl genrsa -out jindemo.key 3072
openssl req -new -out jindemo.csr -sha256 -key jindemo.key
openssl x509 -req -in jindemo.csr -days 365 -signkey jindemo.key -out jindemo.crt -outform PEM

```

Configure apache and restart it
-------------------

### 3. Configure the apache file

If you are using apache 2.4 (like me), the list of required modules for ssl are listed
at the top of the default ssl file (i.e. /etc/apache2/extra/httpd-ssl.conf) in the comments.

Also, because I want to redirect all non https traffic to https, I will use redirect which depends on the mod_alias module.

So open the apache conf file (/etc/apache2/httpd.conf in my case) and make sure all modules are uncommented.

```apache
LoadModule .../mod_log_config.so
LoadModule .../mod_setenvif.so
LoadModule .../mod_ssl.so
LoadModule .../socache_shmcb_module.so
LoadModule .../mod_alias.so
```

Then in the same config file, include the ssl conf file:

```apache
Include /etc/apache2/extra/httpd-ssl.conf
```

Also make sure that the vhost file is included

```apache
Include /etc/apache2/extra/httpd-vhosts.conf
```


### 4. Configure the default ssl config file

Now in the ssl default config file (/etc/apache2/extra/httpd-ssl.conf), make sure those lines are set.
Some of them needs to be commented for our purposes.


```apache
Listen 443
SSLCertificateFile "/private/etc/apache2/ssl/jindemo.crt"
SSLCertificateKeyFile "/private/etc/apache2/ssl/jindemo.key"
#SSLCACertificatePath
#SSLCARevocationPath
```

### 5. Create the virtual host

Now in the vhost file (/etc/apache2/extra/httpd-vhosts.conf), create a new entry:


```apache
<VirtualHost *:443>
    SSLEngine On
    SSLCipherSuite HIGH:MEDIUM:!MD5:!RC4:!3DES
    SSLProxyCipherSuite HIGH:MEDIUM:!MD5:!RC4:!3DES
    SSLCertificateFile /etc/apache2/ssl/jindemo.crt
    SSLCertificateKeyFile /etc/apache2/ssl/jindemo.key

    DocumentRoot "/komin/jin_site_demo/www"
    ServerName jindemo
    SetEnv APPLICATION_ENVIRONMENT dev
    <Directory "/komin/jin_site_demo/www">
        AllowOverride All
        Require all granted
    </Directory>         
</VirtualHost>
```


### 6. Redirect non-https traffic to https


In your http virtual host, add the Redirect line:

```apache2
<VirtualHost *:80>
	# ...
    # ServerName jindemo
    # DocumentRoot "/komin/jin_site_demo/www"

    Redirect permanent / https://jindemo/

	# ...
</VirtualHost>
```


### 7. Restart apache


Check that your apache conf is ok

```bash
apachectl -S
```


Then restart apache

```bash
apachectl -k restart
```









Make our browser accept our certificate
--------------

At this point, we shall be able to open the https version of our website in the browser.

However the browser might warn you that there is a risk with this certificate.
Just accept the risk as an exception, depending on your browser (i.e. go to advanced > accept risk or something like that...).




Sources:
- https://stackoverflow.com/questions/36138517/apache-warns-that-my-self-signed-certificate-is-a-ca-certificate


