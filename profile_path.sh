#!/bin/bash

PROFILE="$HOME/.profile"
LINE='export PATH=$HOME/.local/bin:$PATH'

# Create .profile if it doesn't exist
if [ ! -f "$PROFILE" ]; then
    echo "# ~/.profile: executed by the command interpreter for login shells." > "$PROFILE"
    echo "$LINE" >> "$PROFILE"
    echo ".profile created and PATH line added."
else
    # Check if the line is already present
    if ! grep -Fxq "$LINE" "$PROFILE"; then
        echo "$LINE" >> "$PROFILE"
        echo "PATH line added to existing .profile."
    else
        echo "PATH line already present in .profile. No changes made."
    fi
fi
