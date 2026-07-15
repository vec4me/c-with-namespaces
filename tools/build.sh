build() {
    local target="$1"
    local dependency
    local up_to_date=true

    if [ ! -e "build/$target.pcm" ] || [ ! -e "build/$target.o" ] || [ ! "build/$target.pcm" -nt "src/$target.ccm" ] || [ ! "build/$target.o" -nt "src/$target.ccm" ]; then
        up_to_date=false
    fi
    for dependency in $(sed -n 's/^import \([^;]*\);/\1/p' "src/$target.ccm"); do
        if [ -e "build/$dependency.pcm" ] && { [ "build/$dependency.pcm" -nt "build/$target.pcm" ] || [ "build/$dependency.pcm" -nt "build/$target.o" ]; }; then
            up_to_date=false
        fi
    done
    if $up_to_date; then
        return
    fi

    clang++ \
        -fprebuilt-module-path=build \
        -std=c++20 \
        -O3 \
        -x c++-module \
        -fmodule-output="build/$target.pcm" \
        -c "src/$target.ccm" \
        -o "build/$target.o" || exit 1
}

module_graph() {
    local source
    local module
    local dependency

    for source in src/*.ccm; do
        module="$(basename "$source" .ccm)"
        printf '%s %s\n' "$module" "$module"
        for dependency in $(sed -n 's/^import \([^;]*\);/\1/p' "$source"); do
            if [ -e "src/$dependency.ccm" ]; then
                printf '%s %s\n' "$dependency" "$module"
            fi
        done
    done
}

main() {
    local sources=()
    local objects=()
    local module
    local modules

    mkdir -p build

    modules="$(module_graph | tsort)" || return 1
    for module in $modules; do
        build "$module"
        sources+=("src/$module.ccm")
        objects+=("build/$module.o")
    done

    clang++ \
        -fprebuilt-module-path=build \
        -std=c++20 \
        -O3 \
        src/main.cc \
        "${objects[@]}" \
        -o build/c-with-namespaces || return 1

    ./build/c-with-namespaces \
        check \
        --ignore-external \
        "${sources[@]}" \
        src/main.cc \
        -- \
        -std=c89 \
        -Wall \
        -Wextra \
        -pedantic
}

main "$@"
