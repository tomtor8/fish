# Scripts for Nautilus

- in `~/.local/share/nautilus/scripts/`create your custom scripts (bash, fish, lua...)
- make the scripts executable and they will show up in the context menu in Nautilus on file selection
- you can select multiple files or directories
- all selected items are passed into a script (in case of Fish as `$argv`)
- use for loops to process them

## Compress images script

- uses `zenity` to choose a compression rate
- files are compressed accordingly and converted to `jpg`
- all compressed files are moved to `compressed` directory that is automatically creating in the current working directory
- you can select one or more image files

## images2pdf

A Nautilus script that merges the selected JPEG and PNG images into a single PDF using [img2pdf](https://gitlab.mister-muffin.de/josch/img2pdf).

### Features

- Works on the files selected in Nautilus (non-JPEG/PNG files are ignored)
- Small Zenity form for the PDF name, page borders and page size
- Page size: A4 portrait, A4 landscape, or none (page size follows the image)
- Borders in cm, with top/bottom and left/right set separately (decimal comma accepted, e.g. `0,5`)
- Sensible defaults: an empty name becomes `converted-document-<unix timestamp>`, empty borders become `0`
- Asks before overwriting an existing file
- Desktop notifications for warnings, errors and success

### Requirements

- [Fish](https://fishshell.com/) 3.5 or newer (uses the `path` builtin)
- `img2pdf` (e.g. `pipx install img2pdf` or `pacman -S img2pdf`)
- `zenity`
- `notify-send` (libnotify)
- `file`

### Installation

```fish
cp images2pdf.fish ~/.local/share/nautilus/scripts/"Images to PDF"
chmod +x ~/.local/share/nautilus/scripts/"Images to PDF"
```

### Usage

1. In Nautilus, select the images (JPEG/PNG).
2. Right-click → **Scripts** → **Images to PDF**.
3. Fill in the form (all fields are optional) and confirm.
4. A notification reports when the PDF is ready.
5. The PDF is saved next to the first selected image

Pages follow the order in which Nautilus passes the files to the script.

### Notes

- PNGs with transparency are supported (stored as a soft mask).
- JPEGs are embedded without re-encoding; PNGs are recompressed losslessly.
