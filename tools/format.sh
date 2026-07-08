for source in src/*.ccm src/main.cc; do
    clang-format -i --style="{BasedOnStyle: LLVM, IndentWidth: 4, ColumnLimit: 0, FixNamespaceComments: false}" "$source" || exit 1
done
