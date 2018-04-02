Install universe and kamille on a new server
======================================
2018-04-02



A quick reminder on how to install universe and kamille environment on a new server (ubtuntu 16 xenial 16.04.02).



Install universe
==================


First install uni tool
--------------------------

First install the [uni tool](https://github.com/lingtalfi/universe-naive-importer).


```bash
cd 
mkdir -p tools; cd tools
git clone https://github.com/lingtalfi/universe-naive-importer
```

Then make an alias 

```bash
sudo ln -s /home/ling/tools/universe-naive-importer/uni /usr/bin/uni
which uni 
```


Now import the whole universe
--------------------------


I like to put it in a websites directory, but do as you want...


```bash
cd 
mkdir -p websites/universe; cd websites/universe
uni importall -f
```



Install kamille environment
=================================


First install kit
-------------------

Now let's install kit ([kamille installer tool](https://github.com/lingtalfi/kamille-installer-tool))


```bash
cd 
mkdir -p tools; cd tools
git clone https://github.com/lingtalfi/kamille-installer-tool
```


Then make an alias 

```bash
sudo ln -s /home/ling/tools/kamille-installer-tool/kamille /usr/bin/kamille
which kamille
```




Now import all the modules
--------------------------


I like to put them in a websites directory, but do as you want...


```bash
cd 
mkdir -p websites/kamille-modules; cd websites/kamille-modules
kamille importall -f -xx
```

Note: the -xx option stands for "in place", which basically tells kit that the parent dir of the module is the current dir.
(without the -xx option, you would get warnings: can't cd into class-modules...)










