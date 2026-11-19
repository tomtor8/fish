#!/usr/bin/env fish

function print_help
    echo "Command: music-tags"
    echo "Depends on eyeD3; install via pipx."
    echo "Without arguments runs the interactive script."
    echo
    echo "-h/--help: Prints this help."
    echo "-r/--remove-tags: Removes all tags."
    echo "-i/--remove-images: Removes all images."
    echo "-s/--show: Shows all tags."
end

# `pick_dir` without arguments starts fd in the current directory
# `pick_dir ~/some/path` starts fd in the mentioned directory
# the second argument is a header
function pick_dir --description 'Fuzzy-find a directory and print its full path'
    set -l root .
    set -q argv[1]; and set root $argv[1]

    fd --type d --absolute-path . $root \
        | fzf --height 40% --reverse --header="$argv[2]"
end

function pick_file --description 'Fuzzy-find an image file and print its full path'
    set -l root .
    set -q argv[1]; and set root $argv[1]

    # with-nth shows only the last three parts of the path but accepts the whole path
    fd --type f --extension png --extension jpeg --extension jpg --absolute-path . $root \
        | fzf --height 40% --reverse --header="$argv[2]" --delimiter / --with-nth -3..-1
end

# first arg is target path, second arg is header, third to last is command to run
function pick_and_run --description 'Pick an mp3 directory and run a command on it'
    set -l dir (pick_dir "$argv[1]" "$argv[2]")
    or exit 1

    # $dir must not be empty string
    test -n "$dir"; and test -d "$dir"; or exit 1

    # check if directory contains mp3 files
    if count "$dir"/*.mp3 >/dev/null
        # argv[3..-1] is the command with arguments
        for f in "$dir"/*.mp3
            $argv[3..-1] "$f"
        end
    else
        echo "No mp3 files in directory: $dir" >&2
        exit 1
    end
end

argparse --max-args=0 --exclusive h,show,remove-images,remove-tags \
    h/help s/show i/remove-images r/remove-tags -- $argv
or exit 1

if set -q _flag_h
    print_help
    exit 0
else if set -q _flag_show
    pick_and_run /home/tom "Pick Directory of MP3s to Show Tags" eyeD3
    # exit 0 hides any failures
    exit
else if set -q _flag_remove_images
    pick_and_run /home/tom "Pick Directory of MP3s to Remove Image Tags" eyeD3 --remove-all-images --
    exit
else if set -q _flag_remove_tags
    pick_and_run /home/tom "Choose Directory of MP3s to Remove All Tags" eyeD3 --remove-all --
    exit
end

##### CHOOSE DIRECTORY OF MP3s #####
set -l music_dir (pick_dir /home/tom "Choose Directory of MP3s to Add Tags")
or exit 1

test -n "$music_dir"; and test -d "$music_dir"; or exit 1

# check if directory contains mp3 files
count "$music_dir"/*.mp3 >/dev/null
or begin
    echo "No mp3 files in directory: $dir" >&2
    exit 1
end

##### SET RELEASE YEAR #####
set -l release_year
set -l release_year_args
while true
    set release_year (gum input --prompt="Release Year: " --placeholder="2026" --prompt.foreground="115")
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

##### SET ALBUM NAME #####
set -l album_name
set -l album_name_args
while true
    set album_name (gum input --prompt="Album Name: " --placeholder="Album name..." --prompt.foreground="115")
    or exit 1

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
    set album_artist (gum input --prompt="Album Artist: " --placeholder="Artist name..." --prompt.foreground="115")
    or exit 1

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
    set genre (gum input --prompt="Genre: " --placeholder="Cool genre name..." --prompt.foreground="115")
    or exit 1

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

if gum confirm "Do you want to set a front cover image?" --selected.background="150" --selected.foreground="0" --prompt.foreground="115"
    while true
        set cover_path (pick_file /home/tom "Choose a Front Cover (jpeg, jpg, png)")
        or break

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
end

set -l num_of_tracks (count "$music_dir"/*.mp3)

for f in "$music_dir"/*.mp3
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
