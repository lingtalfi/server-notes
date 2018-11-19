My git workflow (local)
===================
2018-11-19


(loosing memory again?)



Here is what I do on my machine to create a new git repository and push it to github.com:



- create the directory (example_dir)
- cd example_dir
- ginit example_project (doing git init, plus internal tracking reference work)
- go to github.com, create a new repository (example_repo)
    - copy the line: git remote add origin https://github.com/lingtalfi/example_repo.git
- (paste) git remote add origin https://github.com/lingtalfi/example_repo.git
- git snap (add and commit all files)
- git pp (push with tags to origin master)


Then to update:
- cd example_dir
- git snap
- git pp


