# Export the path to the oh-my-zsh directory
export ZSH="$HOME/.oh-my-zsh"

# Set the ZSH theme to "arch"
ZSH_THEME="arch"

# Specify the plugins to be loaded
plugins=(git kitty zsh-autosuggestions)

# Set the highlight style for ZSH autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ecf0f1"

# Source the oh-my-zsh initialization script
source $ZSH/oh-my-zsh.sh

# Add the user's bin directory to the PATH
export PATH="$PATH:$HOME/.bin"

# Source custom aliases from the .aliases file
source $HOME/.aliases