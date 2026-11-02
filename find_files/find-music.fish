#!/usr/bin/env fish

# add as many directories with music as you want
set -l music_dirs ~/Music

test -d ~/.cache/find_files; or mkdir -p ~/.cache/find_files

set -l music_cache ~/.cache/find_files

function update_db --inherit-variable music_dirs --inherit-variable music_cache
    set -l lines_for_artists_db
    set -l lines_for_albums_db
    for music_dir in $music_dirs
        test -e $music_dir; or continue # if dir nonexistent skip

        set -l artist_paths (fd '.*' --type directory --min-depth 1 --max-depth 1 $music_dir)
        for art_path in $artist_paths
            set art_path (string trim -- "$art_path")
            if test -d "$art_path"
                set -l short_art_path (string replace --all "_" " " -- (basename "$art_path"))
                set -l line_for_artists_db "$art_path:$short_art_path"
                set -a lines_for_artists_db "$line_for_artists_db"
            end
        end
    end
    printf '%s\n' $lines_for_artists_db >"$music_cache/artists-db.txt"
    # sort file in place based on the second field separated by :
    sort --field-separator : --key 2 --output "$music_cache/artists-db.txt" "$music_cache/artists-db.txt"
    for music_dir in $music_dirs
        test -e $music_dir; or continue

        set -l album_paths (fd '.*' --type directory --min-depth 2 --max-depth 2 $music_dir)
        for alb_path in $album_paths
            set alb_path (string trim -- "$alb_path")
            if test -d "$alb_path"
                set -l dir_name (string split -r -m1 / (dirname "$alb_path"))
                set -l base_name (basename "$alb_path")
                set -l combi_name "$dir_name[-1] > $base_name"
                set combi_name (string replace --all "_" " " -- "$combi_name")
                set -l line_for_albums_db "$alb_path:$combi_name"
                set -a lines_for_albums_db "$line_for_albums_db"
            end
        end
    end
    printf '%s\n' $lines_for_albums_db >"$music_cache/albums-db.txt"
    sort --field-separator : --key 2 --output "$music_cache/albums-db.txt" "$music_cache/albums-db.txt"
end

if not test -e "$music_cache/artists-db.txt"
    or not test -e "$music_cache/albums-db.txt"
    update_db
    notify-send -i emblem-default "Created Database" "Music database created in .cache/find_files"
end

# Choose category
set -l category (printf 'Albums\nArtists\nUpdate Database' | fuzzel --dmenu --width 30 --minimal-lines --prompt="Pick Category > ")
# pressing everything except Return exits the script
test $status -ne 0; and exit 0

set -l fuzzel_status
set -l full_path

switch $category
    case Artists
        set prompt "Artists > "
        set db artists-db.txt
    case Albums
        set prompt "Albums > "
        set db albums-db.txt
    case "Update Database"
        update_db
        notify-send -i emblem-default "Updated Database" "Updated music database in .cache/find_files"
        exit 0
    case '*'
        exit 0
end

set full_path (fuzzel --dmenu --counter --nth-delimiter=":" --with-nth 2 --accept-nth 1 --width 60 --prompt="$prompt" --placeholder=" 󰌑 Kew 󰘵 1 Mpv 󰘵 2 Eartag" < "$music_cache/$db")
set fuzzel_status $status

# $status 2 means fuzzel was exited using Esc, $status 0 Return fuzzel value
# $status 10 Alt+1 plays in amberol; $11 Alt+2 eartag
switch $fuzzel_status
    case 0
        foot --app-id kew -e kew play "$full_path" &
        disown
    case 10
        foot --app-id mpv -e mpv --no-video "$full_path" &
        disown
    case 11
        eartag "$full_path" &
        disown
    case '*'
        exit 0
end
