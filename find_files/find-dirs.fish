#!/usr/bin/env fish

# add as many directories as you want, separated by : replacements for FUZZEL
set -l query_dirs $HOME/Documents:DOCS $HOME/Pictures:PICS \
    $HOME/Code:CODE $HOME/Projects:PROJECTS $HOME/.config/nvim:NVIM \
    $HOME/.local/share/snippets:SNIPPETS $HOME/.config/hypr:HYPR \
    $HOME/.local/share/dotfiles:DOTFILES

if not test -d ~/.cache/find_files
    mkdir -p ~/.cache/find_files
end

set -l dir_cache ~/.cache/find_files

function update_db --inherit-variable query_dirs --inherit-variable dir_cache
    set -l lines_for_dirs_db
    for query_dir in $query_dirs
        # split the query_dir along :
        set -l matches (string match -rg -- '^([^:]+):(.*)$' "$query_dir")
        set -l clean_query_dir "$matches[1]"
        set -l replacement (string trim "$matches[2]")
        # if dir doesn't exist continue in loop
        test -e "$clean_query_dir"; or continue
        set -a lines_for_dirs_db "$query_dir" # add itself to the db

        set -l dir_paths (fd . --type directory "$clean_query_dir")
        for dir_path in $dir_paths
            set dir_path (string trim -- "$dir_path")
            if test -d "$dir_path"
                set -l short_dir_path (string replace "$clean_query_dir" "$replacement" -- "$dir_path")
                set -l line_for_dirs_db "$dir_path:$short_dir_path"
                set -a lines_for_dirs_db "$line_for_dirs_db"
            end
        end
    end
    set -a lines_for_dirs_db "Update:Update Database"
    printf '%s\n' $lines_for_dirs_db >"$dir_cache/dirs-db.txt"
    # sort file in place based on the second field separated by :
    sort --field-separator : --key 2 --output "$dir_cache/dirs-db.txt" "$dir_cache/dirs-db.txt"
end

if not test -e "$dir_cache/dirs-db.txt"
    update_db
    notify-send -i emblem-default "Created Database" "Directory database created in .cache/find_files"
end

set chosen_line (fuzzel --dmenu --counter --nth-delimiter=":" --with-nth 2 --accept-nth 1 --width 60 --prompt="$prompt" --placeholder=" 󰌑 Strata 󰘵 1 Yazi 󰘵 2 Kitty 󰘵 3 Zen 󰘵 4 Imv" < "$dir_cache/dirs-db.txt")
set -l fuzzel_status $status

# on pressing Esc Fuzzel status is 2
test $fuzzel_status -eq 2; and exit 0

if test "$chosen_line" = Update
    update_db
    notify-send -i emblem-default "Updated Database" "Directory database updated in .cache/find_files"
    exit 0
end

# $status 2 means fuzzel was exited using Esc, $status 0 Return fuzzel value
# $status 10 Alt+1 plays in amberol; $11 Alt+2 eartag
switch $fuzzel_status
    case 0
        strata "$chosen_line" &
        disown
    case 10
        kitty --app-id yazi -e yazi "$chosen_line" &
        disown
    case 11
        kitty --app-id kitty-editor -e nvim "$chosen_line" &
        disown
    case 12
        zen --new-tab "$chosen_line" &
        disown
    case 13
        imv "$chosen_line" &
        disown
    case '*'
        exit 0
end
