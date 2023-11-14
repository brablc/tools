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
}

function _dj_init() {
    [[ -n "${VIRTUAL_ENV:-}" ]] || vactivate
    export DYLD_FALLBACK_LIBRARY_PATH=$(brew --prefix libpq)/lib:$DYLD_FALLBACK_LIBRARY_PAT
}

function dj() {
    while [[ ! -f manage.py && ! -d .django-dir && "$PWD" != "$HOME" ]]; do
        cd ..
    done
    if [[ -d .django-dir ]]; then
        cd $(readlink .django-dir)
    fi
    _dj_init
    python manage.py "$@"
}

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
