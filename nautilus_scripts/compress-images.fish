#!/usr/bin/env fish

set -l quality (zenity --scale --text="Image Quality" --min-value=5 --max-value=100 --value=80 --step=5)

set -l outdir compressed
mkdir -p $outdir

for file in $argv
    test -f $file; or continue

    set -l ext (string lower (path extension $file))
    set -l base (path change-extension '' $file)

    switch $ext
        case .jpg .jpeg
            magick $file -strip -quality $quality $outdir/$file
        case .png
            magick $file -background white -alpha remove -alpha off \
                -strip -quality $quality $outdir/$base.jpg
        case '*'
            continue
    end

    or notify-send "Failed compression: $file" >&2
end

notify-send "Image compression finished."
