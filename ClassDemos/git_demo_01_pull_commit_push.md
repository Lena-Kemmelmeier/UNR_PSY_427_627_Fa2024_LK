# Git demo 1: clone, pull, add/commit, push
This is a demo of basic git functionality. 

1. To assure that everyone is starting with a clean repo, please FORK the following repo to your personal git repository:

http://github.com/piecesofmindlab/teaching_git

keep the name as `teaching_git`

2. Create a folder on your computer in which you will be working. Choose somewhere sensible, in your code folder, on your desktop, etc. Make sure you can navigate a terminal and matlab or spyder to that location. 

(open a terminal from anaconda navigator to assure that you have git functionality in the terminal; make sure you have git installed in the environment from which you open the terminal)

3. clone your fork of this repo to your local folder: first, navigate to that folder in a terminal. We are going to clone two separate versions of this repo to your machine in two separate folders - so call the commands: 

`git clone git@github.com:<your git account>/teaching_git.git class_demo_A`

`git clone git@github.com:<your git account>/teaching_git.git class_demo_B`

Leave your terminal open and change directories into the class_demo_A folder. 

4. In spyder or matlab, navigate to the class_demo_A folder. Open the first_file.py file, and add a line to it. Save it. 

5. In the terminal, type 

`git status`

You should see the first_file.py file in red, indicating that it has been changed. 

6. Add this file to the staging area for git changes (this says you are aiming to commit these changes, but does not yet commit them to the permanent history)

`git add .`

The . adds all files that have been changed, deleted, or added to the staging area. 

7. To commit the changes to the record, call:

`git commit -m "Update to first_file.py"`

Don't forget the -m and quotes! Otherwise you will be dropped into an editor to add a commit message. There are conventions to make commit messages more informative to experienced users, but those are out of scope for now. 

8. To see the changelog, call:

`git log -n 1`

to display the last git message

9. To push the changes to your git repo, call: 

`git push`

If you have your ssh keys and email and username configured correctly, this should upload the changes you have made to the git repo. 

10. Now we will simulate updating anotehr computer with the changes you have made. In your terminal app, change directories to the other repo you cloned (`class_demo_B`)Call: 

`git status`

To show what's going on in this repo right now. Then call: 

`git fetch`

to get an updated list of what (if anything) has happened in the remote repository on github. Once you've called that, call 

`git status` 

again, and you should see a message telling you that your repo is behind the repo on github. 

Call

`git pull` 

to copy the changes and history from the remote repo into THIS directory too. Then call 

`git log -n 2` 

to see the message about what was changed. 

## We are now going to make two kinds of changes to the files in our git repo, one of which will cause problems and one of which will not. 

11. Go back to the class_demo_A folder in matlab or spyder. 

- In that folder, add a new file. Call it `second_file.txt`, and add a line or two of text (whatever you want). 
- Add, commit, and push that change
- change directories in the terminal to the other folder (class_demo_B). Now add a DIFFERENT file, called `third_file.m` Add some text to it. 
- Add and commit that change. Then TRY topush the change to the main repo. You should get an error that the remote repo has changes too. 

12. These changes are easy to reconcile, since they modified different files. All you have to do in this case is pull the remote repo and the changes will be automatically *merged*. 
- call `git pull`
- add a commit message in the command-line editor, save the commit message, and quit. 
- Push the resulting changes back to the remote repo (what command will you use?)
- Go back to the class_demo_A folder and pull those changes (what command will you use?). Now both folders (both simulated computers) have up-to-date code. 

13. Now we're going to get ourselves in trouble. Open class_demo_A in matlab or spyder, and make a change to the text in one line of the file. Then open the OTHER version of the same file in the other folder (class_demo_B), and make a change to the *same line of the same file* in that directory. Add and commit the changes in both folders separately. 

This situation is analogous to two people making changes to the same lines of code in a script or a part of a code library - it can certainly happen. git provides mechanisms to resolve these changes. 

14. from the class_demo_A folder in the terminal, call `git push`

15. Note that we won't be able to push from the other folder, because liek before there are now changes there. So instead, from the class_demo_B folder in the terminal, call `git pull`. 

