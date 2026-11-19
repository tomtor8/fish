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
