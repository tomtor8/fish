#!/usr/bin/env fish

# check if img2pdf installed
command -q img2pdf
or begin
    notify-send -i dialog-warning Warning "img2pdf not installed."\n"Use pipx or pacman to install."
    exit 1
end

set -l image_files

# $argv are selected files in Nautilus
for f in $argv
    set -l mime (file --brief --mime-type -- "$f")
    if contains -- "$mime" image/jpeg image/png
        set -a image_files "$f"
    end
end

# check if image_files is an empty list
test (count $image_files) -eq 0
and begin
    notify-send -i dialog-warning Warning "No Image Files Selected!"
    exit 1
end

set -l out (zenity --forms --title="Convert Images to PDF" \
    --add-entry="PDF Name Without Suffix" \
    --add-entry="Border Top/Bottom in cm" \
    --add-entry="Border Left/Right in cm" \
    --add-combo="Pagesize" --combo-values="A4 Portrait|A4 Landscape|No Pagesize" \
    --separator="|")
or exit 1

set -l fields (string split '|' -- $out)
# remove redundant pdf suffix
set -l pdf_name (string replace -ri '\.pdf$' '' -- "$fields[1]")
# replace eg 0,5 for 0.5
set -l top_bottom_border (string replace , . -- "$fields[2]")
set -l left_right_border (string replace , . -- "$fields[3]")

# defaults for empty fields
# date sets unix timestamp
test -z "$pdf_name"; and set pdf_name converted-document-(date +%s)
test -z "$top_bottom_border"; and set top_bottom_border 0
test -z "$left_right_border"; and set left_right_border 0

# validate numbers
for v in $top_bottom_border $left_right_border
    if not string match -qr '^\d+(\.\d+)?$' -- $v
        notify-send -i dialog-error Error "Invalid border value: $v"
        exit 1
    end
end

set -l pagesize_args
switch "$fields[4]"
    case "A4 Portrait"
        set pagesize_args --pagesize A4
    case "A4 Landscape"
        set pagesize_args --pagesize "A4^T"
end

# create full path of the newly created pdf
set -l target (path dirname -- $image_files[1])/"$pdf_name".pdf

# if target file already exist, exit
if test -e "$target"
    zenity --question --no-markup --default-cancel \
        --text="The file $target already exists. Do you want to overwrite it?"
    or begin
        notify-send -i dialog-information Info "Exiting script!"
        exit 1
    end
end

img2pdf $image_files --output "$target" $pagesize_args \
    --border "$top_bottom_border"cm:"$left_right_border"cm
or begin
    notify-send -i dialog-error Error "Failed conversion of images to PDF."
    exit 1
end

notify-send -i dialog-information Info "Created $target"
