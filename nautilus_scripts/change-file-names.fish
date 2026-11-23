#!/usr/bin/env fish

# $argv - all arguments passed into this script by a file manager
# $argv - Nautilus gets only the relative path, Strata gets full path

# filter only files from passed in paths
set -l selected_files (path filter --type file -- $argv)
# full path of all files
set selected_files (path resolve -- $selected_files)

set -l counter 0

for file in $selected_files
    set -l base_name (path basename -- "$file")
    set -l dir_name (path dirname -- "$file")
    set -l renamed_base (string lower -- "$base_name")
    set renamed_base (string replace -- "'" "" "$renamed_base")
    set renamed_base (string replace -r -a -- '[ _]+' '-' "$renamed_base")
    # remove redundant dashes (2 or more)
    set renamed_base (string replace -r -a -- '-{2,}' '-' "$renamed_base")

    if test "$renamed_base" != "$base_name"
        mv "$file" "$dir_name"/"$renamed_base"
        set counter (math $counter + 1)
    end
end

notify-send -i dialog-information Info "Number of changed file names: $counter"
