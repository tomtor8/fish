#!/usr/bin/env fish

# $argv - all arguments passed into this script by a file manager
# $argv - Nautilus gets only the relative path, Strata gets full path

# filter only files from passed in paths
set -l selected_files (path filter --type file -- $argv)
# full path of all files
set selected_files (path resolve -- $selected_files)

set -l counter 0
set -l skipped_counter 0

for file in $selected_files
    set -l base_name (path basename -- "$file")
    set -l dir_name (path dirname -- "$file")
    set -l renamed_base (string lower -- "$base_name")
    set renamed_base (string replace -- "'" "" "$renamed_base")
    set renamed_base (string replace -r -a -- '[ _]+' '-' "$renamed_base")
    # remove redundant dashes (2 or more)
    set renamed_base (string replace -r -a -- '-{2,}' '-' "$renamed_base")

    if test "$renamed_base" != "$base_name"
        set -l new_file_name "$dir_name"/"$renamed_base"
        if test -e "$new_file_name"
            set skipped_counter (math $skipped_counter + 1)
            begin
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] file renaming failed:"
                echo "$file"
                echo
            end >>~/.cache/fish-script-errors.txt
            continue
        end
        mv "$file" "$new_file_name"
        set counter (math $counter + 1)
    end
end

set -l notify_args
test $skipped_counter -gt 0
and set notify_args -u critical -t 10000

# final notification
set -l changed "Number of changed file names: $counter"
set -l skipped "Number of skipped files: $skipped_counter"
set -l errors "Check ~/.cache/fish-script-errors.txt"

notify-send $notify_args -i dialog-information Info \
    "$changed"\n"$skipped"\n"$errors"
