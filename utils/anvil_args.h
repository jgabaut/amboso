#ifndef ANVIL_ARGS_H_
#define ANVIL_ARGS_H_

#include <stdbool.h>

enum Anvil_Args_Index {
    ANVIL_TARGETDIR_I=1,
    ANVIL_BUILDSDIR_I,
    ANVIL_BINNAME_I,
    ANVIL_TAG_I,
    ANVIL_STEGODIR_I,
    ANVIL_ARGS_I_TOT
};

typedef struct Anvil_Info {
    const char* target_dir;
    const char* builds_dir;
    const char* bin_name;
    const char* tag;
    const char* stego_dir;
} Anvil_Info;

bool parse_anvil_args(int argc, char** argv, Anvil_Info* info);
#define ANVIL_INFO_FMT "{target dir: %s, builds_dir: %s, bin_name: %s, tag: %s, stego_dir: %s}"
#define ANVIL_INFO_ARG(x) (x).target_dir, (x).builds_dir, (x).bin_name, (x).tag, (x).stego_dir
void debug_anvil_args(Anvil_Info info);

#endif // ANVIL_ARGS_H_

#ifdef ANVIL_ARGS_IMPLEMENTATION
bool parse_anvil_args(int argc, char** argv, Anvil_Info* info) {
    int expected = ANVIL_ARGS_I_TOT;
    if (argc < expected) {
        fprintf(stderr, "Invalid argc: {%i}, expected: {%i}\n", argc, expected);
        return false;
    }
    if (!info) return false;

    for (int i=0; i < argc; i++) {
        switch(i) {
            case ANVIL_TARGETDIR_I: {
                //printf("ANVIL_TARGETDIR: {%s}\n", argv[i]);
                info->target_dir = argv[i];
            }
            break;
            case ANVIL_BUILDSDIR_I: {
                //printf("ANVIL_BUILDSDIR: {%s}\n", argv[i]);
                info->builds_dir = argv[i];
            }
            break;
            case ANVIL_BINNAME_I: {
                //printf("ANVIL_BINNAME: {%s}\n", argv[i]);
                info->bin_name = argv[i];
            }
            break;
            case ANVIL_TAG_I: {
                //printf("ANVIL_TAG: {%s}\n", argv[i]);
                info->tag = argv[i];
            }
            break;
            case ANVIL_STEGODIR_I: {
                //printf("ANVIL_STEGODIR: {%s}\n", argv[i]);
                info->stego_dir = argv[i];
            }
            break;
            default: {
                //if (i) printf("Extra arg: {%s}\n", argv[i]);
            }
            break;
        }
    }

    return true;
}

void debug_anvil_args(Anvil_Info info)
{
    fprintf(stderr, "Anvil_Info: " ANVIL_INFO_FMT "\n", ANVIL_INFO_ARG(info));
}
#endif // ANVIL_ARGS_IMPLEMENTATION
