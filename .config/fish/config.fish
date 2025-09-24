if status is-interactive
    # Aliases
    alias python python3
    alias vim nvim
    alias fs 'cd (stribog-select)'
    alias fgg "git switch (git branch | fzf | sed 's/ //g' | sed 's/*//')"
    alias fgd "git branch -d (git branch | fzf | sed 's/ //g' | sed 's/*//')"
    alias fgD "git branch -D (git branch | fzf | sed 's/ //g' | sed 's/*//')"
    alias fgr "git checkout (git branch -r | fzf | sed 's/ //g' | sed 's/*//') -t"
    alias gs 'git switch -c'
    alias g 'git status'
    alias gap 'git add -p .'
    alias air '~/go/bin/air'
end

# Environment variables
set -gx TERM xterm-256color
set -gx BUN_INSTALL $HOME/.bun
set -gx FLYCTL_INSTALL $HOME/.fly
set -gx SDKMAN_DIR $HOME/.sdkman
set -gx PNPM_HOME /home/marko/.local/share/pnpm
set -gx SSH_AUTH_SOCK $HOME/.1password/agent.sock

# PATH additions
set -gx PATH $BUN_INSTALL/bin $PATH
set -gx PATH $HOME/.cargo/bin $PATH
set -gx PATH $HOME/.local/bin $PATH
set -gx PATH $HOME/.local/share/fnm $PATH
set -gx PATH $HOME/.local/share/nvim/mason/packages/delve $PATH
set -gx PATH /usr/local/go/bin $PATH
set -gx PATH $HOME/go/bin $PATH
set -gx PATH $HOME/.fly/bin $PATH
set -gx PATH $PNPM_HOME $PATH
set -gx PATH /root/.opencode/bin $PATH
set -gx PATH /root/dev/.dotfiles/scripts $PATH

# Initialize tools
if [ -d "$FNM_PATH" ]
  set PATH "$FNM_PATH" $PATH
  fnm env | source
end

if test -f $HOME/.sdkman/bin/sdkman-init.sh
    # SDKMAN doesn't work well with fish, but we can set JAVA_HOME if needed
    if test -d $SDKMAN_DIR/candidates/java/current
        set -gx JAVA_HOME $SDKMAN_DIR/candidates/java/current
    end
end
set -gx PATH /home/marko/dev/.dotfiles/scripts $PATH

set -x N_PREFIX "$HOME/n"; contains "$N_PREFIX/bin" $PATH; or set -a PATH "$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).

# opencode
fish_add_path /home/marko/.opencode/bin
