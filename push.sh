#!/bin/bash

echo -e "\033[0;32mDeploying markdown updates to GitHub...\033[0m"

# Go To Public folder
echo -e "\033[0;32mPull markdown code from GitHub...\033[0m"
git pull

git add *

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

git branch -M main
# Push source and build repos.


echo -e "\033[0;32mPush markdown code to GitHub...\033[0m"

git push -u origin main

# Come Back up to the Project Root

