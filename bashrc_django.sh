alias vscode='open -a "Visual Studio Code"'

function vactivate() {
    if [[ -n "${VIRTUAL_ENV:-}" ]]; then
        deactivate
    fi
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.venv" ]]; then
            source "$dir/.venv/bin/activate"
            return
        fi
        dir="$(dirname "$dir")"
    done
    echo "No .venv directory found."
    return 1
}
export -f vactivate

function _dj_init() {
    [[ -n "${VIRTUAL_ENV:-}" ]] || vactivate
    export DYLD_FALLBACK_LIBRARY_PATH=$(brew --prefix libpq)/lib:$DYLD_FALLBACK_LIBRARY_PAT
}
export -f _dj_init

function dj() {
    while [[ ! -f manage.py && ! -f .django-dir && "$PWD" != "$HOME" ]]; do
        cd ..
    done
    if [[ -f .django-dir ]]; then
        cd $(cat .django-dir)
    fi
    _dj_init
    python manage.py "$@"
}
export -f dj

_dj() {
    _dj_init

    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}
    COMPREPLY=()

    if [[ ${prev} == "dj" ]]; then
        COMPREPLY=( $(compgen -W "$(python manage.py help --commands)" -- ${cur}) )
    fi
    return 0
}
complete -F _dj dj


function dj_liverun() {

    vactivate || return 1
    _dj_init

    let session_name='dj_liverun'

    if ! tmux has-session -t $session_name 2>/dev/null; then

        tmux new-session -d -s $session_name

        tmux split-window -v
        tmux split-window -v
        tmux select-pane -t 2 # Select Pane 2 (bottom pane)
        tmux split-window -h  # Split Pane 2 horizontally: creates Pane 3 beside Pane 2

        tmux select-pane -t 1
        tmux send-keys 'while true; do dj runserver 0.0.0.0:8000; done' C-m

        tmux select-pane -t 2
        tmux send-keys 'dj livereload' C-m

        tmux select-pane -t 3
        tmux resize-pane -R 20
        tmux send-keys 'npm run tailwind' C-m

        tmux select-pane -t 0
    fi

    tmux attach-session -t $session_name
}
