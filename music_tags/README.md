# Music Metadata / Tags Editor

This Fish script enables editing, adding and removing metadata/tags of mp3 files.

## Format of the music files

It's desirable to have the music files prepared in a single directory and named properly.
Each file must start with an index (ideally zero padded, e.g., 01, 02...) then separated from the rest of the file name by a space character or by `-` or `_`.

For batch renaming you can use e.g. `f2` command line utility.

```fish
# prepend all files with zero padded double digit index starting from 01
f2 -f '(.*)' -r '{1%02d} $1' -e
```

**Examples:**

```text
01 First Music File.mp3
02 Second Music File.mp3
```
I prefer the previous format.

```text
01 - First Music File.mp3
02 - Second Music File.mp3
or
01-First Music File.mp3
02-Second Music File.mp3
or
01 _ First Music File.mp3
02 _ Second Music File.mp3
and so on...
```

The script handles multiple spaces between the index and the rest of the file name.
Title tag, track number tag, and total tracks number tag are parsed from the filename.

## Images

You can add image serving as the front cover. The format of images must be either jpeg/jpg or png (script checks the format).
In the interactive mode supply the full path of the image (you can use tilde `~` instead of `/home/some_user`). The autocompletion works only for directories, the filename should be typed manually.

## Skipping the tag fields

You can skip tag fields in the interactive mode by pressing `return`. Then the tag remains untouched.

## Dependencies

`eyeD3` python package installed via `pipx`

## Usage

**Command:** `music-tags`

Run without arguments for CLI interactive usage.

### Options

`-h/--help`

`-r/--remove-tags <full dir path>`

Remove all tags from mp3 files.

**Example:**

```fish
music-tags -r ~/Music/some_artist/some_album
music-tags -r ~/Music/some_artist/some_album/
music-tags --remove-tags ~/Music/some_artist/some_album
music-tags --remove-tags=~/Music/some_artist/some_album
music-tags --remove-tags /home/some_user/Music/some_artist/some_album/
music-tags --remove-tags="/home/some_user/Music/some_artist/some_album/"
```
You should use qoutes if there are spaces in directory names, otherwise it's not necessary. Directory names can have trailing `/` character, even trailing spaces. These are handled by the script.

`-i/--remove-images <full dir path>`

Removes all images from metadata.


```fish
music-tags -i ~/Music/some_artist/some_album
music-tags -i ~/Music/some_artist/some_album/
music-tags --remove-images ~/Music/some_artist/some_album
music-tags --remove-images=~/Music/some_artist/some_album
music-tags --remove-images /home/some_user/Music/some_artist/some_album/
music-tags --remove-images="/home/some_user/Music/some_artist/some_album/"
```

