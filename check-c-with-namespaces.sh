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
standard="${2#--}"

if [ ! -f "$source" ]; then
    echo "check-c-with-namespaces: expected source file as first argument" >&2
    exit 1
fi

if [ "$2" = "$standard" ]; then
    echo "check-c-with-namespaces: expected C standard flag like --c89 or --gnu11" >&2
    exit 1
fi

perl -0pe '
    s/^\s*module;\s*\n//mg;
    s/^\s*export\s+module\s+\w+\s*;\s*\n//mg;
    s/^\s*import\s+\w+\s*;\s*\n//mg;
    $has_namespace = s/^\s*(?:export\s+)?namespace\s+\w+\s*\{\s*\n//m;
    s/\n\}\s*$/\n/s if $has_namespace;
    s/^\s*export\s+//mg;
    s/extern "C"/extern/g;
    s/::/__/g;
' "$source" \
| clang -I "$(dirname "$source")" -x c -std="$standard" -pedantic-errors -Wno-implicit-function-declaration -fsyntax-only -
