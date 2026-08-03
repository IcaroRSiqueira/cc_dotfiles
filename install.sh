#!/bin/bash
set -eu

DOTFILES_REPOSITORY="${DOTFILES_REPOSITORY:-IcaroRSiqueira/cc_dotfiles}"
DOTFILES_REPO_URL="${DOTFILES_REPO_URL:-}"

if [ -n "$DOTFILES_REPO_URL" ]; then
  dotfiles_repo_url="$DOTFILES_REPO_URL"
elif [[ "$DOTFILES_REPOSITORY" == https://* || "$DOTFILES_REPOSITORY" == git@* ]]; then
  dotfiles_repo_url="$DOTFILES_REPOSITORY"
else
  dotfiles_repo_url="https://github.com/${DOTFILES_REPOSITORY}.git"
fi

if [ -d "$HOME/.cc_dotfiles" ]; then
  echo "Using existing dotfiles directory at $HOME/.cc_dotfiles"
else
  echo "Installing Campus Code Dotfiles"
  echo "We'll install:"
  echo "  - zsh, tmux, vim, git, silver searcher"
  echo "  - mise with Ruby and Node.js"
  echo "  - dotfiles configuration (symlinks, plugins, fonts)"

  if [ -z "${LOCAL_INSTALL:-}" ]; then
    echo "Installing from remote source"
    if ! command -v git > /dev/null 2>&1; then
      case "$(uname -s)" in
        Linux)
          sudo apt-get update
          sudo apt-get install -y git
          ;;
      esac
    fi
    git clone --depth=10 "$dotfiles_repo_url" "$HOME/.cc_dotfiles"
  else
    echo "Installing from local source"
    rsync -a --no-perms --exclude='.vagrant' --exclude='tags' --exclude='vim/autoload' --exclude='vim/bundle' --exclude='vim/backups' . "$HOME/.cc_dotfiles"
    curl -fLo "$HOME/.cc_dotfiles/vim/autoload/plug.vim" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
fi

case "$(uname -s)" in
  Linux)
    bash "$HOME/.cc_dotfiles/ubuntu.sh"
    ;;
  Darwin)
    bash "$HOME/.cc_dotfiles/mac.sh"
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
    ;;
  *)
    echo "Operational system not supported, aborting installation"
    exit 1
    ;;
esac

# Install mise with Ruby and Node.js — common to all platforms
curl https://mise.run | sh
eval "$(~/.local/bin/mise activate bash)"
mise settings ruby.compile=false
mise use --global ruby
mise use --global node

# Ensure the Ruby toolchain used for the install is isolated from older RVM-managed gems.
~/.local/bin/mise exec -- gem install --no-document ostruct rake

cd "$HOME/.cc_dotfiles"
~/.local/bin/mise exec -- rake install

