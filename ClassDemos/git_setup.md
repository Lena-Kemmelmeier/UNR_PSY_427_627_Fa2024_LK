# Git setup

Prior to using git and github, please make sure you have the following set up: 

1. a git account
2. SSH keys for your user set up in your personal git page. You can create these on your computer using the command: 

`ssh-keygen -t rsa`

Please save these keys in the default location, which should be a folder called .ssh (the dot at the beginning means that this is a hidden folder; on mac and linux systems, it is in your home folder, ~/.ssh/)

You will be given an option to add a password, such that every time you use these keys to access your git account (to push, fetch, pull etc) you will need to enter that password. This is a good idea, but please don't forget whatever password you use. 

There should be two files created by the above step, id_rsa and id_rsa.pub You should open the id_rsa.pub (the public one) in matlab or spyder or whatever editor you want, and copy its full contents to a new ssh key in your git account. 

3. You also need to configure youur git user on your laptop (if you haven't yet). To test whether you have configured it, call: 

`git config --global user.name`

and

`git config --global user.email`

This shouuld print out your name and your email address for each of the two lines above. If you are not configured yet (if that doesn't spit out your name or if you get an error), call: 

`git config --global user.name "FIRST_NAME LAST_NAME"`

and

`git config --global user.email "your_name@unr.edu"`

to set each of these fields. Git requires accountabilty, so these two must be set one way or another; setting them globally for a computer that you principally work on is the easieset way to do this. 

That should be it! (fingers crossed that it is...)