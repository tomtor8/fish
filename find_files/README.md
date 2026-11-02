# Fish scripts for finding stuff

## Find directories

- `find-dirs.fish` finds directories in selected paths and feeds them to the `Fuzzel` dmenu
- launch the script with `SUPER + P` then `D` keybind submap
- after creating/adding new directories, update the local database by launching the script and choosing the `Update Database` line in `Fuzzel`
- the database file is located at `~/.cache/find_files/dirs-db.txt` (the file is created automatically)

## Find pdfs

- finds `pdf` files in selected paths and feeds them to the `Fuzzel` dmenu
- the files are displayed with their two parent directories
- launch the script with `SUPER + P` then `P` keybind submap
- after creating/adding new PDF files, update the local database by launching the script and choosing the `Update Database` line in `Fuzzel`
- the database file is located at `~/.cache/find_files/pdfs-db.txt` (the file is created automatically)

### Opening pdfs

Press `Return` to open in `zathura`.
Press `Alt+1` to open in `Zen Browser` tab.

## Find text files

- finds `md` and `txt` files in selected paths and feeds them to the `Fuzzel` dmenu
- the files are displayed with their two parent directories
- launch the script with `SUPER + P` then `T` keybind submap
- after creating/adding new text files, update the local database by launching the script and choosing the `Update Database` line in `Fuzzel`
- the database file is located at `~/.cache/find_files/text-files-db.txt` (the file is created automatically)

### Opening text files

Press `Return` to open in `Neovim in Kitty`.
Press `Alt+1` to open in `Neovim in Kitty` in read-only mode.
Press `Alt+2` to open in `Neovim in Foot`.
Press `Alt+3` to open in `Zen Browser` tab.

## Find scripts

- finds `lua`, `fish`, `py`, and `sh` files in selected paths and feeds them to the `Fuzzel` dmenu
- the files are displayed with their two parent directories
- launch the script with `SUPER + P` then `S` keybind submap
- after creating/adding new script files, update the local database by launching the script and choosing the `Update Database` line in `Fuzzel`
- the database file is located at `~/.cache/find_files/script-files-db.txt` (the file is created automatically)

### Opening scripts

Press `Return` to open in `Neovim in Kitty`.
Press `Alt+1` to open in `Neovim in Kitty` in read-only mode.
Press `Alt+2` to open in `Neovim in Foot`.

## Find music

- finds `mp3` and `m4a` files in selected paths and feeds them to the `Fuzzel` dmenu
- then pick albums, artists or update database from the `Fuzzel` menu
- launch the script with `SUPER + P` then `M` keybind submap
- after adding new music files, update the local database by launching the script and choosing the `Update Database` line in `Fuzzel`
- the database file is located at `~/.cache/find_files/albums-db.txt` or `~/.cache/find_files/artists-db.txt` (the files are created automatically)

### Opening music

Press `Return` to open in `kew` player.
Press `Alt+1` to open in `mpv` player.
