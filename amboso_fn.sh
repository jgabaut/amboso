#!/usr/bin/env bash
#  SPDX-License-Identifier: GPL-3.0-only
#  Bash symbols sourced by amboso.
#    Copyright (C) 2023-2025  jgabaut
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

AMBOSO_API_LVL="2.0.12"
at() {
    #printf -- "{ call: [$(( ${#BASH_LINENO[@]} - 1 ))] -> {\n"
    log_cl "{ call: [" debug white
    for ((i=${#BASH_LINENO[@]}-1;i>1;i--)); do # i>1 is needed to avoid printing "backtrace" and its little number
    [[ $i -gt 2 ]] && continue #This should skip printing the upper functions that get printed by the "caller" while read

    local indent="$(( ${#BASH_LINENO[@]} -i  -2 ))" # -2 because of the above
    for ((j=0; j<indent; j++)); do
        printf "\t"
    done

    local func="${FUNCNAME[i]}"
    local linenum="${BASH_LINENO[i-1]}" # the -1 affects the line number in the output, giving us the one that would be to "backtrace"
    if [[ "$i" -ne 2 ]]; then { #We have something unexpected per this function....
        printf "<%s@%s> ->\n" "${func}" "${linenum}"
    } else {
        printf "<%s@%s>]}\n" "${func}" "${linenum}"
    }
    fi
    done
    #printf "<line: %s>\n" "$LINENO"
}

backtrace() {
   #[[ $tracing -eq 0 ]] && echo -n "{ [MAIN] at: $trace_line } -> {"
   if [[ $trace_line -eq 0 ]] ; then {
     printf "\n\n\n\n{ [$(( $trace_line ))] [ trace at) \n"
   } else {
     at
   }
   fi
   trace_line=1
   while read LINE SUB FILE < <(caller "$trace_line"); do
       if [[ "$verbose_flag" -ge 4 ]] ; then {
           log_cl "at {${SUB} : ${LINE}} -> {${FILE}}" debug white
       } else {
           log_cl "at {${SUB} : ${LINE}}" debug white
       }
       fi
       trace_line=$((trace_line+1))
   done
}

trace() {
  if [[ $trace_flag -gt 0 ]] ; then {
   backtrace
  } else {
   :
  }
  fi
}

# Function to compare SemVer strings
# @return 0 equals, 1 lesser, 2 greater
compare_semver() {

    local ver1="$1"
    local op="$2"
    local ver2="$3"
    local want_greater=1
    local want_lesser=1
    local want_equal=1

    case "$op" in
        "==") want_equal=0 ;;
        ">") want_greater=0 ;;
        "<") want_lesser=0 ;;
        ">=") want_equal=0; want_greater=0 ;;
        "<=") want_equal=0; want_lesser=0 ;;
        *)
            log_cl "Invalid op in compare_semver: $op" error
            exit 1
            ;;
    esac

    # Extract version major numer (major.minor.patch)
    local major1=$(echo "$ver1" | awk -F '.' '{print $1}')
    local major2=$(echo "$ver2" | awk -F '.' '{print $1}')

    # Compare major number
    if [[ $major1 -lt $major2 ]]; then
        return "$want_lesser"
    elif [[ $major1 -gt $major2 ]]; then
        return "$want_greater"
    else
        # Extract version minor number (major.minor.patch)
        local minor1=$(echo "$ver1" | awk -F '.' '{print $2}')
        local minor2=$(echo "$ver2" | awk -F '.' '{print $2}')
        # If major number is the same, compare the minor number
        if [[ $minor1 -lt $minor2 ]]; then
            return "$want_lesser"
        elif [[ $minor1 -gt $minor2 ]]; then
            return "$want_greater"
        else
            # Extract version patch number (major.minor.patch)
            local patch1=$(echo "$ver1" | awk -F '.' '{print $3}')
            local patch2=$(echo "$ver2" | awk -F '.' '{print $3}')
            # If minor number is the same, compare the patch number
            if [[ $patch1 -lt $patch2 ]]; then
                return "$want_lesser"
            elif [[ $patch1 -gt $patch2 ]]; then
                return "$want_greater"
            else
                return "$want_equal"
            fi
        fi
    fi
}

log_cl() {
    local has_color="${AMBOSO_COLOR:-0}"
    local do_filelog="${AMBOSO_LOGGED:-0}"
    local tk_bold="bold"
    local tk_thin="thin"
    local clr_default="0"
    local clr_red="1"
    local clr_green="2"
    local clr_yellow="3"
    local clr_blue="4"
    local clr_magenta="5"
    local clr_cyan="6"
    local clr_white="7"
    local colorname_0="default"
    local colorname_1="red"
    local colorname_2="green"
    local colorname_3="yellow"
    local colorname_4="blue"
    local colorname_5="magenta"
    local colorname_6="cyan"
    local colorname_7="white"

    local lvl_4="debug"
    local lvl_3="info"
    local lvl_2="warn"
    local lvl_1="error"

    local lvl_4_tag="DEBUG"
    local lvl_3_tag="INFO"
    local lvl_2_tag="WARN"
    local lvl_1_tag="ERROR"

    local msg="$1"
    local lvl="$2"
    local color="$3"
    local thick="$4"
    [[ -z "$thick" ]] && thick="thin"

    local verb_lvl=3
    local lvl_tag=""
    local begin_color=0
    local thickness=0

    case $lvl in
        "")
            :
            ;;
        "$lvl_4")
            verb_lvl=4
            lvl_tag="$lvl_4_tag"
            begin_color="$clr_magenta"
            ;;
        "$lvl_3")
            verb_lvl=3
            lvl_tag="$lvl_3_tag"
            begin_color="$clr_green"
            ;;
        "$lvl_2")
            verb_lvl=2
            lvl_tag="$lvl_2_tag"
            begin_color="$clr_yellow"
            ;;
        "$lvl_1")
            verb_lvl=1
            lvl_tag="$lvl_1_tag"
            begin_color="$clr_red"
            ;;
        *)
            printf "${FUNCNAME[0]}(): unexpected lvl => {$lvl}\n"
            exit 1
            ;;
    esac
    case $thick in
        "")
            :
            ;;
        "$tk_bold")
            thickness=1
            ;;
        "$tk_thin")
            :
            ;;
        *)
            printf "${FUNCNAME[0]}(): unexpected thickness => {$thick}\n"
            exit 1
            ;;
    esac
    case $color in
        "")
            :
            ;;
        "$colorname_0")
            begin_color="$clr_default"
            ;;
        "$colorname_1")
            begin_color="$clr_red"
            ;;
        "$colorname_2")
            begin_color="$clr_green"
            ;;
        "$colorname_3")
            begin_color="$clr_yellow"
            ;;
        "$colorname_4")
            begin_color="$clr_blue"
            ;;
        "$colorname_5")
            begin_color="$clr_magenta"
            ;;
        "$colorname_6")
            begin_color="$clr_cyan"
            ;;
        "$colorname_7")
            begin_color="$clr_white"
            ;;
        *)
            printf "${FUNCNAME[0]}(): unexpected color => {$color}\n"
            exit 1
            ;;
    esac

    if [[ "$msg" =~ ^\[ ]] ; then {
        lvl_tag=""
    }
    fi

    if [[ "$has_color" -le 0 ]] ; then {
        begin_color=0
    }
    fi

    #printf "thick: {$thickness}\nclr: {$begin_color}\nlvl_tag: {$lvl_tag}\nmsg: {$msg}\n\n"
    if [[ "$begin_color" -eq 0 && -z "$lvl_tag" ]] ; then {
        printf "$msg\n"
        [[ "$do_filelog" -gt 0 ]] && printf "$msg\n" >> "./anvil.log"
    } elif [[ "$begin_color" -eq 0 && ! -z "$lvl_tag" ]] ; then {
        printf "[$lvl_tag]    $msg\n"
        [[ "$do_filelog" -gt 0 ]] && printf "[$lvl_tag]    $msg\n" >> "./anvil.log"
    } elif [[ -z "$lvl_tag" ]] ; then {
        printf "\033[$thickness;3${begin_color}m$msg\033[0m\n"
        [[ "$do_filelog" -gt 0 ]] && printf "$msg\n" >> "./anvil.log"
    } else {
        printf "\033[$thickness;3${begin_color}m[$lvl_tag]    $msg\033[0m\n"
        [[ "$do_filelog" -gt 0 ]] && printf "[$lvl_tag]    $msg\n" >> "./anvil.log"
    }
    fi
}

echo_amboso_splash() {
    local amboso_version="$1"
    prog="$2"
    printf "amboso, v$amboso_version\nCopyright (C) 2023-2025  jgabaut\n\n  This program comes with ABSOLUTELY NO WARRANTY; for details type \`$prog -W\`.\n  This is free software, and you are welcome to redistribute it\n  under certain conditions; see file \`LICENSE\` for details.\n\n  Full source is available at https://github.com/jgabaut/amboso\n\n"
}

echo_invil_notice() {
  log_cl "The bash implementation of amboso is being ported to Rust." info
  log_cl "amboso v2.x is going to try to maintain compatibility with \"invil\", the new reference implementation, but it may fail to do so proptly." warn
  log_cl "You can find the new version at https://github.com/jgabaut/invil" info
}

try_doing_make() {
  if [[ -f "./Makefile" ]] ; then {
    log_cl "Found Makefile." info
    make
    make_res="$?"
    if [[ "$make_res" -ne 0 ]] ; then {
        log_cl "\"make\" failed." info
        return "$make_res"
    }
    fi
    return "$make_res"
  } elif [[ -f "./configure.ac" && -f "./Makefile.am" ]] ; then {
    log_cl "Found:\n\n    configure.ac\n\n    Makefile.am" info
    autoreconf
    automake --add-missing
    autoreconf
    ./configure
    make
    make_res="$?"
    if [[ "$make_res" -ne 0 ]] ; then {
        log_cl "\"automake\" failed." info
        return "$make_res"
    }
    fi
    return "$make_res"
  } else {
    log_cl "Can't find a Makefile or a configure.ac, quitting." warn
    return 1
  }
  fi
}

echo_active_flags () {
  printf "[ENV]      Args:\n\n"
  printf "           CC \"%s\"\n" "$CC"
  if [[ "$CFLAGS_was_passed" -gt 0 ]]; then {
    printf "           CFLAGS \"%s\"\n\n" "$passed_CFLAGS"
  } elif [[ ! -z "${CFLAGS:-}" ]]; then {
    printf "           CFLAGS \"%s\"\n\n" "$CFLAGS"
  }
  fi

  printf "[CONFIG]   Amboso config:\n\n"
  printf -- "           -a {%s}\n" "$std_amboso_version"
  printf -- "           -k {%s}\n" "$std_amboso_kern"
  printf -- "           -O {%s} %s\n" "$stego_dir" "$stego_dir_flag"
  printf -- "           -D {%s}\n" "$scripts_dir"
  printf -- "           -K {%s}\n" "$kazoj_dir"
  printf -- "           -S {%s} %s\n" "$source_name" "$sourcename_was_set"
  printf -- "           -E {%s} %s\n" "$exec_entrypoint" "$exec_was_set"
  printf -- "           -M {%s} %s\n" "$makefile_version" "$vers_make_flag"
  printf -- "           -A {%s} %s\n" "$use_autoconf_version" "$vers_autoconf_flag"
  printf -- "           -C {%s} %s\n\n" "$passed_autoconf_arg" "$pass_autoconf_arg_flag"

  printf "[DEBUG]    Current flags:\n\n"

  printf "           [MODE]    -"
  [[ $small_test_mode_flag -gt 0 ]] && printf "t"
  [[ $test_mode_flag -gt 0 ]] && printf "T"
  [[ $git_mode_flag -gt 0 ]] && printf "g"
  [[ $base_mode_flag -gt 0 ]] && printf "B"
  printf "\n"
  printf "           [OP]    -"
  if [[ $verbose_flag -gt 0 ]] ; then {
    for verb_lv in $(seq 0 $(($verbose_flag-1))) ; do {
      printf "V"
    }
    done
  }
  fi
  [[ $extensions_flag -ne 1 ]] && printf "e" #extensions_flag is 1 by default
  [[ $force_build_flag -gt 0 ]] && printf "F"
  [[ $enable_make_rebuild_flag -ne 1 ]] && printf "R"
  [[ $do_filelog_flag -gt 0 ]] && printf "J"
  [[ $allow_color_flag -lt 1 ]] && printf "P"
  [[ $gen_C_headers_flag -gt 0 ]] && printf "G"
  [[ $be_stego_parser_flag -gt 0 ]] && printf "x"
  [[ $show_time_flag -gt 0 ]] && printf "w"
  [[ $start_time_flag -gt 0 ]] && printf "Y"
  [[ $ignore_git_check_flag -gt 0 ]] && printf "X"
  [[ $show_warranty_flag -gt 0 ]] && printf "W"
  [[ $tell_uname_flag -gt 0 ]] && printf "U"
  [[ $pack_flag -gt 0 ]] && printf "z"
  [[ $quiet_flag -gt 0 ]] && printf "q"
  [[ $init_flag -gt 0 ]] && printf "i"
  [[ $build_flag -gt 0 ]] && printf "b"
  [[ $purge_flag -gt 0 ]] && printf "p"
  [[ $delete_flag -gt 0 ]] && printf "d"
  [[ $small_list_flag -gt 0 ]] && printf "l"
  [[ $big_list_flag -gt 0 ]] && printf "L"
  [[ $bighelp_flag -gt 0 ]] && printf "H"
  [[ $smallhelp_flag -gt 0 ]] && printf "h"
  [[ $version_flag -eq 1 ]] && printf "v"
  [[ $version_flag -gt 1 ]] && printf "v" #One more level to this option
  printf "\n\n"
  printf "           [VERBOSE LEVEL]    $verbose_flag\n\n"
}

print_sysinfo () {
  printf "[SYSTEM]    System info:\n\n"
  printf "            [ kernel_name ]    [ $kernel_name ]\n"
  printf "            [ kernel_release ]    [ $kernel_release ]\n"
  printf "            [ machine_name ]    [ $machine_name ]\n"
  printf "            [ os_name ]    [ $os_name ]\n"
}

echo_amboso_version() {
  local curr_v="$1"
  local api_v="$2"
  local amboso_version="amboso, v$curr_v (Compat: v$api_v)"
  printf "$amboso_version\n"
}
echo_amboso_version_short() {
  printf "$amboso_currvers\n"
}

echo_timer() {
  if [[ $show_time_flag -eq 0 ]] ; then {
    [[ $verbose_flag -le 3 || $quiet_flag -gt 0 ]] && return
  }
  fi
  st="$1"
  msg="$2"
  color="$3"
  et=$(date +%s.%N)
  runtime=$( printf "$et - $st\n" | bc -l )
  display_zero=$(printf "$runtime\n" | cut -d '.' -f 1)
  if [[ -z $display_zero ]]; then {
    display_zero="0"
  } else {
    display_zero=""
  }
  fi
  log_cl "[TIME]    [ \"$msg\" ] Took [ $display_zero$runtime ] seconds." info
  return
}

check_tags() {
	git fetch --tags
    repo_tags=()
    # From: https://www.shellcheck.net/wiki/SC2207
    # For bash 3.x+, must not be in posix mode, may use temporary files
    while IFS='' read -r line; do repo_tags+=("$line"); done < <(git tag -l)

  for tag in "${supported_versions[@]}"; do
    if [[ " ${repo_tags[*]} " =~ " $tag " ]]; then {
      latest_version="$tag"
      if [[ $verbose_flag -gt 3 ]] ; then {
        shown_tag="$tag"
        log_cl "[AMBOSO]  Supported Tag $shown_tag exists in the repo." warn >&2
      }
      fi
	} else {
      if [[ $verbose_flag -gt 3 ]] ; then {
        shown_tag="$tag"
        log_cl "[AMBOSO]  Supported Tag $shown_tag is missing in the repo." warn >&2
	  }
	  fi
    }
    fi
  done
}

echo_tag_info() {
	tag=$1
	tag_date="$(git show -q --clear-decorations --format="%at" "$tag" 2>/dev/null)"
	tag_author="$(git show -q --clear-decorations "$tag" 2>/dev/null | grep Author | cut -f2 -d':' | awk -F" " '{print $1}')"
    tag_txt="$(git show -q --clear-decorations "$tag" 2>/dev/null | grep commit | awk -F" " '{print $2}' | cut -c 1-8)"
	log_cl "[AMBOSO]    Tag text was:  [$tag_txt]" info
	log_cl "[AMBOSO]    Tag author was:  [$tag_author ]" info
	log_cl "[AMBOSO]    Tag date was:  [$tag_date]" info
}

amboso_init_proj() {
    target_dir="$1"
    local is_strict="$2"
    if [[ ! -d "$target_dir" ]] ; then {
        log_cl "Invalid dir: {$target_dir}." error
        if [[ ! -e "$target_dir" ]] ; then {
            log_cl "Trying to mkdir: {$target_dir}." warn
            mkdir "$target_dir"
            mkdir_res="$?"
            if [[ "$mkdir_res" -eq 0 ]] ; then {
                log_cl "Created dir: {$target_dir}." info
            } else {
                log_cl "Failed mkdir for: {$target_dir}." error
                return 1
            }
            fi
        } else {
            log_cl "{$target_dir} already exists and it is not a directory." error
            return 1
        }
        fi
    }
    fi
    if [[ -z "$is_strict" ]] ; then {
        is_strict=0
    }
    fi

    local dir_basename="$(basename "$target_dir")"
    local caps_dir_basename="${dir_basename^^}" # Needs bash >=4.0, see: https://stackoverflow.com/questions/11392189/how-can-i-convert-a-string-from-uppercase-to-lowercase-in-bash

    if [[ "$is_strict" -eq 0 ]] ; then {
        #Not doing strict init
        :
    } elif [[ "$is_strict" -eq 1 ]] ; then {
        #Doing strict init
        dir_basename="hello_world"
        caps_dir_basename="HW"
    } else {
        #Invalid
        log_cgl "Invalid argument: {$is_strict}" error
        return 1
    }
    fi

    log_cl "Using dir_basename {$dir_basename}" debug
    log_cl "Using capsdir_basename {$caps_dir_basename}" debug
    is_git_repo=0
    ( cd "$target_dir" || { log_cl "[CRITICAL]    cd failed for {$target_dir}." error ; return 1 ; } ;
      #Check if target dir is a repo
      git rev-parse --is-inside-work-tree 2>/dev/null 1>&2
    )
    is_git_repo="$?"
    if [[ $is_git_repo -eq 0 ]] ; then {
       log_cl "{$target_dir} is a git repo. Quitting.." error
       return 1
    }
    fi
    log_cl "[PREP]    New amboso project in {$target_dir}" info

    mkdir -p "$target_dir"/src
    mkdir -p "$target_dir"/bin
    mkdir -p "${target_dir}/bin/v0.1.0"
    mkdir -p "$target_dir"/tests
    mkdir -p "$target_dir"/tests/ok
    mkdir -p "$target_dir"/tests/errors

    printf "[build]\nsource = \"main.c\"\nbin = \"%s\"\nmakevers = \"0.1.0\"\nautomakevers = \"0.1.0\"\ntests = \"tests\"\n[tests]\ntestsdir = \"ok\"\nerrortestsdir = \"errors\"\n[versions]\n\"0.1.0\" = \"%s\"\n" "$dir_basename" "$dir_basename" > "$target_dir"/stego.lock

    printf "#include <stdio.h>\nint main(void) {\nprintf(\"Hello, World!\");\nreturn 0;\n}\n" > "$target_dir"/src/main.c

    printf "#Generated by amboso v$amboso_currvers\n# ignore object files\n*.o\n# also explicitly ignore our executable for good measure\n%s\n# also explicitly ignore our windows executable for good measure\n%s.exe\n# also explicitly ignore our debug executable for good measure\n%s_debug\n#We also want to ignore the dotfile dump if we ever use anvil with -c flag\namboso_cfg.dot\n# MacOS DS_Store ignoring\n.DS_Store\n# ignore debug log file\ndebug_log.txt\n# ignore files generated by Autotools\nautom4te.cache/\ncompile\nconfig.guess\nconfig.log\nconfig.status\nconfig.sub\nconfigure\ninstall-sh\nmissing\naclocal.m4\nconfigure~\nMakefile\nMakefile.in\n# ignore amboso log file\nanvil.log\n#ignore invil log file\ninvil.log\n" "$dir_basename" "$dir_basename" "$dir_basename" > "$target_dir"/.gitignore

    printf "#Generated by amboso v$amboso_currvers\nAC_INIT([%s], [0.1.0], [email@example.com])\nAM_INIT_AUTOMAKE([foreign -Wall])\nAC_CANONICAL_HOST\nbuild_linux=no\nbuild_windows=no\nbuild_mac=no\necho \"Host os:  \$host_os\"\n\nAC_ARG_ENABLE([debug],  [AS_HELP_STRING([--enable-debug], [Enable debug build])],  [enable_debug=\$enableval],  [enable_debug=no])\nAM_CONDITIONAL([DEBUG_BUILD], [test \"\$enable_debug\" = \"yes\"])\ncase \"\${host_os}\" in\n\tmingw*)\n\t\techo \"Building for mingw32: [\$host_cpu-\$host_vendor-\$host_os]\"\n\t\tbuild_windows=yes\n\t\tAC_SUBST([${caps_dir_basename}_CFLAGS], [\"-I/usr/x86_64-w64-mingw32/include -static -fstack-protector\"])\n\t\tAC_SUBST([${caps_dir_basename}_LDFLAGS], [\"-L/usr/x86_64-w64-mingw32/lib\"])\n\t\tAC_SUBST([CCOMP], [\"/usr/bin/x86_64-w64-mingw32-gcc\"])\n\t\tAC_SUBST([OS], [\"w64-mingw32\"])\n\t\tAC_SUBST([TARGET], [\"%s.exe\"])\n\t;;\n\tdarwin*)\n\t\tbuild_mac=yes\n\t\techo \"Building for macos: [\$host_cpu-\$host_vendor-\$host_os]\"\n\t\tAC_SUBST([${caps_dir_basename}_CFLAGS], [\"-I/opt/homebrew/opt/ncurses/include\"])\n\t\tAC_SUBST([${caps_dir_basename}_LDFLAGS], [\"-L/opt/homebrew/opt/ncurses/lib\"])\n\t\tAC_SUBST([OS], [\"darwin\"])\n\t\tAC_SUBST([TARGET], [\"%s\"])\n\t;;\n\tlinux*)\n\t\techo \"Building for Linux: [\$host_cpu-\$host_vendor-\$host_os]\"\n\t\tbuild_linux=yes\n\t\tAC_SUBST([${caps_dir_basename}_CFLAGS], [\"\"])\n\t\tAC_SUBST([${caps_dir_basename}_LDFLAGS], [\"\"])\n\t\tAC_SUBST([OS], [\"Linux\"])\n\t\tAC_SUBST([TARGET], [\"%s\"])\n\t;;\nesac\n\nAM_CONDITIONAL([DARWIN_BUILD], [test \"\$build_mac\" = \"yes\"])\nAM_CONDITIONAL([WINDOWS_BUILD], [test \"\$build_windows\" = \"yes\"])\nAM_CONDITIONAL([LINUX_BUILD], [test \"\$build_linux\" = \"yes\"])\n\nAC_ARG_VAR([VERSION], [Version number])\nif test -z \"\$VERSION\"; then\n  VERSION=\"0.1.0\"\nfi\nAC_DEFINE_UNQUOTED([VERSION], [\"\$VERSION\"], [Version number])\nAC_CHECK_PROGS([CCOMP], [gcc clang])\nAC_CHECK_HEADERS([stdio.h])\nAC_CHECK_FUNCS([malloc calloc])\nAC_CONFIG_FILES([Makefile])\nAC_OUTPUT\n" "$dir_basename" "$dir_basename" "$dir_basename" "$dir_basename" > "$target_dir"/configure.ac

    printf "#Generated by amboso v$amboso_currvers\nAUTOMAKE_OPTIONS = foreign\nCFLAGS = @CFLAGS@\nSHELL := /bin/bash\n.ONESHELL:\nMACHINE := \$\$(uname -m)\nPACK_NAME = \$(TARGET)-\$(VERSION)-\$(OS)-\$(MACHINE)\n%s_SOURCES = src/main.c\nLDADD = \$(${caps_dir_basename}_LDFLAGS)\nAM_LDFLAGS = -O2\nAM_CFLAGS = \$(${caps_dir_basename}_CFLAGS) -O2 -Werror -Wpedantic -Wall\nif DEBUG_BUILD\nAM_LDFLAGS += -ggdb -O0\nAM_CFLAGS += \nelse\nAM_LDFLAGS += -s\nendif\n\n%%.o: %%.c\n\t\$(CCOMP) -c \$(CFLAGS) \$(AM_CFLAGS) $< -o \$@\n\n\$(TARGET): \$(%s_SOURCES:.c=.o)\n\t@echo -e \"    CFLAGS: [ \$(CFLAGS) ]\"\n\t@echo -e \"    AM_CFLAGS: [ \$(AM_CFLAGS) ]\"\n\t@echo -e \"    LDADD: [ \$(LDADD) ]\"\n\t\$(CCOMP) \$(CFLAGS) \$(AM_CFLAGS) \$(%s_SOURCES:.c=.o) -o \$@ \$(LDADD) \$(AM_LDFLAGS)\n\nclean:\n\t@echo -en \"Cleaning build artifacts:  \"\n\t-rm \$(TARGET)\n\t-rm src/*.o\n\t-rm static/*.o\n\t@echo -e \"Done.\"\n\ncleanob:\n\t@echo -en \"Cleaning object build artifacts:  \"\n\t-rm src/*.o\n\t-rm static/*.o\n\t@echo -e \"Done.\"\n\nanviltest:\n\t@echo -en \\\"Running anvil tests.\"\n\t./anvil -tX\n\t@echo -e \"Done.\"\n\nall: \$(TARGET)\nrebuild: clean all\n.DEFAULT_GOAL := all\n" "$dir_basename" "$dir_basename" "$dir_basename" > "$target_dir"/Makefile.am

    log_cl "Creating new repo in {$target_dir}" info

    ( cd "$target_dir" || { log_cl "[CRITICAL]    cd failed for {$target_dir}." error ; return 1 ; } ;
      git init
      [[ $quiet_flag -eq 0 ]] && log_cl "Initialised git repo" info
      git submodule add --depth 1 "git@github.com:jgabaut/amboso.git"
      [[ $quiet_flag -eq 0 ]] && log_cl "Added amboso submodule" info
      ln -s "amboso/amboso" "anvil"
      res="$?"
      [[ $quiet_flag -eq 0 ]] && log_cl "Symlinked \"amboso/amboso\" to \"./anvil\"" info
      exit "$res"
    )
    [[ "$?" -eq 0 ]] || { log_cl "git prep failed for {$target_dir}." error ; return 1 ; } ;
    [[ $quiet_flag -eq 0 ]] && log_cl "Done init for {$target_dir}" info
}

gen_C_headers() {
	target_dir="$1"
	tag="$2"
    local tag_str="$3"
	execname="$4"
	headername="anvil__$execname.h"
	c_headername="anvil__$execname.c"
	tag_date="$(git show -q --clear-decorations --format="%at" "$tag" 2>/dev/null)"
	tag_author="$(git show -q --clear-decorations "$tag" 2>/dev/null | grep Author | cut -f2 -d':' | awk -F" " '{printf $1}')"
    tag_txt="$(git show -q --clear-decorations "$tag" 2>/dev/null | grep commit | awk -F" " '{print $2}' | cut -c 1-8)"
	log_cl "[AMBOSO]    Gen C header for ($execname), v($tag) to dir ($target_dir)" info
	log_cl "[AMBOSO]    Reset file ($target_dir/$headername)" info
	printf "" > "$target_dir/$headername"
	log_cl "[AMBOSO]    Reset file ($target_dir/$c_headername)" info
	printf "" > "$target_dir/$c_headername"
    local header_gentime="$(date +%s)"
    printf "//Generated by amboso v$AMBOSO_API_LVL\n" >> "$target_dir/$headername"
    printf "//Repo at https://github.com/jgabaut/amboso\n\n" >> "$target_dir/$headername"
	printf "#ifndef ANVIL__${execname}__\n" >> "$target_dir/$headername"
	printf "#define ANVIL__${execname}__\n\n" >> "$target_dir/$headername"
	printf "static const char ANVIL__API_LEVEL__STRING[] = \"$AMBOSO_API_LVL\"; /**< Represents amboso version used for [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "static const char ANVIL__${execname}__VERSION_STRING[] = \"$tag_str\"; /**< Represents current version for [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "static const char ANVIL__${execname}__VERSION_DESC[] = \"$tag_txt\"; /**< Represents current version info for [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "static const char ANVIL__${execname}__VERSION_DATE[] = \"$tag_date\"; /**< Represents date for current version for [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "static const char ANVIL__${execname}__VERSION_AUTHOR[] = \"$tag_author\"; /**< Represents author for current version for [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
    printf "static const char ANVIL__${execname}__HEADER_GENTIME[] = \"$header_gentime\"; /**< Represents generation time for [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "const char *get_ANVIL__API__LEVEL__(void); /**< Returns a version string for amboso API of [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "const char *get_ANVIL__VERSION__(void); /**< Returns a version string for [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "const char *get_ANVIL__VERSION__DESC__(void); /**< Returns a version info string for [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "const char *get_ANVIL__VERSION__DATE__(void); /**< Returns a version date string for [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "const char *get_ANVIL__VERSION__AUTHOR__(void); /**< Returns a version author string for [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "const char *get_ANVIL__HEADER__GENTIME__(void); /**< Returns a generation time string for [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "#endif\n" >> "$target_dir/$headername"

    printf "//Generated by amboso v$AMBOSO_API_LVL\n\n" >> "$target_dir/$c_headername"
	printf "#include \"$headername\"\n\n" >> "$target_dir/$c_headername"
	printf "const char *get_ANVIL__VERSION__(void)\n{\n    return ANVIL__${execname}__VERSION_STRING;\n}\n\n" >> "$target_dir/$c_headername"
	printf "const char *get_ANVIL__VERSION__DESC__(void)\n{\n    return ANVIL__${execname}__VERSION_DESC;\n}\n\n" >> "$target_dir/$c_headername"
	printf "const char *get_ANVIL__VERSION__DATE__(void)\n{\n    return ANVIL__${execname}__VERSION_DATE;\n}\n\n" >> "$target_dir/$c_headername"
	printf "const char *get_ANVIL__VERSION__AUTHOR__(void)\n{\n    return ANVIL__${execname}__VERSION_AUTHOR;\n}\n\n" >> "$target_dir/$c_headername"
	printf "const char *get_ANVIL__HEADER__GENTIME__(void)\n{\n    return ANVIL__${execname}__HEADER_GENTIME;\n}\n\n" >> "$target_dir/$c_headername"
	printf "const char *get_ANVIL__API__LEVEL__(void)\n{\n    return ANVIL__API_LEVEL__STRING;\n}\n" >> "$target_dir/$c_headername"

}

set_supported_tests() {
  kazoj_dir=$1
  tests_filecount=0
  errors_filecount=0
  skipped=0
  i=0

  #tests loop
  cases_path="$kazoj_dir/$cases_dir"
  if [[ ! -d $cases_path ]]; then {
    log_cl "\"$cases_path\" was not a valid directory.\n" debug
    return 1
  }
  fi
  errorcases_path="$kazoj_dir/$errors_dir"
  if [[ ! -d $errorcases_path ]]; then {
    log_cl "\"$errorcases_path\" was not a valid directory.\n" debug
    return 1
  }
  fi
  for FILE in "$cases_path"/* ; do {
    [[ -e "$FILE" ]] || { log_cl "{$FILE} did not exist." warn ; continue ;}
      test_fp="$cases_path/$(basename "$FILE")"
      extens=$(printf "${cases_path}/${FILE}\n" | awk -F"." '{print $2}')
      if [[ "$extens" != "k" ]] ; then {
          [[ $verbose_flag -gt 3 && $quiet_flag -eq 0 ]] && log_cl "{$test_fp} does not have .k extension." warn
        skipped=$((skipped+1))
        continue
      }
      fi
      double_extens=$(printf "${cases_path}/${FILE}\n" | awk -F"." '{print $3}')
    if [[ "$double_extens" = "stderr" || "$double_extens" = "stdout" ]] ; then {
      skipped=$((skipped+1))
      [[ $verbose_flag -ge 4 && $quiet_flag -eq 0 ]] && log_cl "[PREP-TEST]    Skip record $FILE (at $(dirname "$test_fp"))." debug >&2
      continue
    }
    fi
    if ! [[ -f $test_fp && -x $test_fp ]] ; then {
      skipped=$((skipped+1))
      [[ $verbose_flag -ge 4 && $quiet_flag -eq 0 ]] && log_cl "[PREP-TEST]    Skip test \"$FILE\" (at $(dirname "$test_fp")), not an executable." debug >&2
      continue
    }
    fi
    read_tests_files["$tests_filecount"]="$(basename "$FILE")"
    tests_filecount=$(($tests_filecount+1))
  }
  done
  #errors loop
  for FILE in "$errorcases_path"/* ; do {
    [[ -e "$FILE" ]] || { log_cl "{$FILE} did not exist." warn ; continue ;}
    test_fp="$errorcases_path/$(basename "$FILE")"
    extens=$(printf "${errorcases_path}/${FILE}\n" | awk -F"." '{print $2}')
    if [[ "$extens" != "k" ]] ; then {
      [[ $verbose_flag -gt 3 && $quiet_flag -eq 0 ]] && log_cl "{$test_fp} does not have .k extension." warn
      skipped=$((skipped+1))
      continue
    }
    fi
    double_extens=$(printf "${errorcases_path}/${FILE}\n" | awk -F"." '{print $3}')
    if [[ "$double_extens" = "stderr" || "$double_extens" = "stdout" ]] ; then {
      skipped=$((skipped+1))
      [[ $verbose_flag -ge 4 && $quiet_flag -eq 0 ]] && log_cl "[PREP-TEST]    Skip record $FILE (at $(dirname "$test_fp"))." debug >&2
      continue
    }
    fi
    if ! [[ -f $test_fp && -x $test_fp ]] ; then {
      skipped=$((skipped+1))
      [[ $verbose_flag -ge 4 && $quiet_flag -eq 0 ]] && log_cl "[PREP-TEST]    Skip errtest \"$FILE\" (at $(basename "$test_fp")), not an executable." debug >&2
      continue
    }
    fi
    read_errortests_files["$errors_filecount"]="$(basename "$FILE")"
    errors_filecount=$(($errors_filecount+1))
  }
  done
  #echo "version array size is " "${#read_versions[@]}" >&2
  count_tests_names="${#read_tests_files[@]}"
  count_errortests_names="${#read_errortests_files[@]}"
  for test_name_idx in $(seq 0 $(($count_tests_names-1))); do
    supported_tests[test_name_idx]=${read_tests_files[$test_name_idx]}
  done
  for test_name_idx in $(seq 0 $(($count_errortests_names-1))); do
    supported_tests[$(($test_name_idx + $count_tests_names))]=${read_errortests_files[$test_name_idx]}
  done
  tot_tests=${#supported_tests[@]}
  #echo "tot tests: $tot_tests"
}

echo_tests_info() {
  kazoj_dir="$1"
  set_supported_tests "$kazoj_dir" 2>/dev/null
  echoed_cases_dir="${tests_info[0]}"
  echoed_errors_dir="${tests_info[1]}"
  log_cl "Tests dir is: ( $kazoj_dir )." debug >&2
  log_cl "Cases dir is: ( $echoed_cases_dir )." debug >&2
  log_cl "( $count_tests_names ) cases ready." debug >&2
  if [[ $big_list_flag -gt 0 ]] ; then {
    for test_name_idx in $(seq 0 $(($count_tests_names-1))) ; do {
      log_cl "( ${read_tests_files[$test_name_idx]} )." debug >&2
    }
    done
  }
  fi
  log_cl "Errors dir is: ( $echoed_errors_dir )." debug >&2
  log_cl "( $count_errortests_names ) error cases ready." debug >&2
  if [[ $big_list_flag -gt 0 ]] ; then {
    for test_name_idx in $(seq 0 $(($count_errortests_names-1))) ; do {
      log_cl "( ${read_errortests_files[$test_name_idx]} )." debug >&2
    }
    done
  }
  fi
  log_cl "( $tot_tests ) total tests ready." debug >&2
  #echo "$count_tests_infos"
  #echo "test info array contents are: ( ${tests_info[@]} )" >&2
}

echo_othermode_tags() {
  #Print remaining read versions not available in current mode
  if [[ $base_mode_flag -gt 0 ]] ; then {
    mode_txt="git"
    printf "  ( $count_git_versions ) supported tags when running in ( $mode_txt ) mode.\n"
    printf "  Run again in ( $mode_txt ) mode to use them.\n"
    for git_tag_idx in $(seq 0 $(($count_git_versions-1))); do {
      (( $git_tag_idx % 4 == 0)) && [[ $git_tag_idx -ne 0 ]] && printf "\n"
      printf "    ${read_git_tags[git_tag_idx]}"
    }
    done
  } else {
    mode_txt="base"
    printf "  ( $count_base_versions ) supported tags when running in ( $mode_txt ) mode.\n"
    printf "  Run again in ( $mode_txt ) mode to use them.\n"
    for git_tag_idx in $(seq 0 $(($count_base_versions-1))); do {
      (( $git_tag_idx % 4 == 0)) && [[ $git_tag_idx -ne 0 ]] && printf "\n"
      log_cl "    ${read_base_tags[git_tag_idx]}" info blue
    }
    done
  }
  fi
  printf "\n"
}

echo_supported_tags() {
  mode_txt="git"
  [[ $base_mode_flag -gt 0 ]] && mode_txt="base"
  printf "  ( $tot_vers ) supported tags for current mode ( $mode_txt ).\n"
  for tag_idx in $(seq 0 $(($tot_vers-1))); do { #Print currently supported versions (only ones conforming to mode)
    (( $tag_idx % 4 == 0)) && [[ $tag_idx -ne 0 ]] && printf "\n"
    log_cl "    ${supported_versions[tag_idx]}" info blue
  }
  done
  printf "\n"
}

git_mode_check() {
  is_git_repo=0
  #Check if we're inside a repo
  git rev-parse --is-inside-work-tree 2>/dev/null 1>&2
  is_git_repo="$?"
  if [[ $is_git_repo -gt 0 ]] ; then {
    if [[ $extensions_flag -gt 0 ]] ; then {
        log_cl "Not running in a git repo. Extensions enabled, returning success.\n" warn
        return 0
    } else {
        log_cl "Not running in a git repo. Try running with -B to use base mode.\n" error
        exit 1
    }
    fi
  }
  fi
  [[ $verbose_flag -gt 3 ]] && log_cl "[MODE]    Running in git mode." info >&2
  #Check if status is clean
  if output=$(git status --untracked-files=no --porcelain) && [ -z "$output" ]; then
	  return 0
  else
	return 1
  fi
}

amboso_help() {
    amboso_usage
    amboso_help_string="Options:
  -D, --amboso-dir <BIN_DIR>         Specify the directory to host tags [default: ./bin]
  -O, --stego-dir <STEGO_DIR>        Specify the directory to host stego.lock file [default: wd, BIN_DIR]
  -K, --kazoj-dir <TESTS_DIR>        Specify the directory to host tests
  -S, --source <SOURCE_NAME>         Specify the source name
  -E, --execname <EXEC_NAME>         Specify the target executable name
  -M, --maketag <MAKE_MINTAG>        Specify min tag using make as build/clean step
  -a, --anvil-version <AMBOSO_VERS>  Specify amboso version to use
  -k, --anvil-kern <AMBOSO_KERN>     Specify amboso kern to use
  -G, --gen-c-header <C_HEADER_DIR>  Generate anvil C header for passed dir
  -x, --linter <LINT_TARGET>         Act as stego linter for passed file
  -T, --test                         Specify test mode
  -B, --base                         Specify base mode
  -g, --git                          Specify git mode
  -t, --testmacro                    Specify test macro mode
  -i, --init                         Build all tags for current mode
  -p, --purge                        Delete binaries for all tags for current mode
  -d, --delete                       Delete binary for passed tag
  -b, --build                        Build binary for passed tag
  -r, --run                          Run binary for passed tag
  -l, --list                         Print supported tags for current mode
  -L, --list-all                     Print supported tags for all modes
  -q, --quiet                        Less output
  -s, --silent                       Almost no output
  -V, --verbose <VERBOSE>            More output [default: 3]
  -w, --watch                        Report timer
  -v, --version                      Print current version and quit
  -W, --warranty                     Print warranty info and quit
  -X, --no-gitcheck                  Ignore git mode checks
  -J, --logged                       Output to log file
  -P, --no-color                     Disable color output
  -F, --force                        Enable force build
  -R, --no-rebuild                   Disable calling make rebuild
  -C, --config <CONFIG_FILE>         Pass configuration file for ./configure arguments
  -Z, --cflags <CFLAGS>              Pass CFLAGS for single file mode
  -e, --strict                       Turn off extensions to 2.0
  -h, --help                         Print help
  -Y <START_TIME>                    Set start time of the program
  -z        (pack)                   Run \"make pack\"
  -H        (bighelp)                Print more help"
  printf "%s\n" "$amboso_help_string"
}

amboso_usage() {
  printf "amboso - Build tool wrapping make and git tags\n"
  printf "Usage: amboso [OPTIONS] [TAG] [COMMAND]\n"
  printf "    Run with -H for more info about options.\n\n"
  printf "Commands:
  test     does testing things
  build    Tries building latest tag
  init     Prepare a new anvil project
  version  Prints invil version
  help     Print this message or the help of the given subcommand(s)\n"

  printf "Arguments:
  [TAG]  Optional tag argument\n\n"
  printf "Example usage:  $(basename "$prog_name") [(-O|-D|-K|-M|-S|-E|-G|-C|-Z|-x|-V|-Y|-a|-k) <ARG>] [-TBtg] [-bripd] [-hHvlLsqwXWPJRFe] [TAG]\n"
}

escape_colorcodes_tee() {
  file="$1"
  outfile="$2"
  printf "" >"$outfile"
  #sed -r 's/\/\\3/g' "$file"
  #sed -e 's/\\033\[/COLOR[/g' -e 's/COLOR\[1;3/"<colorTag[Heavy,/g' -e 's/COLOR\[0;3/"<colorTag[Light,/g' -e 's/\\e\[0m/\]>"/g' "$file" >>"$outfile"
  #sed 's/\x1B\[\([0-9]\{1,2\}\(;[0-9]\{1,2\}\)\?\)\?[mGK]//g' <"$file"
  cat "$file" | tee "$outfile"
}

escape_colorcodes() {
  file="$1"
  outfile="$2"
  printf "" >"$outfile"
  #sed -r 's/\/\\3/g' "$file"
  #sed -e 's/\\033\[/COLOR[/g' -e 's/COLOR\[1;3/"<colorTag[Heavy,/g' -e 's/COLOR\[0;3/"<colorTag[Light,/g' -e 's/\\e\[0m/\]>"/g' "$file" >>"$outfile"
  #sed 's/\x1B\[\([0-9]\{1,2\}\(;[0-9]\{1,2\}\)\?\)\?[mGK]//g' <"$file"
  cat -e "$file" >"$outfile"
}

record_test() {
  tfp="$1" # test_file_path
  printf "" > "$tfp.stdout"
  printf "" > "$tfp.stderr"
  tmp_stdout="$(mktemp)"
  tmp_stderr="$(mktemp)"
  run_test "$tfp" >>"$tmp_stdout" 2>>"$tmp_stderr"
  res="$?"
  #echo "r: $res" >> "$tmp_stdout"
  escape_colorcodes_tee "$tmp_stdout" "$tfp.stdout"
  escape_colorcodes_tee "$tmp_stderr" "$tfp.stderr"
  rm -f "$tmp_stdout" || log_cl "Failed removing tmpfile ($tmp_stdout). Why?\n" error
  [[ $verbose_flag -gt 3 ]] && log_cl "[TEST]    Removed tempfile \"$tmp_stdout\"." info >&2
  rm -f "$tmp_stderr" || log_cl "Failed removing tmpfile ($tmp_stderr). Why?\n" error
  [[ $verbose_flag -gt 3 ]] && log_cl "[TEST]    Removed tempfile \"$tmp_stderr\"." info >&2
}

run_test() {
  tfp="$1" # test_file_path
  #echo -en "\033[1;36m"
  "$tfp"
  res="$?"
  #echo -en "\e[0m"
  return "$res"

}

delete_test() {
  #WIP
  tfp="$1" # test_file_path
  (
    printf "deleting $tfp\n" 2>/dev/null
    exit "$?"
  )
  res="$?"

  if [[ $res -eq 0 ]]; then {
    log_cl "[TEST]    Deleted $tfp." info >&2
  } else {
    log_cl "[TEST]    Failed deleting $tfp. How?" error >&2
  }
  fi
}

lex_stego_file() {
    #
    # Lex "scopes", "variables", "values" from stego file.
    # For each error detected in the file, prints a notice to stderr.
    # If any error is detected, it returns before printing to stdout.
    # Otherwise, prints the parsed tokens to stdout, using this format:
    #
    ############################################################################
    #                          #                                               #
    #   Format notes           #            Actual Output                      #
    #                          #                                               #
    ############################################################################
    #   main scope, named ""   #Variable: _dog, Value: bar                     #
    #                          #------------------------                       #
    #   other scope            #Scope: hi                                      #
    #                          #Variable: hi_foo, Value: fib                   #
    #                          #Variable: hi_man, Value: bar                   #
    #                          #------------------------                       #
    ############################################################################
    #
    if [[ ! -f $1 ]] ; then {
      log_cl "${FUNCNAME[0]}(): \"$1\" is not a valid file." error
      exit 8
    }
    fi
    input_file="$1"
    # Check if awk is available
    if ! command -v "${AMBOSO_AWK_NAME}" > /dev/null; then
        log_cl "[CRITICAL]    Error: ${AMBOSO_AWK_NAME} is not installed. Please install ${AMBOSO_AWK_NAME} before running this script." error
        exit 9
    fi

    "${AMBOSO_AWK_NAME}" '{
        # Remove leading and trailing whitespaces
        gsub(/^[ \t]+|[ \t]+$/, "")

        # Remove trailing comments outside quotes
        gsub(/#[^\n"]*$/, "")

        # Skip empty lines
        if ($0 == "") {
            next
        }

        if ($0 ~ /^\s*\[[^-A-Z\[\]\\\/\$]+\]\s*$/) {
            # Extract and set the current scope
            if (match($0, /^\s*\[\s*([^-A-Z\[\]]+)\s*\]\s*$/, a)) {
                current_scope=gensub(/\s*$/, "", "g", a[1])
                scopes[current_scope]++
            } else {
                print "[LINT]    Invalid header:    " $0 "" > "/dev/stderr"
                error_flag=1
            }
        } else if ($0 ~ /^"?[^"=\[\]_\$\\\/{}]+"? *= *"[^=\[\]\${}]+"$/) {
            # Check if the line is a valid variable assignment

            split($0, parts, "=")
            variable=gensub(/^ *"?([^"]+)"? *$/, "\\1", "g", parts[1])
            value=gensub(/^ *"?([^"]*)"? *$/, "\\1", "g", parts[2])

            # Trim trailing whitespaces from variable and value
            gsub(/[ \t]+$/, "", variable)
            gsub(/[ \t]+$/, "", value)

            # Check if left side contains disallowed characters
            if (index(variable, " ") > 0 || (index(variable, "#") > 0 && index(variable, "\"") == 0)) {
                print "[LINT]    Invalid left side (contains spaces or disallowed characters):    " variable "" > "/dev/stderr"
                error_flag=1
                next
            }

            if (current_scope == "main") {
                variable = "main_" variable
            }
            values[current_scope "_" variable]=value
            if (!(current_scope in scopes)) {
                scopes[current_scope]++
            }
        } else if ($0 ~ /^[^-A-Z_\[\]\$\\\/{}]+ *= *{[^}A-Z\\\$#\]\[]+ *}$/) {
            # Check if line has a curly bracket rightval
            # Extract variable
            variable = gensub(/^ *"?([^{="]+)"? *=.*$/, "\\1", "g", $0)
            value = gensub(/^.*= *{ *([^}A-Z\\\$]+) *}$/, "\\1", "g", $0)
            # Trim trailing whitespaces from variable and value
            gsub(/[ \t]+$/, "", variable)
            gsub(/[ \t]+$/, "", value)
            if (current_scope == "main") {
                variable = "main_" variable
            }
            values[current_scope "_" variable]=value
            if (!(current_scope in scopes)) {
                scopes[current_scope]++
            }
        } else {
                if ($0 ~ /^$/) {
                    # This is a comment-only line and we can ignore it
                    next
                } else {
                    print "[LINT]    Invalid line:    " $0 "" > "/dev/stderr"
                    error_flag=1
                }
        }
    } END {
        if (error_flag == 1) {
                print "[LEX]    Errors while lexing." > "/dev/stderr"
        } else {
            # Print each scope and its variable-value pairs
            for (scope in scopes) {
                print "Scope: " scope
                for (var in values) {
                    if (index(var, scope "_") == 1 || (scope == "main" && index(var, "main_") == 1)) {
                        print "Variable: " var ", Value: " values[var]
                    }
                }
                print "------------------------"
            }
        }
    }' "$input_file"
}

parse_lexed_stego() {
  # Parse "scopes", "variables", "values" from stego lexed tokens
  # Expects format described in lex_stego_file()

  input="$1"
  # Read the output into Bash arrays
  while IFS= read -r line; do
      if [[ $line =~ ^Scope:\ (.*)$ ]]; then
          current_scope="${BASH_REMATCH[1]}"
      elif [[ $line =~ ^Variable:\ (.+),\ Value:\ (.*)$ ]]; then
          variable="${BASH_REMATCH[1]}"
          value="${BASH_REMATCH[2]}"
          scopes+=("$current_scope")
          variables+=("$variable")
          values+=("$value")
      fi
  done <<< "$input"
}

try_parsing_anvil_conf() {
  if [[ ! -f $1 ]] ; then {
    log_cl "${FUNCNAME[0]}(): \"$1\" is not a valid file." error
    exit 9
  }
  fi
  input="$1"
  verbose="$2"
  lexed_tokens=""

  lexed_tokens="$(lex_stego_file "$input")"
  if [[ ! -z $lexed_tokens ]]; then {
    parse_lexed_stego "$lexed_tokens"
    parse_res="$?"
    return "$parse_res"
  } else {
    log_cl "[PARSE]    Lint failed." error
    return 1
  }
  fi
}

lint_stego_file() {
  #Try lexing input file. If verbose is 1, print the lexed tokens.
  #If lex output is empty, return 1.
  if [[ ! -f $1 ]] ; then {
    log_cl "${FUNCNAME[0]}(): \"$1\" is not a valid file." error
    exit 8
  }
  fi

  input="$1"
  verbose="$2"

  lex_output="$(lex_stego_file "$input")"
  [[ $verbose -eq 1 ]] && printf "$lex_output\n"
  if [[ -z "$lex_output" ]]; then
    log_cl "[CHECK]    Errors occurred during lexing." error
    return 1
  fi
  return 0
}

try_parsing_stego() {
  # Lints the passed file. If verbose if passed as "1", also prints the lexed tokens to stdout.
  # Then, if the lint was successful, tries parsing the lexed tokens.
  # Upon return, arrays "scopes", "variables", "values" are set.
  if [[ ! -f $1 ]] ; then {
    log_cl "${FUNCNAME[0]}(): \"$1\" is not a valid file." error
    exit 8
  }
  fi
  input="$1"
  verbose="$2"
  lexed_tokens=""

  if compare_semver "$std_amboso_version" ">" "1.8.x" ; then {
    lexed_tokens="$(lex_stego_file "$input")"
  } else {
    # Run the legacy function
    lexed_tokens="$(lex_legacy_stego 1 "$input")"
    if [[ "$?" != 0 ]]; then {
        log_cl "[PARSE]    Legacy lex for {$std_amboso_version} failed." error
        return 1
    }
    fi
  }
  fi
  if [[ ! -z $lexed_tokens ]]; then {
    parse_lexed_stego "$lexed_tokens"
    parse_res="$?"
    return "$parse_res"
  } else {
    log_cl "[PARSE]    Lint failed." error
    return 1
  }
  fi
}

bash_gulp_anvil_conf() {
  # Try gulping the "scopes", "variables" and "values" bash arrays from parsing the passed file
  local input="$1"
  if [[ ! -f "$input" ]] ; then {
    log_cl "${FUNCNAME[0]}(): \"$input\" is not a valid file." error
    exit 8
  }
  fi

  filename="$input"
  verbose="$2"
  try_parsing_anvil_conf "$input" "$verbose"
  parse_res="$?"
  if [[ $parse_res -eq 0 ]]; then {
    [[ $verbose -eq 1 ]] && log_cl "[SUCCESS]    Parsed file \"$filename\"" info
    [[ $verbose -eq 1 ]] && log_cl "[Lexed variables] { ${variables[*]} }\n" info magenta
    [[ $verbose -eq 1 ]] && log_cl "[Lexed values]    { ${values[*]} }" info blue
    return 0
  } else {
    log_cl "${FUNCNAME[0]}(): Failed parsing file { $1 }\n" error
    return 1
  }
  fi
}

use_anvil_version_arg() {
  local my_value="$1"
  local anvil_version_regex='^([1-9][0-9]*|0)\.([1-9][0-9]*|0)\.([1-9][0-9]*|0)$'
  if [[ "$my_value" =~ $anvil_version_regex ]] ; then {
    case "$my_value" in
      1.8.*)
          log_cl "Invalid version arg --> {$my_value}" error
          log_cl "Hint: Use one of these: --> {" error
          for v in "${std_amboso_version_list[@]}"; do
              log_cl "    $v" info
          done
          log_cl "}" error
          exit 1
          ;;
      1.9.*)
          log_cl "Invalid version arg --> {$my_value}" error
          log_cl "Hint: Use one of these: --> {" error
          for v in "${std_amboso_version_list[@]}"; do
              log_cl "    $v" info
          done
          log_cl "}" error
          exit 1
          ;;
      1.*)
          log_cl "${FUNCNAME[0]}():    Turning off extensions flag" info
          extensions_flag=0
          ;;
      2.0.0)
          log_cl "${FUNCNAME[0]}():    Turning off extensions flag" info
          extensions_flag=0
          ;;
      2.0.*)
          :
          ;;
      2.1.0)
          log_cl "${FUNCNAME[0]}():    Running as 2.1 preview" info
          ;;
      *)
          log_cl "${FUNCNAME[0]}():    Invalid version arg --> {$my_value}" error
          log_cl "Hint: Use one of these: --> {" error
          for v in "${std_amboso_version_list[@]}"; do
              log_cl "    $v" info
          done
          log_cl "}" error
          exit 1
          ;;
    esac
    [[ "$verbose_flag" -ge 4 ]] && log_cl "${FUNCNAME[0]}():  Using ANVIL_VERSION: {$my_value}\n" info
    if compare_semver "$std_amboso_version" "<" "$min_amboso_v_stego_noforce" ; then {
        log_cl "Taken legacy path: stego.lock defined value always overrides current std_amboso_version." warn cyan
        log_cl "Current: {$std_amboso_version}, min needed: {$min_amboso_v_stego_noforce}" warn
        if compare_semver "$std_amboso_version" "<=" "${AMBOSO_API_LVL}" ; then {
          # This check was not present originally.
          std_amboso_version="$my_value"
        } else {
          log_cl "Resetting std_amboso_version. ($std_amboso_version) -> {${AMBOSO_API_LVL}}" warn magenta
          std_amboso_version="${AMBOSO_API_LVL}"
        }
        fi
        log_cl "Set std_amboso_version to -> {$std_amboso_version}" warn
    } else {
      if compare_semver "$std_amboso_version" "<=" "${AMBOSO_API_LVL}" ; then {
        # This check was not present originally.
        std_amboso_version="$my_value"
      } else {
        log_cl "Resetting std_amboso_version. ($std_amboso_version) -> {${AMBOSO_API_LVL}}" warn magenta
        std_amboso_version="${AMBOSO_API_LVL}"
      }
      fi
    }
    fi
  } else {
    log_cl "${FUNCNAME[0]}():  Invalid version standard --> {$my_value}" error
    log_cl "Not matching regex --> \'$anvil_version_regex\'" error
    exit 1
  }
  fi
}

set_anvil_conf_info() {
  # Reads the passed file and sets
  # - Anvil version and kern
  anvil_file="$1"
  verbose="$2"

  bash_gulp_anvil_conf "$anvil_file" 0 #&& print_amboso_stego_scopes
  if [[ ! $? -eq 0 ]]; then {
    log_cl "Failed parsing conf file at \"$anvil_file\"." error
    exit 10
  }
  fi
  for ((i=0; i<${#scopes[@]}; i++)); do
  [[ $verbose -gt 1 ]] && printf "{${variables[i]}} = {${values[i]}}\n"
  scope="${scopes[i]}"
  variable="${variables[i]}"
  value="${values[i]}"
  #is_noscope=0
  if [[ -z $scope ]] ; then {
    :
    #is_noscope=1
    #Display scope as "main", even tho it should be equal to ""
    #printf "\033[1;35mScope:\033[0m \"main\", \033[1;33mVariable:\033[0m \"$variable\", Value: \"\033[1;36m$value\033[0m\"\n\n"
  } else {
    #Print values for all scopes
    #printf "\033[1;34mScope:\033[0m \"$scope\", \033[1;33mVariable:\033[0m \"$variable\", Value: \"\033[1;36m$value\033[0m\"\n\n"
    if [[ $scope = "anvil" ]] ; then {
        if [[ $variable = "anvil_version" ]] ; then {
          use_anvil_version_arg "$value"
        } elif [[ $variable = "anvil_kern" ]] ; then {
          if compare_semver "$std_amboso_version" ">=" "$min_amboso_v_kern" ; then {
            handle_kern_arg "$value"
          } else {
            if [[ "${AMBOSO_LVL_REC}" -eq 1 || "$verbose_flag" -gt 3 ]] ; then {
              log_cl "std_amboso_version --> {$std_amboso_version}" info
              log_cl "Ignoring stego-defined kern --> {$value}" debug
            }
            fi
          }
          fi
        }
        fi
    }
    fi
  }
  fi
  done
  count_source_infos="${#sources_info[@]}"
  return 0
}

bash_gulp_stego() {
  # Try gulping the "scopes", "variables" and "values" bash arrays from parsing the passed file
  input="$1"
  if [[ ! -f "$input" ]] ; then {
    log_cl "${FUNCNAME[0]}(): \"$input\" is not a valid file." error
    exit 8
  }
  fi

  filename="$input"
  verbose="$2"
  try_parsing_stego "$input" "$verbose"
  parse_res="$?"
  if [[ $parse_res -eq 0 ]]; then {
    [[ $verbose -eq 1 ]] && log_cl "[SUCCESS]    Parsed file \"$filename\"" info
    [[ $verbose -eq 1 ]] && log_cl "[Lexed variables] { ${variables[*]} }\n" info magenta
    [[ $verbose -eq 1 ]] && log_cl "[Lexed values]    { ${values[*]} }" info blue
    return 0
  } else {
    log_cl "${FUNCNAME[0]}(): Failed parsing file { $1 }\n" error
    return 1
  }
  fi
}

print_amboso_stego_scopes() {
  for ((i=0; i<${#scopes[@]}; i++)); do
  scope="${scopes[i]}"
  variable="${variables[i]}"
  value="${values[i]}"
  #is_noscope=0
  if [[ -z $scope ]] ; then {
    :
    #is_noscope=1
    #Display scope as "main", even tho it should be equal to ""
    #printf "\033[1;35mScope:\033[0m \"main\", \033[1;33mVariable:\033[0m \"$variable\", Value: \"\033[1;36m$value\033[0m\"\n\n"
  } else {
    #Print values for all scopes
    #printf "\033[1;34mScope:\033[0m \"$scope\", \033[1;33mVariable:\033[0m \"$variable\", Value: \"\033[1;36m$value\033[0m\"\n\n"
    if [[ $scope = "build" ]] ; then {
      if [[ $variable = "build_source" ]]; then {
        printf "ANVIL_SOURCE: {$value}\n"
      } elif [[ $variable = "build_bin" ]]; then {
        printf "ANVIL_BIN: {$value}\n"
      } elif [[ $variable = "build_makevers" ]]; then {
        printf "ANVIL_MAKE_VERS: {$value}\n"
      } elif [[ $variable = "build_automakevers" ]]; then {
        printf "ANVIL_AUTOMAKE_VERS: {$value}\n"
      } elif [[ $variable = "build_tests" ]]; then {
        printf "ANVIL_TESTDIR: {$value}\n"
      }
      fi
    } elif [[ $scope = "versions" ]] ; then {
        tag="$(printf -- "$variable\n" | cut -f2 -d'_')"
        if [[ $tag == B* ]] ; then {
          printf -- "ANVIL_BASE_VERSION: {$tag}\n"
        } else {
          printf "ANVIL_GIT_VERSION: {$tag}\n"
        }
        fi
    } elif [[ $scope = "tests" ]] ; then {
        test_dir="$value"
        if [[ $variable = "tests_testsdir" ]] ; then {
          printf "ANVIL_BONE_DIR: {$test_dir}\n"
        } elif [[ $variable = "tests_errortestsdir" ]] ; then {
          printf "ANVIL_KULPO_DIR: {$test_dir}\n"
        }
        fi
    } elif [[ $scope = "anvil" ]] ; then {
        if [[ $variable = "anvil_version" ]] ; then {
          printf "ANVIL_VERSION: {$value}\n"
        } elif [[ $variable = "anvil_kern" ]] ; then {
          if compare_semver "$std_amboso_version" ">=" "$min_amboso_v_kern" ; then {
              printf "ANVIL_KERN: {$value}\n"
          }
          fi
        }
        fi
    }
    fi
  }
  fi
  done
}

set_amboso_stego_info() {
  # Reads the passed file and sets
  # - Amboso build info variables
  # - Version tag variables
  stego_file="$1"
  verbose="$2"

  bash_gulp_stego "$stego_file" 0 #&& print_amboso_stego_scopes
  if [[ ! $? -eq 0 ]]; then {
    log_cl "Failed parsing stego file at \"$stego_file\"." error
    exit 7
  }
  fi
  git_tags_count=0
  base_tags_count=0
  read_tags=0
  for ((i=0; i<${#scopes[@]}; i++)); do
  [[ $verbose -gt 1 ]] && printf "{${variables[i]}} = {${values[i]}}\n"
  scope="${scopes[i]}"
  variable="${variables[i]}"
  value="${values[i]}"
  #is_noscope=0
  if [[ -z $scope ]] ; then {
    :
    #is_noscope=1
    #Display scope as "main", even tho it should be equal to ""
    #printf "\033[1;35mScope:\033[0m \"main\", \033[1;33mVariable:\033[0m \"$variable\", Value: \"\033[1;36m$value\033[0m\"\n\n"
  } else {
    #Print values for all scopes
    #printf "\033[1;34mScope:\033[0m \"$scope\", \033[1;33mVariable:\033[0m \"$variable\", Value: \"\033[1;36m$value\033[0m\"\n\n"
    if [[ $scope = "build" ]] ; then {
      if [[ $variable = "build_source" ]]; then {
        [[ $verbose -gt 0 ]] && printf "ANVIL_SOURCE: {$value}\n"
        [[ $verbose -gt 0 ]] && printf "source_name: {$value} <- {$source_name}\n\n"
        source_name="$value"
        sources_info[0]="$source_name"
      } elif [[ $variable = "build_bin" ]]; then {
        [[ $verbose -gt 0 ]] && printf "ANVIL_BIN: {$value}\n"
        [[ $verbose -gt 0 ]] && printf "exec_entrypoint: {$value} <- {$exec_entrypoint}\n\n"
        exec_entrypoint="$value"
        sources_info[1]="$exec_entrypoint"
      } elif [[ $variable = "build_makevers" ]]; then {
        [[ $verbose -gt 0 ]] && printf "ANVIL_MAKE_VERS: {$value}\n"
        [[ $verbose -gt 0 ]] && printf "makefile_version: {$value} <- {$makefile_version}\n\n"
        makefile_version="$value"
        sources_info[2]="$makefile_version"
      } elif [[ $variable = "build_automakevers" ]]; then {
        [[ $verbose -gt 0 ]] && printf "ANVIL_AUTOMAKE_VERS: {$value}\n"
        [[ $verbose -gt 0 ]] && printf "use_automake_version: {$value} <- {$use_automake_version}\n\n"
        [[ $verbose -gt 0 ]] && printf "use_autoconf_version: {$value} <- {$use_autoconf_version}\n\n"
        use_automake_version="$value"
        use_autoconf_version="$value"
        sources_info[4]="$use_automake_version"
        sources_info[5]="$use_autoconf_version"
      } elif [[ $variable = "build_tests" ]]; then {
        [[ $verbose -gt 0 ]] && printf "ANVIL_TESTDIR: {$value}\n"
        [[ $verbose -gt 0 ]] && printf "kazoj_dir: {$value} <- {$kazoj_dir}\n\n"
        kazoj_dir="$value"
        sources_info[3]="$kazoj_dir"
      }
      fi
    } elif [[ $scope = "versions" ]] ; then {
        tag="$(printf -- "$variable\n" | cut -f2 -d'_')"
        if [[ $tag == B* ]] ; then {
          [[ $verbose -gt 0 ]] && printf "ANVIL_BASE_VERSION: {$tag}\n"
          cut_tag="$(printf -- "$tag\n" | cut -f2 -d'B')"
          read_base_tags[base_tags_count]="$cut_tag"
          #printf "${read_base_tags[base_tags_count]} at {$base_tags_count}\n"
          base_tags_count=$(($base_tags_count+1))
          read_tags=$(($read_tags+1))
        } else {
          [[ $verbose -gt 0 ]] && printf "ANVIL_GIT_VERSION: {$tag}\n"
          read_git_tags[git_tags_count]="$tag"
          #printf "${read_git_tags[git_tags_count]} at {$git_tags_count}\n"
          git_tags_count=$(($git_tags_count+1))
          read_tags=$(($read_tags+1))
        }
        fi
    } elif [[ $scope = "tests" ]] ; then {
        read_dir="$value"
        if [[ $variable = "tests_testsdir" ]] ; then {
          [[ $verbose -gt 0 ]] && printf "ANVIL_BONE_DIR: {$read_dir}\n"
          tests_info[0]="$read_dir"
          cases_dir="${tests_info[0]}"
        } elif [[ $variable = "tests_errortestsdir" ]] ; then {
          [[ $verbose -gt 0 ]] && printf "ANVIL_KULPO_DIR: {$read_dir}\n"
          tests_info[1]="$read_dir"
          errors_dir="${tests_info[1]}"
        }
        fi
    } elif [[ $scope = "anvil" ]] ; then {
        if [[ $variable = "anvil_version" ]] ; then {
          use_anvil_version_arg "$value"
        } elif [[ $variable = "anvil_kern" ]] ; then {
          if compare_semver "$std_amboso_version" ">=" "$min_amboso_v_kern" ; then {
            #log_cl "Checking stego kern value: {$value}" debug
            handle_kern_arg "$value"
          } else {
            if [[ "${AMBOSO_LVL_REC}" -eq 1 || "$verbose_flag" -gt 3 ]] ; then {
              log_cl "std_amboso_version --> {$std_amboso_version}" info
              log_cl "Ignoring stego-defined kern --> {$value}" debug
            }
            fi
          }
          fi
        } elif [[ $variable = "anvil_custombuilder" ]] ; then {
            if compare_semver "$std_amboso_version" ">=" "$min_amboso_v_custom_kern" ; then {
                handle_custombuilder_arg "$value"
                local chk_res="$?"
                [[ "$chk_res" -ne 0 ]] && { log_cl "anvil_custombuilder --> {$value}" error; exit 1; }
            } else {
                if [[ "${AMBOSO_LVL_REC}" -eq 1 || "$verbose_flag" -gt 3 ]] ; then {
                  log_cl "std_amboso_version --> {$std_amboso_version}" info
                  log_cl "Ignoring stego-defined builder --> {$value}" debug
                }
                fi
            }
            fi
        }
        fi
    }
    fi
  }
  fi
  done
  count_source_infos="${#sources_info[@]}"
  if [[ -z $exec_entrypoint ]] ; then {
      log_cl "Missing binary name." error
      exit 1
  }
  fi
  if [[ -z $source_name ]] ; then {
      log_cl "${FUNCNAME[0]}(): Missing source name." error
      exit 2
  }
  fi
  if [[ -z $makefile_version ]] ; then {
      log_cl "Missing first version using make." error
      exit 3
  }
  fi
  if [[ -z $use_automake_version ]] ; then {
      log_cl "Missing first version using automake." error
      exit 4
  }
  fi
  if [[ -z $use_autoconf_version ]] ; then {
      log_cl "Missing first version using autoconf." error
      exit 5
  }
  fi
  if [[ -z $kazoj_dir ]] ; then {
      log_cl "Missing tests dir." error
      exit 6
  }
  fi
  [[ $verbose -gt 0 ]] && log_cl "Read {$count_source_infos} amboso params." info

  count_git_versions="${#read_git_tags[@]}"
  count_base_versions="${#read_base_tags[@]}"
  strict_regex='^([1-9][0-9]*|0)\.([1-9][0-9]*|0)\.([1-9][0-9]*|0)$'
  full_regex='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-((0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*))*))?(\+([0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*))?$'

  for gt in "${read_git_tags[@]}" ; do {
      if [[ ! "$gt" =~ $strict_regex ]] ; then {
        if [[ "$gt" =~ $full_regex ]] ; then {
            log_cl "Pre-release and build metadata is not allowed for strict semver." warn
        }
        fi
        log_cl "Invalid key: {$gt}" error
        exit 1
      }
      fi
  }
  done
  for bt in "${read_base_tags[@]}" ; do {
      if [[ ! "$bt" =~ $strict_regex ]] ; then {
        if [[ "$gt" =~ $full_regex ]] ; then {
            log_cl "Pre-release and build metadata is not allowed for strict semver." warn
        }
        fi
        log_cl "Invalid key: {$bt}" error
        exit 1
      }
      fi
  }
  done
  # Sort the SemVer tags
  read_git_tags=($(printf "%s\n" "${read_git_tags[@]}" | sort -V))
  read_base_tags=($(printf "%s\n" "${read_base_tags[@]}" | sort -V))

  #echo "$count_git_versions"
  #echo "$count_base_versions"
  #echo_active_flags
  #echo "base version array contents are: ( ${read_base_tags[@]} )" >&2
  #echo "git version array contents are: ( ${read_git_tags[@]} )" >&2
  #echo "version array contents are: ( ${read_versions[@]} )" >&2
  if [[ $base_mode_flag -gt 0 ]] ; then {
    for base_tag_idx in $(seq 0 $(($count_base_versions-1))); do
      supported_versions[base_tag_idx]=${read_base_tags[$base_tag_idx]}
    done
  } else {
    for git_tag_idx in $(seq 0 $(($count_git_versions-1))); do
      supported_versions[git_tag_idx]=${read_git_tags[$git_tag_idx]}
    done
  }
  fi
  tot_vers="${#supported_versions[@]}"
  latest_idx=0
  if [[ "$tot_vers" -eq 0 ]] ; then {
    log_cl "Empty supported versions map." warn
    latest_idx=0
  } else {
    latest_idx="$(( $tot_vers - 1))"
  }
  fi
  latest_version="${supported_versions[latest_idx]}"
  [[ $verbose -gt 0 ]] && log_cl "Read {$tot_vers} tags." info
  return 0
}

handle_anvil_arg() {
  local arg="$1"
  if [[ "$arg" =~ $std_amboso_regex ]] ; then {
     case "$arg" in
       1.*)
           log_cl "${FUNCNAME[0]}():    Turning off extensions flag" info
           extensions_flag=0
           std_amboso_version="$arg"
           log_cl "Using {$std_amboso_version} version standard" info
           ;;
       2.0.0)
           log_cl "${FUNCNAME[0]}():    Turning off extensions flag" info
           extensions_flag=0
           std_amboso_version="$arg"
           log_cl "Using {$std_amboso_version} version standard" info
           ;;
       2.0.*)
           std_amboso_version="$arg"
           log_cl "Using {$std_amboso_version} version standard" info
           ;;
       *)
           log_cl "Invalid version arg --> {$arg}" error
           log_cl "Hint: Use one of these: --> {" error
           for v in "${std_amboso_version_list[@]}"; do
               log_cl "    $v" info
           done
           log_cl "}" error
           exit 1
           ;;
     esac
   } elif [[ "$arg" =~ $std_amboso_short_regex ]] ; then {
     case "$arg" in
       1.[0-9])
           log_cl "${FUNCNAME[0]}():    Turning off extensions flag" info
           extensions_flag=0
           std_amboso_version="${arg}.0"
           log_cl "Using {$std_amboso_version} version standard" info
           ;;
       2.0)
           log_cl "${FUNCNAME[0]}():    Turning off extensions flag" info
           #We don't update the std_amboso_version yet, since this version is current and we can use the latest patch.
           extensions_flag=0
           log_cl "Using {$std_amboso_version} version standard (patch level: $(cut -f3 -d'.' <<< "$std_amboso_version"))" info
           ;;
       2.1)
           #We don't update the std_amboso_version yet, since this version is in development
           log_cl "Using {$std_amboso_version} version standard" info
           ;;
       *)
           log_cl "Invalid version arg --> {$arg}" error
           log_cl "Hint: Use one of these: --> {" error
           for v in "${std_amboso_short_version_list[@]}"; do
               log_cl "    $v" info
           done
           log_cl "}" error
           exit 1
           ;;
     esac

       :
   } else {
     log_cl "Invalid version standard --> {$arg}" error
     log_cl "Not matching regex --> \'$std_amboso_regex\'" error
     exit 1
   }
   fi
}

handle_kern_arg() {
  local arg="$1"
  case "$arg" in
   "amboso-C" | "anvilPy" | "custom" )
       queried_amboso_kern="$arg"
       [[ "$verbose_flag" -gt 3 ]] && log_cl "Queried {$queried_amboso_kern} kern" info
       ;;
   *)
       log_cl "Invalid kern argument --> {$arg}" error
       log_cl "Hint: Use one of these: --> {" error
       for v in "${std_amboso_kern_list[@]}"; do
           log_cl "    $v" info
       done
       log_cl "}" error
       exit 1
       ;;
  esac
}

handle_genC_arg() {
  gen_C_headers_flag=1
  gen_C_headers_destdir="$1"
  if [[ ! -d $gen_C_headers_destdir ]] ; then {
      log_cl "($gen_C_headers_destdir) was not a valid directory." warn
      gen_C_headers_set=1 #TODO: this reads horribly. It's a patch to allow the called function to still be called, since now it will try to make the directory
  } else {
      gen_C_headers_set=1
  }
  fi
}

handle_verbose_arg() {
  local requested_lvl="$1"
  local verbose_lvl_re='^[0-5]$'
  if ! [[ "$requested_lvl" =~ $verbose_lvl_re ]]; then {
      log_cl "Invalid verbose lvl: {$requested_lvl}" error
      amboso_help
      exit 1
  } else {
  verbose_flag="$( printf "$requested_lvl\n" | awk -F" " '{print $1}')"
  }
  fi
}

handle_nohyphen_flags_arg() {
    local arg="$1"
    local flag="$2"
    [[ -z "$arg" ]] && { log_cl "Invalid empty arg for flag --$flag" error; amboso_usage; exit 1; }
    [[ "${AMBOSO_ALLOW_FLAGS_HYPHEN_ARG:-0}" -gt 0 ]] && return #We skip the hyphen check. Someone may not want it?
    [[ "$arg" == -* ]] && { log_cl "Flag arguments should not start with -:  -$flag $arg" error; amboso_usage; exit 1; }
}

handle_config_arg() {
    local arg="$1"
    local flag="$2"
    [[ -z "$arg" ]] && { log_cl "Invalid empty arg for flag -$flag" error; amboso_usage; exit 1; }
    if [[ "${AMBOSO_CONFIG_FLAG_ARG_ISFILE:-1}" -ne 0 ]]; then { #Isfile defaults to 1 to start with backwards compatibility
        #We expect the argument to be a filename
        #Note that setting AMBOSO_ALLOW_FLAGS_HYPHEN_ARG >0 is also needed if the filename starts with -
        handle_nohyphen_flags_arg "$arg" "$flag"
    }
    fi
}

check_for_reserved_chars() {
    local arg="$1"
    local reserved_chars='[\$\`\"\;\|\&\>\<\*\(\)\#\{\}]|\[|\]'

    # Check if the arg contains any of the reserved characters
    if [[ $arg =~ $reserved_chars ]]; then
        return 1  # Return 1 for invalid arg
    fi

    return 0  # Return 0 for valid arg
}

handle_custombuilder_arg() {
    local arg="$1"
    [[ -z "$arg" ]] && { log_cl "Invalid empty arg for custombuilder" error; return 1; }
    check_for_reserved_chars "$arg"
    local res="$?"
    [[ "$res" -ne 0 ]] && { log_cl "Invalid arg for custombuilder: {$arg}" error; return 1; }
    amboso_custom_builder="$arg"
}

amboso_git_switch() {
    local head_detached="${1:-0}"
    local git_switch_res=1
    if [[ "$head_detached" -eq 1 ]]; then {
        #We use --detach when the checkout started from a detached HEAD to begin with
        # If we were to always use it, we'd not go back to previous named branch
        log_cl "Checkout started from a detached HEAD, will add --detach to the switchback" debug
        git switch - --detach #We get back to starting repo state
        git_switch_res="$?"
    } else {
        git switch - #We get back to starting repo state
        git_switch_res="$?"
    }
    fi
    return "$git_switch_res"
}

amboso_is_head_detached() {
    if compare_semver "$std_amboso_version" ">=" "$min_amboso_v_check_detached"; then {
        #From https://stackoverflow.com/questions/17322876/how-to-tell-if-your-head-is-detached-in-git
        local cur_head_str="$(git rev-parse --abbrev-ref --symbolic-full-name HEAD)"
        if [[ "$cur_head_str" = "HEAD" ]]; then {
            log_cl "Starting from a detached HEAD" debug cyan
            return 0
        }
        fi
    } else {
      log_cl "Taken legacy path: will not do --detach on switchback" warn cyan
    }
    fi
    return 1
}

ambosoC_build_step() {
    # This function is not very clean. It uses some variables which are to be set before calling it.
    # Some of these variables are:
    #   has_makefile
    #   can_automake
    local target_dir_path="$1"
    local target_tag="$2"
    local target_binary="$3"
    local target_source="$4"
    local has_config_script_args="$5"
    local config_script_arg="$6"
    local has_CFLAGS="$7"
    local arg_CFLAGS="$8"
    if [[ ! -d "$target_dir_path" ]] ; then
      if compare_semver "$std_amboso_version" ">=" "$min_amboso_v_treegen" ; then {
        [[ "$base_mode_flag" -gt 0 ]] && { log_cl "Base mode, can't find target dir {$target_dir_path}." error >&2; return 1; } ;
        log_cl "Creating target_dir_path {$target_dir_path}" debug cyan >&2
        mkdir "$target_dir_path" || { log_cl "Failed creating target_dir_path: {$target_dir_path}" error >&2 ; return 1; } ;
      } else {
        log_cl "'$target_dir_path' is not a valid directory.\n    Check your supported versions for details on ( $target_tag ).\n" error >&2
        echo_timer "$amboso_start_time"  "Invalid path [$target_dir_path]" "1"
        return 1
      }
      fi
    fi
    #we try to build
    tool_txt="single file gcc"
    if [[ $has_makefile -gt 0 ]]; then { #Make mode
      tool_txt="make"
      if [[ $can_automake -gt 0 ]] ; then { #We support automake by doing autoreconf and ./configure before running make.
        tool_txt="automake"
        log_cl "[MODE]    target ( $target_tag ) >= ( $use_autoconf_version ), can autoconf." debug >&2
        autoreconf
        if [[ $? -ne 0 ]] ; then {
          log_cl "autoreconf failed. Doing \"automake --add-missing ; autoreconf\"" warn >&2
          automake --add-missing
          autoreconf
        }
        fi
        configure_arg=""
        if [[ "$has_config_script_args" -eq 1 ]] ; then {
            if [[ "${AMBOSO_CONFIG_FLAG_ARG_ISFILE:-1}" -ne 0 ]]; then { #Isfile defaults to 1 to start with backwards compatibility
              configure_arg="$(cat "$config_script_arg")"
            } else {
              configure_arg="$config_script_arg"
            }
            fi
            log_cl "[CONF]    Running \"./configure $configure_arg\"" debug
        }
        fi
        ./configure "$configure_arg"
        configure_res="$?"
        if [[ "$configure_res" -ne 0 ]]; then {
            log_cl "./configure returned {$configure_res}" warn
        }
        fi
        log_cl "Done 'autoreconf' and './configure'." info >&2
      }
      fi
      log_cl "[MODE]    target ( $target_tag ) >= ( $makefile_version ), has Makefile." debug >&2
      [[ $verbose_flag -gt 3 ]] && log_cl "[BUILD]    Building ( $target_tag ), using make." debug >&2
      curr_dir=$(realpath .)
      start_t=$(date +%s.%N)
      if [[ $git_mode_flag -eq 0 && $base_mode_flag -eq 1 ]] ; then { #Building in base mode, we cd into target directory before make
        [[ $verbose_flag -gt 3 ]] && log_cl "[BUILD]    Running in base mode, expecting full source in $target_dir_path." debug #>&2
        cd "$target_dir_path" || { log_cl "[CRITICAL]    cd failed. Quitting." error ; exit 4 ; };
        if [[ "$enable_make_rebuild_flag" -gt 0 ]] ; then {
          log_cl "Running \"make rebuild\"" debug
          make rebuild >&2
          comp_res=$?
        } else {
          log_cl "Running \"make\"" debug
          make >&2
          comp_res=$?
        }
        fi
      } else { #Building in git mode, we checkout the tag and move the binary after the build
        [[ $verbose_flag -gt 3 ]] && log_cl "[BUILD]    Running in git mode, checking out ( $target_tag )." debug #>&2
        local head_detached=0
        if amboso_is_head_detached; then {
            head_detached=1
        }
        fi
        git checkout "$target_tag" 2>/dev/null #Repo goes back to tagged state
        checkout_res=$?
        if [[ $checkout_res -gt 0 ]] ; then { #Checkout failed, we don't build and we set comp_res
          log_cl "Checkout of ( $target_tag ) failed, this stego.lock tag does not work for the repo." error #>&2
          comp_res=1
        } else { #Checkout successful, we build
          git submodule update --init --recursive #We set all submodules to commit state
          #Never try to build if checkout fails
          if [[ "$enable_make_rebuild_flag" -gt 0 ]] ; then {
            log_cl "Running \"make rebuild\"" debug
            make rebuild >&2
            comp_res=$?
          } else {
            log_cl "Running \"make\"" debug
            make >&2
            comp_res=$?
          }
          fi
          #Output is expected to be in the main dir:
          if [[ ! -e ./$target_binary ]] ; then {
            log_cl "$target_binary not found at $(pwd)." error #>&2
          } else {
            mv "./$target_binary" "$target_dir_path" #All files generated during the build should be ignored by the repo, to avoid conflict when checking out
            [[ $verbose_flag -gt 3 ]] && log_cl "[BUILD]    Moved $target_binary to $target_dir_path." debug #>&2
          }
          fi
          amboso_git_switch "$head_detached"
          switch_res="$?"
          if [[ $switch_res -gt 0 ]]; then {
            log_cl "\nCan't finish checking out ($target_tag).\n    You may have a dirty index and may need to run \"git restore .\".\n Quitting.\n" error
            echo_timer "$amboso_start_time"  "Failed checkout" "1"
            exit 1
          }
          fi
          git submodule update --init --recursive #We set all submodules to commit state
          [[ $quiet_flag -eq 0 ]] && log_cl "[BUILD]    Switched back to starting commit." info
        }
        fi
      }
      fi
      end_t=$(date +%s.%N)
      runtime=$( printf "$end_t - $start_t\n" | bc -l )
      cd "$curr_dir" || { log_cl "[CRITICAL]    cd failed. Quitting." error ; exit 4; };
    } else { #Straight gcc mode
      [[ $verbose_flag -gt 3 ]] && log_cl "[MODE]    target ( $target_tag ) < ( $makefile_version ), single file build with gcc." debug >&2
      [[ $verbose_flag -gt 3 ]] && log_cl "[BUILD]    Building ( $target_tag ), using gcc call." debug >&2
      #echo "" >&2 #new line for error output
      if [[ -z $target_source ]]; then {
        log_cl "[WTF-ERROR]    Missing source file name. ( $target_tag ).\n" error
        amboso_usage
        echo_timer "$amboso_start_time"  "Missing source name for [$target_tag]" "1"
        exit 1
      }
      fi
      [[ $pack_flag -gt 0 ]] && log_cl "[PACK]    -z is not supported for ($tool_txt). TAG < ($makefile_version).\n\n    Current: ($target_tag @ $target_source).\n" error

      start_t=$(date +%s.%N)
      if [[ $git_mode_flag -eq 0 ]] ; then { #Building in base mode, we cd into target directory before make
        [[ $verbose_flag -gt 3 ]] && log_cl "[BUILD]    Running in base mode, expecting full source in $target_dir_path." debug #>&2
        if [[ $has_CFLAGS -gt 0 ]] ; then {
            log_cl "[BUILD]    Running: {$CC $arg_CFLAGS $target_dir_path/$target_source -o $target_dir_path/$target_binary -lm}" info
            "$CC" "$arg_CFLAGS" "$target_dir_path"/"$target_source" -o "$target_dir_path"/"$target_binary" -lm 2>&2
            comp_res=$?
        } else {
            local env_CFLAGS="${CFLAGS:-}"
            if [[ ! -z "$env_CFLAGS" ]]; then {
                  log_cl "[BUILD]    Running: {$CC $env_CFLAGS $target_dir_path/$target_source -o $target_dir_path/$target_binary -lm}" info
                  "$CC" "$env_CFLAGS" "$target_dir_path"/"$target_source" -o "$target_dir_path"/"$target_binary" -lm 2>&2
                  comp_res=$?
            } else {
                  log_cl "[BUILD]    Running: {$CC $target_dir_path/$target_source -o $target_dir_path/$target_binary -lm}" info
                  "$CC" "$target_dir_path"/"$target_source" -o "$target_dir_path"/"$target_binary" -lm 2>&2
                  comp_res=$?
            }
            fi
        }
        fi
      } else { #Building in git mode, we checkout the tag and move the binary after the build
        [[ $verbose_flag -gt 3 ]] && log_cl "[BUILD]    Running in git mode, checking out ( $target_tag )." debug #>&2
        local head_detached=0
        if amboso_is_head_detached; then {
            head_detached=1
        }
        fi
        git checkout "$target_tag" 2>/dev/null #Repo goes back to tagged state
        checkout_res=$?
        if [[ $checkout_res -gt 0 ]] ; then { #Checkout failed, we set comp_res and don't build
          log_cl "Checkout of ( $target_tag ) failed, stego.lock may be listing a tag name not on the repo." error
          comp_res=1
        } else {
          git submodule update --init --recursive 2>/dev/null #We set all submodules to commit state
          if [[ $has_CFLAGS -gt 0 ]] ; then {
              log_cl "[BUILD]    Running: {$CC $arg_CFLAGS $target_dir_path/$target_source -o $target_dir_path/$target_binary -lm}" info
              "$CC" "$arg_CFLAGS" "$target_dir_path"/"$target_source" -o "$target_dir_path"/"$target_binary" -lm 2>&2 #Never try to build if checkout fails
              comp_res=$?
          } else {
              log_cl "[BUILD]    Running: {$CC $target_dir_path/$target_source -o $target_dir_path/$target_binary -lm}" info
              "$CC" "$target_dir_path"/"$target_source" -o "$target_dir_path"/"$target_binary" -lm 2>&2 #Never try to build if checkout fails
              comp_res=$?
          }
          fi
          #All files generated during the build should be ignored by the repo, to avoid conflict when checking out
          amboso_git_switch "$head_detached" 2>/dev/null
          switch_res="$?"
          if [[ $switch_res -gt 0 ]]; then {
            log_cl "Can't finish checking out ($target_tag). Quitting." error
            echo_timer "$amboso_start_time"  "Failed checkout for [$target_tag]" "1"
            exit 1
          }
          fi
          [[ $verbose_flag -gt 3 ]] && log_cl "[BUILD]    Switched back to starting commit." debug >&2
        }
        fi
      }
      fi
      end_t=$(date +%s.%N)
      runtime=$( printf "$end_t - $start_t\n" | bc -l )
    }
    fi
    #Check compilation result
    if [[ $comp_res -eq 0 ]] ; then
      log_cl "[BUILD]    Done Building ( $target_tag ) , took $runtime seconds, using ( $tool_txt )." info
      return 0
    else
      log_cl "Build for ( $target_tag ) failed, quitting.\n" error >&2
      echo_timer "$amboso_start_time"  "Failed build for [$target_tag]" "1"
      return 1
    fi
}

ambosoC_delete_step() {
    local target_dir_path="$1"
    local target_tag="$2"
    local target_binary="$3"
    local clean_res=1
    if [[ $has_makeclean -gt 0 && $base_mode_flag -gt 0 ]] ; then { #Running in git mode skips make clean
      tool_txt="make clean"
      has_bin=0
      curr_dir=$(realpath .)
      delete_path="$target_dir_path""/v""$target_tag"
        if [[ ! -d $delete_path ]] ; then {
          log_cl "'$delete_path' is not a valid directory.\n    Check your supported versions for details on ( $target_tag ).\n" error #>&2
        } elif [[ -x $target_dir_path/v$target_tag/$target_binary ]] ; then { #Executable exists
          has_bin=1 && log_cl "[DELETE]   ( $target_tag ) has an executable.\n" info >&2
          cd "$delete_path" || { log_cl "[CRITICAL]    cd failed. Quitting." error ; exit 4 ;};
          make clean 2>/dev/null #1>&2
          clean_res=$?
          cd "$curr_dir" || { log_cl "[CRITICAL]    cd failed. Quitting." error ; exit 4 ;};
          echo_timer "$amboso_start_time"  "Did delete, res was [$clean_res]" "3"
          exit "$clean_res"
        } else {
          [[ $verbose_flag -gt 3 ]] && log_cl "[DELETE]   ( $target_tag ) does not have an executable at ( $delete_path ).\n" debug # >&2
          echo_timer "$amboso_start_time"  "Nothing to delete" "1"
          exit 1
        }
        fi
    } else { #Doesn't have Makefile, build method 2. Running in git mode also skips using make clean
      tool_txt="rm"
      clean_res=128
      if [[ -x $target_dir_path"/v$target_tag"/"$target_binary" ]] ; then {
        [[ $verbose_flag -gt 3 ]] && log_cl "[DELETE]    ( $target_tag ) has an executable." debug >&2
        rm "$(realpath "$target_dir_path"/"v${target_tag}/${target_binary}")" #2>/dev/null
        clean_res=$?
        if [[ $clean_res -eq 0 ]] ; then {
          log_cl "[DELETE]    Success on ( $target_tag )." info
        } else {
          log_cl "[DELETE]    Failure on ( $target_tag )." error
        }
        fi
        echo_timer "$amboso_start_time"  "Did delete, res was [$clean_res]" "3"
        return "$clean_res"
      } else {
        log_cl "[DELETE]    ( $target_tag ) does not have an executable." warn >&2
        echo_timer "$amboso_start_time"  "Did delete, res was [$clean_res]" "3"
        return 1
      }
      fi
    }
    fi
}

anvilPy_delete_step() {
    local target_dir_path="$1"
    local target_tag="$2"
    local target_binary="$3"
    local clean_res=1
    tool_txt="rm"
    clean_res=128
    if [[ -x $target_dir_path"/v$target_tag"/"$target_binary" ]] ; then {
      [[ $verbose_flag -gt 3 ]] && log_cl "[DELETE]    ( $target_tag ) has an executable." debug >&2
      rm "$(realpath "$target_dir_path"/"v${target_tag}/${target_binary}")" #2>/dev/null
      clean_res=$?
      if [[ $clean_res -eq 0 ]] ; then {
        log_cl "[DELETE]    Success on ( $target_tag )." info
      } else {
        log_cl "[DELETE]    Failure on ( $target_tag )." error
      }
      fi
      echo_timer "$amboso_start_time"  "Did delete, res was [$clean_res]" "3"
      return "$clean_res"
    } else {
      log_cl "[DELETE]    ( $target_tag ) does not have an executable." warn >&2
      echo_timer "$amboso_start_time"  "Did delete, res was [$clean_res]" "3"
      return 1
    }
    fi
}

anvilPy_git_restore() {
    [[ ! "$git_mode_flag" -gt 0 ]] && return 0 # Return early when out of git mode
    local q_tag="$1"
    local head_detached="${2:-0}"
    amboso_git_switch "$head_detached"
    local switch_res="$?"
    if [[ $switch_res -gt 0 ]]; then {
      log_cl "\nCan't finish checking out ($q_tag).\n    You may have a dirty index and may need to run \"git restore .\".\n Quitting.\n" error
      echo_timer "$amboso_start_time"  "Failed checkout" "1"
      exit 1
    }
    fi
    git submodule update --init --recursive #We set all submodules to commit state
    [[ $quiet_flag -eq 0 ]] && log_cl "[BUILD]    Switched back to starting commit." info
    return 0
}

anvilPy_gen_shim() {
    local target_dir="$1"
    local target_tag="$2"
    local target_bin="$3"
    local target_main="$4"

    [[ ! -d "$target_dir" ]] && { log_cl "${FUNCNAME[0]}():    Invalid dir: {$target_dir}" error; anvilPy_git_restore "$target_tag"; return 1; }

    local target_shim_path="$target_dir/$target_bin"
    local shim_txt="#!/bin/python3\n\n##\n# Generated by amboso v$std_amboso_version {API: {$AMBOSO_API_LVL}}\n# Repo at https://github.com/jgabaut/amboso\n##\n\nimport sys\nimport re\nfrom unpack.$target_bin.$target_main import main\n\nif __name__ == '__main__':\n    sys.argv[0] = re.sub(r'(-script\.pyw|\.exe)?$', '', sys.argv[0])\n    sys.exit(main())\n"
    log_cl "[SHIM]    Writing shim to $target_shim_path >>> $shim_txt <<<" info
    printf "%b" "$shim_txt" > "$target_shim_path"
    log_cl "[SHIM]    Setting permissions to 755 for shim" debug
    chmod 755 "$target_shim_path"
    return 0
}

anvilPy_build_step() {
    log_cl "Doing anvilPy build step" info
    log_cl "args: {$*}" info
    local target_d="$1" # Target dir
    local q_tag="$2" # Queried tag
    local bin_name="$3" # Target bin name
    local stego_dir="$4" # Stego dir name
    local anvilPy_unpack_dirname="unpack"
    local pyproj_toml_path="$stego_dir/pyproject.toml"

    local head_detached=0
    if amboso_is_head_detached; then {
        head_detached=1
    }
    fi

    if [[ "$git_mode_flag" -gt 0 ]] ; then {
        [[ $verbose_flag -gt 3 ]] && log_cl "[BUILD]    Running in git mode, checking out ( $q_tag )." debug #>&2
        git checkout "$q_tag" 2>/dev/null #Repo goes back to tagged state
        checkout_res=$?
        if [[ $checkout_res -gt 0 ]] ; then { #Checkout failed, we don't build
          log_cl "Checkout of ( $q_tag ) failed, this stego.lock tag does not work for the repo." error #>&2
          return 1
        }
        fi
        #Checkout successful, we build
        git submodule update --init --recursive #We set all submodules to commit state
        #Never try to build if checkout fails
    }
    fi

    if [[ ! -f "$pyproj_toml_path" ]] ; then {
        log_cl "Can't find $pyproj_toml_path" error
        anvilPy_git_restore "$q_tag" "$head_detached"
        return 1
    }
    fi

    #TODO: find a better way to pass main entrypoint name to gen_shim()
    local main_entry="$(grep "^[[:space:]]*${bin_name}[[:space:]]*=" "$pyproj_toml_path")"
    local grep_res="$?"
    [[ "$grep_res" -ne 0 ]] && { log_cl "${FUNCNAME[0]}():    Failed grep of {$pyproj_toml_path} for main entry. Errcode: {$grep_res}" error; anvilPy_git_restore "$q_tag" "$head_detached"; return 1; }

    [[ -z "$main_entry" ]] && { log_cl "${FUNCNAME[0]}():    Can't deduce main_entry from {$pyproj_toml_path}" error; anvilPy_git_restore "$q_tag"; return 1; }

    log_cl "[BUILD]    Extracted main_entry: {$main_entry}" debug

    # Remove the prefix up to and including the start delimiter
    main_entry="${main_entry#*$bin_name.}"
    # Remove everything after the end delimiter
    local main_name="${main_entry%:main*}"

    [[ -z "$main_name" ]] && { log_cl "${FUNCNAME[0]}():    Can't deduce main_name from main_entry: {$main_entry}" error; anvilPy_git_restore "$q_tag"; return 1; }

    log_cl "[BUILD]    Extracted main name: {$main_name}" info

    if [[ ! -d "$target_d" ]] ; then
      if compare_semver "$std_amboso_version" ">=" "$min_amboso_v_treegen" ; then {
        [[ "$base_mode_flag" -gt 0 ]] && { log_cl "Base mode, can't find target dir {$target_d}." error >&2; anvilPy_git_restore "$q_tag"; return 1; } ;
        log_cl "Creating target_d {$target_d}" debug cyan >&2
        mkdir "$target_d" || { log_cl "Failed creating target_d: {$target_d}" error >&2 ; anvilPy_git_restore "$q_tag"; return 1; } ;
      } else {
        log_cl "'$target_d' is not a valid directory.\n    Check your supported versions for details on ( $q_tag ).\n" error >&2
        echo_timer "$amboso_start_time"  "Invalid path [$target_d]" "1"
        anvilPy_git_restore "$q_tag" "$head_detached"
        return 1
      }
      fi
    fi

    local build_res=0
    python -m build
    build_res="$?"
    if [[ "$build_res" -eq 0 ]] ; then {
        local srcdist_path_glob="./dist/*-$q_tag.tar.gz"
        mapfile -t srcdist_files < <(compgen -G "$srcdist_path_glob")

        if [[ "${#srcdist_files[@]}" -ne 1 ]] ; then {
            log_cl "[BUILD]    Error: srcdist_path_glob expands to multiple files: {${srcdist_files[*]}}" error
            anvilPy_git_restore "$q_tag" "$head_detached"
            return 1
        }
        fi
        local srcdist_path="${srcdist_files[0]}"
        local dist_filename="$(basename "$srcdist_path")"
        local whldist_filename="${dist_filename%%.tar.gz}-py3-none-any.whl" # Strip .tar.gz
        local whldist_path="./dist/$whldist_filename"
        log_cl "[BUILD]    srcdist_path: {$srcdist_path} dist_filename {$dist_filename}" info
        log_cl "[BUILD]    whldist_path: {$whldist_path}" info

        log_cl "[BUILD]    Move {$srcdist_path} to {$target_d/$dist_filename}" debug
        mv  "$srcdist_path" "$target_d"/"$dist_filename"

        log_cl "[BUILD]    Move {$whldist_path} to {$target_d/$whldist_filename}" debug
        mv  "$whldist_path" "$target_d"/"$whldist_filename"

        local unpack_dir="$target_d/$anvilPy_unpack_dirname"
        if [[ ! -d "$unpack_dir" ]] ; then {
            log_cl "Creating unpack_dir {$unpack_dir}" debug cyan
            mkdir "$unpack_dir" || { log_cl "Failed creating unpack_dir: {$unpack_dir}" error >&2 ; return 1; } ;
            touch "$unpack_dir/__init__.py"
        }
        fi
        log_cl "[BUILD]    Untar {$target_d/$dist_filename} to {$target_d/$anvilPy_unpack_dirname}" debug

        # --strip-components=1 removes the root dir, putting all files in our target dirname
        tar -xvzf "$target_d"/"$dist_filename" --strip-components=1 -C "$target_d/$anvilPy_unpack_dirname"

        anvilPy_gen_shim "$target_d" "$q_tag" "$bin_name" "$main_name"
    } else {
        log_cl "[BUILD]    Failed python -m build" error
    }
    fi
    anvilPy_git_restore "$q_tag" "$head_detached"
    return "$build_res"
}

custom_build_step () {
    local target_d="$1"
    local q_tag="$2"
    local bin_name="$3"
    local stego_dir="$4"
    local custom_builder="$5"
    if [[ -z "$custom_builder" ]]; then {
        log_cl "[BUILD]    anvil_custombuilder was not set. Check your stego file." error
        return 1
    }
    fi
    local head_detached=0
    if amboso_is_head_detached; then {
        head_detached=1
    }
    fi

    if [[ "$git_mode_flag" -gt 0 ]] ; then {
        [[ $verbose_flag -gt 3 ]] && log_cl "[BUILD]    Running in git mode, checking out ( $q_tag )." debug #>&2
        git checkout "$q_tag" 2>/dev/null #Repo goes back to tagged state
        checkout_res=$?
        if [[ $checkout_res -gt 0 ]] ; then { #Checkout failed, we don't build
          log_cl "Checkout of ( $q_tag ) failed, this stego.lock tag does not work for the repo." error #>&2
          return 1
        }
        fi
        #Checkout successful, we build
        git submodule update --init --recursive #We set all submodules to commit state
        #Never try to build if checkout fails
    }
    fi

    if [[ ! -x "$custom_builder" ]]; then {
        log_cl "[BUILD]    Builder {$custom_builder} is not an executable file." error
        anvilPy_git_restore "$q_tag" "$head_detached"
        return 1
    } else {
        if [[ ! -d "$target_d" ]] ; then
          if compare_semver "$std_amboso_version" ">=" "$min_amboso_v_treegen" ; then {
            [[ "$base_mode_flag" -gt 0 ]] && { log_cl "Base mode, can't find target dir {$target_d}." error >&2; return 1; } ;
            log_cl "Creating target_d {$target_d}" debug cyan >&2
            mkdir "$target_d" || { log_cl "Failed creating target_d: {$target_d}" error >&2 ; return 1; } ;
          } else {
            log_cl "'$target_d' is not a valid directory.\n    Check your supported versions for details on ( $q_tag ).\n" error >&2
            echo_timer "$amboso_start_time"  "Invalid path [$target_d]" "1"
            return 1
          }
          fi
        fi
        log_cl "[BUILD]    Running custom builder for tag {$q_tag}, output file expected at: {./$bin_name}" info
        log_cl "[BUILD]    $prog_name will try to mv {./$bin_name} to {$target_d/$bin_name}" debug
        log_cl "[BUILD]    Running : {$custom_builder $target_d $bin_name $q_tag $stego_dir}" info magenta
        "$custom_builder" "$target_d" "$bin_name" "$q_tag" "$stego_dir"
        local cs_build_res="$?"
        if [[ "$cs_build_res" -ne 0 ]] ; then {
            log_cl "[BUILD]    Custom build step returned {$cs_build_res}" error
            anvilPy_git_restore "$q_tag" "$head_detached"
            return "$cs_build_res"
        }
        fi
        #Output is expected to be in the main dir:
        if [[ ! -e ./"$bin_name" ]]; then {
            if [[ ! -e "$target_d/$bin_name" ]]; then {
                log_cl "[BUILD]    Can't find {./$bin_name} after running {$custom_builder} command" error
                anvilPy_git_restore "$q_tag" "$head_detached"
                return 1
            } else {
                log_cl "[BUILD]    It seems {$custom_builder} command may have moved {$bin_name} to {$target_d}. Skipping mv" warn
                anvilPy_git_restore "$q_tag" "$head_detached"
                return 0
            }
            fi
        } else {
            mv "./$bin_name" "$target_d/" #All files generated during the build should be ignored by the repo, to avoid conflict when checking out
            [[ $verbose_flag -gt 3 ]] && log_cl "[BUILD]    Moved $bin_name to $target_d." debug #>&2
        }
        fi
    }
    fi
    anvilPy_git_restore "$q_tag" "$head_detached"
    return 0
}

amboso_test_step() {
  # This function is not very clean. It uses some variables which are to be set before calling it.
  # Some of these variables are:
  #   supported_tests (array)
  #   tot_tests (len of supported_tests)
  #   values used to reconstruct flags for recursion on -Ti
  #   TODO: ensure state_cases_arrlen == count_tests_names (len of read_tests_files)
  #   TODO: ensure state_errors_arrlen == count_errortests_names (len of read_errortests_files)

  local target_test="$1"
  local target_tests_root="$2"
  local target_cases_dir="$3"
  local target_errors_dir="$4"
  local state_cases_arrname="${5}[@]"
  local state_cases_arr=("${!state_cases_arrname}")
  local state_cases_arrlen="${#state_cases_arr[@]}"
  local state_errors_arrname="${6}[@]"
  local state_errors_arr=("${!state_errors_arrname}")
  local state_errors_arrlen="${#state_errors_arr[@]}"

  if [[ $quiet_flag -eq 0 && $verbose_flag -ge 4 ]]; then { #WIP
      log_cl "[VERB]    Test mode (-T was on)." info >&2
      [[ $small_test_mode_flag -gt 0 ]] && log_cl "[VERB]    (-t was on)." info >&2
      echo_tests_info "$target_tests_root" >&2
  }
  fi
  test_name=""
  test_type=""
  test_path=""
  [[ $verbose_flag -gt 3 ]] && log_cl "[TEST]    Checking if query $target_test is a testcase." info >&2
  local t_counter=0
  for current_item in "${state_cases_arr[@]}"; do {
    [[ $verbose_flag -gt 3 ]] && log_cl "[TEST]    Checking case ($t_counter/$state_cases_arrlen): $current_item" info >&2
    #echo "checking $current_item"
    if [[ $target_test = "$current_item" ]]; then {
      test_type="casetest"
      test_name="$target_test"
      test_path="$target_tests_root/$target_cases_dir/${read_tests_files[$t_counter]}"
      break; #done looking
    }
    fi
    t_counter="$(($t_counter+1))"
  }
  done
  t_counter=0
  if [[ -z $test_name ]] ; then {
    [[ $verbose_flag -ge 4 ]] && log_cl "[TEST]    Checking if query $target_test is a error testcase." info >&2
    for current_item in "${state_errors_arr[@]}"; do {
      [[ $verbose_flag -ge 4 ]] && log_cl "[TEST]    Checking error case ($t_counter/$state_errors_arrlen): $current_item" info >&2
      #echo "checking $current_item"
      if [[ $target_test = "$current_item" ]] ; then {
        test_type="errortest"
        test_name="$target_test"
        test_path="$target_tests_root/$target_errors_dir/${read_errortests_files[$t_counter]}"
        break; #done looking
      }
      fi
      t_counter="$(($t_counter+1))"
    }
    done
  }
  fi

  if [[ $quiet_flag -eq 0 ]]; then { #WIP
      log_cl "[TEST]    Expected:\n\n    type:  $test_type\n\n    name:  $test_name\n    path:  $test_path\n" info >&2
  }
  fi

  if [[ -z $test_path ]]; then {
    if [[ $quiet_flag -eq 0 ]] ; then {
      flaginit=""
      flagbuild=""
      [[ $build_flag -gt 0 ]] && flagbuild="b"
      [[ $init_flag -gt 0 ]] && flaginit="t"
      log_cl "[VERB]    Test path was empty but we have [-$flagbuild$flaginit]." debug >&2
    }
    fi
    if [[ -z $test_path && -z $target_test ]] ; then {
      [[ $quiet_flag -eq 0 ]] && log_cl "[VERB]    testpath was empty, query was empty. Should quit." debug >&2
      keep_run_txt=""
      if [[ $init_flag -gt 0 ]] ; then {
        keep_run_txt="[INIT]"
        log_cl "[TEST]    ( \"empty\"[$target_test] ) is not a supported test. $keep_run_txt." error >&2
        echo_timer "$amboso_start_time"  "Empty test query" "1"
        return 1
      }
      fi
      printf "${FUNCNAME[0]}():    UNREACHABLE.\n"
      exit 1
    } elif [[ -z $test_path && ! -z $target_test ]] ; then {
      [[ $quiet_flag -eq 0 ]] && log_cl "[VERB]    testpath was empty, query was not empty: ( $target_test )." info >&2
      keep_run_txt=""
      if [[ $init_flag -gt 0 ]] ; then {
        keep_run_txt="[INIT]"
        log_cl "[TEST]    ( $target_test ) is not a supported test name, we quit at this point. $keep_run_txt." error >&2
        echo_timer "$amboso_start_time"  "Unsupported test query [$target_test]" "3"
        return 1
      }
      fi
      [[ $build_flag -gt 0 ]] && keep_run_txt="[BUILD]" && log_cl "[TEST]    ( $target_test ) is not a supported tag, but we continue to $keep_run_txt." debug >&2
    } else {
      [[ $verbose_flag -ge 4 || $quiet_flag -eq 0 ]] && log_cl "[TEST] expected:\n  $test_type\n\n  name: $test_name\n  path: $test_path" debug # >&2
      log_cl "[TEST]    target: ( $test_path ).\n" info
    }
    fi
  } elif [[ -z $test_path && -z $target_test ]] ; then {
    #Panic
    log_cl "( $test_name : at  $test_path ) is not a supported test.\n" error
    log_cl "       Run with -h for help.\n" error
    echo_timer "$amboso_start_time"  "Unsupported test name [$test_name] at [$test_path]" "1"
    return 1
  }
  fi

  relative_testpath="$test_path"

  if [[ $build_flag -gt 0 ]] ; then {
    log_cl "[TEST]    \"-b\" is set, Recording: ( $relative_testpath )." debug >&2
    #record_test "$relative_testpath"
  } elif [[ $delete_flag -gt 0 ]] ; then {
    :
    #echo -e "\033[0;34m[TEST]    \"-d\" is set, Deleting: ( $relative_testpath ).\e[0m" >&2
    #delete_test "$relative_testpath"
  } elif [[ $init_flag -gt 0 ]] ; then {
    echo "UNREACHABLE."
    exit 1
    #init_all_tests "$relative_testpath"
  } elif [[ $purge_flag -gt 0 ]] ; then {
    :
    #echo "[TEST]    Deleting ALL: ( $relative_testpath )."
    #purge_all_tests "$relative_testpath"
  }
  fi
  if [[ -z $relative_testpath && $init_flag -eq 0 ]] ; then {
    #Exit 0 as intended behaviour FIXME
    log_cl "[TEST]    Can't proceed further with no valid target path, query was ( $target_test )." warn
    log_cl "[TEST]    Supported tests:\n" info
    echo_tests_info "$target_tests_root"
    log_cl "[TEST]    Quitting." error
    echo_timer "$amboso_start_time"  "Invalid target path [$relative_testpath]" "1"
    return 1
  }
  fi
  if [[ -z $relative_testpath && $init_flag -eq 1 && ! -z $target_test ]] ; then {
    #Exit 0 as intended behaviour FIXME
    log_cl "Can't proceed even with -i flag, with no testpath. ( p: $relative_testpath ) can't be be ( q: $target_test )." error
    echo_timer "$amboso_start_time"  "Invalid target path (-i) [$relative_testpath]" "1"
    return 0
  }
  fi
  if [[ -z $relative_testpath && $init_flag -eq 1 && -z $target_test ]] ; then {
    log_cl "Can't proceed with no query.  ( q: $target_test, p: $relative_testpath )." error
    echo_timer "$amboso_start_time"  "Empty test query [$target_test]" "1"
    return 1
  }
  fi
  run_tmp_out="$(mktemp)"
  run_tmp_escout="$(mktemp)"
  run_tmp_err="$(mktemp)"
  run_tmp_escerr="$(mktemp)"
  [[ $verbose_flag -gt 3 ]] && log_cl "[TEST]    Created tempfiles." debug >&2
  log_cl "[TEST]    Running:    \"$relative_testpath\"" debug
  run_test "$relative_testpath" >>"$run_tmp_out" 2>>"$run_tmp_err"
  ran_res="$?"

  if [[ $ran_res -eq 69 ]] ; then {
    log_cl "Test call returned 69, we clean tmpfiles and follow suit." warn
    #Delete tmpfiles
    rm -f "$run_tmp_out" || log_cl "Failed removing tmpfile ($run_tmp_out). Why?\n" error
    [[ $verbose_flag -gt 3 ]] && log_cl "[TEST]    Removed tempfile \"$run_tmp_out\"." debug >&2
    rm -f "$run_tmp_err" || log_cl "Failed removing tmpfile ($run_tmp_err). Why?\n" error
    [[ $verbose_flag -gt 3 ]] && log_cl "[TEST]    Removed tempfile \"$run_tmp_err\"." debug >&2
    rm -f "$run_tmp_escout" || log_cl "Failed removing tmpfile ($run_tmp_escout). Why?\n" error
    [[ $verbose_flag -gt 3 ]] && log_cl "[TEST]    Removed tempfile \"$run_tmp_escout\"." debug >&2
    rm -f "$run_tmp_escerr" || log_cl "Failed removing tmpfile ($run_tmp_escerr). Why?\n" error
    [[ $verbose_flag -gt 3 ]] && log_cl "[TEST]    Removed tempfile \"$run_tmp_escerr\".\n" debug >&2
    log_cl "[PANIC]    Quitting with 69." error
    echo_timer "$amboso_start_time"  "Test run ended with 69" "1"
    return 69
  }
  fi
  #echo "r: $ran_res" >> "$run_tmp_out"
  escape_colorcodes_tee "$run_tmp_out" "$run_tmp_escout"
  escape_colorcodes_tee "$run_tmp_err" "$run_tmp_escerr"
  if [[ $build_flag -gt 0 ]] ; then {
    cp "$run_tmp_escout" "$relative_testpath.stdout" || printf "Failed replacing stdout with new file.\n"
    cp "$run_tmp_escerr" "$relative_testpath.stderr" || printf "Failed replacing stderr with new file.\n"
  } else {
    [[ $quiet_flag -eq 0 || $verbose_flag -gt 3 ]] && log_cl "[TEST]    Won't record, no [-b].\n" info
  }
  fi
  rm -f "$run_tmp_out" || log_cl "Failed removing tmpfile ($run_tmp_out). Why?\n" error
  [[ $verbose_flag -gt 3 ]] && log_cl "[TEST]    Removed tempfile \"$run_tmp_out\"." debug >&2
  rm -f "$run_tmp_err" || log_cl "Failed removing tmpfile ($run_tmp_err). Why?\n" error
  [[ $verbose_flag -gt 3 ]] && log_cl "[TEST]    Removed tempfile \"$run_tmp_err\"." debug >&2
  #Testing diff for escaped stdout
  ( diff "$run_tmp_escout" "$relative_testpath".stdout ) 2>/dev/null 1>&2
  diff_res="$?"
  out_res=""
  if [[ "$diff_res" -eq 0 ]]; then {
    out_res="pass"
    if [[ ! -z "$run_tmp_escout" ]] ; then { #FIXME: SC2157 && ! -z "$relative_testpath".stdout ]]; then {
      #This one doesn't go on stderr since we still want it in recursive calls:
      [[ $verbose_flag -gt 3 ]] && log_cl "[TEST]    Pass, both outputs are not empty." debug
    } elif [[ -z "$run_tmp_escout" ]]; then {
      [[ $verbose_flag -gt 3 ]] && log_cl "[TEST]    Pass, current stdout is empty. Is that expected?" info >&2
    } #FIXME: SC2157 elif [[ -z "$relative_testpath.stdout" ]]; then {
      #[[ $verbose_flag -gt 0 ]] && printf "\033[0;35m[TEST]    Pass, registered stdout is empty. Is that expected?\e[0m\n" >&2
    #}
    fi
    if [[ $verbose_flag -gt 3 && $quiet_flag -eq 0 ]]; then {
      log_cl "[TEST]    (stdout) Expected:" info
      cat "$relative_testpath.stdout"
      log_cl "[TEST]    (stdout) Found:" info
      cat "$run_tmp_escout"
    }
    fi
  } else {
    out_res="fail"
    if [[ $quiet_flag -eq 0 ]]; then {
      log_cl "[TEST]    (stdout) Expected:" info
      cat "$relative_testpath.stdout"
      log_cl "[TEST]    (stdout) Found:" error
      cat "$run_tmp_escout"
    }
    fi
    log_cl "[TEST]    Failed: stdout changed." error
    #cat "$run_tmp_escout"
  }
  fi
  rm -f "$run_tmp_escout" || log_cl "Failed removing tmpfile ($run_tmp_escout). Why?\n" error
  [[ $verbose_flag -gt 3 ]] && log_cl "[TEST]    Removed tempfile \"$run_tmp_escout\"." debug >&2
  #Testing diff for escaped stderr
  ( diff "$run_tmp_escerr" "$relative_testpath".stderr ) 2>/dev/null 1>&2
  diff_res="$?"
  if [[ "$diff_res" -eq 0 ]]; then {
    err_res="pass"
    if [[ ! -z "$run_tmp_escerr" ]]; then { #FIXME SC2157 && ! -z "$relative_testpath.stderr" ]]; then {
      #This one doesn't go on stderr since we still want it in recursive calls:
      [[ $verbose_flag -gt 3 ]] && log_cl "[TEST]    Pass, both stderrs are not empty." debug
    } elif [[ -z "$run_tmp_escerr" ]]; then {
      [[ $verbose_flag -gt 3 ]] && log_cl "[TEST]    Pass, current run stderr is empty. Is that expected?" info >&2
    } #FIXME SC2157 elif [[ -z "$relative_testpath.stderr" ]]; then {
     # [[ $verbose_flag -gt 0 ]] && printf "\033[0;35m[TEST]    Pass, registered stderr is empty. Is that expected?\e[0m\n" >&2
    #}
    fi
    if [[ $verbose_flag -gt 3 && $quiet_flag -eq 0 ]]; then {
      log_cl "[TEST]    (stderr) Expected:" info
      cat "$relative_testpath.stderr"
      log_cl "[TEST]    (stderr) Found:" info
      cat "$run_tmp_escerr"
    }
    fi
    #cat "$run_tmp_escerr"
  } else {
    err_res="fail"
    if [[ $quiet_flag -eq 0 ]]; then {
      log_cl "[TEST]    (stderr) Expected:" info
      cat "$relative_testpath.stderr"
      log_cl "[TEST]    (stderr) Found:" error
      cat "$run_tmp_escerr"
    }
    fi
    log_cl "[TEST]    Failed: stderr changed." error
    #cat "$run_tmp_escerr"
  }
  fi
  rm -f "$run_tmp_escerr" || log_cl "Failed removing tmpfile ($run_tmp_escerr). Why?\n" error
  [[ $verbose_flag -gt 3 ]] && log_cl "[TEST]    Removed tempfile \"$run_tmp_escerr\"." debug >&2
  if [[ $build_flag -gt 0 ]] ; then {
    #We simulate success since we're recording
    log_cl "[TEST]    Phony pass (recording)." debug
    [[ $verbose_flag -gt 3 ]] && log_cl "(out: $out_res)" debug
    [[ $verbose_flag -gt 3 ]] && log_cl "(err: $err_res)" debug
    echo_timer "$amboso_start_time"  "Phony test pass" "3"
    return 0 #We return earlier
  } elif [[ $out_res = "pass" && $err_res = "pass" ]]; then {
    log_cl "[TEST]    Passed." info
    echo_timer "$amboso_start_time"  "Test pass" "2"
    return 0 #We return earlier
  } elif [[ $out_res = "fail" ]] ; then {
   : #echo "failed" #We echoed before
  } elif [[ $err_res = "fail" ]] ; then {
   : #echo "failed" #We echoed before
  } else {
    log_cl "Unexpected values (o:$out_res/e:$err_res) should be either pass or fail. How?" error
  }
  fi
  echo_timer "$amboso_start_time"  "Test fail" "1"
  return 1
}

amboso_parse_args() {
  export AMBOSO_LVL_REC="${AMBOSO_LVL_REC:-0}"
  #Increment depth counter
  AMBOSO_LVL_REC=$(($AMBOSO_LVL_REC+1))
  # check recursion
  if [[ "${AMBOSO_LVL_REC}" -le "2" ]]; then
    PARENT_COMMAND="$(ps -o comm= $PPID)"
    [[ "$PARENT_COMMAND" = "$prog_name" ]] && log_cl "Unexpected result while checking amboso recursion level." error && exit 1
  else
    log_cl "[AMBOSO]    Exceeded depth for recursion ( nested ${AMBOSO_LVL_REC} times).\n" error
    echo_timer "$amboso_start_time"  "Excessive recursion" "1"
    exit 69
  fi

  #Prepare flag values to default value
  purge_flag=0
  run_flag=0 #By default we don't run the binary
  build_flag=0
  delete_flag=0
  init_flag=0
  verbose_flag=3
  quiet_flag=0
  dir_flag=0
  exec_entrypoint= #By default the value is empty
  exec_was_set=0
  source_name=
  sourcename_was_set=0
  bighelp_flag=0
  smallhelp_flag=0
  vers_make_flag=0
  makefile_version=""
  vers_autoconf_flag=0
  use_autoconf_version=""
  git_mode_flag=1 #By default we run in git mode
  base_mode_flag=0
  test_mode_flag=0
  small_test_mode_flag=0
  test_info_was_set=0
  testdir_flag=0
  kazoj_dir=""
  big_list_flag=0
  small_list_flag=0
  version_flag=0
  silent_flag=0
  pack_flag=0
  tell_uname_flag=0
  gen_C_headers_set=0
  gen_C_headers_flag=0
  gen_C_headers_destdir=""
  start_time_flag=0
  start_time_val=""
  start_time_set=0
  show_time_flag=0
  ignore_git_check_flag=0
  show_warranty_flag=0
  be_stego_parser_flag=0
  queried_stego_filepath=""
  pass_autoconf_arg_flag=0
  passed_autoconf_arg=""
  allow_color_flag=1
  do_filelog_flag=0
  enable_make_rebuild_flag=1
  force_build_flag=0
  extensions_flag=1
  CFLAGS_was_passed=0
  passed_CFLAGS=""
  std_amboso_version="${AMBOSO_API_LVL}"
  std_amboso_regex='^([1-9][0-9]*|0)\.([1-9][0-9]*|0)\.([1-9][0-9]*|0)$'
  std_amboso_short_regex='^([1-9][0-9]*)\.([1-9][0-9]*|0)$'
  std_amboso_version_list=("2.0.0" "2.0.*" "1.*" "2.1.0")
  std_amboso_short_version_list=("2.0" "2.1" "1.*")
  std_amboso_kern="amboso-C"
  std_amboso_kern_list=("amboso-C" "anvilPy" "custom")
  queried_amboso_kern=""
  min_amboso_v_kern="2.0.2"
  min_amboso_v_extensions="2.0.1"
  min_amboso_v_stego_noforce="2.0.3"
  min_amboso_v_fix_awk="2.0.3"
  stego_dir=""
  stego_dir_flag=0
  min_amboso_v_stegodir="2.0.3"
  min_amboso_v_treegen="2.0.4"
  min_amboso_v_morekern="2.0.9"
  min_amboso_v_refuseTi="2.0.11"
  min_amboso_v_check_detached="2.0.11"
  min_amboso_v_anvilPy_kern="2.1.0"
  min_amboso_v_custom_kern="2.1.0"
  amboso_custom_builder=""
  long_options_hack="-:" # From https://stackoverflow.com/questions/402377/using-getopts-to-process-long-and-short-command-line-options/7680682#7680682
  while getopts "Z:O:A:M:S:E:D:K:G:Y:x:V:C:a:k:${long_options_hack}wBgbpHhrivdlLtTqszUXWPJRFe" opt; do
    case $opt in
      -)
        case "${OPTARG}" in
          anvil-version) val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 )); handle_anvil_arg "$val";;
          anvil-version=*) val=${OPTARG#*=}; opt=${OPTARG%=$val}; handle_anvil_arg "$val";;
          anvil-kern) val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 )); handle_kern_arg "$val";;
          anvil-kern=*) val=${OPTARG#*=}; opt=${OPTARG%=$val}; handle_kern_arg "$val";;
          amboso-dir) val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 )); handle_nohyphen_flags_arg "$val" "-amboso-dir"; dir_flag=1; scripts_dir="$val";;
          amboso-dir=*) val=${OPTARG#*=}; opt=${OPTARG%=$val}; handle_nohyphen_flags_arg "$val" "-amboso-dir"; dir_flag=1; scripts_dir="$val";;
          stego-dir) val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 )); handle_nohyphen_flags_arg "$val" "-stego-dir"; stego_dir_flag=1; stego_dir="$val";;
          stego-dir=*) val=${OPTARG#*=}; opt=${OPTARG%=$val}; handle_nohyphen_flags_arg "$val" "-stego-dir"; stego_dir_flag=1; stego_dir="$val";;
          kazoj-dir) val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 )); handle_nohyphen_flags_arg "$val" "-kazoj-dir"; testdir_flag=1; kazoj_dir="$val"; test_info_was_set=1;;
          kazoj-dir=*) val=${OPTARG#*=}; opt=${OPTARG%=$val}; handle_nohyphen_flags_arg "$val" "-kazoj-dir"; testdir_flag=1; kazoj_dir="$val"; test_info_was_set=1;;
          source) val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 )); handle_nohyphen_flags_arg "$val" "-source"; source_name="$val"; sourcename_was_set=1;;
          source=*) val=${OPTARG#*=}; opt=${OPTARG%=$val}; handle_nohyphen_flags_arg "$val" "-source"; source_name="$val"; sourcename_was_set=1;;
          execname) val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 )); handle_nohyphen_flags_arg "$val" "-execname"; exec_entrypoint="$val"; exec_was_set=1;;
          execname=*) val=${OPTARG#*=}; opt=${OPTARG%=$val}; handle_nohyphen_flags_arg "$val" "-execname"; exec_entrypoint="$val"; exec_was_set=1;;
          maketag) val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 )); handle_nohyphen_flags_arg "$val" "-maketag"; vers_make_flag=1; makefile_version="$val";;
          maketag=*) val=${OPTARG#*=}; opt=${OPTARG%=$val}; handle_nohyphen_flags_arg "$val" "-maketag"; vers_make_flag=1; makefile_version="$val";;
          gen-c-header) val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 )); handle_genC_arg "$val";;
          gen-c-header=*) val=${OPTARG#*=}; opt=${OPTARG%=$val}; handle_genC_arg "$val";;
          linter) val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 )); handle_nohyphen_flags_arg "$val" "-linter"; be_stego_parser_flag=1; queried_stego_filepath="$val";;
          linter=*) val=${OPTARG#*=}; opt=${OPTARG%=$val}; handle_nohyphen_flags_arg "$val" "-linter"; be_stego_parser_flag=1; queried_stego_filepath="$val";;
          verbose) val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 )); handle_verbose_arg "$val";;
          verbose=*) val=${OPTARG#*=}; opt=${OPTARG%=$val}; handle_verbose_arg "$val";;
          config) val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 )); handle_config_arg "$val" "-config"; pass_autoconf_arg_flag=1; passed_autoconf_arg="$val";;
          config=*) val=${OPTARG#*=}; opt=${OPTARG%=$val}; handle_config_arg "$val" "-config"; pass_autoconf_arg_flag=1; passed_autoconf_arg="$val";;
          cflags) val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 )); CFLAGS_was_passed=1; passed_CFLAGS="$val";;
          cflags=*) val=${OPTARG#*=}; opt=${OPTARG%=$val}; CFLAGS_was_passed=1; passed_CFLAGS="$val";;
          test) test_mode_flag=1;;
          base) base_mode_flag=1;;
          git) git_mode_flag=1;;
          testmacro) small_test_mode_flag=1;;
          init) init_flag=1;;
          purge) purge_flag=1;;
          build) build_flag=1;;
          delete) delete_flag=1;;
          run) run_flag=1;;
          list) small_list_flag=1;;
          list-all) big_list_flag=1;;
          quiet) quiet_flag=1;;
          silent) silent_flag=1;;
          watch) show_time_flag=1;;
          version) version_flag=$(($version_flag+1));;
          warranty) show_warranty_flag=1;;
          ignore-gitcheck) ignore_git_check_flag=1;;
          logged) do_filelog_flag=1;;
          no-color) { allow_color_flag=0; AMBOSO_COLOR=0; };;
          force) force_build_flag=1;;
          no-rebuild) enable_make_rebuild_flag=0;;
          strict) extensions_flag=0;;
          help) smallhelp_flag=1;;
        *)
          if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
            log_cl "Unknown option --${OPTARG}" error
            amboso_usage
            log_cl "Run with -h, --help to see available long options" info
            exit 1
          fi
          ;;
        esac;;
      O )
        if compare_semver "$std_amboso_version" ">=" "$min_amboso_v_stegodir" ; then {
          stego_dir="$OPTARG"
          stego_dir_flag=1
        } else {
          log_cl "Taken legacy path, ignoring passed -O arg -> {$OPTARG}" warn
        }
        fi
        ;;
      k ) handle_kern_arg "$OPTARG";;
      a ) handle_anvil_arg "$OPTARG";;
      e ) extensions_flag=0;;
      F ) force_build_flag=1;;
      R ) enable_make_rebuild_flag=0;;
      P ) { allow_color_flag=0; AMBOSO_COLOR=0; };;
      J ) do_filelog_flag=1;;
      C ) handle_config_arg "$OPTARG" "C"; pass_autoconf_arg_flag=1; passed_autoconf_arg="$OPTARG";;
      x ) handle_nohyphen_flags_arg "$OPTARG" "x"; be_stego_parser_flag=1; queried_stego_filepath="$OPTARG";;
      W ) show_warranty_flag=1;;
      X ) ignore_git_check_flag=1;;
      G ) handle_genC_arg "$OPTARG";;
      Z ) CFLAGS_was_passed=1; passed_CFLAGS="$OPTARG";;
      U ) tell_uname_flag=1;;
      z ) pack_flag=1;;
      s ) silent_flag=1;;
      S ) handle_nohyphen_flags_arg "$OPTARG" "S"; source_name="$OPTARG"; sourcename_was_set=1;;
      w ) show_time_flag=1;;
      Y ) handle_nohyphen_flags_arg "$OPTARG" "Y"; start_time_val="$OPTARG"; amboso_start_time="$start_time_val"; start_time_set=1; start_time_flag=1;;
      E ) handle_nohyphen_flags_arg "$OPTARG" "E"; exec_entrypoint="$OPTARG"; exec_was_set=1;;
      D ) handle_nohyphen_flags_arg "$OPTARG" "D"; dir_flag=1; scripts_dir="$OPTARG";;
      K ) handle_nohyphen_flags_arg "$OPTARG" "K"; testdir_flag=1; kazoj_dir="$OPTARG"; test_info_was_set=1;;
      M ) handle_nohyphen_flags_arg "$OPTARG" "M"; vers_make_flag=1; makefile_version="$OPTARG";;
      A ) handle_nohyphen_flags_arg "$OPTARG" "A"; vers_autoconf_flag=1; use_autoconf_version="$OPTARG";;
      L ) big_list_flag=1;;
      l ) small_list_flag=1;;
      H ) bighelp_flag=1;;
      h ) smallhelp_flag=1;;
      B ) base_mode_flag=1;;
      g ) git_mode_flag=1;;
      t ) small_test_mode_flag=1;;
      T ) test_mode_flag=1;;
      V ) handle_verbose_arg "$OPTARG";;
      q ) quiet_flag=1;;
      v ) version_flag=$(($version_flag+1));;
      p ) purge_flag=1;;
      r ) run_flag=1;;
      b ) build_flag=1;;
      d ) delete_flag=1 ;;
      i ) init_flag=1;;
      \? ) log_cl "Invalid option: -$OPTARG. Run with -h for help." error >&2; exit 1;;
      : ) log_cl "Option -$OPTARG requires an argument. Run with -h for help." error >&2; exit 1;;
    esac
  tot_opts=$OPTIND
  done

  if [[ $version_flag -eq 1 ]] ; then {
    echo_amboso_version_short
    echo_timer "$amboso_start_time"  "Version flag, 1" "2"
    exit 0
  } elif [[ $version_flag -gt 1 ]] ; then {
    echo_amboso_version "$amboso_currvers" "$std_amboso_version"
    echo_timer "$amboso_start_time"  "Version flag, >1" "2"
    exit 0
  }
  fi

  #Check if we are printing help info and exiting early
  if [[ $smallhelp_flag -gt 0 ]]; then {
    if [[ $AMBOSO_LVL_REC -gt 1 ]] ; then {
      printf "[AMBOSO]    can't ask for help on a recursive call, try running \"$prog_name -h\" from a shell. ( depth $((${AMBOSO_LVL_REC}-1)) )\n\n        args: (\"$*\")\n" >&2
      echo_timer "$amboso_start_time"  "Recursive help?" "1"
      exit 1
    }
    fi
    echo_amboso_version "$amboso_currvers" "$std_amboso_version"
    if [[ "$extensions_flag" -eq 0 ]] ; then { # To keep the old behaviour of -h having less output than -H
        amboso_usage
        printf "\nTry running with with -H for more info.\n\n"
    } else {
        amboso_help
    }
    fi
    #"$prog_name" -H -D "$scripts_dir" | less
    echo_timer "$amboso_start_time"  "Show help" "2"
    exit 0
  }
  fi
  #Check if we are printing Help info and exiting early
  if [[ $bighelp_flag -gt 0 ]]; then {
    if [[ $AMBOSO_LVL_REC -gt 1 ]] ; then {
      printf "[AMBOSO]    can't ask for help on a recursive call, try running \"$prog_name -H\" from a shell. ( depth $((${AMBOSO_LVL_REC}-1)) )\n\n        args: (\"$*\")\n" >&2
      echo_timer "$amboso_start_time"  "Recursive bighelp?" "1"
      exit 1
    }
    fi
    echo_amboso_version "$amboso_currvers" "$std_amboso_version"
    amboso_help
    echo_timer "$amboso_start_time"  "Show big help" "2"
    exit 0
  }
  fi

  if [[ "$extensions_flag" -ne 0 ]] && compare_semver "$std_amboso_version" "<" "$min_amboso_v_extensions" ; then {
    # Turn off extensions when below 2.0.1
    log_cl "${FUNCNAME[0]}():    Turning off extensions flag" info
    extensions_flag=0
  }
  fi

  if [[ "${AMBOSO_CONFIG_FLAG_ARG_ISFILE:-1}" -ne 0 && "$pass_autoconf_arg_flag" -gt 0 ]] ; then { #Isfile defaults to 1 to start with backwards compatibility
    [[ -f "$passed_autoconf_arg" ]] || { log_cl "Invalid file for configure argument: {$passed_autoconf_arg}" error ; exit 1 ; } ;
  }
  fi

  CC="${CC:-gcc}"
  AMBOSO_COLOR="$allow_color_flag"
  AMBOSO_LOGGED="$do_filelog_flag"
  export AMBOSO_COLOR="${AMBOSO_COLOR:-0}"
  export AMBOSO_LOGGED="${AMBOSO_LOGGED:-0}"
  export AMBOSO_AWK_NAME="${AMBOSO_AWK_NAME:-awk}"
  if [[ "${AMBOSO_LVL_REC}" -lt 2 ]]; then {
    [[ "$quiet_flag" -eq 0 ]] && echo_amboso_splash "$amboso_currvers" "$(basename "$prog_name")"
    if ! command -v "bc" > /dev/null; then
        log_cl "[CRITICAL]    Error: bc is not installed. Please install bc before running this script." error
        exit 8
    fi
    local awk_check="$("${AMBOSO_AWK_NAME}" --version 2>/dev/null)"
    local awk_check_res="$?"
    local is_gawk="$(grep "GNU" <<< "$awk_check")"
    local is_mawk="$(grep "mawk" <<< "$awk_check")"
    local is_nawk=""
    if [[ "$awk_check_res" -ne 0 ]] ; then {
      log_cl "awk check result was not zero, assuming it's mawk." warn
      is_mawk="yes"
    } else {
      if [[ -z "$is_mawk" && -z "$is_gawk" ]] ; then {
        log_cl "Couldn't grep \"GNU\" nor \"mawk\" in awk check output, assuming it's nawk." warn
        is_nawk="yes"
      } elif [[ -z "$is_mawk" ]] ; then {
        is_gawk="yes"
      } else {
        log_cl "Got to fallback error for \"mawk\" detection." warn
        log_cl "awk seems to support --version but it has \"mawk\" in its output." warn
        is_mawk="yes"
      }
      fi
    }
    fi
    if ! [[ "$is_gawk" = "yes" ]] ; then {
      log_cl "This script needs gawk installed to work. It seems your awk is not gawk." warn
      log_cl "When running as >=2.0.3, a direct invocation of gawk is performed later." debug
      if [[ "$is_mawk" = "yes" ]] ; then {
        log_cl "awk seems to be mawk. The script may fail unexpectedly. See issue: https://github.com/jgabaut/amboso/issues/58" warn
        if compare_semver "$std_amboso_version" ">=" "$min_amboso_v_fix_awk" ; then {
            log_cl "Trying to use gawk instead.\n" warn magenta
            AMBOSO_AWK_NAME="gawk"
        }
        fi
      } elif [[ "$is_nawk" = "yes" ]] ; then {
        log_cl "awk seems to be nawk. The script may fail unexpectedly. See issues:" warn
        log_cl "https://github.com/jgabaut/amboso/issues/58" warn
        log_cl "https://github.com/jgabaut/amboso/issues/100" warn
        if compare_semver "$std_amboso_version" ">=" "$min_amboso_v_fix_awk" ; then {
            log_cl "Trying to use gawk instead.\n" warn magenta
            AMBOSO_AWK_NAME="gawk"
        }
        fi
      }
      fi
    }
    fi
    [[ "$quiet_flag" -eq 0 ]] && echo_invil_notice
  }
  fi
  if [[ $quiet_flag -eq 0 && $show_warranty_flag -gt 0 && "${AMBOSO_LVL_REC}" -eq 1 ]]; then {
    printf "THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY
  APPLICABLE LAW.  EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT
  HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM \"AS IS\" WITHOUT WARRANTY
  OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM
  IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF
  ALL NECESSARY SERVICING, REPAIR OR CORRECTION.\n"
  }
  fi

  if [[ "${AMBOSO_LVL_REC}" -eq "1" ]]; then {
    if [[ "${BASH_VERSINFO:-0}" -lt "4" ]] ; then {
        log_cl "Bash version: {$BASH_VERSION} is less than 4\n" warn
        log_cl "amboso may not work as expected. See issue: https://github.com/jgabaut/amboso/issues/21\n" warn
    } elif [[ "${BASH_VERSINFO:-0}" -eq "4" ]] ; then {
        log_cl "Bash version: {$BASH_VERSION} is less than 5\n" warn
        log_cl "amboso may not work as expected.\n" warn
    }
    fi
  }
  fi

  [[ $verbose_flag -ge 4 ]] && log_cl "[PREP]    Done getopts." debug >&2
  [[ $verbose_flag -gt 3 && ! "$(basename "$prog_name")" = "anvil" ]] && log_cl "[AMBOZO]    Please, symlink me to \"anvil\".\n" debug >&2

  # Load functions from amboso_fn.sh
  #source_amboso_api

  if [[ $verbose_flag -ge 4 ]] ; then {
    log_cl "[PREP]    Printing active flags:" debug >&2
    echo_active_flags >&2
  }
  fi
  trace_flag=0
  trace_line="421"
  # Check env var to enable backtrace
  export AMBOSO_TRACING="${AMBOSO_TRACING:-0}"
  if [[ ${AMBOSO_TRACING} -gt 0 ]]; then {
    trace_line=0
    trace_flag=1;
    log_cl "[TRACE]    Tracing started." debug >&2
    trap backtrace ERR
  } else {
    : #echo "{No trace}" >&2
  }
  fi

  [[ $verbose_flag -ge 4 ]] && log_cl "[PREP]    Parent command is: ( $PARENT_COMMAND )." debug >&2


  #Won't print call info for top level calls
  if [[ ${AMBOSO_LVL_REC} -gt 1 ]] ; then {
  #and 1+ nested test calls ( with -T, from -t calling -T)
    [[ $quiet_flag -eq 0 && $verbose_flag -gt 3 ]] && log_cl "[AMBOSO]    Amboso depth: ( $((${AMBOSO_LVL_REC}-1)) )" debug
    if [[ $AMBOSO_LVL_REC -lt 2 ]] ; then {
      printf "\n\n        args: (\"$*\")\n" >&2
      echo_active_flags >&2
    } elif [[ $AMBOSO_LVL_REC -gt 2 ]] ; then {
      [[ $test_info_was_set -eq 1 ]] && log_cl "[AMBOSO]    Deep recursion (>1), are you calling \"$prog_name\" in a test? ;)" debug >&2
      #[[ $small_test_mode_flag -gt 0 ]] && echo "[ERROR]    Can't proceed and macro -t for -T on all tags." && exit 69
      #[[ $test_mode_flag -gt 0 ]] && echo "[ERROR]    Can't proceed with test mode." && exit 69
    }
    fi
  } elif [[ $AMBOSO_LVL_REC -eq 1 ]] ; then {
      #Print lvl info for top level calls
      #echo "AMBOSO_LVL_REC: [$AMBOSO_LVL_REC]" >&2
      :
  }
  fi

  if [[ $be_stego_parser_flag -eq 1 ]] ; then {
      filepath="$queried_stego_filepath"

      [[ -f "$filepath" ]] || { log_cl "\"$filepath\" was not a valid file." error ; exit 1 ; }

      if [[ $ignore_git_check_flag -eq 1 ]]; then {
          log_cl "EXPERIMENTAL:    Running as Makefile parser." debug >&2
          if [[ $big_list_flag -eq 1 ]] ; then {
              najlo_main -d "$filepath"
              exit "$?"
          } elif [[ $small_list_flag -eq 1 ]] ; then {
              najlo_main -s "$filepath"
              exit "$?"
          } elif [[ $init_flag -eq 1 ]] ; then {
              najlo_main -vv
              exit "$?"
          } else {
              echo_najlo_splash "$najlo_version" "$base_prog_name"
              lex_makefile "$filepath" 0 0 1 0
              exit "$?"
          }
          fi
      } elif [[ $big_list_flag -eq 1 ]] ; then {
          lex_stego_file "$filepath"
          exit $?
      } elif [[ $small_list_flag -eq 1 ]] ; then {
          lint_stego_file "$filepath" 0 # We call with verbose ($2) 0, and won't get the lexed tokens printed.
          lint_res="$?"
          if [[ $lint_res -eq 0 ]]; then {
            log_cl "[LINT]    { Success on: \"$filepath\" }" info
            exit 0
          } else {
            log_cl "[LINT]    { Failure on: \"$filepath\" }" error
            exit 1
          }
          fi
          exit $?
      } else {
          bash_gulp_stego "$filepath" 0
          [[ $? -eq 0 ]] && print_amboso_stego_scopes
          exit $?
      }
      fi
      exit $?
  }
  fi

  [[ "$verbose_flag" -ge 4 ]] && log_cl "[AMBOSO]    Current version: $amboso_currvers\n" info

  [[ $quiet_flag -eq 0 && $verbose_flag -gt 3 ]] && for read_arg in "$@"; do { printf "[ARG]    \"$read_arg\"\n" ; } ; done

  #We check if we have to silence all subsequent output
  if [[ ( $test_mode_flag -eq 0 && $small_test_mode_flag -eq 0 ) && $silent_flag -gt 0 ]] ; then {
    log_cl "[MODE]    Running in silent mode, will now suppress all output.\n" info
    echo_timer "$amboso_start_time"  "Silent run, turning off outputs" "2"
    exec 3>&1 &>/dev/null
    printf "This output is going to dev null\n"
    printf "This erroutput is going to dev null\n" >&2
  }
  fi

  #We check again if testmode was requested, and reset the other mode flags.
  # -T always overrides -g and -B
  if [[ $test_mode_flag -gt 0 ]] ; then {
    git_mode_flag=0
    base_mode_flag=0
    log_cl "[MODE]    Running in test mode." info >&2
  }
  fi

  #We check again if basemode was requested, as the only flag checked in build stage is git_mode_flag
  #If base_mode_flag is asserted, we always override git_mode_flag

  #Default mode with no flags should be git mode
  if [[ $base_mode_flag -gt 0 ]] ; then {
    git_mode_flag=0
    log_cl "[MODE]    Running in base mode, expecting full source builds." debug >&2
  }
  fi
  if [[ $git_mode_flag -gt 0 && $be_stego_parser_flag -eq 0 ]] ; then {
      # We skip git mode check if we're going to be stego parser.
    git_mode_check
    git_mode_check_res="$?"
    if [[ $git_mode_check_res -eq 0 ]]; then {
      [[ $verbose_flag -gt 3 ]] && log_cl "[GIT]    Status was clean." debug >&2
    } else {
      [[ $verbose_flag -gt 3 || $quiet_flag -eq 0 ]] && log_cl "[GIT]    Status was not clean!" error >&2
          if [[ $ignore_git_check_flag -eq 0 ]]; then {
        [[ $verbose_flag -gt 3 || $quiet_flag -eq 0 ]] && log_cl "[AMBOSO]    Quitting." error >&2
            echo_timer "$amboso_start_time"  "Dirty git status" "1"
        return 1
      }
      fi
      [[ $verbose_flag -gt 3 || $quiet_flag -eq 0 ]] && log_cl "[AMBOZO]    We ignore this and will waste time." info magenta >&2
    }
    fi
  }
  fi

  #Get global conf
  #if [[ "$extensions_flag" -eq 0 ]]; then {
  if [[ -f "$HOME/.anvil/anvil.toml" ]] ; then {
      set_anvil_conf_info "$HOME/.anvil/anvil.toml" "$verbose_flag"
  }
  fi

  #We always notify of missing -D argument
  [[ ! $dir_flag -gt 0 ]] && scripts_dir="./bin/" && log_cl "No -D flag, using ( $scripts_dir ) for target dir. Run with -V <lvl> to see more." debug >&2 #&& usage && exit 1

  if [[ ! -d "$scripts_dir" ]] ; then {
    if compare_semver "$std_amboso_version" ">=" "$min_amboso_v_treegen" ; then {
        log_cl "Creating scripts_dir: {$scripts_dir}" debug cyan >&2
        mkdir "$scripts_dir" || { log_cl "Failed creating scripts_dir: {$scripts_dir}" error; return 1; } ;
    } else {
        log_cl "${FUNCNAME[0]}():    \"$scripts_dir\" was not a valid dir." debug
    }
    fi
  }
  fi

  if compare_semver "$std_amboso_version" ">=" "$min_amboso_v_stegodir" ; then {
    #We always notify of missing -O argument
    [[ ! $stego_dir_flag -gt 0 ]] && stego_dir="." && log_cl "No -O flag, using ( $stego_dir ) for stego dir. Run with -V <lvl> to see more." debug >&2

    if [[ ! -f "${stego_dir}/stego.lock" ]] ; then {
      log_cl "${FUNCNAME[0]}():    \"$stego_dir/stego.lock\" was not a valid stego file. Trying {\"$scripts_dir\"}." warn
      stego_dir="$scripts_dir"
    }
    fi
  } else {
    log_cl "Taken legacy path, setting stego_dir = scripts_dir -> {$scripts_dir}" warn
    stego_dir="$scripts_dir"
  }
  fi

  #We always notify of missing -K argument, if in test mode
  if [[ $test_mode_flag -gt 0 && ! $testdir_flag -gt 0 ]] ; then {
    if compare_semver "$std_amboso_version" "<" "$min_amboso_v_stegodir" ; then {
        log_cl "Using legacy method, scripts_dir contains stego.lock\n" debug
        set_amboso_stego_info "$scripts_dir/stego.lock" "$verbose_flag"
    } else {
        set_amboso_stego_info "$stego_dir/stego.lock" "$verbose_flag"
    }
    fi
    res="$?"
    [[ $res -eq 0 ]] || log_cl "Problems when doing set_amboso_stego_info($kazoj_dir).\n" warn
    set_supported_tests "$kazoj_dir"
    res="$?"
    [[ $res -eq 0 ]] || log_cl "Problems when doing set_supported_tests($kazoj_dir).\n" warn
    kazoj_dir="$(pwd)/kazoj/"
    [[ $quiet_flag -eq 0 ]] && log_cl "No -K flag, using ( $kazoj_dir ) for target dir. Run with -V <lvl> to see more." debug >&2 #&& usage && exit 1
  }
  fi
  if [[ $test_mode_flag -gt 0 && $test_info_was_set -gt 0 ]] ; then {
    if [[ $AMBOSO_LVL_REC -lt 2 ]] ; then {
      log_cl "bone dir: ( $cases_dir )" debug >&2
      log_cl "       kulpo dir: ( $errors_dir )" debug >&2 #&& usage && exit 1
    } else {
      [[ ! -z $cases_dir ]] && log_cl "bone dir: ( $cases_dir )" debug >&2
      [[ ! -z $errors_dir ]] && log_cl "       kulpo dir: ( $errors_dir )" debug >&2 #&& usage && exit 1
      log_cl "[PANIC]    Running  as \"$prog_name\" in test mode is not supported. Quitting with 69.\n" error #&& usage && exit 1
      echo_timer "$amboso_start_time"  "Test calling \"$(basename "$prog_name")\" in test mode to run a test with..." "1"
      exit 69
      #We return 69 and will check for this somewhere
    }
    fi
  } elif [[ $test_info_was_set -eq 0 && $test_mode_flag -gt 0 ]] ; then {
    if [[ $AMBOSO_LVL_REC -lt 2 ]] ; then {
      log_cl "bone dir (NO -K passed to this call): ( $cases_dir )" debug >&2
      log_cl "       kulpo dir (NO -K passed to this amboso call): ( $errors_dir )" debug >&2 #&& usage && exit 1
    } else {
      #Deep case: we're running a test, calling a program that calls amboso in test mode.
      log_cl "bone dir (NO -K passed to this call): ( $cases_dir )" debug >&2
      log_cl "       kulpo dir (NO -K passed to this amboso call): ( $errors_dir )" debug >&2 #&& usage && exit 1

      log_cl "[PANIC]    Running  \"$(basename "$prog_name")\" using test mode in a program that will be called by test mode is not supported.\n" error >&2 #&& usage && exit 1
      echo_timer "$amboso_start_time"  "Test calling \"$(basename "$prog_name")\" in test mode to run a test with..." "1"
      exit 1
    }
    fi
  }
  fi

  #Syncpoint: we assert we know these names after this. WIP
  if compare_semver "$std_amboso_version" "<" "$min_amboso_v_stegodir" ; then {
    log_cl "Using legacy method, scripts_dir contains stego.lock\n" debug
    set_amboso_stego_info "$scripts_dir/stego.lock" "$verbose_flag"
  } else {
    set_amboso_stego_info "$stego_dir/stego.lock" "$verbose_flag"
  }
  fi
  if [[ ! $? -eq 0 ]] ; then {
    log_cl "[CRITICAL]    Could not set amboso stego info." error
    exit 1
  }
  fi

  set_supported_tests "$kazoj_dir"

  if [[ $verbose_flag -ge 4 ]]; then {
      log_cl "[FETCH]    Fetching remote tags" info >&2
      echo_tag_info "$version"
  }
  fi

  # Check queried kern
  if compare_semver "$std_amboso_version" ">=" "$min_amboso_v_kern" ; then {
    if [[ ! -z "$queried_amboso_kern" ]] ; then {
        if compare_semver "$std_amboso_version" ">=" "$min_amboso_v_morekern" ; then {
            :
        } elif [[ ! "$queried_amboso_kern" = "amboso-C" ]]; then { # Legacy path: Refuse kern as unknown
            log_cl "Invalid kern argument --> {$queried_amboso_kern}" error
            log_cl "Hint: Use one of these: --> {" error
            log_cl "    amboso-C" info
            log_cl "}" error
            exit 1
        }
        fi

        if [[ "$queried_amboso_kern" = "anvilPy" ]]; then {
            if compare_semver "$std_amboso_version" ">=" "$min_amboso_v_anvilPy_kern" ; then {
                log_cl "\n##\n#\n# The anvilPy kern is experimental.\n#\n##\n" warn
            } else {
                log_cl "Can't use anvilPy kern while running as {$std_amboso_version}" debug
                log_cl "Using this function requires running as 2.1.0 preview." debug
                return 1
            }
            fi
        } elif [[ "$queried_amboso_kern" = "custom" ]]; then {
            if compare_semver "$std_amboso_version" ">=" "$min_amboso_v_custom_kern" ; then {
                log_cl "\n##\n#\n# The custom kern is experimental.\n#\n##\n" warn
            } else {
                log_cl "Can't use custom kern while running as {$std_amboso_version}" debug
                log_cl "Using this function requires running as 2.1.0 preview." debug
                return 1
            }
            fi
        }
        fi
        log_cl "Using {$queried_amboso_kern}" info
        std_amboso_kern="$queried_amboso_kern"
    } else {
        log_cl "Queried kern is empty: {$queried_amboso_kern}, sticking with {$std_amboso_kern}" debug
    }
    fi
  } else {
    log_cl "${FUNCNAME[0]}():    Can't use queried amboso kern: {$queried_amboso_kern}" info
    if [[ ! -z "$queried_amboso_kern" ]] ; then {
        log_cl "Running as: {$std_amboso_version}, less than {$min_amboso_v_kern}" warn
        log_cl "Ignoring query for kern {$queried_amboso_kern}" warn
    } else {
        log_cl "Queried kern is empty: {$queried_amboso_kern}" debug
    }
    fi
  }
  fi

  if [[ $verbose_flag -ge 4 ]]; then { #WIP
      log_cl "[VERB]    SYNCPOINT:  listing tag names" info cyan >&2
      echo_supported_tags >&2
      #This echo_tests_info call makes so we
      # ALWAYS do set_supported_tests for no reason
      # TODO: check if any usage of echo_tests_info happens before
      # the first call to set_supported_tests, in order to drop the call to set
      # inside
      #echo_tests_info "$kazoj_dir" >&2
  }
  fi

  #If we're in test mode and test dir was not set, we check if "./kazoj" is a directory and use that. If it isn't, we may get the name from stego.lock. If that is not a directory, we quit immediately.
  if [[ -z $kazoj_dir && $test_mode_flag -gt 0 ]] ; then {
    #TODO Do we need to do further checks for amboso_testflag_version?
    log_cl "kazoj_dir was not set, while in test mode." error
    exit 3
  }
  fi

  #Check if we are printing tag list for current mode and exiting early
  if [[ $small_list_flag -gt 0 ]]; then {
    if [[ $git_mode_flag -gt 0 || $base_mode_flag -gt 0 ]] ; then {
      echo_supported_tags
    } elif [[ $test_mode_flag -gt 0 ]]; then {
      echo_tests_info "$kazoj_dir"
    }
    fi
    echo_timer "$amboso_start_time"  "List tags" "2"
    exit 0
  }
  fi

  #Check if we are printing tag list for both modes and exiting early
  if [[ $big_list_flag -gt 0 ]]; then {
    if [[ $git_mode_flag -gt 0 || $base_mode_flag -gt 0 ]] ; then {
      echo_supported_tags
      echo_othermode_tags
    } elif [[ $test_mode_flag -gt 0 ]]; then {
      echo_tests_info "$kazoj_dir"
    }
    fi
    echo_timer "$amboso_start_time"  "List all tags" "2"
    exit 0
  }
  fi

  #If version for makefile support was not specified, we notify in verbose mode or not in quiet mode
  if [[ -z $makefile_version ]] ; then {
    [[ $verbose_flag -gt 3 || $quiet_flag -eq 0 ]] && log_cl "[ASSERT-FALSE]    makefile_version was empty" error >&2
    exit 1
  }
  fi

  #We notify of missing -E argument if we're in verbose mode or not in quiet mode
  if [[ -z $exec_entrypoint ]] ; then {
    [[ $verbose_flag -gt 3 || $quiet_flag -eq 0 ]] && log_cl "[ASSERT-FALSE]    exec_entrypoint was empty." error >&2
    exit 1
  }
  fi

  #We notify of missing -S argument if we're in verbose mode or not in quiet mode
  if [[ -z $source_name ]] ; then {
    [[ $verbose_flag -gt 3 || $quiet_flag -eq 0 ]] && log_cl "[ASSERT-FALSE]    source_name was empty." error >&2
    exit 1
  }
  fi

  #We notify of missing -A argument if we're in verbose mode or not in quiet mode
  if [[ -z $use_autoconf_version ]] ; then {
    [[ $verbose_flag -gt 3 || $quiet_flag -eq 0 ]] && log_cl "[ASSERT-FALSE]    use_autoconf_version was empty." error >&2
    exit 1
  }
  fi

  #Display needed values if in verbose mose
  [[ $verbose_flag -gt 3 || $quiet_flag -eq 0 ]]  && [[ ! $dir_flag -gt 0 ]] && log_cl "Using target dir: ( $scripts_dir )." info >&2
  [[ $verbose_flag -gt 3 || $quiet_flag -eq 0 ]] && [[ ! $exec_was_set -gt 0 ]] && log_cl "Using target bin: ( $exec_entrypoint )." info >&2
  [[ $verbose_flag -gt 3 || $quiet_flag -eq 0 ]] && [[ ! $sourcename_was_set -gt 0 ]] && log_cl "Using source file name: ( $source_name )." info >&2
  [[ $verbose_flag -gt 3 || $quiet_flag -eq 0 ]] && [[ ! $vers_make_flag -gt 0 ]] && log_cl "Using tag for make support: ( $makefile_version ) as first tag compiled with make." info >&2
  [[ $verbose_flag -gt 3 || $quiet_flag -eq 0 ]] && [[ ! $vers_autoconf_flag -gt 0 ]] && log_cl "Using tag for automake support: ( $use_autoconf_version ) as first tag compiled with automake." info >&2
  [[ $verbose_flag -gt 3 || $quiet_flag -eq 0 ]] && [[ $test_mode_flag -gt 0 && ! $test_info_was_set -gt 0 ]] && log_cl "Using tests dir: ( $kazoj_dir )." info >&2

  #Check if we are doing init and we're not in test mode
  #Which means we want to build all tags
  #TODO: Why is this checked before determining if we're doing build mode or test mode?
  if [[ $init_flag -gt 0 && $test_mode_flag -eq 0 && $small_test_mode_flag -eq 0 ]] ; then {
    if [[ $quiet_flag -eq 0 && $verbose_flag -ge 4 ]]; then { #WIP
        log_cl "[VERB]    Init mode (no -tT): build all tags" info >&2
        echo_supported_tags >&2
    }
    fi

    count_bins=0
    start_t_init=$(date +%s.%N)
    for tag_idx in $(seq 0 $(($tot_vers-1))); do
      init_vers="${supported_versions[$tag_idx]}"
      [[ $quiet_flag -eq 0 ]] && printf "[INIT]    Trying to build ( $init_vers ) ( $(($tag_idx+1)) / $tot_vers )\n" >&2
      #Build this vers
      #Init mode ALWAYS tries building, even if we have the binary already ATM
      #Save verbose flag
      case "$std_amboso_kern" in
        "amboso-C")
            has_makefile=0
            if compare_semver "$init_vers" ">=" "$makefile_version" ; then {
            #if [[ $init_vers > $makefile_version || $init_vers = "$makefile_version" ]] ; then
              has_makefile=1
            }
            fi

            can_automake=0
            if compare_semver "$init_vers" ">=" "$use_autoconf_version" ; then {
              #if [[ $init_vers > $use_autoconf_version || $init_vers = "$use_autoconf_version" ]] ; then
              can_automake=1
            }
            fi

            ambosoC_build_step "${scripts_dir}v${init_vers}" "$init_vers" "$exec_entrypoint" "$source_name" "$pass_autoconf_arg_flag" "$passed_autoconf_arg" "$CFLAGS_was_passed" "$passed_CFLAGS"
            ;;
        "anvilPy")
            anvilPy_build_step "${scripts_dir}v${init_vers}" "$init_vers" "$exec_entrypoint" "$stego_dir"
            ;;
        "custom")
            custom_build_step "${scripts_dir}v${init_vers}" "$init_vers" "$exec_entrypoint" "$stego_dir" "$amboso_custom_builder"
            ;;
        *)
            log_cl "[BUILD]    Invalid kern: {$std_amboso_kern}" error
            exit 1
            ;;
      esac
      if [[ $? -eq 0 ]] ; then {
        [[ $verbose_flag -gt 3 ]] && log_cl "[INIT]    $init_vers binary ready." info >&2
        count_bins=$(($count_bins +1))
      } else {
        verbose_hint=""
        [[ $verbose_flag -lt 1 ]] && verbose_hint="Run with -V <lvl> to see more info."
        log_cl "[INIT]    Failed build for $init_vers binary. $verbose_hint\n" error
      }
      fi
    done
    end_t_init=$(date +%s.%N)
    runtime_init=$( printf "$end_t_init - $start_t_init\n" | bc -l )
    display_zero=$(printf "$runtime_init\n" | cut -d '.' -f 1)
    if [[ -z $display_zero ]]; then {
      display_zero="0"
    } else {
      display_zero=""
    }
    fi
    log_cl "[INIT]    Took $display_zero$runtime_init seconds, ( $count_bins / $tot_vers ) binaries ready." info
    #We don't quit after the full build.
    #exit 0
  }
  fi

  if [[ $init_flag -gt 0 && $test_mode_flag -gt 0 ]] && [[ $verbose_flag -gt 3 || $quiet_flag -eq 0 ]] ; then {
    if compare_semver "$std_amboso_version" ">=" "$min_amboso_v_refuseTi"; then {
        log_cl "Invalid usage: -Ti." error
        log_cl "To record all tests, use -tb instead." error
        return 1
    } else {
        log_cl "Taken legacy path: accept -Ti to record all tests" warn cyan
        log_cl "[TEST]    [-i]    Will record all tests." info >&2
        log_cl "DEPRECATED" warn >&2
    }
    fi
  }
  fi
  if [[ $purge_flag -gt 0 && $test_mode_flag -gt 0 ]] && [[ $verbose_flag -gt 3 || $quiet_flag -eq 0 ]] ; then {
    :
    #echo -e "\033[0;35m[TEST]    [-p]\e[0m    Will clean all tests." >&2
  }
  fi
  if [[ $build_flag -gt 0 && $test_mode_flag -gt 0 ]] && [[ $verbose_flag -gt 3 || $quiet_flag -eq 0 ]] ; then {
    log_cl "[TEST]    [-b]    Will record test query." info >&2
  }
  fi
  if [[ $delete_flag -gt 0 && $test_mode_flag -gt 0 ]] && [[ $verbose_flag -gt 3 || $quiet_flag -eq 0 ]] ; then {
    :
    #echo -e "\033[0;35m[TEST]    [-d]\e[0m    Will clean test query." >&2
  }
  fi

  #If we have -t and not -T, we check all tests and EXIT
  #WIP
  if [[ $small_test_mode_flag -gt 0 && $test_mode_flag -eq 0 ]] ; then {
    if [[ $quiet_flag -eq 0 ]] ; then {
      log_cl "-t assert: shortcut to run \"$prog_name\" with -T" debug
      log_cl "will pass: ( -qVbw ) to subcall, if asserted.\n" debug
    }
    fi
    if [[ $init_flag -gt 0 ]]; then {
        log_cl "Recording all tests with -ti is deprecated." error
        exit 2
    }
    fi

    tot_successes=0
    tot_failures=0
    start_t_tests=$(date +%s.%N)
    for k in $(seq 0 $(($tot_tests-1))); do {
      start_t_curr_test=$(date +%s.%N)
      amboso_test_step "${supported_tests[$k]}" "$kazoj_dir" "$cases_dir" "$errors_dir" "read_tests_files" "read_errortests_files"
      retcod="$?"
      if [[ $retcod -eq 0 ]] ; then {
        tot_successes=$(($tot_successes+1))
      } else {
        tot_failures=$(($tot_failures+1))
      }
      fi
      if [[ $retcod -eq 69 ]] ; then {
        log_cl "[PANIC]    A test call returned 69 while in macro mode. Doing the same.\n" error
        echo_timer "$amboso_start_time"  "Test returned 69" "1"
        exit 69
      }
      fi
      end_t_curr_test=$(date +%s.%N)
      runtime_curr_test=$( printf "$end_t_curr_test - $start_t_curr_test\n" | bc -l )
      display_zero=$(printf "$runtime_curr_test\n" | cut -d '.' -f 1)
      if [[ -z $display_zero ]]; then {
        display_zero="0"
      } else {
        display_zero=""
      }
      fi
      [[ $quiet_flag -eq 0 ]] && log_cl "[TEST]  ($(($k+1))/$tot_tests)  took $display_zero$runtime_curr_test seconds." info
    }
    done
    end_t_tests=$(date +%s.%N)
    runtime_tests=$( printf "$end_t_tests - $start_t_tests\n" | bc -l )
    display_zero=$(printf "$runtime_tests\n" | cut -d '.' -f 1)
    if [[ -z $display_zero ]]; then {
      display_zero="0"
    } else {
      display_zero="" #what?
    }
    fi
    #echo -e "\033[0;34m[TEST]    Full testing took $display_zero$runtime_tests seconds ( $tot_tests done).\e[0m\n"
    echo_timer "$amboso_start_time"  "Test macro" "6"
    log_cl "[TEST]    Successes: {$tot_successes}" info
    log_cl "[TEST]    Failures: {$tot_failures}" info
    exit $tot_failures
  } elif [[ $small_test_mode_flag -gt 0 && $test_mode_flag -gt 0 ]] ; then {
    log_cl "[PANIC]    [-t] used with [-T].\n\n        -t is a shortcut to run as -T on all tests found.\n" info
    echo_timer "$amboso_start_time"  "Wrong test flag usage" "1"
    exit 1
  }
  fi

  #Version argument is mandatory outside of:
    # purge or init mode (when not in test mode
    # init mode or FULL test mode (when in test mode)
  #check arg num
  # nothing else is allowed
  #shift all the options
  for tot_opts_idx in $(seq 0 $(( $tot_opts - 2 )) ); do {
    shift
  }
  done

  # $0 is now target version, at position 1 in the array ??
  v_pos=1
  if [[ $# -eq 1 ]] ; then {
    query="${!v_pos}"
    if [[ $query = "latest" ]] ; then {
        #TODO: calling the check slows down everything, with the advantage of offering a "working" build command
        check_tags
        query="$latest_version"
    }
    fi
  } else {
    query=""
  }
  fi

  if [[ $quiet_flag -eq 0 && $verbose_flag -ge 4 ]]; then { #WIP
      log_cl "[VERB]    SYNCPOINT: shifted args, query was: ( $query )." debug >&2
  }
  fi

  tot_left_args=$(( $# ))
  if [[ $tot_left_args -gt 1 ]]; then {
    log_cl "\n    Unknown argument: \"$2\" (ignoring other $(($tot_left_args-1)) args).\n" error
    amboso_usage
    echo_timer "$amboso_start_time"  "Unknown arg [$2]" "1"
    exit 1
  }
  fi

  #If we don't have init or purge flag, we bail on a missing version argument
  if [[ $tot_left_args -lt 1 && $purge_flag -eq 0 && $init_flag -eq 0 && $test_mode_flag -eq 0 ]]; then {
    case "$std_amboso_kern" in
        "amboso-C")
            try_doing_make
            ;;
        "anvilPy" | "custom")
            log_cl "Missing query." error
            log_cl "           Run with -h for help." info
            echo_timer "$amboso_start_time"  "Missing query" "1"
            return 1
            ;;
        *)
            log_cl "[BUILD]    Invalid kern: {$std_amboso_kern}" error
            exit 1
            ;;
    esac
    make_res="$?"
    #printf "\033[1;31m[ERROR]    Missing query.\e[0m\n\n"
    #printf "\033[1;33m           Run with -h for help.\e[0m\n\n"
    echo_timer "$amboso_start_time"  "Missing query" "1"
    return "$make_res"
  } elif [[ $tot_left_args -lt 1 && $test_mode_flag -gt 0 ]] ; then {
    #If in test mode, we still whine about a target test
    if [[ $init_flag -gt 0 ]]; then {
      if compare_semver "$std_amboso_version" ">=" "$min_amboso_v_refuseTi"; then {
        log_cl "Invalid usage: -Ti." error
        log_cl "To record all tests, use -tb instead." error
        return 1
      } else {
          log_cl "Taken legacy path: accept -Ti to record all tests" warn cyan
          #Legacy behaviour support: called with -Ti
          #This behaviour is deprecated
          #Call with -tb instead
          :
      }
      fi
    } else {
      log_cl "Missing test query.\n" error
      log_cl "       Run with -h for help.\n" error
    }
    fi
    #printf "can we do init/purge?\n" #TODO wth does this mean
  }
  fi
  #Check if we are doing a test
  if [[ $test_mode_flag -gt 0 ]]; then {
    if [[ $init_flag -gt 0 ]]; then {
      if compare_semver "$std_amboso_version" ">=" "$min_amboso_v_refuseTi"; then {
        log_cl "Invalid usage: -Ti." error
        log_cl "To record all tests, use -tb instead." error
        return 1
      }
      fi
      log_cl "Legacy behaviour support: called with -Ti" warn
      log_cl "This behaviour is deprecated." warn
      log_cl "Call with -tb instead." warn

      log_cl "Taken legacy path: accept -Ti to record all tests" warn cyan
      log_cl "Setting init_flag to 0" debug
      init_flag=0
      log_cl "Setting build_flag to 1, was: $build_flag" debug
      build_flag=1

      log_cl "( $tot_tests ) total tests ready." debug >&2
      local curr_test_count=0
      for curr_test in "${supported_tests[@]}"; do {
          log_cl "Recording test ($curr_test_count/$tot_tests):" debug
          amboso_test_step "$curr_test" "$kazoj_dir" "$cases_dir" "$errors_dir" "read_tests_files" "read_errortests_files"
          local curr_test_res="$?"
          if [[ $curr_test_res -eq 69 ]]; then {
            log_cl "[PANIC]    Unsupported: a test call returned 69. Will do the same.\n" error
            echo_timer "$amboso_start_time"  "Record Test call returned 69" "1"
            return 69
          }
          fi
          curr_test_count="$(($curr_test_count+1))"
      }
      done
      return "$?"
    } else {
      amboso_test_step "$query" "$kazoj_dir" "$cases_dir" "$errors_dir" "read_tests_files" "read_errortests_files"
      return "$?"
    }
    fi
  }
  fi
  #End of test mode block

  #We expect $scripts_dir to end with /
  local interpr_regex='stego.lock$'
  local interpr_does_make=1

  if compare_semver "$std_amboso_version" ">" "2.0.2" && [[ "$query" =~ $interpr_regex ]] ; then {
    log_cl "Running as interpreter for {$query}\n" info
    if [[ "$std_amboso_kern" = "anvilPy" || "$std_amboso_kern" = "custom" ]]; then {
      log_cl "[KERN]    Avoiding make branch for {$std_amboso_kern} interpreter" debug
      interpr_does_make=0
    }
    fi
    if [[ "$interpr_does_make" -gt 0 ]] ; then {
      case "$std_amboso_kern" in
          "amboso-C")
              log_cl "Building: -->    {Plain make}\n" info magenta
              try_doing_make
              ;;
          "anvilPy" | "custom")
              log_cl "[BUILD]    Interpreter make branch for {$std_amboso_kern} kern is not implemented" error
              return 1
              ;;
          *)
              log_cl "[BUILD]    Invalid kern: {$std_amboso_kern}" error
              exit 1
              ;;
      esac
      make_res="$?"
      #printf "\033[1;31m[ERROR]    Missing query.\e[0m\n\n"
      #printf "\033[1;33m           Run with -h for help.\e[0m\n\n"
      echo_timer "$amboso_start_time"  "Missing query" "1"
      return "$make_res"
    } else {
      log_cl "Building: -->    {$latest_version}\n" info magenta
      log_cl "Setting build flag: --> {$build_flag} to 1" info magenta
      build_flag=1
      check_tags
      query="$latest_version"
    }
    fi
  }
  fi
  version=""
  for tag_idx in $(seq 0 $(($tot_vers-1))); do
    [[ $query = "${supported_versions[$tag_idx]}" ]] && version="$query" && script_path="${scripts_dir}v${version}"
  done

  if [[ -z $version ]]; then {
    #We only freak out if we don't have test_mode, purge or init flags on
    if [[ $test_mode_flag -eq 0 && $purge_flag -eq 0 && $init_flag -eq 0 && $gen_C_headers_set -eq 0 ]] ; then {
      log_cl "( $query ) is not a supported tag.\n" error
      log_cl "       Run with -h for help.\n" error
      echo_timer "$amboso_start_time"  "Invalid query [$query]" "1"
      exit 1
    } elif [[ ! -z $query && $test_mode_flag -gt 0 ]] ; then { #If we're in test mode, gently tell the user that the version is not supported
      keep_run_txt=""
      [[ $init_flag -gt 0 ]] && keep_run_txt="${mode_txt}[INIT]"
      [[ $purge_flag -gt 0 ]] && keep_run_txt="${mode_txt}[PURGE]"
      log_cl "( $query ) is not a supported test. $keep_run_txt." debug >&2
      echo_timer "$amboso_start_time"  "Invalid test query [$query]" "1"
      exit 1;
    } elif [[ $gen_C_headers_set -gt 0 ]] ; then { #If we're in C header gen mode, we swap the query for HEAD
      if [[ -z "$query" ]]; then {
          log_cl "( $query ) is not a supported tag.\n" error
          log_cl "       Run with -h for help.\n" error
          echo_timer "$amboso_start_time"  "Invalid query [$query]" "1"
          exit 1
      }
      fi
      log_cl "( $query ) is not a supported tag. Retrying using HEAD\n" warn
      version="HEAD"
    }
    fi
  }
  fi
  #We now should have a valid $version value, outside of purge or init mode

  if [[ $gen_C_headers_set -gt 0 && $gen_C_headers_flag -gt 0 ]]; then {
      log_cl "[AMBOSO]    Generate C header for [$version]." info >&2
      gen_C_headers "$gen_C_headers_destdir" "$version" "$query" "$exec_entrypoint"
  }
  fi


  has_makefile=0
  if compare_semver "$version" ">=" "$makefile_version" ; then {
  #if [[ $version > $makefile_version || $version = "$makefile_version" ]] ; then
    has_makefile=1
  }
  fi


  can_automake=0
  if compare_semver "$version" ">=" "$use_autoconf_version" ; then {
  #if [[ $version > $use_autoconf_version || $version = "$use_autoconf_version" ]] ; then
    can_automake=1
  }
  fi

  #If we can't find the file we may try to build it
  if [[ ! -z "$version" && ( ( ! -f "$script_path/$exec_entrypoint" ) || "$force_build_flag" -gt 0 ) ]] ; then {
    if [[ "$force_build_flag" -le 0 ]] ; then {
        log_cl "[QUERY]    ( $version ) binary not found in ( $script_path )." warn #>&2
    } else {
        log_cl "[QUERY]    Forcing build for ( $version ) binary." debug #>&2
    }
    fi
    if [[ $verbose_flag -gt 3 ]] ; then {
        echo_tag_info "$version"
    }
    fi
    if [[ ! $build_flag -gt 0 ]] ; then { #We exit here if we don't want to try building and we're not going to purge
      log_cl "To try building, run with -b flag\n" debug >&2
      if [[ ! $purge_flag -gt 0 ]] ; then {
       echo_timer "$amboso_start_time"  "No build flag" "1"
       exit 1 # quit if we're not purging
      }
      fi
    } else {
        case "$std_amboso_kern" in
            "amboso-C")
                ambosoC_build_step "$script_path" "$version" "$exec_entrypoint" "$source_name" "$pass_autoconf_arg_flag" "$passed_autoconf_arg" "$CFLAGS_was_passed" "$passed_CFLAGS"
                ;;
            "anvilPy")
                anvilPy_build_step "$script_path" "$version" "$exec_entrypoint" "$stego_dir"
                ;;
            "custom")
                custom_build_step "$script_path" "$version" "$exec_entrypoint" "$stego_dir" "$amboso_custom_builder"
                ;;
            *)
                log_cl "[BUILD]    Invalid kern: {$std_amboso_kern}" error
                exit 1
                ;;
        esac
        local build_step_res="$?"
        [[ "$build_step_res" -ne 0 ]] && {
            log_cl "[BUILD]    Failed build step for ( $version ) .\n" error
            exit "$build_step_res"
        }
    }
    fi

  } elif [[ ! -z $version ]] ; then { #Binary was present, we notify if we were running with build flag
    log_cl "[QUERY]    ( $version ) binary is ready at ( $script_path ) .\n" info >&2
    if [[ $verbose_flag -gt 3 ]] ; then {
        echo_tag_info "$version"
    }
    fi
    if [[ $build_flag -gt 0 ]] ; then {
      log_cl "[BUILD]    Found binary for ( $version ), won't build.\n" info >&2

    }
    fi
    #Check if we're packing the ready version
    if [[ $pack_flag -gt 0 ]] ; then {
      #We just leverage make pack and assume it's ready to roll
      log_cl "[PACK]    Running in base mode, expecting full source in $script_path." warn #>&2
      make pack
      pack_res=$?
      if [[ $pack_res -gt 0 ]] ; then { #make pack failed
        log_cl "[PACK]    Packing ($version) in base mode, failed.\n    Expected source at ($script_path)." error #>&2
      } else {
        log_cl "[PACK]    Packed ($version):\n    from  ($script_path)" info #>&2
      }
      fi
    }
    fi

  } elif [[ ! -z $query ]] ; then {
    log_cl "[QUERY]    ( $query ) invalid query, run with -V <lvl> to see more." error
    if [[ $verbose_flag -gt 3 ]] ; then {
        echo_tag_info "$version"
    }
    fi
  }
  fi

  #We check the run flag to run the binary
  if [[ ! -z $version && $run_flag -eq 1 && -x $script_path/$exec_entrypoint ]] ; then {
    # TODO: put this to some use that doesn't involve the legacy app() function
    #
    #if [[ $build_flag -gt 0 && $comp_res -eq 0 ]]; then { #The second condition is needed to catch running a freshly built tag
    #  app "$(echo_node build_success running)"
    #} else {
    #  app "$(echo_node query_success_ready running)"
    #}
    #fi

    log_cl "\n    Running script $script_path/$exec_entrypoint" debug
    ( cd "$script_path" || { log_cl "[CRITICAL]    cd failed. Quitting." error ; exit 4 ;} ; ./"$exec_entrypoint" )
  } elif [[ ! -z $version && $run_flag -eq 0  ]] ; then {
    log_cl "Running without -r flag, won't run." debug >&2
  } elif [[ -z $version && $run_flag -gt 0 ]] ; then {
    [[ $verbose_flag -gt 3 ]] && log_cl "Running with -r but requested an empty tag ( $version )!" warn >&2
  }
  fi

  #Check if we are deleting and exiting early
  #We skipped first deletion pass if purge mode is requested, since we will enter here later
  if [[ $delete_flag -gt 0 && $purge_flag -eq 0 ]] ; then {
    case "$std_amboso_kern" in
        "amboso-C")
            ambosoC_delete_step "$scripts_dir" "$version" "$exec_entrypoint"
            ;;
        "anvilPy" | "custom" ) #TODO: handle custom delete step
            anvilPy_delete_step "$scripts_dir" "$version" "$exec_entrypoint"
            ;;
        *)
            log_cl "[BUILD]    Invalid kern: {$std_amboso_kern}" error
            exit 1
            ;;
    esac
    local del_res="$?"
    if [[ "$del_res" -ne 0 ]]; then {
        log_cl "[DELETE]    Errors while trying to delete {$scripts_dir/v$version/$exec_entrypoint}" error
    }
    fi
    return "$del_res" # A delete op always results in main returning
  }
  fi

  #Check if we are purging
  if [[ purge_flag -gt 0 ]]; then
    tot_removed=0
    tool_txt="rm"
    has_bin=0
    for tag_idx in $(seq 0 $(($tot_vers-1)) ); do
      clean_res=1
      has_makeclean=0
      purge_vers=${supported_versions[$tag_idx]}
      if [[ -x $scripts_dir/v$purge_vers/$exec_entrypoint ]] ; then {
        has_bin=1 #&& [[ $verbose_flag -gt 0 ]] && echo -e "\033[0;32m[DELETE]    $version has an executable.\e[0m\n" >&2
      } else {
        log_cl "[PURGE]    Could not find target for ( $purge_vers ) at {$scripts_dir/v$purge_vers/$exec_entrypoint}. Ignoring it." warn
        continue; #We just skip the version
      }
      fi
      case "$std_amboso_kern" in
          "amboso-C")

              if compare_semver "$purge_vers" ">=" "$makefile_version" ; then {
              #if [[ $purge_vers > "$makefile_version" || $purge_vers = "$makefile_version" ]] ; then
                  [[ $git_mode_flag -eq 0 ]] && has_makeclean=1 && tool_txt="make clean" #We never use make clean for purge, if in git mode
              }
              fi
              ambosoC_delete_step "$scripts_dir" "$purge_vers" "$exec_entrypoint"
              ;;
          "anvilPy" | "custom" ) # TODO: handle custom delete step
              anvilPy_delete_step "$scripts_dir" "$purge_vers" "$exec_entrypoint"
              ;;
          *)
              log_cl "[BUILD]    Invalid kern: {$std_amboso_kern}" error
              exit 1
              ;;
      esac
      clean_res="$?"

      #Check clean result
      if [[ $clean_res -eq 0 && $has_bin -gt 0 ]] ; then {
        #we advance the count
        tot_removed=$(($tot_removed +1))
        [[ $verbose_flag -gt 3 ]] && log_cl "[PURGE]    Removed ( $purge_vers ) using ( $tool_txt )." debug >&2
      } else {
        verbose_hint=""
        [[ $verbose_flag -lt 1 ]] && verbose_hint="Run with -V <lvl> to see more info."
        log_cl "[PURGE]    Failed delete for ( $purge_vers ) binary. $verbose_hint\n" error
        [[ $verbose_flag -gt 3 ]] && log_cl "[PURGE]    Failed removing ( $purge_vers ) using ( $tool_txt ). $verbose_hint" error #>&2
      }
      fi

    done
    if [[ $tot_removed -gt 0 ]] ; then {
      log_cl "[PURGE]    Purged ( $tot_removed / $tot_vers ) versions, quitting.\n" info
    } else {
      log_cl "[PURGE]    No binaries to purge found.\n" info
    }
    fi
  fi

  echo_timer "$amboso_start_time"  "Run" "6"
  exit 0

}

amboso_source_lgcy_pos=1
amboso_bin_lgcy_pos=2
amboso_makevers_lgcy_pos=3
amboso_tests_lgcy_pos=4
amboso_automakevers_lgcy_pos=5
amboso_lgcy_build_pos=0
amboso_lgcy_versions_pos=6
amboso_lgcy_bone_pos=0
amboso_lgcy_kulpo_pos=2
amboso_dashline="------------------------"

int_to_anvilname() {
    n="$1"
    case "$n" in
        "$amboso_source_lgcy_pos")
            printf "source"
        ;;
        "$amboso_bin_lgcy_pos")
            printf "bin"
        ;;
        "$amboso_makevers_lgcy_pos")
            printf "makevers"
        ;;
        "$amboso_tests_lgcy_pos")
            printf "tests"
        ;;
        "$amboso_automakevers_lgcy_pos")
            printf "automakevers"
        ;;
        *)
            printf "Unexpected number: {%s}\n" "$n"
            return 1
    esac
    return 0
}

lex_legacy_kazoj() {
    local target_dir="$1"
    local k=0
    local k_value=""
    while read -r k_l ; do {
        k_value="$(cut -f1 -d"#" <<< "$k_l")"
        if [[ "$k" -eq "$amboso_lgcy_bone_pos" || "$k" -eq "$amboso_lgcy_kulpo_pos" ]]; then {
            [[ "$k" -eq "$amboso_lgcy_bone_pos" ]] && printf "Scope: tests\n"
        } else {
            [[ "$k" -eq $((amboso_lgcy_bone_pos +1)) ]] && printf "Variable: tests_bonedir, Value: %s\n" "$k_value"
            [[ "$k" -eq $((amboso_lgcy_kulpo_pos +1)) ]] && printf "Variable: tests_kulpodir, Value: %s\n" "$k_value"
        }
        fi
        k="$((k+1))"
    } done < "$target_dir/kazoj.lock"
}


lex_legacy_stego() {
    local try_kazoj_lex="$1"
    local re='^[0-9]+$'
    if ! [[ "$try_kazoj_lex" =~ $re ]] ; then {
        try_kazoj_lex=0
    }
    fi
    local input="$2"
    [[ -f "$input" ]] || { printf "\"%s\" is not a valid file.\n" "$input" ; return 1; } ;
    local stego_dir=""
    stego_dir="$(dirname "$input")"
    [[ -d "$stego_dir" ]] || { printf "\"%s\" is not a valid dir.\n" "$stego_dir" ; return 1; } ;

    local line_idx=0
    local kulpo_dir=""


    local value=""
    local comment=""
    while read -r line ; do {
        value="$(cut -f1 -d"#" <<< "$line")"
        comment="$(cut -f2 -d"#" <<< "$line")"
        if [[ -z "$comment" ]]; then {
            comment="Empty desc."
        }
        fi

        if [[ "$line_idx" -eq "$amboso_lgcy_build_pos" ]]; then {
            printf "Scope: build\n"
        } elif [[ "$line_idx" -eq "$amboso_lgcy_versions_pos" ]] ; then {
            printf -- "%s\n" "$amboso_dashline"
            printf "Scope: versions\n"
        } else {
            printf "Variable: "
            if [[ "$line_idx" -gt "$amboso_lgcy_versions_pos" ]]; then {
                printf "versions_"
                if [[ "$(cut -c1 <<< "$value")" == "?" ]]; then {
                    value="B${value:1}"
                }
                fi
                printf "%s, Value: %s\n" "$value" "$comment"
            } else {
                printf "build_%s, Value: %s\n" "$(int_to_anvilname "$line_idx")" "$value"
                if [[ "$line_idx" -eq 4 ]] ; then {
                    kulpo_dir="$value" # Save this for later
                }
                fi
            }
            fi
            #printf "val: \"$value\", i: {$i}\n"
        }
        fi
        i=$((i+1))
    }
    done < "$input"
    printf -- "%s\n" "$amboso_dashline"
    if [[ "$try_kazoj_lex" -gt 0 ]] ; then {
        [[ -f "${kulpo_dir}/kazoj.lock" ]] || { printf "\"%s\" is not a valid file.\n" "${kulpo_dir}/kazoj.lock"; return 1; }
        lex_legacy_kazoj "$kulpo_dir"
        printf -- "%s\n" "$amboso_dashline"
    }
    fi
}

amboso_main() {
  if [[ ! $# -eq 0 ]] ; then {
    local cmd="$(printf -- "$1" | cut -f1 -d'-')"
    if [[ ! -z $cmd ]] ; then {
      printf "COMMAND: {$cmd}\n"
      local re='stego.lock$'
      if [[ "$cmd" =~ $re ]] ; then {
          shift
          # Try doing make
          (amboso_parse_args "$@")
          unset AMBOSO_LVL_REC
          unset AMBOSO_COLOR
          unset AMBOSO_LOGGED
          unset AMBOSO_AWK_NAME
          return "$?"
      }
      fi
      if [[ $cmd = "quit" ]] ; then {
        unset AMBOSO_LVL_REC
        unset AMBOSO_COLOR
        unset AMBOSO_LOGGED
        unset AMBOSO_AWK_NAME
        exit 0
      }
      fi
      if [[ $cmd = "version" ]] ; then {
        (amboso_parse_args "-v")
        unset AMBOSO_LVL_REC
        unset AMBOSO_COLOR
        unset AMBOSO_LOGGED
        unset AMBOSO_AWK_NAME
        return
      }
      fi
      if [[ $cmd = "build" ]] ; then {
        (amboso_parse_args "-Xb" "latest")
        unset AMBOSO_LVL_REC
        unset AMBOSO_COLOR
        unset AMBOSO_LOGGED
        unset AMBOSO_AWK_NAME
        return
      }
      fi
      if [[ $cmd = "init" ]] ; then {
          (amboso_init_proj "$2" 0)
          #FIXME
          #We pass 0 to NOT have strict behaviour anymore. Currently, we can't actually pass --strict in any way.
          #This changes from 2.0.0, but we can't run the backwards-compatible code without refactoring the logic to pass in flags with subcommands
        unset AMBOSO_LVL_REC
        unset AMBOSO_COLOR
        unset AMBOSO_LOGGED
        unset AMBOSO_AWK_NAME
        return
      }
      fi
      if [[ $cmd = "help" ]] ; then {
        log_cl "[AMBOSO-MAIN]    Quick commands:\n" info
        printf "    build        Build latest version\n\n"
        printf "    init         Prepare current dir for an amboso project\n\n"
        printf "    version      Print amboso version\n\n"
        printf "    quit         Quit amboso\n\n"
        printf "    help         Print this message\n\n"
        log_cl "[AMBOSO-MAIN]    Amboso help (-h):\n" info
        (amboso_parse_args "-Xh")
        unset AMBOSO_LVL_REC
        unset AMBOSO_COLOR
        unset AMBOSO_LOGGED
        unset AMBOSO_AWK_NAME
        return
      }
      fi
    }
    fi
    (amboso_parse_args "$@")
    res="$?"
    unset AMBOSO_LVL_REC
    unset AMBOSO_COLOR
    unset AMBOSO_LOGGED
    unset AMBOSO_AWK_NAME
    return "$res"
  } else { # Try doing make
    (amboso_parse_args "$@")
    unset AMBOSO_LVL_REC
    unset AMBOSO_COLOR
    unset AMBOSO_LOGGED
    unset AMBOSO_AWK_NAME
    return "$?"

    # Legacy: REPL
    #TODO: move repl
    #
    #while read  -re -p "[AMBOSO-MAIN]$ " line ;
    #do {
    #  cmd="$(printf -- "${line}" | cut -f1 -d'-')"
    #  if [[ ! -z $cmd ]] ; then {
    #    printf "COMMAND: {$cmd}\n"
    #    if [[ $cmd = "quit" ]] ; then {
    #      unset AMBOSO_LVL_REC
    #      exit 0
    #    }
    #    fi
    #    if [[ $cmd = "version" ]] ; then {
    #      (amboso_parse_args "-v")
    #      unset AMBOSO_LVL_REC
    #      return

    #    }
    #    fi
    #    if [[ $cmd = "build" ]] ; then {
    #      (amboso_parse_args "-Xb"  "latest")
    #      unset AMBOSO_LVL_REC
    #      return
    #    }
    #    fi
    #    if [[ $cmd = "init" ]] ; then {
    #      (amboso_init_proj "$2")
    #      unset AMBOSO_LVL_REC
    #      return
    #    }
    #    fi
    #    if [[ $cmd = "help" ]] ; then {
    #      printf "\033[1;35m[AMBOSO-MAIN]\033[0m    Quick commands:\n\n"
    #      printf "    build        Build latest version\n\n"
    #      printf "    init         Prepare current dir for an amboso project\n\n"
    #      printf "    version      Print amboso version\n\n"
    #      printf "    quit         Quit amboso\n\n"
    #      printf "    help         Print this message\n\n"
    #      printf "\033[1;35m[AMBOSO-MAIN]\033[0m    Amboso help (-h):\n\n"
    #      (amboso_parse_args "-Xh")
    #      unset AMBOSO_LVL_REC
    #      return
    #    }
    #    fi
    #  }
    #  fi
    #  printf "\033[1;35m[CMDLINE]\033[0m    \"\033[1;36m$line\033[0m\"\n"
    #  (amboso_parse_args "$line")
    #  res="$?"
    #  unset AMBOSO_LVL_REC
    #}
    #done < "${1:-/dev/stdin}"
  }
  fi

  return "$res"
}

##########################################
#
#  najlo.sh - https://github.com/jgabaut/najlo
#
#  Version 0.0.4, commit 1dfa970c93a82d6bf1c588d7120c64a272491f1a
#
#########################################
# SPDX-License-Identifier: GPL-3.0-only
# Copyright (C) 2024  jgabaut
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# -----------------------------
# Lex a Makefile
# -----------------------------
#
# expr:=1
# %.o: %.c
#     ./build.sh
# rules: dep1 dep2 dependencies
#     this = rule_expr;
#
# -----------------------------
# Output format: In development
#
# -----------------------------
# The setting of dbg_print to 1 enables the internal logic format to be displayed.
# -----------------------------
# {RULE} -> {myrecipe}
#	 <- {DEPS} -> {} -> [#0] ->
#		{NO_DEPS}
#	 };
#	 {RULE_EXPR} -> {@echo "HELLO"}
#	 {RULE_EXPR} -> {touch $^}
# {RULE} -> {%.o}
#	 <- {DEPS} -> { %.c} -> [#1] ->
#		{INGR} - {%.c} [0],
#	 };
#	 {RULE_EXPR} -> {@echo "Transmute"}
# {EXPR} -> {.DEFAULT_GOAL := all}
# {EXPR} -> {hey = 10}
# ----------------------------
# The final recap output can be turned off by setting skip_recap to 1.
# ----------------------------
# {MAIN} -> {
#	[{EXPR_MAIN} -> {foo = 10}, [#0]],
#	[{EXPR_MAIN} -> {.DEFAULT_GOAL := all}, [#1]],
#	[{EXPR_MAIN} -> {hey = 10}, [#2]],
#}
#{RULES} -> {
#	[{RULE} [#0] -> {src/najlo.sh} <- {1707065478} <- {DEPS} -> { LICENSE} -> [#1]],
#	[{RULE} [#1] -> {src/najlo_cli.sh} <- {1706853672} <- {DEPS} -> {} -> [#0]],
#	[{RULE} [#2] -> {toot} <- {NO_TIME} <- {DEPS} -> {} -> [#0]],
#	[{RULE} [#3] -> {./anvil} <- {NO_TIME} <- {DEPS} -> { toot src/najlo.sh} -> [#2]],
#	[{RULE} [#4] -> {all} <- {NO_TIME} <- {DEPS} -> { src/najlo.sh toot} -> [#2]],
#	[{RULE} [#5] -> {%.a} <- {NO_TIME} <- {DEPS} -> { %.o} -> [#1]],
#}
#{DEPS} -> {
#	[{RULE: src/najlo.sh #0} <-- [{LICENSE} {[0], [1707065478]}, ]],
#	[{RULE: src/najlo_cli.sh #1} <-- [{NO_DEPS}]],
#	[{RULE: toot #2} <-- [{NO_DEPS}]],
#	[{RULE: ./anvil #3} <-- [{toot} {[0], [NO_TIME]}, {src/najlo.sh} {[1], [NO_TIME]}, ]],
#	[{RULE: all #4} <-- [{src/najlo.sh} {[0], [NO_TIME]}, {toot} {[1], [NO_TIME]}, ]],
#	[{RULE: %.a #5} <-- [{%.o} {[0], [NO_TIME]}, ]],
#}
#{RULE_EXPRS} -> {
#	{{RULE} [#0] -> {src/najlo.sh} <- {1707065478} <- {DEPS} -> { LICENSE} -> [#1]} --> [{RULE_EXPR #0} {@echo "HI"}, ],
#	{{RULE} [#1] -> {src/najlo_cli.sh} <- {1706853672} <- {DEPS} -> {} -> [#0]} --> [{RULE_EXPR #0} {@echo "HELLO"}, {RULE_EXPR #1} {touch $^}, ],
#	{{RULE} [#2] -> {toot} <- {NO_TIME} <- {DEPS} -> {} -> [#0]} --> [{RULE_EXPR #0} {@echo "TOOT"}, ],
#	{{RULE} [#3] -> {./anvil} <- {NO_TIME} <- {DEPS} -> { toot src/najlo.sh} -> [#2]} --> [{RULE_EXPR #0} {@echo -e "\033[1;35m[Makefile]\e[0m    Bootstrapping \"./$anvil\":"}, ],
#	{{RULE} [#4] -> {all} <- {NO_TIME} <- {DEPS} -> { src/najlo.sh toot} -> [#2]} --> [{RULE_EXPR #0} {@echo "Transmute"}, {RULE_EXPR #1} {@echo "Transmute"}, ],
#	{{RULE} [#5] -> {%.a} <- {NO_TIME} <- {DEPS} -> { %.o} -> [#1]} --> [{RULE_EXPR #0} {@echo "Transmute"}, {RULE_EXPR #1} {@echo "Transmute"}, {RULE_EXPR #2} {@echo "Transmute"}, {RULE_EXPR #3} {@echo "Transmute"}, ],
#}
# ----------------------------
#

najlo_version="0.0.4"
rule_rgx='^([[:graph:]^:]+:){1,1}([[:space:]]*[[:graph:]]*)*$'
# Define the tab character as a variable
ruleline_mark_char=$'\t'
# Build the regex with the tab character variable
ruleline_rgx="^$ruleline_mark_char"

echo_najlo_version_short() {
  printf "%s\n" "$najlo_version"
}

echo_najlo_version() {
  printf "najlo, v%s\n" "$najlo_version"
}

echo_najlo_splash() {
    local njl_version="$1"
    local prog="$2"
    printf "najlo, v{%s}\nCopyright (C) 2024  jgabaut\n\n  This program comes with ABSOLUTELY NO WARRANTY; for details type \`%s -W\`.\n  This is free software, and you are welcome to redistribute it\n  under certain conditions; see file \`LICENSE\` for details.\n\n  Full source is available at https://github.com/jgabaut/najlo\n\n" "$njl_version" "$prog"
}

lex_makefile() {
    local lvl_regex='^[0-9]+$'
    local input="$1"
    [[ -f "$input" ]] || { printf "{%s} was not a valid file.\n" "$input"; exit 1 ; }
    local dbg_print="$2"
    if ! [[ "$dbg_print" =~ $lvl_regex ]] ; then {
        [[ -n "$dbg_print" ]] && printf "Invalid arg: {%s}. Using 0\n" "$2"
        dbg_print=0
    }
    fi
    local skip_recap="$3"
    if ! [[ "$skip_recap" =~ $lvl_regex ]] ; then {
        [[ -n "$skip_recap" ]] && printf "Invalid arg: {%s}. Using 0\n" "$3"
        skip_recap=0
    }
    fi
    local report_warns="$4"
    if ! [[ "$report_warns" =~ $lvl_regex ]] ; then {
        [[ -n "$report_warns" ]] && printf "Invalid arg: {%s}. Using 0\n" "$4"
        report_warns=0
    }
    fi
    local draw_progress="$5"
    if ! [[ "$draw_progress" =~ $lvl_regex ]] ; then {
        [[ -n "$draw_progress" ]] && printf "Invalid arg: {%s}. Using 0\n" "$5"
        draw_progress=0
    }
    fi

    local tot_lines="$(cut -f1 -d' ' <<< "$(wc -l "$input")")"
    local rulename=""
    local rule_ingredients=""
    local last_rulename=""
    local inside_rule=0
    local comment=""
    local line=""
    local ingrs_arr=""
    local ingr_i=0
    local rulexpr_i=0
    local rule_i=0
    local mod_time=""
    local ingr_mod_time=""
    local mainexpr_i=0
    local -a mainexpr_arr=()
    local -a rules_arr=()
    local -a ruleingrs_arr=()
    local -a rulexpr_arr=()
    local tot_warns=0
    local cur_line=0
    local PROGRESS_BAR_WIDTH=40  # Width of the progress bar

    while IFS= read -r line; do {
        #[[ ! -z "$line" ]] && printf "line: {%s}\n" "$line"
        comment="$(cut -f2 -d'#' <<< "$line")"
        line="$(cut -f1 -d'#' <<< "$line")"
        rulename="$(cut -f1 -d":" <<< "$line")"
        #rule_ingredients="$(awk -F": " '{print $2}' <<< "$line")"
        if [[ "$draw_progress" -gt 0 ]] ; then {
            cur_line="$((cur_line +1))"
            # Update progress bar
            progress=$((cur_line * 100 / tot_lines))
            filledWidth=$((progress * PROGRESS_BAR_WIDTH / 100))
            emptyWidth=$((PROGRESS_BAR_WIDTH - filledWidth))
            printf "\033[1;35m  Reading...    [" >&2
            # Draw filled portion of the progress bar
            for ((i = 0; i < filledWidth; ++i)); do
                printf "#" >&2
            done
            # Draw empty portion of the progress bar
            for ((i = 0; i < emptyWidth; ++i)); do
                printf " " >&2
            done
            printf "]    %d%%\r\e[0m" "$progress" >&2
        }
        fi

        # If the line ends with "\", collect continuation
        if [[ "$line" == *"\\" ]] ; then {
            # Line continuation found, remove trailing backslash
            echo "line: {$line}" >&2
            current_line="${line%\\}"
            echo "current_line: {$current_line}" >&2
            # Continue reading next line and append to current_line
            while IFS= read -r next_line; do {
                current_line+="${next_line%\\}"
                echo "current_line, after conjunction: {$current_line}" >&2
                if [[ "$next_line" != *"\\" ]]; then {
                    break
                }
                fi
            } done
        } else {
            # Line does not end with "\"
            current_line="$line"
        }
        fi

        rule_ingredients="$(awk -F": " '{print $2}' <<< "$current_line")"

        # Process line

        if [[ "$current_line" =~ $rule_rgx ]] ; then {
            # Line matched rule regex
            inside_rule=1
            last_rulename="$rulename"
            ingr_i=0
            rulexpr_i=0
            mod_time="$(date -r "$rulename" +%s 2>/dev/null)"
            [[ -z "$mod_time" ]] && mod_time="NO_TIME"
            [[ "$dbg_print" -gt 0 ]] && printf "{RULE} [#%s] -> {%s} <- {%s}" "$rule_i" "$rulename" "$mod_time"
            [[ "$dbg_print" -gt 0 ]] && printf "\n\t<- {DEPS} -> {%s} ->" "$rule_ingredients"
            ingrs_arr=( $rule_ingredients )
            [[ "$dbg_print" -gt 0 ]] && printf " [#%s] ->" "${#ingrs_arr[@]}"
            for ingr in "${ingrs_arr[@]}" ; do {
                #printf "\n\t[[ingr: $ingr]] - [[$rule_ingredients]]\n"
                if [[ ! -z "$ingr" ]] ; then {
                    [[ "$dbg_print" -gt 0 ]] && printf "\n\t\t{INGR} - {%s} [%s], " "$ingr" "$ingr_i"
                    ingr_mod_time="$(date -r "$ingr" +%s 2>/dev/null)"
                    [[ -z "$ingr_mod_time" ]] && ingr_mod_time="NO_TIME"
                    [[ "$dbg_print" -gt 0 ]] && printf "[%s]" "$ingr_mod_time"
                    ruleingrs_arr[$rule_i]="${ruleingrs_arr[$rule_i]}{$ingr} {[$ingr_i], [$ingr_mod_time]}, "
                } else {
                    printf "ERROR????????\n"
                }
                fi
                ingr_i="$(($ingr_i +1))"
            }
            done
            # Check if rule has no deps
            if [[ $ingr_i -eq 0 ]] ; then {
                [[ "$dbg_print" -gt 0 ]] && printf "\n\t\t{NO_DEPS}"
                ruleingrs_arr[$rule_i]="{NO_DEPS}"
            }
            fi
            [[ "$dbg_print" -gt 0 ]] && printf "\n\t};\n"
            ruleingrs_arr[$rule_i]="{RULE: $rulename #$rule_i} <-- [${ruleingrs_arr[$rule_i]}]"
            rules_arr[$rule_i]="{RULE} [#$rule_i] -> {$rulename} <- {$mod_time} <- {DEPS} -> {$rule_ingredients} -> [#${#ingrs_arr[@]}]"
            rule_i="$(($rule_i +1))"
        } elif [[ "$current_line" =~ $ruleline_rgx ]] ; then {
          # Line matched the ruleline regex
          #
          # Remove leading tab
            if [[ "$current_line" == "${ruleline_mark_char}"* ]] ; then {
                current_line="${current_line#"$ruleline_mark_char"}"
            } else {
                printf "ERROR: matched ruleline regex but slipped the leading tab removal.\n" >&2
                printf "Current line: {%s}\n." "$current_line" >&2
                exit 1
            }
            fi
            # We found an expression inside a rule (rule scope)
            [[ "$dbg_print" -gt 0 ]] && printf "\t{RULE_EXPR} -> {%s}, [#%s]," "$current_line" "$rulexpr_i"
            #printf "In rule: {%s}\n" "$last_rulename"
            [[ "$dbg_print" -gt 0 ]] && printf "\n"
            rulexpr_arr[$rule_i]="${rulexpr_arr[$rule_i]}{RULE_EXPR #$rulexpr_i} {$current_line}, "
            rulexpr_i="$(($rulexpr_i +1))"
        } else {
          if [[ -z "$current_line" ]] ; then {
              continue
          } else {
            inside_rule=0
            rulexpr_i=0
          }
          fi
          if [[ -z "$last_rulename" ]]; then {
            # We found an expression before any rule (main scope)
            #
            # We don't have to print them now if we collect them and group print later
            #
            [[ "$dbg_print" -gt 0 ]] && printf "{EXPR_MAIN} -> "
            [[ "$dbg_print" -gt 0 ]] && printf "{%s}, [#%s],\n" "$current_line" "$mainexpr_i"
            mainexpr_arr[$mainexpr_i]="{EXPR_MAIN} -> {$current_line}, [#$mainexpr_i]"
            mainexpr_i="$(($mainexpr_i +1))"
          } else {
            # We found an expression outside a rule, after finding at least one rule (main scope)
            #
            # We don't have to print them now if we collect them and group print later
            #
            local start_w_space_regex='^ +'
            [[ "$dbg_print" -gt 0 ]] && printf "{EXPR_MAIN} -> "
            [[ "$dbg_print" -gt 0 ]] && printf "{%s}, [#%s],\n" "$current_line" "$mainexpr_i"
            if [[ "$report_warns" -gt 0 && "$current_line" =~ $start_w_space_regex ]] ; then {
                printf "\033[1;33mWARN:    a recipe line must start with a tab.\033[0m\n"
                printf "\033[1;33m%s\033[0m\n" "$current_line"
                printf "\033[1;33m^^^ Any recipe line starting with a space will be interpreted as a main expression.\033[0m\n"
                tot_warns="$((tot_warns +1))"
            }
            fi
            mainexpr_arr[$mainexpr_i]="{EXPR_MAIN} -> {$current_line}, [#$mainexpr_i]"
            mainexpr_i="$(($mainexpr_i +1))"
          }
          fi
        }
        fi
    }
    done < "$input"

    [[ "$skip_recap" -gt 0 ]] && return "$tot_warns"
    printf "{MAIN} -> {\n"
    for mexpr in "${mainexpr_arr[@]}"; do {
        printf "\t[%s],\n" "$mexpr"
    }
    done
    printf "}\n"

    printf "{RULES} -> {\n"
    for rul in "${rules_arr[@]}"; do {
        printf "\t[%s],\n" "$rul"
    }
    done
    printf "}\n"

    printf "{DEPS} -> {\n"
    for dep in "${ruleingrs_arr[@]}"; do {
        printf "\t[%s],\n" "$dep"
    }
    done
    printf "}\n"

    local rl_i=0
    printf "{RULE_EXPRS} -> {\n"
    for r_express in "${rulexpr_arr[@]}"; do {
        printf "\t[[%s] --> [%s]],\n" "${rules_arr[$rl_i]}" "$r_express"
        rl_i="$((rl_i +1))"
    }
    done
    printf "}\n"
    return "$tot_warns"
}

najlo_main() {
#TODO: add real option handling
local prog_name="$(readlink -f "$0")"
local base_prog_name="$(basename "$prog_name")"
local res=0
case "$1" in
    "-s") {
      shift
      lex_makefile "$@" 0 0 1 1
      res="$?"
    }
    ;;
    "-v") {
      echo_najlo_version_short
      exit 0
    }
    ;;
    "-vv") {
      echo_najlo_version
      exit 0
    }
    ;;
    "-d") {
      shift
      lex_makefile "$@" 1 0 1 0
      res="$?"
    }
    ;;
    "-q") {
      shift
      lex_makefile "$@" 0 1 1 0
      res="$?"
    }
    ;;
    *) {
      echo_najlo_splash "$najlo_version" "$base_prog_name"
      lex_makefile "$@" 0 0 1 1
      res="$?"
    }
    ;;
esac
if [[ "$res" -ne 0 ]] ; then {
  printf "%s(): errors while lexing. One of the recipe lines may be starting with a space.\n" "${FUNCNAME[0]}"
}
fi
return "$res"
}
