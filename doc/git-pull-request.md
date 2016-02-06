Github pull request 
=======================
2016-02-06




Memo for making a pull request on github.
 
 
 
1\. Go to github.com and fork the repository you want to update by clicking the fork button.

This will create a forked version (your version) of the repository.
For the demo, I will fork the [awesome-shell](https://github.com/alebcay/awesome-shell) repository.

Once I click the fork button, I have the following repository created.

```bash
https://github.com/lingtalfi/awesome-shell
```


2\. On your machine, cd to the directory where you want to work, and clone the forked repository you want to update
 
```bash
cd ~/gitforks
git clone https://github.com/lingtalfi/awesome-shell.git
```

3\. Cd into the local copy, and make sure you have the latest version before you start working on it

```bash
cd awesome-shell
git pull origin master
```

4\. Create a new branch (in this demo called pull-request-demo)

```bash
git checkout -b pull-request-demo
```

5\. Now work on it...

6\. When the new version is ready, commit it, then push it back to your forked public repository

```bash
git snap add k tool
git push origin pull-request-demo
```

Note: snap comes from my-git-config, this is basically a commit.


7\. Now go to github.com, to the forked repository version (https://github.com/lingtalfi/awesome-shell in my case),
        and refresh the page. Switch to your pull branch (using the selector on the page where it says branch: master),
        and then click the "New pull request" button.
        
        
8\. In the "Open a pull request" dialog, leave a comment if you want, then push the "Create pull request" button
        
9\. Then wait for the response of the forked repo's owner.
            By now your job is done.
        
         
         





Sources
----------

- Tutorial: https://yangsu.github.io/pull-request-tutorial/
- Special git commands (dd, snap), comes from [my git config](https://github.com/lingtalfi/my-git-config)
