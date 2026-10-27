#!/usr/bin/env fish

function print_help
    echo "Command: music-tags"
    echo "Depends on eyeD3; install via pipx."
    echo "Without arguments runs the interactive script."
    echo
    echo "-h/--help: Prints this help."
    echo
    echo "-r/--remove-tags <full dir path>: Removes all tags."
    echo "music-tags --remove-tags=~/Music/artist/album"
    echo "music-tags --remove-tags=/home/tom/Music/artist/album/"
    echo "music-tags -r ~/Music/artist/album"
    echo
    echo "-i/--remove-images <full dir path>: Removes all images."
    echo "music-tags --remove-images ~/Music/artist/album"
    echo "music-tags --remove-images /home/tom/Music/artist/album/"
    echo "music-tags -i ~/Music/artist/album"
end

argparse --max-args=0 h/help 'r/remove-tags=' 'i/remove-images=' -- $argv
or begin
    print_help
    exit 1
end

if set -q _flag_h
    print_help
    exit 0
end

if set -q _flag_remove_images
    set -l dir (string replace -r -- '^~(?=/|$)' "$HOME" "$_flag_remove_images")
    set dir (string trim "$dir")

    if not test -d "$dir"
        echo "Not a valid directory: $dir" >&2
        exit 1
    end

    for f in $dir/*.mp3
        eyeD3 --remove-all-images -- "$f"
    end
    exit 0
end

if set -q _flag_remove_tags
    set -l dir (string replace -r -- '^~(?=/|$)' "$HOME" "$_flag_remove_tags")
    set dir (string trim "$dir")

    if not test -d "$dir"
        echo "Not a valid directory: $dir" >&2
        exit 1
    end

    for f in $dir/*.mp3
        eyeD3 --remove-all -- "$f"
    end
    exit 0
end

set -l music_dir
while true
    # can use ~ instead of /home/tom
    read --shell --prompt-str="Music Directory Path: " music_dir
    or exit 1 # if read aborted with ctrl c or ctrl d
    # replace tilde with $HOME
    set music_dir (string trim "$music_dir")
    set music_dir (string replace -r -- '^~(?=/|$)' "$HOME" "$music_dir")
    # remove trailing / in dir path
    set music_dir (string replace -r -- '/$' '' "$music_dir")
    if test -d "$music_dir"
        break
    else
        echo "The music directory path is not valid. Try again!" >&2
    end
end

set -l release_year
set -l release_year_args
while true
    read --prompt-str="Release Year (Enter to skip): " release_year
    or exit 1 # if read aborted with ctrl c or ctrl d
    if test -z "$release_year"
        break
    end
    if string match -qr '^[0-9]{4}$' "$release_year"
        set release_year_args --release-year "$release_year"
        break
    else
        echo "The release year is not valid. Try again!" >&2
    end
end

set -l album_name
set -l album_name_args
while true
    read --prompt-str="Album Name (Enter to skip): " album_name
    or exit 1 # if read aborted with ctrl c or ctrl d
    if test -z "$album_name"
        break
    end
    if string match -qr '^\w+' "$album_name" # must begin with word character
        set album_name_args --album "$album_name"
        break
    else
        echo "The album name is not valid. Try again!" >&2
    end
end

set -l album_artist
set -l album_artist_args
set -l artist_args
while true
    read --prompt-str="Album Artist Name (Enter to skip): " album_artist
    or exit 1 # if read aborted with ctrl c or ctrl d
    if test -z "$album_artist"
        break
    end
    if string match -qr '^\w+' "$album_artist" # must begin with word character
        set album_artist_args --album-artist "$album_artist"
        set artist_args --artist "$album_artist"
        break
    else
        echo "The album artist name is not valid. Try again!" >&2
    end
end

set -l genre
set -l genre_args

while true
    read --prompt-str="Genre (Enter to skip): " genre
    or exit 1 # if read aborted with ctrl c or ctrl d
    if test -z "$genre"
        break
    end
    if string match -qr '^\w+' "$genre" # must begin with word character
        set genre_args --genre "$genre"
        break
    else
        echo "The genre is not valid. Try again!" >&2
    end
end

set -l cover_path
set -l image_args

while true
    read --shell --prompt-str="Cover image path (Enter to skip): " cover_path
    or exit 1
    # if empty break
    if test -z "$cover_path"
        break
    end
    # replace tilde with $HOME
    set cover_path (string replace -r -- '^~(?=/|$)' "$HOME" "$cover_path")
    if test -f "$cover_path"
        # get mime type of file, eg, image/jpeg using file command
        set -l mime (file --brief --mime-type -- "$cover_path")
        if contains -- $mime image/jpeg image/png
            set image_args --add-image "$cover_path:FRONT_COVER:cover"
            break
        else
            echo "Cover must be a JPEG or PNG (got: $mime)" >&2
            continue
        end
    else
        echo "The cover path is not valid. Try again!" >&2
    end
end

set -l num_of_tracks (count $music_dir/*.mp3)

for f in $music_dir/*.mp3
    echo "Processing: $f"
    set -l clean_name (basename --suffix=".mp3" "$f")
    set -l title (string match -rg '^\d+\s*[-_]?\s*(.*)$' -- "$clean_name")
    or begin
        echo "Title parsing failed for file: $f" >&2
        continue # skip this file
    end
    set -l track_num (string match -rg '^0*(\d+)' -- "$clean_name")
    or begin
        echo "Track number parsing failed for file: $f" >&2
        continue # skip this file
    end
    # if empty image_args disappears
    # if not empty unquoted image_args expand to two separate arguments
    eyeD3 --title "$title" $artist_args $album_name_args \
        $album_artist_args $genre_args $release_year_args \
        --track "$track_num" --track-total "$num_of_tracks" \
        $image_args -- "$f"
end
