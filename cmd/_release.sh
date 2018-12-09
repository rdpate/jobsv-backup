fatal() { rc="$1"; shift; printf %s\\n "${0##*/} error: $*" >&2; exit "$rc"; }
nonfatal() { printf %s\\n "${0##*/}: $*" >&2; }
get_fd() {
    local x
    set -- ${MAKEFLAGS-}
    fd=
    for x; do
        case "$x" in
            --jobserver-fds=?*,?*|--jobserver-auth=?*,?*)
                fd="${x#*,}"
                ;;
            esac
        done
    [ -n "$fd" ] || fatal 64 'jobserver not running!'
    }
get_fd
# always release if possible
if [ -e /dev/fd ]; then
    # workaround: dash, zsh, and probably more do not allow >&X when X > 9
    trap 'printf x >/dev/fd/"$fd"' exit
else
    release() {
        printf x >&"$fd" || nonfatal "failed to release token"
        }
    trap release exit
    fi