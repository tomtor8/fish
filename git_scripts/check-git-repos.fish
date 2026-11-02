#!/usr/bin/env fish

# Hardcoded list of Git-tracked directories
set -l repos \
    "$HOME/Documents/notes" \
    "$HOME/.config/hypr" \
    "$HOME/.config/nvim" \
    "$HOME/.local/share/snippets" \
    "$HOME/.local/share/dotfiles"

set -l behind_list
set -l error_list
set -l checked_count 0

for repo in $repos
    # Skip if directory or .git subdirectory doesn't exist
    test -d "$repo/.git"; or continue

    builtin cd $repo; or continue

    # Ensure a remote tracking branch is configured
    if git remote | string match -q '*'
        set -l repo_name (path basename $repo)

        # Fetch remote updates quietly with a 5-second timeout
        timeout 5 git fetch --quiet 2>/dev/null
        set -l fetch_status $status

        # Check for fetch errors (e.g., no network connection, timeout, auth failure)
        if test $fetch_status -ne 0
            set -a error_list "$repo_name"
            continue
        end

        # Check how many commits local is behind tracking branch
        set -l count (git rev-list HEAD..@{u} --count 2>/dev/null)

        if test -n "$count"; and test "$count" -gt 0
            set -a behind_list "$repo_name ($count behind)"
        end

        set checked_count (math $checked_count + 1)
    end
end

# --- Notification Dispatcher ---

if test (count $behind_list) -gt 0
    # Case 1: One or more repositories are behind
    set -l total (count $behind_list)
    set -l formatted_list (string join ", " $behind_list)

    notify-send -u normal \
        -a "Git Sync Status" \
        "Git Updates Available ($total)" \
        "The following repos are behind remote:\n$formatted_list"

else if test (count $error_list) -gt 0
    # Case 2: Network/Fetch errors occurred
    set -l formatted_errors (string join ", " $error_list)

    notify-send -u critical \
        -a "Git Sync Status" \
        "Git Fetch Failed" \
        "Could not check remote status for:\n$formatted_errors"

else if test $checked_count -gt 0
    # Case 3: All checked repositories are completely up to date
    notify-send -u low \
        -a "Git Sync Status" \
        "All Repositories Up to Date" \
        "Checked $checked_count repositories. Everything is in sync."
end
