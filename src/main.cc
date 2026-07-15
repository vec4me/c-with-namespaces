import check;

#include <stdio.h>
#include <string.h>

typedef enum command {
    UNKNOWN,
    CHECK,
    HELP
} command;

static command parse_command(const char *argument) {
    if (strcmp(argument, "check") == 0) {
        return CHECK;
    }
    if (strcmp(argument, "help") == 0) {
        return HELP;
    }
    return UNKNOWN;
}

static void print_usage(void) {
    fputs("usage: c-with-namespaces <command> [arguments]\n"
          "try 'c-with-namespaces help' for more information\n",
          stderr);
}

static void print_help(void) {
    puts("C with Namespaces Compliance Tools");
    puts("");
    puts("usage:");
    puts("  c-with-namespaces <command> [arguments]");
    puts("");
    puts("commands:");
    puts("  check  Check source files for compliance.");
    puts("  help   Show this help.");
    puts("");
    puts("check usage:");
    puts("  c-with-namespaces check [--ignore-external] <source>... -- <clang-arg>...");
    puts("");
    puts("check arguments:");
    puts("  <source>     A source file to check.");
    puts("  <clang-arg>  An option to pass to Clang.");
    puts("");
    puts("check options:");
    puts("  --ignore-external  Ignore errors from included headers.");
    puts("  --                 Treat all remaining arguments as Clang options.");
    puts("");
    puts("Sources may be supplied in any order. Duplicate source paths are ignored.");
    puts("");
    puts("examples:");
    puts("  c-with-namespaces check source.ccm main.cc -- -std=c89 -Wall -Wextra -pedantic  Check two source files with strict C89 warnings.");
    puts("  c-with-namespaces check --ignore-external source.ccm main.cc -- -Iinclude       Check two source files while ignoring included-header errors.");
    puts("");
}

int main(int argc, char **argv) {
    command command;

    if (argc < 2) {
        print_help();
        return 0;
    }

    command = parse_command(argv[1]);
    if (command == HELP && argc == 2) {
        print_help();
        return 0;
    }
    if (command != CHECK || argc < 3) {
        print_usage();
        return 1;
    }

    return check::run(argc - 2, argv + 2);
}
