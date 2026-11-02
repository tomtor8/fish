#!/usr/bin/env fish

# add as many directories with music as you want
set -l dirs ~/Code ~/Projects

test -d ~/.cache/find_files; or mkdir -p ~/.cache/find_files

set -l file_cache ~/.cache/find_files

function update_db --inherit-variable dirs --inherit-variable file_cache
    set -l lines_for_files_db
    for d in $dirs
        test -e $d; or continue # skip nonexistent dir

        set -l file_paths (fd . -e lua -e fish -e py -e sh $d)
        for file_path in $file_paths
            set file_path (string trim -- "$file_path")
            if test -f "$file_path"
                set -l clean_file_path (string replace --all -r "(-|_)" " " -- "$file_path")
                set -l split_file_path (string split -r -m3 / "$clean_file_path")
                set -l combined_name "$split_file_path[-3]/$split_file_path[-2] > $split_file_path[-1]"
                set -l line_for_files_db "$file_path:$combined_name"
                set -a lines_for_files_db "$line_for_files_db"
            end
        end
    end
    # add an Update line to trigger db update
    set -a lines_for_files_db "Update:Update Database"
    printf '%s\n' $lines_for_files_db >"$file_cache/script-files-db.txt"
    # sort file in place based on the second field separated by :
    sort --field-separator : --key 2 --output "$file_cache/script-files-db.txt" "$file_cache/script-files-db.txt"
end

if not test -e "$file_cache/script-files-db.txt"
    update_db
    sleep 1
    notify-send -i emblem-default "Created Database" "Script files database created in .cache/find_files"
end

set -l chosen_line (fuzzel --dmenu --counter --nth-delimiter=":" --with-nth 2 --accept-nth 1 --width 80 --prompt="Script Files > " --placeholder=" 󰌑 Kitty 󰘵 1 View only 󰘵 2 Foot" < "$file_cache/script-files-db.txt")
set -l fuzzel_status $status

# on pressing Esc Fuzzel status is 2
test $fuzzel_status -eq 2; and exit 0

if test "$chosen_line" = Update
    update_db
    notify-send -i emblem-default "Updated Database" "Script files database updated in .cache/find_files"
    exit 0
end

# $status 0 Return fuzzel value, opens in kitty
# $status 10 Alt+1 opens script file in kitty in read only mode
# $status 11 Alt+1 opens script file in foot
switch $fuzzel_status
    case 0
        kitty --app-id kitty-editor -e nvim "$chosen_line" &
        disown
    case 10
        kitty --app-id kitty-editor -e nvim -M "$chosen_line" &
        disown
    case 11
        foot --app-id foot-editor -e nvim "$chosen_line" &
        disown
    case '*'
        exit 0
end
