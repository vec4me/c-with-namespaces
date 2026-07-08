# Code validator for C with Namespaces.
# C with Namespaces is C source wrapped in the small C++ surface we use for
# modules, imports, exports, and namespace boundaries. This validator removes
# that wrapper and gives clang the plain C body. That means this input:
#
#     export module widget;
#     import base;
#     namespace widget {
#     typedef struct State {
#         int count;
#     } State;
#     }
#
# is checked as this:
#
#     typedef struct State {
#         int count;
#     } State;
#
# If the remaining body is not valid under the requested C standard, clang
# reports it. Namespaces are assumed to wrap the file body when present.

source="$1"
output="$(mktemp /tmp/check-c-with-namespaces.XXXXXX)"

if [ ! -f "$source" ]; then
    echo "check-c-with-namespaces: expected source file as first argument" >&2
    exit 1
fi

perl -0pe '
    s/^\s*module;\s*\n//mg;
    s/^\s*export\s+module\s+\w+\s*;\s*\n//mg;
    s/^\s*import\s+\w+\s*;\s*\n//mg;
    $has_namespace = s/^\s*(?:export\s+)?namespace\s+\w+\s*\{\s*\n//m;
    s/\n\}\s*(?:\/\/[^\n]*)?\s*$/\n/s if $has_namespace;
    s/^\s*export\s+//mg;
    s/extern "C"/extern/g;
    s/::/INTERNAL_SCOPE_RESOLUTION_OPERATOR/g;
' "$source" \
| clang -x c -ferror-limit=0 "${@:2}" -c -o /dev/null - 2>"$output"

# Omit file-local import resolution diagnostics from lowered namespace references.
perl -ne '
    sub flush {
        if (@block && !$skip) {
            print @block;
            $failed = 1 if $block[0] =~ /^<stdin>:\d+:\d+: (?:error|fatal error):/ || $block[0] =~ /^fatal error:/;
        }
        @block = ();
        $skip = 0;
    }

    if (/^<stdin>:\d+:\d+: (?:error|warning|fatal error):/) {
        flush();
        @block = ($_);
        $skip = /INTERNAL_SCOPE_RESOLUTION_OPERATOR/;
        next;
    }

    if (/^\d+ warnings? and \d+ errors? generated\.$/) {
        flush();
        print if $failed;
        next;
    }

    if (@block) {
        push @block, $_;
        $skip = 1 if /INTERNAL_SCOPE_RESOLUTION_OPERATOR/;
        next;
    }

    print;

    END {
        flush();
        exit $failed;
    }
' "$output" >&2

status="$?"
rm -f "$output"
exit "$status"
