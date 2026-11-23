#!/usr/bin/env fish

# $argv - all arguments passed into this script by a file manager
# $argv - Nautilus gets only the relative path, Strata gets full path
set -l quality (zenity --scale --text="Image Quality" \
    --min-value=5 --max-value=100 --value=80 --step=5)
or begin
    # exit on pressing Cancel button
    notify-send -i dialog-information Info "Exiting image compression script!"
    exit 0
end

# filter only files from passed in paths
set -l selected_files (path filter --type file -- $argv)
# full path of all files
set selected_files (path resolve -- $selected_files)

# get parent directory name eg /home/user/Pictures
set parent_dir (path dirname -- "$selected_files[1]")

set -l outdir "$parent_dir"/compressed
mkdir -p $outdir

for file in $selected_files
    set -l ext (string lower (path extension $file))
    set -l base (path change-extension '' $file)

    switch $ext
        case .jpg .jpeg
            magick $file -strip -quality $quality $outdir/(path basename -- "$file")
        case .png
            magick $file -background white -alpha remove -alpha off \
                -strip -quality $quality $outdir/(path basename -- "$base").jpg
        case '*'
            continue
    end

    or notify-send -i dialog-error Error "Failed compression: $file" >&2
end

notify-send -i dialog-information Info "Image compression finished."
