#!/bin/bash

# Array of directories to add
directories=(
    "data/site_CMUCampus/2024_04_16/collect_01"
    "data/site_CMUCampus/2024_05_03/collect_01"
    "data/site_FlagstaffHill/2024_05_03/collect_01"
    "data/site_FlagstaffHill/2024_05_03/collect_02"
    "data/site_FlagstaffHill/2024_06_04/collect_01"
    "data/site_FrickPark/2024_05_14/collect_01"
    "data/site_FrickPark/2024_05_14/collect_02"
)

# Add each directory to DVC
for dir in "${directories[@]}"
do
    if [ -d "$dir" ]; then
        dvc add "$dir"
    else
        echo "Directory $dir does not exist."
    fi
done

# Add the generated .dvc files to Git
for dir in "${directories[@]}"
do
    dvc_file="$dir.dvc"
    if [ -f "$dvc_file" ]; then
        git add "$dvc_file"
    else
        echo "DVC file $dvc_file does not exist."
    fi
done

# Add .gitignore changes
git add data/.gitignore

# Commit the changes to Git
git commit -m "Add collect folders to DVC"
