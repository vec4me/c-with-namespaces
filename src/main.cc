import check;

#include <stdio.h>
#include <string.h>

typedef enum Command {
    UNKNOWN,
    CHECK,
    HELP,
} Command;

static Command parse_command(const char *argument) {
    if (strcmp(argument, "--check") == 0) {
        return CHECK;
    }
    if (strcmp(argument, "--help") == 0) {
        return HELP;
    }
    return UNKNOWN;
}

static void print_usage(void) {
    puts("usage: c-with-namespaces --check <source>... -- <clang-arg>...");
}

int main(int argc, char **argv) {
    Command command;

    if (argc < 2) {
        print_usage();
        return 1;
    }

    command = parse_command(argv[1]);
    if (command == HELP && argc == 2) {
        print_usage();
        return 0;
    }
    if (command != CHECK || argc < 3) {
        print_usage();
        return 1;
    }

    return check::run(argc - 2, argv + 2);
}
