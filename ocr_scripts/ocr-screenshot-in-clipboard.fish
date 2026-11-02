#!/usr/bin/env fish

set STRIP_NEWLINES false

# iterate through the list of arguments
for arg in $argv
    if test $arg = --strip-newlines
        set STRIP_NEWLINES true
    end
end

sleep 0.5s

grim -g (slurp -c "#74c7ecff" -d) - | wl-copy

sleep 0.5s

set OCR_OUTPUT (wl-paste | tesseract stdin stdout -l eng 2>/dev/null | string collect)

if test "$STRIP_NEWLINES" = true
    # Use 'string join' to replace newlines with spaces and 'string trim' to clean up
    echo -n "$OCR_OUTPUT" | string join " " | string replace -ra ' +' ' ' | string trim | wl-copy
    notify-send -i dialog-information "Screenshot OCR-ed" "Copied to clipboard & newlines removed." -t 3000
else
    echo "$OCR_OUTPUT" | wl-copy
    notify-send -i dialog-information "Screenshot OCR-ed" "Copied to clipboard & newlines preserved." -t 3000
end
