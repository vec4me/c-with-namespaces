mkdir -p build

sources=""

build() {
    target="$1"

    case " $sources " in
        *" $target "*) return ;;
    esac

    for dependency in $(sed -n 's/^import \([^;]*\);/\1/p' "$target"); do
        if [ -e "src/$dependency.ccm" ]; then
            build "src/$dependency.ccm"
        fi
    done

    target="$1"

    if [ -e "build/$(basename "$target" .ccm).pcm" ] && [ -e "build/$(basename "$target" .ccm).o" ]; then
        sources="$sources $target"
        return
    fi

    clang++ \
        -fprebuilt-module-path=build \
        -std=c++20 \
        -x c++-module \
        -fmodule-output="build/$(basename "$target" .ccm).pcm" \
        -c "$target" \
        -o "build/$(basename "$target" .ccm).o" || exit 1

    sources="$sources $target"
}

for target in src/*.ccm; do
    build "$target"
done

clang++ \
    -fprebuilt-module-path=build \
    -std=c++20 \
    src/main.cc \
    build/*.o \
    -o build/c-with-namespaces || exit 1

build/c-with-namespaces --check $sources src/main.cc -- -std=c99 -Wall -Wextra -pedantic || exit 1
