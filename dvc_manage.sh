#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 [-d directory] [-s start_date] [-r remove_date] [-h]"
    echo "  -d directory   Directory to check (default: current directory)"
    echo "  -s start_date  Start date in yyyy_mm_dd format (default: today's date)"
    echo "  -r remove_date Remove all collect_[number].dvc files before this date (format: yyyy_mm_dd)"
    echo "  -h             Display this help message"
    exit 0
}

# Default values
TARGET_DIR="."
START_DATE=$(date +'%Y_%m_%d')  # Default to today's date
REMOVE_DATE=""

# Parse command-line options
while getopts "d:s:r:h" opt; do
    case ${opt} in
        d )
            TARGET_DIR=$OPTARG
            ;;
        s )
            START_DATE=$OPTARG
            ;;
        r )
            REMOVE_DATE=$OPTARG
            ;;
        h )
            usage
            ;;
        * )
            usage
            ;;
    esac
done

# Function to remove .dvc files, cache, and remote data before a specific date, without removing local files
remove_old_dvc_files() {
    local dir=$1
    local remove_date=$2

    # Navigate to the target directory
    cd "$dir" || { echo "Failed to change directory to $dir"; exit 1; }

    echo "Removing .dvc files, cache, and remote data before $remove_date."

    # Find and remove all collect_[number].dvc files before the remove_date
    find . -type f -name 'collect_*.dvc' | while read -r dvc_file; do
        # Extract the date from the directory structure
        file_date=$(echo "$dvc_file" | grep -oP '\d{4}_\d{2}_\d{2}')
        if [[ "$file_date" < "$remove_date" ]]; then
            echo "Removing $dvc_file from DVC, cache, and remote storage."

            # First, unprotect and remove the data from remote and cache
            dvc unprotect "$dvc_file" || { echo "Failed to unprotect $dvc_file"; exit 1; }
            dvc remove "$dvc_file" || { echo "Failed to remove $dvc_file"; exit 1; }
            
            # Stage the removal of the .dvc file in Git
            git rm --cached "$dvc_file"

            # Remove the .dvc file itself, but do not affect local data
            rm -f "$dvc_file"
        fi
    done

    # Stage all modified files
    git add -u

    # Stage new (untracked) files, if necessary
    git add .

    # Commit the removal of the .dvc files to Git
    git commit -m "Remove old .dvc files before $remove_date" || { echo "Failed to commit changes to Git"; exit 1; }
}

# Function to check for .dvc files and push if not already pushed
push_dvc_files() {
    local dir=$1

    # Navigate to the target directory
    cd "$dir" || { echo "Failed to change directory to $dir"; exit 1; }

    echo "Checking and pushing all .dvc files."

    # Find all .dvc files
    find . -type f -name '*.dvc' | while read -r dvc_file; do
        echo "Checking $dvc_file..."
        
        # Check if the .dvc file's data has already been pushed
        if ! dvc status -r origin "$dvc_file" | grep -q "new data"; then
            echo "$dvc_file has already been pushed. Skipping..."
        else
            echo "Pushing $dvc_file to remote..."
            dvc push "$dvc_file" -j4 || { echo "Failed to push $dvc_file"; exit 1; }
        fi
    done

    echo "All .dvc files have been checked and pushed if necessary."
}

# Function to check if a date is greater than or equal to the start date
date_is_greater_or_equal() {
    local file_date=$1
    local filter_date=$2
    [[ "$file_date" > "$filter_date" || "$file_date" == "$filter_date" ]]
}

manage_dvc() {
    local dir=$1
    local start_date=$2
    local end_date=$3

    # Navigate to the target directory
    cd "$dir" || { echo "Failed to change directory to $dir"; exit 1; }

    echo "Searching for .dvc files from $start_date to $end_date."

    # Find all .dvc files with numbers from 00 to 10 or containing "faro" in all subdirectories
    local dvc_files
    dvc_files=$(find . -type f \( -name 'collect_*.dvc' -a \( -name 'collect_00.dvc' -o -name 'collect_01.dvc' -o -name 'collect_02.dvc' -o -name 'collect_03.dvc' -o -name 'collect_04.dvc' -o -name 'collect_05.dvc' -o -name 'collect_06.dvc' -o -name 'collect_07.dvc' -o -name 'collect_08.dvc' -o -name 'collect_09.dvc' -o -name 'collect_10.dvc' \) \) -o -name '*faro*.dvc')

    if [ -z "$dvc_files" ]; then
        echo "No collect_[00-10].dvc or files containing 'faro' found from $start_date to $end_date. Adding files to DVC."

        # Handle overlapping DVC files
        overlapping_files=$(dvc status | grep -oP "(?<=output: ).*")
        if [ -n "$overlapping_files" ]; then
            echo "Overlapping DVC files detected:"

            # Extract the list of overlapping files and remove them
            echo "$overlapping_files" | while read -r file; do
                echo "Removing overlapping file $file"
                dvc remove "$file" || { echo "Failed to remove overlapping file $file"; exit 1; }
            done
        fi

        # Find and add each file to DVC one by one, applying the date filter
        find . -type f ! -name '*.dvc' | while read -r file; do
            # Extract the date part from the file path (assuming it's in the format yyyy_mm_dd somewhere in the path)
            file_date=$(echo "$file" | grep -oP '\d{4}_\d{2}_\d{2}')

            # Only add the file if its date is greater than or equal to the start date
            if date_is_greater_or_equal "$file_date" "$start_date"; then
                full_path=$(realpath "$file")  # Get the full path of the file
                echo "Adding file $full_path to DVC..."
                dvc add "$file" || { echo "Failed to add $full_path to DVC"; exit 1; }
            else
                echo "Skipping file $file because its date ($file_date) is before $start_date"
            fi
        done

        # Commit the changes to each .dvc file
        for dvc_file in $(find . -type f -name '*.dvc'); do
            dvc commit "$dvc_file" || { echo "Failed to commit $dvc_file"; exit 1; }
            # Commit the .dvc files to git
            git add "$dvc_file"
            git commit -m "Add or update $dvc_file" || { echo "Failed to commit $dvc_file to git"; exit 1; }
        done
    else
        echo "collect_[00-10].dvc or files containing 'faro' already exist from $start_date to $end_date. No changes made."
    fi

    # Push all .dvc files, whether they were modified or not
    push_dvc_files "$dir"
}

# If remove_date is provided, remove old .dvc files
if [ -n "$REMOVE_DATE" ]; then
    remove_old_dvc_files "$TARGET_DIR" "$REMOVE_DATE"
else
    # Otherwise, manage the DVC files as usual
    manage_dvc "$TARGET_DIR" "$START_DATE" "$CURRENT_DATE"
fi
