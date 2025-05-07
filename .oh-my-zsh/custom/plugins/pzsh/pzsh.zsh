# Name: pzsh
# Author: iniridwanul
# Email Address: iniridwanul@gmail.com

# Define a function to filter commands before they are added to history
function __filter_history() {
    # Run the function in a clean Zsh environment (isolated options)
    emulate -L zsh
    # Strip the newline character from the command line input
    local line=${1%%$'\n'}

    if [[ "$line" == "pzsh" || "$line" == " pzsh" ]]; then
        # Return 1 (false) to prevent 'pzsh' from being added to history
        return 1
    fi

    # Return 0 (true) to allow all other commands
    return 0
}

# Load the Zsh hook system function (autoloads it if not already loaded)
autoload -Uz add-zsh-hook
# Attach the __filter_history function to the zshaddhistory hook
# This hook is triggered whenever a command is about to be added to history
add-zsh-hook zshaddhistory __filter_history

# Define a function 'pzsh' to launch a private Zsh shell session
pzsh() {
    # Redirect history to a separate or fake file
    export HISTFILE=~/.pzsh_history
    # Disable in-memory history
    export HISTSIZE=0
    # Do not save any history to file
    export SAVEHIST=0
    # Prevent commands from being appended to history immediately
    unsetopt INC_APPEND_HISTORY
    # Prevent history from being shared between sessions
    unsetopt SHARE_HISTORY
    # Start a new Zsh shell (a subshell)
    zsh
}