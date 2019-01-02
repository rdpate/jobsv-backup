set -Cue
exec >&2
fatal() { rc="$1"; shift; printf %s\\n "${0##*/} error: $*" >&2 || true; exit "$rc"; }

src="${1%.o}.c"
redo-ifchange "$src"
[ -e "$src" ] || fatal 66 "missing source $1"
dep="$(dirname "$1")/.$(basename "$1").dep"
target="$1"
output="$3"
set --
for flags in "${0%.do}.flags" "$target.flags"; do
    [ -e "$flags" ] || continue
    redo-ifchange "$flags"
    reldir="$(dirname "$flags")"
    while read -r line; do
        case "$line" in
            '#'*|'') continue ;;
            [-/]*) ;;
            *) line="$reldir/$line" ;;
            esac
        set -- "$@" "$line"
        done <"$flags"
    done
cc -c -MD -MF"$dep" -o"$output" "$@" "$src"
sed -i -r 's/^[^ ]+: //; s/ \\$//; s/^ +| +$//g; s/ +/\n/g' "$dep"
xargs redo-ifchange <"$dep"
rm "$dep"