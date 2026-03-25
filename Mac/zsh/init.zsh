[[ ! -f /opt/homebrew/bin/brew ]] || eval "$(/opt/homebrew/bin/brew shellenv)"

# Lazy load nvm to speed up terminal startup
export NVM_DIR="$HOME/.nvm"
zsh-defer-nvm() {
  # Remove the temporary wrapper functions
  unfunction node npm nvm npx yarn 2>/dev/null
  # Load the real nvm
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}

# Create wrapper functions for node-related commands
node npm nvm npx yarn() {
  zsh-defer-nvm
  # Execute the original command that was just run
  "$0" "$@"
}
