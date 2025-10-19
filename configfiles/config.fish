alias ls 'eza --icons'
zoxide init fish | source
source ~/.config/fish/aliases.fish
thefuck --alias | source
fish_add_path /home/arshan/.spicetify
alias venv "python3 -m venv venv"

function __auto_source_venv --on-variable PWD --description "Activate/Deactivate virtualenv on directory change"
    status --is-command-substitution; and return

    # Check if we are inside a git directory
    if git rev-parse --show-toplevel &>/dev/null
        set gitdir (realpath (git rev-parse --show-toplevel))
        set cwd (pwd -P)
        # While we are still inside the git directory, find the closest
        # virtualenv starting from the current directory.
        while string match "$gitdir*" "$cwd" &>/dev/null
            if test -e "$cwd/.venv/bin/activate.fish"
                source "$cwd/.venv/bin/activate.fish" &>/dev/null
                return
            else
                set cwd (path dirname "$cwd")
            end
        end
    end
    # If virtualenv activated but we are not in a git directory, deactivate.
    if test -n "$VIRTUAL_ENV"
        deactivate
    end
end
alias cp "cpg -g"
alias mv "mvg -g"
function gapc
    if test (count $argv) -eq 0
        echo "Usage: gapc <commit message>"
        return 1
    end
    git add .
    git commit -m "$argv"
    git push
end
fastfetch
