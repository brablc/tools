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
