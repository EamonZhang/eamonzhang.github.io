#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the project.
cd public 

echo -e "\033[0;32mPull code from GitHub...\033[0m"

git pull origin main

cd ..

echo -e "\033[0;32mBuild pages to public folder...\033[0m"

hugo -t simple # if using a theme, replace with `hugo -t <YOURTHEME>`

# Go To Public folder
cd public
# Add changes to git.

git add .

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
echo -e "\033[0;32mPush pages update to GitHub...\033[0m"
git push origin main

# Come Back up to the Project Root
cd ..

echo -e "\033[0;32m Well done !!!, GOOK LUCK Eamon ...\033[0m"
