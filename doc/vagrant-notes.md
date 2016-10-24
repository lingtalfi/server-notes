Vagrant notes
=================
2016-03-15


Summary
-------------

- [Nomenclature/Concepts](#nomenclatureconcepts)
- [How to install an ubuntu machine?](#how-to-install-an-ubuntu-machine)
- [How to list installed machines?](#how-to-list-installed-machines)
- [How to run an installed machine?](#how-to-run-an-installed-machine)
- [How to ssh into a running machine?](#how-to-ssh-into-a-running-machine)
- [How to shutdown a running machine?](#how-to-shutdown-a-running-machine)
- [How to remove an installed machine?](#how-to-remove-an-installed-machine)
- [Where to find more vagrant boxes?](#where-to-find-more-vagrant-boxes)
- [How to do shell provisioning?](#how-to-do-shell-provisioning)
- [Rerun the provisioning](#rerun-the-provisioning)
- [ping back-forth](#ping-back-forth)


Nomenclature/Concepts
=================

- Box

	A box is the file from which the virtual machine is built.
	It usually consists of:

		- the operating system image
		- any software that you would like already installed on that operating system image



- Vagrantfile

	the file that describes the configuration for our virtual machine.

	It should always be stored in the root folder for our virtual machine.


	Port forwarding (to access a virtual machine port from our local machine )
		
		config.vm.network "forwarded_port", guest: 80, host: 8080

	Create additional sync folder (share folder)
	
		config.vm.synced_folder "../data", "/vagrant_data"




- /vagrant
		
		When you ssh into a virtual machine, the /vagrant special folder is linked 
		to the directory you're virtual machine was created in (shared folder).


- port forwarding

	Read the Vagrantfile section



- Server provisioning 

	Server provisioning is preparing the server with the softwares and configuration that it needs
	before we actually use that server.

	Use puppet for that.
	Or you can create shell scripts.





How to install an ubuntu machine?
=======================================


Add a new box to our collection of vagrant boxes.

```bash
# First create a directory that will contain all your boxes, and cd into it
mkdir /path/to/myboxes
cd /path/to/myboxes



# then add a box, either using this style:
vagrant box add precise32 http://files.vagrantup.com/precise32.box

# or this style (go here to choose your box: https://atlas.hashicorp.com/bento/boxes/ubuntu-16.04)
vagrant box add bento/ubuntu-16.04


# add already added box
# vagrant box add --force precise32 http://files.vagrantup.com/precise32.box


# ubuntu
# vagrant box add ubuntu14 https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box


# once downloaded, you can create the Vagrantfile (and configure it if necessary)
vagrant init bento/ubuntu-16.04

# the last thing to do is connect via ssh
vagrant up
vagrant ssh

# when you're done if you want to preserve the state of your vm, exit from ssh, then:
vagrant suspend

# if you want, you can also exit using halt, but you will loose your setup:
vagrant halt


# next time you want to reconnect, do the following
vagrant up
vagrant ssh

```




How to list installed machines?
===================================

```bash
vagrant box list
```



How to run an installed machine?
=====================================

You first create a dir, then cd into that dir, then run the init command (on an installed machine) to create the Vagrantfile.
Finally boot up the virtual machine.


```bash
mkdir firstvm
cd firstvm
vagrant init precise32
vagrant up
# note: if you open virtual box software after the init, you will see your virtual machine running


```


How to ssh into a running machine?
===================================

run the following command in the virtual machine's directory (firstvm in the previous section)

```bash
vagrant ssh
```





How to shutdown a running machine?
========================================

Equivalent of putting a computer to sleep.

```bash
vagrant suspend
```

Wake up a suspended machine

```bash
vagrant resume
```

Graceful shutdown (equivalent of turning off a computer) 

```bash
vagrant halt
```


Destroy everything in the virtual machine (takes less space than other methods, but more destructive)

```bash
vagrant destroy
```




How to remove an installed machine?
======================================

```bash
# vagrant box remove $NAME $PROVIDER
vagrant box remove precise32 virtualbox
```




Where to find more vagrant boxes?
=====================================

- www.vagrantbox.es




How to do shell provisioning?
===================================

Open your Vagrantfile and add this line:

```ruby

# inline method
#config.vm.provision :shell, inline: "echo Hello World!"


# or using a shell script
config.vm.provision :shell, :path './provision.sh'


```

Shell provisioning will be executed at the end of a "vagrant up" call.


Rerun the provisioning
-------------------------

To rerun the provisioning only (much quicker), without restarting the server

```bash 
vagrant provision
``` 



Ping back & forth
=====================

To ping from the host to the guest, you can enable the private network in the VagrantFile.
Uncomment this line:

```ruby
config.vm.network "private_network", ip: "192.168.33.10"
```

Then you can ping your guest using the 192.168.33.10 ip address.

To ping from the guest to the host, first show the ip routes (inside the guest):

```bash
ip route show
```

and look for the line that starts with default.

The ip address following the default keyword is the one that you can ping from the guest to access the host.




Sources: 
http://stackoverflow.com/questions/31037918/vagrant-ping-or-curl-from-guest-to-host-machine










