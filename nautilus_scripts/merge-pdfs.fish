#!/usr/bin/env fish

# check if ghostscript installed
command -q gs
or begin
    notify-send -i dialog-warning Warning "ghostscript not installed."\n"Use pacman to install."
    exit 1
end

set -l pdf_files

for f in $argv
    set -l mime (file --brief --mime-type -- "$f")
    test "$mime" = application/pdf
    and set -a pdf_files "$f"
end

# set -l pdf_file_num (count $pdf_files)

switch (count $pdf_files)
    case 0
        notify-send -i dialog-warning Warning "No PDF Files Selected! Exiting!"
        exit 1
    case 1
        notify-send -i dialog-warning Warning "One PDF File Selected! Not merging!"
        exit 1
end

set -l placeholder_pdf_name "merged-pdf-"(date '+%Y-%m-%d_%H-%M-%S')

set -l out_file (zenity --entry --text="Merged PDF file name (without suffix)" --entry-text="$placeholder_pdf_name")
or begin
    notify-send -i dialog-information Info "Exiting script, merging PDFs cancelled."
    exit 1
end
# remove accidentally written suffix
set out_file (string replace -ri '\.pdf$' '' -- "$out_file")

# default value for empty zenity field
test -z "$out_file"; and set out_file "$placeholder_pdf_name"

# create full path of the newly created pdf
set -l target (path dirname -- $pdf_files[1])/"$out_file".pdf

# if target file already exist, exit
if test -e "$target"
    zenity --question --no-markup --default-cancel \
        --text="The file $target already exists. Do you want to overwrite it?"
    or begin
        notify-send -i dialog-information Info "Exiting script!"
        exit 1
    end
end

# use ghostscript to merge pdfs
# redirect error messages to fish-script-errors.txt
set -l gs_err (gs -dQUIET -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile="$target" $pdf_files 2>&1 >/dev/null)
or begin
    begin
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] gs merge failed:"
        printf '  %s\n' $gs_err
    end >>~/.cache/fish-script-errors.txt
    notify-send -i dialog-error Error "Ghostscript merging PDFs failed."\n"Check ~/.cache/fish-script-errors.txt for more details."
    exit 1
end

notify-send -i dialog-information Info "Created $target"
