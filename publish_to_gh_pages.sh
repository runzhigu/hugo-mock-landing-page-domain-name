#!/bin/bash

###################################################################################
# Automatic gh-pages site updater
#
# Author:  Jérémie Lumbroso <lumbroso@seas.upenn.edu>
# Date:    February 13, 2024
#
# This script automates updating a GitHub Pages site hosted on the gh-pages branch 
# of a repository. It takes a local folder containing the static site content and 
# synchronizes it with the gh-pages branch.
#
# Usage:
#   $0 <content_folder> <github_username/repo>
#
# Example: 
#   $0 public integrimark/blog
#
###################################################################################

# Check if the correct number of arguments were passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <folder> <repo>"
    echo "Example: $0 public integrimark/hugo-landing-page"
    exit 1
fi

FOLDER=$(realpath "$1")  # Ensure we have the absolute path of the folder
REPO=$2
BRANCH="gh-pages"
TMP_REPO_DIR=$(mktemp -d)

# Check $FOLDER exists and is not empty before proceeding
if [ ! -d "$FOLDER" ] || [ -z "$(ls -A "$FOLDER")" ]; then
    echo "The folder is empty or does not exist."
    exit 1
fi

# Ensure the temporary directory exists
if [[ ! "$TMP_REPO_DIR" || ! -d "$TMP_REPO_DIR" ]]; then
  echo "Could not create temp directory."
  exit 1
fi

function cleanup {      
  rm -rf "$TMP_REPO_DIR"
  echo "Cleaned up temporary directory."
}

# Register the cleanup function to be called on the EXIT signal
trap cleanup EXIT

# Attempt to clone the gh-pages branch. If it doesn't exist, initialize a new repo and create an orphan gh-pages branch.
if git clone --branch $BRANCH "https://github.com/$REPO.git" "$TMP_REPO_DIR"; then
    echo "Cloned existing gh-pages branch."
else
    echo "gh-pages branch does not exist, creating..."
    mkdir -p "$TMP_REPO_DIR"
    cd "$TMP_REPO_DIR" || exit
    git init
    git checkout --orphan $BRANCH
fi

# Syncing the gh-pages branch with the folder content
rsync -av --delete --exclude '.git' "$FOLDER/" "$TMP_REPO_DIR/"

cd "$TMP_REPO_DIR" || exit

# Check if there are any changes. If so, commit and push them.
if [ -n "$(git status --porcelain)" ]; then
    git add .
    git commit -m "Update gh-pages"
    # Ensure the remote is set to the target repository
    git remote add origin "https://github.com/$REPO.git"
    git push -u origin $BRANCH
else
    echo "No changes to commit."
fi
