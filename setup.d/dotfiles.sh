#!/bin/bash
# Dotfiles Module - Initialize $HOME as git repo and pull dotfiles

DOTFILES_REPO="${1:-https://github.com/daevski/dotfiles.git}"
DOTFILES_BRANCH="${2:-main}"

log_info "Dotfiles module starting"

# Change to home directory
cd "$HOME"

# Check if already initialized as a git repo
if [ -d "$HOME/.git" ]; then
    log_step "git repository already exists in \$HOME"
    run_with_progress "fetching latest changes" git fetch origin
    run_with_progress "resetting to origin/$DOTFILES_BRANCH" git reset --hard "origin/$DOTFILES_BRANCH"
    log_debug "repository updated"
else
    log_step "initializing \$HOME as git repository"
    git init

    log_step "setting default branch to $DOTFILES_BRANCH"
    git branch -m "$DOTFILES_BRANCH"

    log_step "adding remote origin"
    git remote add origin "$DOTFILES_REPO"

    log_step "setting upstream branch"
    git branch --set-upstream-to=origin/$DOTFILES_BRANCH "$DOTFILES_BRANCH"

    run_with_progress "fetching from origin" git fetch origin

    if ! run_with_progress "pulling dotfiles" git reset --hard "origin/$DOTFILES_BRANCH"; then
        log_error "Failed to pull dotfiles"
        return 1
    fi
    log_debug "dotfiles deployed successfully"
fi

log_success "Dotfiles module complete"
