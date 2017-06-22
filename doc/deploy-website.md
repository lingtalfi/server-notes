Deploy php website
=========================
2016-02-05



A quick tutorial/reminder of my deployment strategy for php websites.



So I've become very lazy, and what I ideally want is push a button and have my local working website deployed 
on production.

I've managed to do that, almost, and I explain how in the following tutorial.
Almost, that's because I actually push three buttons instead of one: one for pushing the files, and two for the database,
but that gives me more flexibility, and it's still very fast (less than 1 minute if you are in great shape and type the perfect manips),
so I'm happy with it.



What is the workflow?
-------------------------

The workflow will do the following


1. Deploy a read-only copy of the local application (website) to the production server, using git. It will also recreate symlinks to frameworks library if necessary, apply perms, that kind of file system related stuff 
2. Then it will allow you to dump your local database and mirror it to the production server. The method is very brutal (a basic hot replacement), but it's fast. 
  
Note: if you are not happy with the brutality of the database method, you can still use the tools that I use, but you will have to tweak
into them a little more. However, I will not explain how to do it, because this tutorial is foremost intended to be 
a personal reminder, so I'm covering only the methods that I use.


So, let's dive in.



Using git to deploy
------------------------

Git is fast: it automatically compresses items before sending them to the production server through ssh.
Then, it can mirror your local copy to the production server, adding/removing the necessary files, and the necessary files only.
Those two reasons alone make it a cool tool to use for deploying websites.
Plus, it remembers every commit, meaning that we could go to a previous version if we wanted to (but to be honest 
I've almost never used that feature with this workflow so far). 

We will use git to create a read only application on the production server, the only working copy will be the local one.



I will use two alias that you may not have: snap and pp.
Those alias can be found [here](https://github.com/lingtalfi/my-git-config).




(local)

First, go to your app and create the local git repository

```bash
cd /path/to/myapp
git init
```

Then, create the .gitignore if necessary. 
Amongst other things, you might want to ignore every items that will be uploaded by web users, like the uploaded/ folders for instance.

Here is an example .gitignore.
 
```bash
.DS_Store
.gitignore
.idea/
1and1/
design/
private/
todo/
videos/
uploaded/ 
``` 


Now let's make a first commit.

```bash
git snap initial commit
```


Then, we connect to the prod server. I'm using a ssh config host named komin in this document.

```bash
ssh komin
```

(remote)

On the remote server, create the application dir.

```bash
cd /home/myuser
mkdir myapp
```

Now let's create a non bare git repository, and do some magic git tricks.

```bash
git init 

# now allow push in the public repository
git config receive.denyCurrentBranch ignore
git config core.worktree ../
cp .git/hooks/post-update.sample .git/hooks/post-update
vim .git/hooks/post-update

(replace the existing content of post-update with the following)

#!/bin/sh 
exec git reset --hard

```

(local)

Now back to the local host.
Let's add a git connection (remote) from your local machine to the production server.

```bash
git remote add origin komin:myapp/.git

(then make some changes to test, and commit)
git snap first export commit
git pp
```

Note that with this strategy, if some one creates new files on the production server, the local git won't be aware of them,
and thus won't delete them. Tha's not a bad thing when you think about it.


So committing from the local machine to the production server now works.
But what if we have symlinks on the local machine.



The deploy script 
------------------------

Depending on how you manage your user permissions, you might want to apply some extra perms after a push to the 
production server. 
Also, if like me you are using a framework via symlinks in your local machine, you need to recreate those symlinks
after the push.

In order to do that kind of stuff, we are going to use a deploy script.

Note: I first believed that using git hooks would be the most appropriate place to do so.
For some reasons, the git hooks didn't work for me (I tried server side post-update and post-receive).
I believe that the reason is that this specific workflow is special. 

So now, I use bash scripts to do that, and it is surprisingly simple and powerful.

 
The following script pushes the local copy to the production server, then connects to the prod server
and recreates the symlinks as I want them.
To be honest, the most difficult part was to find the name of the script.


```bash
cd /path/to/myapp 
mkdir scripts
cd scripts
vim myapp.deploy.sh
```

Put the following content in it:

```bash
cd /path/to/myapp
git pp

# recreate useful symlinks
ssh komin "rm /home/myuser/myapp/planets; ln -s /home/ling/universe/planets /home/myuser/myapp/planets"
```

Don't forget to make it executable

```bash
chmod +x /path/to/myapp/scripts/myapp.deploy.sh
```


Note: In the setup above, before I wrote the tutorial, I uploaded the planets framework to the 
/home/ling/universe/planets directory on the production server.
 
Then, because we don't want to type the full path to the script every time,
create an alias called myapppush

```bash 
alias myapppush='cd "/path/to/myapp/scripts"; ./myapp.deploy.sh'
``` 

So now that's is for the first phase.
Whenever you have finished working on your local copy and you want to push to the server, 
just type:

```bash
myapppush
```

Cool, isn't it?
And by the way, if you need to apply permissions or other stuff, just update your myapp.deploy.sh script.





How to deal with the database
-------------------------------

So now, there is the database.
We have a local database on our local machine, and the remote database on the prod server; 
how do we manage to dump/backup the database in both ways?
 
Well actually, there is a nifty tool (that I wrote) that does just that (and more), it's called [web wizard](https://github.com/lingtalfi/webmaster-wizard).

I recommend that you spend some time with this tool if you are not familiar with it.
In this document, I will write all the necessary bash commands to type to achieve the setup that we need, but I won't dive 
too much into details (details are in the web wizard docs). 
 
 
### Installing Web wizard
 
First let's install web wizard.
This is a tool coded in bash, and it depends on another bash tool called [bash manager](https://github.com/lingtalfi/bashmanager), which is basically a tool that let 
you organize tasks into projects, in order to reuse and automate the tasks.

To install bash manager, there are two steps, the full procedure is described [here](https://github.com/lingtalfi/bashmanager/blob/master/doc/install-bashmanager.eng.md):

- download bashmanager
- create the bashman command


#### Download the lastest version of bashmanager

The bashmanager versions are listed [here](https://github.com/lingtalfi/bashmanager/blob/master/doc/install-bashmanager.eng.md).
As the time of writing, the lastest version is [1.08](https://github.com/lingtalfi/bashmanager/blob/master/code/bash_manager_core-1.08.sh).

It's basically just one single script.

You can put this script anywhere on your machine, but to make things simpler, we will put it directly in the **/usr/local/bin**,
which happens to be in the included directories, which means that we can access it just by typing its name (we don't need to remember the full path).

So download the script and put it here:

```bash 
/usr/local/bin/bash_manager_core-1.08.sh
```


#### Create the bashman command

Since we have decided to directly put the bash manager script in the /usr/local/bin, creating the bashman command simply means to rename the file bashman.

```bash
cd /usr/local/bin
mv bash_manager_core-1.08.sh bashman  
``` 

And that's it for bash manager, now we can call the bashmanager by simply typing bashman.
So, let's continue with the webwizard.


#### Download the webwizard code
 
First, decide where you will put the web wizard code.
For the rest of this document, I will put the web wizard code in the **/path/to/webwizard** directory.

Download the latest [webwizard code release](https://github.com/lingtalfi/webmaster-wizard/releases).
As the time of writing, the lastest web wizard release is [1.3.0](https://github.com/lingtalfi/webmaster-wizard/releases/tag/1.3.0).
 
You will see that there is a directory called home.
Unzip the tarball so that your home is at **/path/to/webwizard/home**.


#### Configuring the web wizard 
 
Now we are in.
In the web wizard's home directory, there are two important folders: config.d and tasks.d.

The tasks directory contains the tasks that we can execute, while the config directory contains the configuration of those tasks.
In the config.d directory, you will find a myconf.demo.txt file. 
This is a sample configuration file.
Copy it to myconf.txt to make it your own configuration file.


```bash
cd /path/to/webwizard/home/config.d 
cp myconf.demo.txt myconf.txt
```

The web wizard comes with a lot of tasks.
You can have a look at the web wizard docs when you have time for that, but for now, 
we don't need all of those, we just need the tasks from the so called "Database apply" section, so do the following:

```bash
vim myconf.txt
```

And replace the content with the following:

```bash
secure(php)*:
myapp=0

sshString(php)*:
myapp=komin


localDbInfo(php)*:
myapp=myapp:root:root


remoteDbInfo(php)*:
myapp=myapp:myapp:ZERj07Fe1


tmpFile(php)*:
myapp=/tmp/wwiz.last.sql



# Database apply - save (2015-10-15 by lingTalfi)
#----------------------------------------
saveFromLocal(php):
myapp=

saveFromLocalDestructive(php):
myapp=

applyToLocal(php):
myapp=

saveFromRemote(php):
myapp=

saveFromRemoteDestructive(php):
myapp=

applyToRemote(php):
myapp=
```
 
Basically, we've just subscribed our app myapp to various tasks (secure, sshString, localDbInfo...), which
are part of our db push/pull workflow. 

Again, see the docs for more details about each task, but in a nutshell:
the secure task will display/hide your password from the terminal screen (you can leave it to 1, unless somebody is watching over your shoulders
and you are paranoid, in which case you will set it to 0).

The (php) suffix means that the task is coded in php, but that doesn't change anything for us as simple users.
The asterisk after the (php) means that the task is executed every time (it's called a configuration task in web wizard's lingo), even
if you don't specify it manually.

The sshString is the name of the ssh config host you want to use.

localDbInfo and remoteDbInfo works the same: the value is 3 fields separated with the colon symbol: the db name, the user name, and the password.

The tmpFile configuration task defines the location of the temporary file used by all the "database apply" tasks.

Basically, any operation using the "database apply" strategy is decomposed in two steps: 
 
- write something to the tmpFile
- then use the content of the tmpFile and export it elsewhere

There is an [image here that sums it up](https://camo.githubusercontent.com/6416da5824c6c737307d5a125d3519d8cb1995e2/687474703a2f2f7331392e706f7374696d672e6f72672f6878326e68796f69722f7777697a5f736176655f6170706c792e6a7067).
  
This strategy let us do any movement of our database push/pull strategy in two steps.
For instance if we want to copy the local database and export it to the production server, we would first dump the local database to the 
tmpFile, and then apply the content of the tmpFile to the distant database.

This works one way or the other.

So, all remaining tasks are just move from/to the tmpFile to the distant/local database.



#### Optimize the web wizard calls 
 
If we stopped now, we would have to type pretty verbose commands.
Let's implement nifty aliases that really make our push job easy.

This is a two steps process.
I'm aware that this might seem frustrating, but trust me, once this is done, you won't regret it.

First, make an alias for the web wizard command itself, I like to use wwiz.

```bash
alias wwiz='bashman -h "/path/to/webwizard/home" -c myconf -v'
```

The -v option is for verbose (otherwise, you have absolutely no output)

The second step is to use the so called "ling aliases".

```bash
vim ~/.bash_manager
```

Put the following content in it:

```bash
alias[webWizard]:

#--------------------------
# database: save-apply
#--------------------------
al = -t applyToLocal -p
ar = -t applyToRemote -p
sld = -t saveFromLocalDestructive -p
sl = -t saveFromLocal -p
srd = -t saveFromRemoteDestructive -p
sr = -t saveFromRemote -p
```


Ok.

At this point my friends, the wwiz is ready for you.
You just need to know how to use it. 


### Push your local database to the prod server

```bash
# save local database to tmpFile 
wwiz sl myapp 

# apply tmpFile's statements to the remote db
wwiz ar myapp 
```

Note: myapp is the identifier that we put in the **/path/to/webwizard/home/config.d/myconf.txt** file.

### Pull the remote database from the prod server to your local database

```bash
# save remote database to tmpFile 
wwiz sr myapp 

# apply tmpFile's statements to the local db
wwiz al myapp 
```
   
Related to our workflow, that's it.


  



Sum up 
--------

So at the end of the day, we can work with our local version, and then push with one command: 

```bash
myapppush
```

If we also want to push the database, we need two extra commands:
```bash
wwiz sl myapp
wwiz ar myapp 
```


This workflow is flexible: we can easily hook into what's going on.
For the files push, we can type some bash commands into the **/path/to/myapp/scripts/myapp.deploy.sh** script.

For the database push, we can hack the tasks in the /path/to/webwizard/home/tasks.d dir, or even create our own.



 
 
 
 
 







  

 

 
 
 
 















