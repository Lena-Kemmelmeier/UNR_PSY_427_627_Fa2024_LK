In these demos, we will get ourselves into more complicated situations, in which files are changed in multiple places, and learn how to smoothly integrate changes into the archival github repository of the code. 

# Merge conflicts
Last time, we merged by default by simply pulling non-conflicting changes. This time, we will try to merge changes in which two users have made changes to the same lines in the same file. 

After the last class demo, you should be starting with three files in each of two directories (class_demo_A and class_demo_B). 

1. Verify that both directories are up-to-date by navigating to each directory in a terminal and calling `git fetch`, `git status`, and `git log -n 3` in each directory. The outputs should be the same. If not, push and/or pull changes to bring both repos to the same state. 
2. Go to class_demo_A in spyder or matlab. Edit the first line of first_file.py to change what is printed (any change is fine)
3. add, commit (with a commit message), and push the changes to your git repo
4. Go do class_demo_B in spyder or matlab. do NOT pull changes (yet). Once again edit the first line of first_file.py, making a DIFFERENT change than you made in the other folder. 
5. add and commit (with a commit message) the changes. Then call `git fetch` and `git status`
6. You should see that your repo and the remote repo each have 1 different commit. Now we are at the same point we were last time, but with changes that conflict (they are to the same line in the same file instead of to different files)
7. pull the remote changes, and let's see what happens. You should get a message that says:
```
Auto-merging first_file.py
CONFLICT (content): Merge conflict in first_file.py
Automatic merge failed; fix conflicts and then commit the result.
```
8. Do what the message says! Open up first_file.py in that folder in either spyder or matlab (or whatever other editor), edit the file to resolve conflicts (removing the portion of the code above the `========` line)
9. add and commit the changes; now you should be able to push, and pull in the other folder!

# Avoiding having conflicting changes
The best way to avoid making conflicting changes is to communicate regularly with other people on your team who may be making changes to the code. You don't technically need to use any of the below if you have a small enough team and good communication (each taking turns). This is not always feasible. SO, git provides *branches* to make changes that will not affect others using the code until you merge a whole set of changes to the main branch.  (We will discuss branches here)

1. Make sure that both folders are up-to-date, and start once again in class_demo_A.  Create a branch of code by calling: 
`git branch new_feature`
and switch over to that branch (This is a critical step!) by calling:
`git checkout new_feature`

2. Call `git status` to see that you are now on a different branch
3. This time, change everything in second_file.txt (edit the file in matlab or spyder)
4. Save the file, add your changes, and commit them with a commit message. 
5. Change directories to the class_demo_B folder. Stay on the main branch. Make a change to third_file.py (any change). Save the file, add the change and commit it with a commit message. push the change to the github repo. 
6. Change directories back to the class_demo_A folder (in terminal and in matlab / spyder). You want the changes to the main branch; so call `git checkout main` to switch your local code back to the main branch. You should see that the changes you made to third_file.py are GONE. (To see them again, you can call `git checkout new_feature` to go back to your local branch. If you do that, come back again to the main branch before proceeding). 
7. With the main branch active in class_demo_A, call `git pull`. You should get the update to third_file.py. Now we have two options: We can forcibly merge the changes in these two branches, or we can update (or "rebase") our new_feature branch to incorporate the changes on main, and keep working there. 
   
   (We will discuss this difference briefly)
8. Let's go with merge first. from main, call `git merge new_feature`. This is basically what we did last time - smashing code together. As before, you will have to deal with any conflicts manually. You may be dropped into an editor to add a commit message (because you have added a new element to the git history by smashing the code from your branch into main)
9. This could be the end, but let's try a different path. Let's revert the main branch to what is on the github repo. To get rid of the last commit (the merge), first call `git log -n 2` to show the last two commits. We want to rewind the clock to get rid of the last one. Commits are identified by cumbersome strings of random characters, e.g. `c1a9966d75f35e52e5343493e72dc3e5349ca7ea`. You will have to identify the commit to which you want to rewind by finding the relevant string in your git history.  It will look something like this: 
```

commit cff258ce7cfdb79afb1ae932eb9514d1c0bbb0bb (HEAD -> main)
Author: Mark Lescroart <mlescroart@unr.edu>
Date:   Thu Oct 31 13:04:34 2024 -0700

    useless commit

commit c1a9966d75f35e52e5343493e72dc3e5349ca7ea (origin/main, origin/HEAD)
Merge: 057f0a4 9732a16
Author: Mark Lescroart <mlescroart@unr.edu>
Date:   Tue Oct 29 14:34:27 2024 -0700

    Merge branch 'main' of github.com:marklescroart/teaching_git_Fa2024 into main
```

For this git history, the second commit here (not the latest, the second-latest) is the one to which we want to revert. So we would call: 
`git reset --hard c1a9966d75f35e52e5343493e72dc3e5349ca7ea` 

(Make sure you put your commit string in there!)

10. Now your repo's main branch should be in the same state as the remote (github) main branch - you can check this by calling `git status`, and you should no longer be 1 commit ahead.
11. The other approach besides a straight merge is to rewrite the history of our `new_feature` branch to allow the changes on main to occur first, and our changes to add to those. There are several reasons we might want to do this - most importantly, if we want to make a pull request to someone else's code that we don't have the authority to modify (more on pull requests later). To do this, first check out your branch (`git checkout new_feature`)
12. From that branch, call `git rebase main` Your code will be updated to look as if it was all done AFTER the changes on main, so it will be able to be merged in seamlessly. 
    
    (We will discuss merge vs rebase more in class)