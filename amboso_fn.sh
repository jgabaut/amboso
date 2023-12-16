#!/bin/bash
#  SPDX-License-Identifier: GPL-3.0-only
#  Bash symbols sourced by amboso.
#    Copyright (C) 2023  jgabaut
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

AMBOSO_API_LVL="1.9.9"
at () {
    printf "{ call: [$(( ${#BASH_LINENO[@]} - 1 ))] "
    for ((i=${#BASH_LINENO[@]}-1;i>=0;i--)); do
    printf '<%s:%s> ' "${FUNCNAME[i]}" "${BASH_LINENO[i]}";
    done
    printf "$LINENO\n"
}

backtrace () {
   #[[ $tracing -eq 0 ]] && echo -n "{ [MAIN] at: $trace_line } -> {"
   if [[ $trace_line -eq 0 ]] ; then {
     printf "\n\n\n\n{ [$(( $trace_line ))] [ trace at) \n"
   } else {
     at printf "[\n"
   }
   fi
   trace_line=1
   while caller "$trace_line"
   do
      #echo "]"
      trace_line=$((trace_line+1))
      #echo -n "at [ $(( $trace_line  )) ] ["
   done
   printf "} -> \n"
}

trace () {
  if [[ $trace_flag -gt 0 ]] ; then {
   backtrace
  } else {
   :
  }
  fi
}

function echo_active_flags {
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
  [[ $gen_C_headers_flag -gt 0 ]] && printf "G"
  [[ $be_stego_parser_flag -gt 0 ]] && printf "x"
  [[ $show_time_flag -gt 0 ]] && printf "w"
  [[ $start_time_flag -gt 0 ]] && printf "C"
  [[ $ignore_fit_check_flag -gt 0 ]] && printf"X"
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
}

print_sysinfo () {
  printf "[SYSTEM]    System info:\n\n"
  printf "            [ kernel_name ]    [ $kernel_name ]\n"
  printf "            [ kernel_release ]    [ $kernel_release ]\n"
  printf "            [ machine_name ]    [ $machine_name ]\n"
  printf "            [ os_name ]    [ $os_name ]\n"
}

function echo_amboso_version {
  printf "$amboso_version\n"
}
function echo_amboso_version_short {
  printf "$amboso_currvers\n"
}

function echo_timer {
  if [[ $show_time_flag -eq 0 ]] ; then {
    [[ $verbose_flag -eq 0 || $quiet_flag -gt 0 ]] && return
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
  printf "\033[1;36m[TIME]\e[0m    [ \033[1;3${color}m\"$msg\"\e[0m ] Took [ \033[1;33m$display_zero$runtime\e[0m ] seconds.\n"
  return
}

function check_tags {
	git fetch --tags
    repo_tags=()
    # From: https://www.shellcheck.net/wiki/SC2207
    # For bash 3.x+, must not be in posix mode, may use temporary files
    while IFS='' read -r line; do repo_tags+=("$line"); done < <(git tag -l)

    # LEGACY
    #
	#if [[ $verbose_flag -gt 1 ]] ; then {
	#	for tag in "${read_versions[@]}"; do
	#	if [[ " ${repo_tags[*]} " =~ " $tag " ]]; then
	#		if [[ $verbose_flag -gt 0 ]] ; then {
	#			shown_tag="\033[1;32m$tag\e[0m"
	#			printf "[AMBOSO]  Read Tag $shown_tag exists in the repo.\n" >&2
	#		}
	#		fi
	#	else {
	#		if [[ $verbose_flag -gt 0 ]] ; then {
	#			shown_tag="\033[1;31m$tag\e[0m"
	#			printf "[AMBOSO]  Read Tag $shown_tag is missing in the repo.\n" >&2
	#		}
	#		fi
	#	}
	#	fi
	#	done
	#}
	#fi

  for tag in "${supported_versions[@]}"; do
    if [[ " ${repo_tags[*]} " =~ " $tag " ]]; then {
      latest_version="$tag"
      if [[ $verbose_flag -gt 0 ]] ; then {
        shown_tag="\033[1;32m$tag\e[0m"
        printf "[AMBOSO]  Supported Tag $shown_tag exists in the repo.\n" >&2
      }
      fi
	} else {
      if [[ $verbose_flag -gt 0 ]] ; then {
        shown_tag="\033[1;31m$tag\e[0m"
        printf "[AMBOSO]  Supported Tag $shown_tag is missing in the repo.\n" >&2
	  }
	  fi
    }
    fi
  done
}

function echo_tag_info {
	tag=$1
	tag_date=$(git show -q --clear-decorations $tag 2>/dev/null | grep Date | cut -f2 -d':')
	tag_author=$(git show -q --clear-decorations $tag 2>/dev/null | grep Author | cut -f2 -d':' | cut -f2 -d' ')
	tag_txt=$(git show -q --clear-decorations $tag 2>/dev/null | tail -n2 | grep -v '^$')
	printf "\033[1;33m[AMBOSO]    Tag text was:  \033[1;34m[$tag_txt    ]\e[0m\n"
	printf "\033[1;33m[AMBOSO]    Tag author was:  \033[1;34m[$tag_author ]\e[0m\n"
	printf "\033[1;33m[AMBOSO]    Tag date was:  \033[1;34m[$tag_date   ]\e[0m\n"
}

function amboso_init_proj {
    target_dir="$1"
    if [[ ! -d "$target_dir" ]] ; then {
        printf "\033[1;31m[ERROR]\033[0m    Invalid dir: {$target_dir}.\n"
        if [[ ! -e "$target_dir" ]] ; then {
            printf "\033[1;33m[WARN]\033[0m    Trying to mkdir: {$target_dir}.\n"
            mkdir "$target_dir"
            mkdir_res="$?"
            if [[ "$mkdir_res" -eq 0 ]] ; then {
                printf "\033[1;32m[INFO]\033[0m    Created dir: {$target_dir}.\n"
            } else {
                printf "\033[1;31m[ERROR]\033[0m    Failed mkdir for: {$target_dir}.\n"
                return 1
            }
            fi
        } else {
            printf "\033[1;31m[ERROR]\033[0m    {$target_dir} already exists and it is not a directory.\n"
            return 1
        }
        fi
    }
    fi
    is_git_repo=0
    ( cd "$target_dir" || printf "\033[1;31m[CRITICAL]\033[0m    cd failed for {$target_dir}.\n"; return 1
      #Check if target dir is a repo
      git rev-parse --is-inside-work-tree 2>/dev/null 1>&2
    )
    is_git_repo="$?"
    if [[ $is_git_repo -eq 0 ]] ; then {
       printf "\n\033[1;31m[ERROR]    {$target_dir} is a git repo. Quitting..\e[0m\n\n"
       return 1
    }
    fi
    printf "\033[1;35m[PREP]\033[0m    New amboso project in {\033[1;33m$target_dir\033[0m}\n"

    mkdir -p "$target_dir"/src
    mkdir -p "$target_dir"/bin
    mkdir -p "$target_dir"/bin/"v0.1.0"
    mkdir -p "$target_dir"/tests
    mkdir -p "$target_dir"/tests/ok
    mkdir -p "$target_dir"/tests/errors

    printf "[build]\nsource = \"main.c\"\nbin = \"hello_world\"\nmakevers = \"0.1.0\"\nautomakevers = \"0.1.0\"\ntests = \"tests\"\n[tests]\ntestsdir = \"ok\"\nerrortestsdir = \"errors\"\n[versions]\n\"0.1.0\" = \"hello_world\"\n" > "$target_dir"/bin/stego.lock

    printf "#include <stdio.h>\nint main(void) {\nprintf(\"Hello, World!\");\nreturn 0;\n}\n" > "$target_dir"/src/main.c

    printf "# ignore object files\n*.o\n# also explicitly ignore our executable for good measure\nhello_world\n# also explicitly ignore our windows executable for good measure\nhello_world.exe\n# also explicitly ignore our debug executable for good measure\nhello_world_debug\n#We also want to ignore the dotfile dump if we ever use anvil with -c flag\namboso_cfg.dot\n# MacOS DS_Store ignoring\n.DS_Store\n# ignore debug log file\ndebug_log.txt\n# ignore files generated by Autotools\nautom4te.cache/\ncompile\nconfig.guess\nconfig.log\nconfig.status\nconfig.sub\nconfigure\ninstall-sh\nmissing\naclocal.m4\nconfigure~\nMakefile\nMakefile.in\n" > "$target_dir"/.gitignore

    printf "AC_INIT([hello_world], [0.1.0], [email@example.com])\nAM_INIT_AUTOMAKE([foreign -Wall])\nAC_CANONICAL_HOST\necho \"Host os:  \$host_os\"\nAM_CONDITIONAL([OS_DARWIN], [test \"\$host_os\" = \"darwin\"])\nAM_CONDITIONAL([MINGW32_BUILD], [test \"\$host_os\" = \"mingw32\"])\nAC_ARG_ENABLE([debug],  [AS_HELP_STRING([--enable-debug], [Enable debug build])],  [enable_debug=\$enableval],  [enable_debug=no])\nAM_CONDITIONAL([DEBUG_BUILD], [test \"\$enable_debug\" = \"yes\"])\nif test \"\$host_os\" = \"mingw32\"; then\n  echo \"Building for mingw32: [\$host_cpu-\$host_vendor-\$host_os]\"\n  AC_SUBST([HW_CFLAGS], [\"-I/usr/x86_64-w64-mingw32/include -static -fstack-protector -DMINGW32_BUILD\"])\n  AC_SUBST([HW_LDFLAGS], [\"-L/usr/x86_64-w64-mingw32/lib\"])\n  AC_SUBST([CCOMP], [\"/usr/bin/x86_64-w64-mingw32-gcc\"])\n  AC_SUBST([OS], [\"w64-mingw32\"])\n  AC_SUBST([TARGET], [\"hello_world.exe\"])\nfi\nif test \"\$host_os\" = \"darwin\"; then\n  echo \"Building for macos: [\$host_cpu-\$host_vendor-\$host_os]\"\n  AC_SUBST([HW_CFLAGS], [\"-I/opt/homebrew/opt/ncurses/include\"])\n  AC_SUBST([HW_LDFLAGS], [\"-L/opt/homebrew/opt/ncurses/lib\"])\n  AC_SUBST([OS], [\"darwin\"])\n  AC_SUBST([TARGET], [\"hello_world\"])\nfi\nif test \"\$host_os\" = \"linux-gnu\"; then\n  echo \"Building for Linux: [\$host_cpu-\$host_vendor-\$host_os]\"\n  AC_SUBST([HW_CFLAGS], [\"\"])\n  AC_SUBST([HW_LDFLAGS], [\"\"])\n  AC_SUBST([OS], [\"Linux\"])\n  AC_SUBST([TARGET], [\"hello_world\"])\nfi\nAC_ARG_VAR([VERSION], [Version number])\nif test -z \"\$VERSION\"; then\n  VERSION=\"0.3.11\"\nfi\nAC_DEFINE_UNQUOTED([VERSION], [\"\$VERSION\"], [Version number])\nAC_CHECK_PROGS([CCOMP], [gcc clang])\nAC_CHECK_HEADERS([stdio.h])\nAC_CHECK_FUNCS([malloc calloc])\nAC_CONFIG_FILES([Makefile])\nAC_OUTPUT\n" > "$target_dir"/configure.ac

    printf "AUTOMAKE_OPTIONS = foreign\nCFLAGS = @CFLAGS@\nSHELL := /bin/bash\n.ONESHELL:\nMACHINE := \$\$(uname -m)\nPACK_NAME = \$(TARGET)-\$(VERSION)-\$(OS)-\$(MACHINE)\nhello_world_SOURCES = src/main.c\nLDADD = \$(HW_LDFLAGS)\nAM_LDFLAGS = -O2\nAM_CFLAGS = \$(HW_CFLAGS) -O2 -Werror -Wpedantic -Wall\nif DEBUG_BUILD\nAM_LDFLAGS += -ggdb -O0\nAM_CFLAGS += \"\"\nelse\nAM_LDFLAGS += -s\nendif\n%%.o: %%.c\n	\$(CCOMP) -c \$(CFLAGS) \$(AM_CFLAGS) $< -o \$@\n\$(TARGET): \$(hello_world_SOURCES:.c=.o)\n	@echo -e \"    AM_CFLAGS: [ \$(AM_CFLAGS) ]\"\n	@echo -e \"    LDADD: [ \$(LDADD) ]\"\n	\$(CCOMP) \$(CFLAGS) \$(AM_CFLAGS) \$(hello_world_SOURCES:.c=.o) -o \$@ \$(LDADD) \$(AM_LDFLAGS)\nclean:\n	@echo -en \"Cleaning build artifacts:  \"\n	-rm \$(TARGET)\n	-rm src/*.o\n	-rm static/*.o\n	@echo -e \"Done.\"\ncleanob:\n	@echo -en \"Cleaning object build artifacts:  \"\n	-rm src/*.o\n	-rm static/*.o\n	@echo -e \"Done.\"\nanviltest:\n	@echo -en \\\"Running anvil tests.\"\n	./anvil -tX\n	@echo -e \"Done.\"\nall: \$(TARGET)\nrebuild: clean all\n.DEFAULT_GOAL := all\n" > "$target_dir"/Makefile.am

    printf "\033[1;34m[INFO]\033[0m    Creating new repo in {\033[1;35m$target_dir\033[0m}\n"

    ( cd "$target_dir" || { printf "\033[1;31m[CRITICAL]\033[0m    cd failed for {$target_dir}.\n"; return 1 ; } ;
      git init
      [[ $quiet_flag -eq 0 ]] && printf "\033[1;32m[INFO]\033[0m    Initialised git repo\n"
      git submodule add --depth 1 "git@github.com:jgabaut/amboso.git"
      [[ $quiet_flag -eq 0 ]] && printf "\033[1;32m[INFO]\033[0m    Added amboso submodule\n"
      ln -s "amboso/amboso" "anvil"
      [[ $quiet_flag -eq 0 ]] && printf "\033[1;32m[INFO]\033[0m    Symlinked \"\033[1;34mamboso/amboso\033[0m\" to \"\033[1;35m./anvil\033[0m\"\n"
    )
    [[ $? -eq 0 ]] || printf "\033[1;31m[ERROR]\033[0m    git prep failed for {$target_dir}.\n"; return 1
    [[ $quiet_flag -eq 0 ]] && printf "\033[1;35m[INFO]\033[0m    Done init for {\033[1;36m$target_dir\033[0m\n"
}

function gen_C_headers {
	target_dir=$1
	tag=$2
	execname=$3
	headername="anvil__$execname.h"
	c_headername="anvil__$execname.c"
	tag_date=$(git show -q --clear-decorations $tag 2>/dev/null | grep Date | cut -f2 -d':')
	tag_author=$(git show -q --clear-decorations $tag 2>/dev/null | grep Author | cut -f2 -d':' | cut -f2 -d' ')
	tag_txt=$(git show -q --clear-decorations $tag 2>/dev/null | head -n1 | grep -v '^$')
	printf "\033[1;35m[AMBOSO]    Gen C header for ($execname), v($tag) to dir ($target_dir)\e[0m\n"
	printf "\033[1;35m[AMBOSO]    Reset file ($target_dir/$headername)\n"
	printf "" > "$target_dir/$headername"
	printf "\033[1;35m[AMBOSO]    Reset file ($target_dir/$c_headername)\n"
	printf "" > "$target_dir/$c_headername"
    printf "//Generated by amboso v$AMBOSO_API_LVL\n" >> "$target_dir/$headername"
    printf "//Repo at https://github.com/jgabaut/amboso\n\n" >> "$target_dir/$headername"
	printf "#ifndef ANVIL__${execname}__\n" >> "$target_dir/$headername"
	printf "#define ANVIL__${execname}__\n\n" >> "$target_dir/$headername"
	printf "static const char ANVIL__API_LEVEL__STRING[] = \"$AMBOSO_API_LVL\"; /**< Represents amboso version used for [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "static const char ANVIL__${execname}__VERSION_STRING[] = \"$tag\"; /**< Represents current version for [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "static const char ANVIL__${execname}__VERSION_DESC[] = \"$tag_txt\"; /**< Represents current version info for [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "static const char ANVIL__${execname}__VERSION_DATE[] = \"$tag_date\"; /**< Represents date for current version for [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "static const char ANVIL__${execname}__VERSION_AUTHOR[] = \"$tag_author\"; /**< Represents author for current version for [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "const char *get_ANVIL__API__LEVEL__(void); /**< Returns a version string for amboso API of [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "const char *get_ANVIL__VERSION__(void); /**< Returns a version string for [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "const char *get_ANVIL__VERSION__DESC__(void); /**< Returns a version info string for [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "const char *get_ANVIL__VERSION__DATE__(void); /**< Returns a version date string for [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "const char *get_ANVIL__VERSION__AUTHOR__(void); /**< Returns a version author string for [$headername] generated header.*/\n\n" >> "$target_dir/$headername"
	printf "#endif\n" >> "$target_dir/$headername"

    printf "//Generated by amboso v$AMBOSO_API_LVL\n\n" >> "$target_dir/$c_headername"
	printf "#include \"$headername\"\n\n" >> "$target_dir/$c_headername"
	printf "const char *get_ANVIL__VERSION__(void)\n{\n    return ANVIL__${execname}__VERSION_STRING;\n}\n\n" >> "$target_dir/$c_headername"
	printf "const char *get_ANVIL__VERSION__DESC__(void)\n{\n    return ANVIL__${execname}__VERSION_DESC;\n}\n\n" >> "$target_dir/$c_headername"
	printf "const char *get_ANVIL__VERSION__DATE__(void)\n{\n    return ANVIL__${execname}__VERSION_DATE;\n}\n\n" >> "$target_dir/$c_headername"
	printf "const char *get_ANVIL__VERSION__AUTHOR__(void)\n{\n    return ANVIL__${execname}__VERSION_AUTHOR;\n}\n\n" >> "$target_dir/$c_headername"
	printf "const char *get_ANVIL__API__LEVEL__(void)\n{\n    return ANVIL__API_LEVEL__STRING;\n}\n" >> "$target_dir/$c_headername"

}

function set_supported_tests {
  kazoj_dir=$1
  tests_filecount=0
  errors_filecount=0
  skipped=0
  i=0

  #tests loop
  cases_path="$kazoj_dir/$cases_dir"
  if [[ ! -d $cases_path ]]; then {
    printf "\033[0;33m[DEBUG]\e[0m    \"$cases_path\" was not a valid directory.\n\n"
    return 1
  }
  fi
  errorcases_path="$kazoj_dir/$errors_dir"
  if [[ ! -d $errorcases_path ]]; then {
    printf "\033[0;33m[DEBUG]\e[0m    \"$errorcases_path\" was not a valid directory.\n\n"
    return 1
  }
  fi
  for FILE in "$cases_path"/* ; do {
    [[ -e "$FILE" ]] || { printf "$FILE did not exist\n" ; continue ;}
      test_fp="$cases_path/$(basename "$FILE")"
      extens=$(printf "$(realpath "$(basename "$FILE")")\n" | cut -d '.' -f '2')
    if [[ $extens = "stderr" || $extens = "stdout" ]] ; then {
      skipped=$((skipped+1))
      [[ $verbose_flag -gt 1 && $quiet_flag -eq 0 ]] && printf "\033[0;37m[PREP-TEST]    Skip record $FILE (at $(dirname $test_fp)).\e[0m\n" >&2
      continue
    }
    fi
    if ! [[ -f $test_fp && -x $test_fp ]] ; then {
      skipped=$((skipped+1))
      [[ $verbose_flag -gt 1 && $quiet_flag -eq 0 ]] && printf "\033[0;36m[PREP-TEST]    Skip test \"$FILE\" (at $(dirname $test_fp)), not an executable.\e[0m\n" >&2
      continue
    }
    fi
    read_tests_files["$tests_filecount"]="$(basename "$FILE")"
    tests_filecount=$(($tests_filecount+1))
  }
  done
  #errors loop
  for FILE in "$errorcases_path"/* ; do {
    [[ -e "$FILE" ]] || { printf "$FILE did not exist\n" ; continue ;}
    test_fp="$errorcases_path/$(basename "$FILE")"
    extens=$(printf "$(realpath "$(basename "$FILE")")\n" | cut -d '.' -f '2')
    if [[ $extens = "stderr" || $extens = "stdout" ]] ; then {
      skipped=$((skipped+1))
      [[ $verbose_flag -gt 1 && $quiet_flag -eq 0 ]] && printf "\033[0;37m[PREP-TEST]    Skip record $FILE (at $(dirname $test_fp)).\e[0m\n" >&2
      continue
    }
    fi
    if ! [[ -f $test_fp && -x $test_fp ]] ; then {
      skipped=$((skipped+1))
      [[ $verbose_flag -gt 1 && $quiet_flag -eq 0 ]] && printf "\033[0;36m[PREP-TEST]    Skip errtest \"$FILE\" (at $(basename $test_fp)), not an executable.\e[0m\n" >&2
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
  for i in $(seq 0 $(($count_tests_names-1))); do
    supported_tests[i]=${read_tests_files[$i]}
  done
  for i in $(seq 0 $(($count_errortests_names-1))); do
    supported_tests[$(($i + $count_tests_names))]=${read_errortests_files[$i]}
  done
  tot_tests=${#supported_tests[@]}
  #echo "tot tests: $tot_tests"
}

function echo_tests_info {
  kazoj_dir="$1"
  set_supported_tests "$kazoj_dir" 2>/dev/null
  echoed_cases_dir="${tests_info[0]}"
  echoed_errors_dir="${tests_info[1]}"
  printf "\033[1;33m[DEBUG]    Tests dir is: ( $kazoj_dir ).\e[0m\n" >&2
  printf "\033[1;33m[DEBUG]    Cases dir is: ( $echoed_cases_dir ).\e[0m\n" >&2
  printf "\033[1;33m[DEBUG]      ( $count_tests_names ) cases ready.\e[0m\n" >&2
  if [[ $big_list_flag -gt 0 ]] ; then {
    for i in $(seq 0 $(($count_tests_names-1))) ; do {
      printf "\033[1;33m[DEBUG]      ( ${read_tests_files[$i]} ).\e[0m\n" >&2
    }
    done
  }
  fi
  printf "\033[1;33m[DEBUG]    Errors dir is: ( $echoed_errors_dir ).\e[0m\n" >&2
  printf "\033[1;33m[DEBUG]      ( $count_errortests_names ) error cases ready.\e[0m\n" >&2
  if [[ $big_list_flag -gt 0 ]] ; then {
    for i in $(seq 0 $(($count_errortests_names-1))) ; do {
      printf "\033[1;33m[DEBUG]      ( ${read_errortests_files[$i]} ).\e[0m\n" >&2
    }
    done
  }
  fi
  printf "\033[1;33m[DEBUG]    ( $tot_tests ) total tests ready.\e[0m\n" >&2
  #echo "$count_tests_infos"
  #echo "test info array contents are: ( ${tests_info[@]} )" >&2
}

function echo_othermode_tags {
  dir="$1"

  #Print remaining read versions not available in current mode
  if [[ $base_mode_flag -gt 0 ]] ; then {
    mode_txt="\033[1;34mgit\e[0m"
    printf "  ( $count_git_versions ) supported tags when running in ( $mode_txt ) mode.\n"
    printf "  Run again in ( $mode_txt ) mode to use them.\n"
    for i in $(seq 0 $(($count_git_versions-1))); do {
      (( $i % 4 == 0)) && [[ $i -ne 0 ]] && printf "\n"
      printf "    \033[0;33m${read_git_tags[i]}\e[0m"
    }
    done
  } else {
    mode_txt="\033[1;31mbase\e[0m"
    printf "  ( $count_base_versions ) supported tags when running in ( $mode_txt ) mode.\n"
    printf "  Run again in ( $mode_txt ) mode to use them.\n"
    for i in $(seq 0 $(($count_base_versions-1))); do {
      (( $i % 4 == 0)) && [[ $i -ne 0 ]] && printf "\n"
      printf "    \033[0;33m${read_base_tags[i]}\e[0m"
    }
    done
  }
  fi
  printf "\n"
}

function echo_supported_tags {
  mode_txt="\033[1;34mgit\e[0m"
  [[ $base_mode_flag -gt 0 ]] && mode_txt="\033[1;31mbase\e[0m"
  dir="$1"
  printf "  ( $tot_vers ) supported tags for current mode ( $mode_txt ).\n"
  for i in $(seq 0 $(($tot_vers-1))); do { #Print currently supported versions (only ones conforming to mode)
    (( $i % 4 == 0)) && [[ $i -ne 0 ]] && printf "\n"
    printf "    \033[1;32m${supported_versions[i]}\e[0m"
  }
  done
  printf "\n"
}

function git_mode_check {
  is_git_repo=0
  #Check if we're inside a repo
  git rev-parse --is-inside-work-tree 2>/dev/null 1>&2
  is_git_repo="$?"
  [[ $is_git_repo -gt 0 ]] && printf "\n\033[1;31m[ERROR]    Not running in a git repo. Try running with -B to use base mode.\e[0m\n\n" && exit 1
  [[ $verbose_flag -gt 0 ]] && printf "\033[1;34m[MODE]    Running in git mode.\e[0m\n" >&2
  #Check if status is clean
  if output=$(git status --untracked-files=no --porcelain) && [ -z "$output" ]; then
	  return 0
  else
	return 1
  fi
}

function amboso_help {
  amboso_usage
  printf "Arguments:

  [-D ...]    BINDIR    Sets directory used to host tags

      [-K ...]    TESTDIR    Sets directory used to host tests

  [-S ...]    SOURCENAME    Sets name for target main source

  [-E ...]    EXECNAME    Sets name for target executable

    [-M ...]    MAKETAG    Sets minimum tag for using make as build/clean step

    [-C ...]    CONFIG_FILE    Filename for ./configure args for automake

    [-G ...]    C_HEADER_DIR    Sets desidered output directory for C header of specified version

  [-tgBT]    mode    Sets run mode

        Building:

    -g    git mode    (Default)

    -B    base mode    (Expects a full source copy of every tag. Not recommended.)

        Testing:

    -T    test mode    (Tests TAG_QUERY)

    -t    test macro    (Recurses as -T\"\$PASSED_FLAGS\" on all tests)

        Extra:

    -x  <stego file>    stego parser    (Runs amboso as stego parser)

    -V  <[0-3]>           Set verbose level

        Optional:

          -l    Lint    (Only lint the stego file)
          -L    Lint    (Only lint the stego file)

  [-bripd]    operation    Combined operations on current tag.

          The operation changes semantics in test mode.

      In the order they are consumed from a top call:

    -i    init    (Recurses as -b\"\$MODE_FLAG\"\"\$PASSED_FLAGS\" on all tags for current build mode)
                  (TEST: record all test results)

    -b    build    Build TAG_QUERY
                  (TEST: record TAG_QUERY test results. If using -t for the macro, it's the same as -i)

    -r    run    Run TAG_QUERY (ATM unused in test mode)

    -d    delete    Delete TAG_QUERY (ATM unused in test mode)

    -p    purge    (Recurses as -b\"\$MODE_FLAG\"\"\$PASSED_FLAGS\" on all tags for current build mode)

  [-hHvVlLqc]    info    Change text output for the program.

    -hH    help    Prints help info
    -v    version    Prints current version and quits
    -lL    list    Lists all valid tags (-L ignores current build mode to check for tags)
    -q    quiet    Less output (useful but not well implemented, recommended on recursive calls)
    -s    silent    Way less output (Some output expected on stderr before the flag is applied)
    -c    control    Output dotfile \'amboso_cfg.dot\' while running.
    -w    watch    Always display timers regardless of verbosity.
    -X    experimental    Ignore the result of git_mode_check, which would stop git mode runs early when git status is not clean.
    -Y [...] START_TIME    Set start time of the program.
    -W     Warranty    Prints warranty information, as per GPL-3.0 license.

  [...]    TAG_QUERY    Ask a tag for current mode

        Reports if target executable name for TAG_QUERY was found at BINDIR/vTAG_QUERY/EXECNAME.\n"

}

function amboso_usage {
  printf "Usage:  $(basename "$prog_name") [(-D|-K|-M|-S|-E|-G|-C|-x|-V|-Y) ...ARGS] [-TBtg] [-bripd] [-hHvlLqcwXW] [TAG_QUERY]\n"
  printf "    Query for a build version ( or stego files parser, with -x).\n"
}

function escape_colorcodes_tee {
  file="$1"
  outfile="$2"
  printf "" >"$outfile"
  #sed -r 's/\/\\3/g' "$file"
  #sed -e 's/\\033\[/COLOR[/g' -e 's/COLOR\[1;3/"<colorTag[Heavy,/g' -e 's/COLOR\[0;3/"<colorTag[Light,/g' -e 's/\\e\[0m/\]>"/g' "$file" >>"$outfile"
  #sed 's/\x1B\[\([0-9]\{1,2\}\(;[0-9]\{1,2\}\)\?\)\?[mGK]//g' <"$file"
  cat "$file" | tee "$outfile"
}

function escape_colorcodes {
  file="$1"
  outfile="$2"
  printf "" >"$outfile"
  #sed -r 's/\/\\3/g' "$file"
  #sed -e 's/\\033\[/COLOR[/g' -e 's/COLOR\[1;3/"<colorTag[Heavy,/g' -e 's/COLOR\[0;3/"<colorTag[Light,/g' -e 's/\\e\[0m/\]>"/g' "$file" >>"$outfile"
  #sed 's/\x1B\[\([0-9]\{1,2\}\(;[0-9]\{1,2\}\)\?\)\?[mGK]//g' <"$file"
  cat -e "$file" >"$outfile"
}

function record_test {
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
  rm -f "$tmp_stdout" || printf "\033[1;31m[ERROR]    Failed removing tmpfile ($tmp_stdout). Why?\n\n"
  [[ $verbose_flag -gt 0 ]] && printf "\033[0;32m[TEST]    Removed tempfile \"$tmp_stdout\".\e[0m\n" >&2
  rm -f "$tmp_stderr" || printf "\033[1;31m[ERROR]    Failed removing tmpfile ($tmp_stderr). Why?\n\n"
  [[ $verbose_flag -gt 0 ]] && printf "\033[0;32m[TEST]    Removed tempfile \"$tmp_stderr\".\e[0m\n" >&2
}

function run_test {
  tfp="$1" # test_file_path
  #echo -en "\033[1;36m"
  "$tfp"
  res="$?"
  #echo -en "\e[0m"
  return "$res"

}

function delete_test {
  #WIP
  tfp="$1" # test_file_path
  (
    printf "deleting $tfp\n" 2>/dev/null
    exit "$?"
  )
  res="$?"

  if [[ $res -eq 0 ]]; then {
    printf "\033[0;32m[TEST]    Deleted $tfp.\e[0m\n" >&2
  } else {
    printf "\033[1;31m[TEST]    Failed deleting $tfp. How?\e[0m\n" >&2
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
      printf "\033[1;31m[ERROR]    ${FUNCNAME[0]}(): \"$1\" is not a valid file.\033[0m\n."
      exit 8
    }
    fi
    input_file="$1"
    # Check if awk is available
    if ! command -v awk > /dev/null; then
        printf "\033[1;31m[CRITICAL]    Error: awk is not installed. Please install awk before running this script.\033[0m\n"
        exit 9
    fi

    awk '{
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
                print "\033[1;31m[LINT]\033[0m    Invalid header:    \033[1;31m" $0 "\033[0m" > "/dev/stderr"
                error_flag=1
            }
        } else if ($0 ~ /^"?[^"A-Z=\[\]_\$\\\/{}]+"? *= *"[^=\[\]\${}]+"$/) {
            # Check if the line is a valid variable assignment

            split($0, parts, "=")
            variable=gensub(/^ *"?([^"]+)"? *$/, "\\1", "g", parts[1])
            value=gensub(/^ *"?([^"]*)"? *$/, "\\1", "g", parts[2])

            # Trim trailing whitespaces from variable and value
            gsub(/[ \t]+$/, "", variable)
            gsub(/[ \t]+$/, "", value)

            # Check if left side contains disallowed characters
            if (index(variable, " ") > 0 || (index(variable, "#") > 0 && index(variable, "\"") == 0)) {
                print "\033[1;31m[LINT]\033[0m    Invalid left side (contains spaces or disallowed characters):    \033[1;31m" variable "\033[0m" > "/dev/stderr"
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
                    print "\033[1;31m[LINT]\033[0m    Invalid line:    \033[1;31m" $0 "\033[0m" > "/dev/stderr"
                    error_flag=1
                }
        }
    } END {
        if (error_flag == 1) {
                print "\033[1;31m[LEX]\033[0m    Errors while lexing." > "/dev/stderr"
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

lint_stego_file() {
  #Try lexing input file. If verbose is 1, print the lexed tokens.
  #If lex output is empty, return 1.
  if [[ ! -f $1 ]] ; then {
    printf "\033[1;31m[ERROR]    ${FUNCNAME[0]}(): \"$1\" is not a valid file.\033[0m\n."
    exit 8
  }
  fi

  input="$1"
  verbose="$2"

  lex_output="$(lex_stego_file "$input")"
  [[ $verbose -eq 1 ]] && printf "$lex_output\n"
  if [[ -z "$lex_output" ]]; then
    printf "\033[1;31m[CHECK]\033[0m    Errors occurred during lexing.\n"
    return 1
  fi
  return 0
}

try_parsing_stego() {
  # Lints the passed file. If verbose if passed as "1", also prints the lexed tokens to stdout.
  # Then, if the lint was successful, tries parsing the lexed tokens.
  # Upon return, arrays "scopes", "variables", "values" are set.
  if [[ ! -f $1 ]] ; then {
    printf "\033[1;31m[ERROR]    ${FUNCNAME[0]}(): \"$1\" is not a valid file.\033[0m\n."
    exit 8
  }
  fi
  input="$1"
  verbose="$2"
  lexed_tokens="$(lex_stego_file "$input")"
  if [[ ! -z $lexed_tokens ]]; then {
    parse_lexed_stego "$lexed_tokens"
    parse_res="$?"
    return "$parse_res"
  } else {
    printf "\033[1;31m[PARSE]\033[0m    Lint failed.\n"
    return 1
  }
  fi
}

bash_gulp_stego() {
  # Try gulping the "scopes", "variables" and "values" bash arrays from parsing the passed file
  if [[ ! -f $1 ]] ; then {
    printf "\033[1;31m[ERROR]    ${FUNCNAME[0]}(): \"$1\" is not a valid file.\033[0m\n"
    exit 8
  }
  fi

  input="$1"
  filename="$input"
  verbose="$2"
  try_parsing_stego "$input" "$verbose"
  parse_res="$?"
  if [[ $parse_res -eq 0 ]]; then {
    [[ $verbose -eq 1 ]] && printf "\033[1;32m[SUCCESS]    Parsed file \"$filename\"\033[0m\n"
    [[ $verbose -eq 1 ]] && printf "\033[1;36m[Lexed variables]\033[0m    { ${variables[*]} }\n\n"
    [[ $verbose -eq 1 ]] && printf "\033[1;35m[Lexed values]\033[0m    { ${values[*]} }\n"
    return 0
  } else {
    printf "\033[1;31m[ERROR]\033[0m    ${FUNCNAME[0]}(): Failed parsing file { \033[1;34m$1\033[0m }\n"
    return 1
  }
  fi
}

print_amboso_stego_scopes() {
  for ((i=0; i<${#scopes[@]}; i++)); do
  scope="${scopes[i]}"
  variable="${variables[i]}"
  value="${values[i]}"
  is_noscope=0
  if [[ -z $scope ]] ; then {
    is_noscope=1
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
        if [[ $tag == -* ]] ; then {
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
    printf "\033[1;31m[ERROR]    Failed parsing stego file at \"$stego_file\".\033[0m\n"
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
  is_noscope=0
  if [[ -z $scope ]] ; then {
    is_noscope=1
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
        if [[ $tag == -* ]] ; then {
          [[ $verbose -gt 0 ]] && printf "ANVIL_BASE_VERSION: {$tag}\n"
          cut_tag="$(printf -- "$tag\n" | cut -f2 -d'-')"
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
    }
    fi
  }
  fi
  done
  count_source_infos="${#sources_info[@]}"
  if [[ -z $exec_entrypoint ]] ; then {
      printf "\033[1;31m[ERROR]    Missing binary name.\033[1;31m\n"
      exit 1
  }
  fi
  if [[ -z $source_name ]] ; then {
      printf "\033[1;31m[ERROR]    Missing source name.\033[1;31m\n"
      exit 2
  }
  fi
  if [[ -z $makefile_version ]] ; then {
      printf "\033[1;31m[ERROR]    Missing first version using make.\033[1;31m\n"
      exit 3
  }
  fi
  if [[ -z $use_automake_version ]] ; then {
      printf "\033[1;31m[ERROR]    Missing first version using automake.\033[1;31m\n"
      exit 4
  }
  fi
  if [[ -z $use_autoconf_version ]] ; then {
      printf "\033[1;31m[ERROR]    Missing first version using autoconf.\033[1;31m\n"
      exit 5
  }
  fi
  if [[ -z $kazoj_dir ]] ; then {
      printf "\033[1;31m[ERROR]    Missing tests dir.\033[1;31m\n"
      exit 6
  }
  fi
  [[ $verbose -gt 0 ]] && printf "\033[1;34m[INFO]    Read {$count_source_infos} amboso params.\033[0m\n"

  count_git_versions="${#read_git_tags[@]}"
  count_base_versions="${#read_base_tags[@]}"
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
    for i in $(seq 0 $(($count_base_versions-1))); do
      supported_versions[i]=${read_base_tags[$i]}
    done
  } else {
    for i in $(seq 0 $(($count_git_versions-1))); do
      supported_versions[i]=${read_git_tags[$i]}
    done
  }
  fi
  tot_vers=${#supported_versions[@]}
  latest_version="${supported_versions[tot_vers-1]}"
  [[ $verbose -gt 0 ]] && printf "\033[1;34m[INFO]    Read {$tot_vers} tags.\033[0m\n"
  return 0
}

amboso_parse_args() {
  export AMBOSO_LVL_REC="${AMBOSO_LVL_REC:-0}"
  #Increment depth counter
  AMBOSO_LVL_REC=$(($AMBOSO_LVL_REC+1))
  # check recursion
  if [[ "${AMBOSO_LVL_REC}" -le "3" ]]; then
    PARENT_COMMAND=$(ps -o comm= $PPID)
    [[ $PARENT_COMMAND = "$prog_name" ]] && printf "Unexpected result while checking amboso recursion level.\n" && exit 1
  else
    printf "\n[AMBOSO]    Exceeded depth for recursion ( nested ${AMBOSO_LVL_REC} times).\n\n"
    echo_timer "$amboso_start_time"  "Excessive recursion" "1"
    exit 69
  fi
  #Functions to output dotfile
  dotfile="./amboso_cfg.dot"
  function app() {
    [[ $print_cfg_flag -eq 0 || ${AMBOSO_LVL_REC} -gt 1 ]] && return
    txt="$1" file="$dotfile"
    printf "$txt\n" >> "$file"
  }
  function echo_node() {
    frm="$1" nd="$2"
    printf " $frm -> $nd \n"
  }
  function echo_start_node() {
    sn="$1"
    printf " $sn ->\n"
  }
  function start_digraph() {
    app "digraph {"
  }
  function end_digraph() {
    app "}"
  }


  #Prepare flag values to default value
  amboso_version="amboso version $amboso_currvers"
  purge_flag=0
  run_flag=0 #By default we don't run the binary
  build_flag=0
  delete_flag=0
  init_flag=0
  verbose_flag=0
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
  print_cfg_flag=0
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
  autoconf_arg_file=""

  while getopts "A:M:S:E:D:K:G:Y:x:V:C:wBgbpHhrivdlLtTqsczUXW" opt; do
    case $opt in
      C )
        pass_autoconf_arg_flag=1
        autoconf_arg_file="$OPTARG"
        [[ -f "$autoconf_arg_file" ]] || { printf "\033[1;31m[ERROR]\033[0m    Invalid file for configure argument: {\033[1;33m%s\033[0m}\n" "$autoconf_arg_file" ; exit 1 ; } ;
        ;;
      x )
        be_stego_parser_flag=1
        queried_stego_filepath="$OPTARG"
        ;;
      W )
        show_warranty_flag=1
        ;;
      X )
        ignore_git_check_flag=1
        ;;
      G )
        gen_C_headers_flag=1
        gen_C_headers_destdir="$OPTARG"
        if [[ ! -d $gen_C_headers_destdir ]] ; then {
            printf "\033[1;33m[WARN]    ($gen_C_headers_destdir) was not a valid directory.\e[0m\n"
            gen_C_headers_set=1 #TODO: this reads horribly. It's a patch to allow the called function to still be called, since now it will try to make the directory
        } else {
                gen_C_headers_set=1
        }
        fi
        ;;
      U )
        tell_uname_flag=1
        ;;
      c )
        print_cfg_flag=1
        ;;
      z )
        pack_flag=1
        ;;
      s )
        silent_flag=1
        ;;
      S )
        source_name="$OPTARG"
        sourcename_was_set=1
        ;;
      w )
        show_time_flag=1
        ;;
      Y )
        start_time_val="$OPTARG"
        amboso_start_time="$start_time_val"
        start_time_set=1
        start_time_flag=1
        ;;
      E )
        exec_entrypoint="$OPTARG"
        exec_was_set=1
        ;;
      D )
        dir_flag=1
        milestones_dir="$OPTARG"
        ;;
      K )
        testdir_flag=1
        kazoj_dir="$OPTARG"
        test_info_was_set=1
        ;;
      M )
        vers_make_flag=1
        makefile_version="$OPTARG"
        ;;
      A )
        vers_autoconf_flag=1
        use_autoconf_version="$OPTARG"
        ;;
      L )
        big_list_flag=1
        ;;
      l )
        small_list_flag=1
        ;;
      H )
        bighelp_flag=1
        ;;
      h )
        smallhelp_flag=1
        ;;
      B )
        base_mode_flag=1
        ;;
      g )
        git_mode_flag=1
        ;;
      t )
        small_test_mode_flag=1
        ;;
      T )
        test_mode_flag=1
        ;;
      V )
        requested_lvl="$OPTARG"
        verbose_lvl_re='^[0-9]$'
        if ! [[ $requested_lvl =~ $verbose_lvl_re ]]; then {
            printf "\033[1;31m[ERROR]\033[0m    Invalid verbose lvl: {%s}\n" "$requested_lvl"
            return 1
        } else {
            verbose_flag="$requested_lvl"
        }
        fi
        ;;
      q )
        quiet_flag=1
        ;;
      v )
        version_flag=$(($version_flag+1))
        ;;
      p )
        purge_flag=1
        ;;
      r )
        run_flag=1
        ;;
      b )
        build_flag=1
        ;;
      d )
        delete_flag=1
        ;;
      i )
        init_flag=1
        ;;
      \? )
        printf "Invalid option: -$OPTARG. Run with -h for help.\n" >&2
        exit 1
        ;;
      : )
        printf "Option -$OPTARG requires an argument. Run with -h for help.\n" >&2
        exit 1
        ;;
    esac
  tot_opts=$OPTIND
  done

  if [[ $quiet_flag -eq 0 && "${AMBOSO_LVL_REC}" -lt 3 ]]; then {
    printf "amboso, version $amboso_currvers\nCopyright (C) 2023  jgabaut\n\n  This program comes with ABSOLUTELY NO WARRANTY; for details type \`$(basename $prog_name) -W\`.\n  This is free software, and you are welcome to redistribute it\n  under certain conditions; see file \`LICENSE\` for details.\n\n  Full source is available at https://github.com/jgabaut/amboso\n\n"
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
        printf "\033[1;31m[WARN]    Bash version: {$BASH_VERSION} is less than 4\e[0m\n\n"
        printf "\033[1;31m[WARN]    amboso may not work as expected.\n\n"
    }
    fi
  }
  fi

  if [[ $print_cfg_flag -gt 0 ]] ; then {
    #Reset output file
    printf "" > "$dotfile"
    #Print opening digraph
    start_digraph
    start_node="start"
    #Unnecessary?
    #app "$( echo_start_node "$start_node" )"

    app "$( echo_node "$start_node" begin_node )"
  }
  fi

  [[ $verbose_flag -gt 1 ]] && printf "\033[0;32m[PREP]    Done getopts.\e[0m\n" >&2
  [[ $verbose_flag -gt 0 && ! $prog_name = "anvil" ]] && printf "\033[1;36m[AMBOZO]\e[0m    Please, symlink me to \"anvil\".\n\n" >&2

  # Load functions from amboso_fn.sh
  #source_amboso_api

  [[ $verbose_flag -gt 1 ]] && printf "\033[0;32m[PREP]    Printing active flags:\e[0m\n" >&2 && echo_active_flags >&2
  main_at=369
  #PROG_START_LINE
  prog_start_line="369"
  trace_flag=0
  trace_line="421"
  # Check env var to enable backtrace
  export AMBOSO_TRACING="${AMBOSO_TRACING:-0}"
  if [[ ${AMBOSO_TRACING} -gt 0 ]]; then {
    trace_line=0
    trace_flag=1;
    printf "\033[0;37m[TRACE]    Tracing started.\e[0m\n" >&2
    trap backtrace DEBUG ERR
  } else {
    : #echo "{No trace}" >&2
  }
  fi

  [[ $verbose_flag -gt 1 ]] && printf "\033[0;37m[PREP]    Parent command is: ( $PARENT_COMMAND ).\e[0m\n" >&2


  #Won't print call info for top level calls
  if [[ ${AMBOSO_LVL_REC} -gt 1 ]] ; then {
  #and 1+ nested test calls ( with -T, from -t calling -T)
    [[ $quiet_flag -eq 0 && $verbose_flag -gt 0 ]] && printf "\033[1;34m[AMBOSO]    Amboso depth: ( $((${AMBOSO_LVL_REC}-1)) )\e[0m\n"
    if [[ $AMBOSO_LVL_REC -lt 2 ]] ; then {
      printf "\n\n        args: (\"$*\")\n" >&2
      echo_active_flags >&2
    } elif [[ $AMBOSO_LVL_REC -gt 2 ]] ; then {
      [[ $test_info_was_set -eq 1 ]] && printf "[AMBOSO]    Deep recursion (>1), are you calling \"$prog_name\" in a test? ;)\n" >&2
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

      [[ -f "$filepath" ]] || { printf "\033[1;31m[ERROR]\033[0m    \"$filepath\" was not a valid file.\n" ; exit 1 ; }

      if [[ $big_list_flag -eq 1 ]] ; then {
          lex_stego_file "$filepath"
          exit $?
      } elif [[ $small_list_flag -eq 1 ]] ; then {
          lint_stego_file "$filepath" 0 # We call with verbose ($2) 0, and won't get the lexed tokens printed.
          lint_res="$?"
          if [[ $lint_res -eq 0 ]]; then {
            printf "\033[1;36m[LINT]\033[0m    { Success on: \"$filepath\" }\n"
            exit 0
          } else {
            printf "\033[1;31m[LINT]\033[0m    { Failure on: \"$filepath\" }\n"
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

  if [[ $version_flag -eq 1 ]] ; then {
    echo_amboso_version_short
    echo_timer "$amboso_start_time"  "Version flag, 1" "2"
    exit 0
  } elif [[ $version_flag -gt 1 ]] ; then {
    echo_amboso_version
    echo_timer "$amboso_start_time"  "Version flag, >1" "2"
    exit 0
  }
  fi

  [[ "$verbose_flag" -gt 1 ]] && printf "\033[1;35m[AMBOSO]    Current version: $amboso_currvers\e[0m\n\n"

  [[ $quiet_flag -eq 0 && $verbose_flag -gt 0 ]] && for read_arg in "$@"; do { printf "[ARG]    \"$read_arg\"\n" ; } ; done

  app "$(echo_node loaded_fn silence_check)"

  #We check if we have to silence all subsequent output
  if [[ ( $test_mode_flag -eq 0 && $small_test_mode_flag -eq 0 ) && $silent_flag -gt 0 ]] ; then {
    printf "\033[1;33m[MODE]\e[0m    Running in silent mode, will now suppress all output.\n\n"
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
    printf "\033[1;33m[MODE]    Running in test mode.\e[0m\n" >&2
  }
  fi

  #We check again if basemode was requested, as the only flag checked in build stage is git_mode_flag
  #If base_mode_flag is asserted, we always override git_mode_flag

  #Default mode with no flags should be git mode
  if [[ $base_mode_flag -gt 0 ]] ; then {
    git_mode_flag=0
    printf "\033[1;31m[MODE]    Running in base mode, expecting full source builds.\e[0m\n" >&2
  }
  fi
  if [[ $git_mode_flag -gt 0 && $be_stego_parser_flag -eq 0 ]] ; then {
      # We skip git mode check if we're going to be stego parser.
    git_mode_check
    git_mode_check_res="$?"
    if [[ $git_mode_check_res -eq 0 ]]; then {
      [[ $verbose_flag -gt 0 ]] && printf "\033[1;33m[GIT]    Status was clean.\e[0m\n" >&2
    } else {
      [[ $verbose_flag -gt 0 || $quiet_flag -eq 0 ]] && printf "\033[1;31m[GIT]    Status was not clean!\e[0m\n" >&2
          if [[ $ignore_git_check_flag -eq 0 ]]; then {
        [[ $verbose_flag -gt 0 || $quiet_flag -eq 0 ]] && printf "\033[1;31m[AMBOSO]    Aborting.\e[0m\n" >&2
            echo_timer "$amboso_start_time"  "Dirty git status" "1"
        return 1
      }
      fi
      [[ $verbose_flag -gt 0 || $quiet_flag -eq 0 ]] && printf "\033[1;35m[AMBOZO]    We ignore this and will waste time.\e[0m\n" >&2
    }
    fi
  }
  fi

  #We always notify of missing -D argument
  [[ ! $dir_flag -gt 0 ]] && milestones_dir="./bin/" && printf "\033[1;33m[DEBUG]    No -D flag, using ( $milestones_dir ) for target dir. Run with -V <lvl> to see more.\e[0m\n" >&2 #&& usage && exit 1


  #We always notify of missing -K argument, if in test mode
  if [[ $test_mode_flag -gt 0 && ! $testdir_flag -gt 0 ]] ; then {
    set_amboso_stego_info "$milestones_dir/stego.lock" "$verbose_flag"
    res="$?"
    [[ $res -eq 0 ]] || printf "\033[0;33m[WARN]\e[0m    Problems when doing set_amboso_stego_info($kazoj_dir).\n\n"
    set_supported_tests "$kazoj_dir"
    res="$?"
    [[ $res -eq 0 ]] || printf "\033[0;33m[WARN]\e[0m    Problems when doing set_supported_tests($kazoj_dir).\n\n"
    kazoj_dir="$(pwd)/kazoj/"
    [[ $quiet_flag -eq 0 ]] && printf "\033[1;33m[DEBUG]    No -K flag, using ( $kazoj_dir ) for target dir. Run with -V <lvl> to see more.\e[0m\n" >&2 #&& usage && exit 1
  }
  fi
  if [[ $test_mode_flag -gt 0 && $test_info_was_set -gt 0 ]] ; then {
    if [[ $AMBOSO_LVL_REC -lt 3 ]] ; then {
      app "$(echo_node silence_check test_mode)"
      app "$(echo_node test_mode recursion_lt_3)"
      printf "\033[1;32m[DEBUG]    bone dir: ( $cases_dir )\e[0m\n" >&2
      printf "\033[1;32m           kulpo dir: ( $errors_dir )\e[0m\n" >&2 #&& usage && exit 1
    } else {
      app "$(echo_node silence_check test_mode)"
      app "$(echo_node test_mode recursion_ge_3)"
      app "$(echo_node recursion_ge_3 end_node)"
      end_digraph
      [[ ! -z $cases_dir ]] && printf "\033[1;32m[DEBUG]    bone dir: ( $cases_dir )\e[0m\n" >&2
      [[ ! -z $errors_dir ]] && printf "\033[1;32m           kulpo dir: ( $errors_dir )\e[0m\n" >&2 #&& usage && exit 1
      printf "\n\033[1;31m[PANIC]    Running  as \"$prog_name\" in test mode is not supported. Quitting with 69.\e[0m\n\n" #&& usage && exit 1
      echo_timer "$amboso_start_time"  "Test calling \"$(basename $prog_name)\" in test mode to run a test with..." "1"
      exit 69
      #We return 69 and will check for this somewhere
    }
    fi
  } elif [[ $test_info_was_set -eq 0 && $test_mode_flag -gt 0 ]] ; then {
      app "$(echo_node silence_check test_mode)"
      app "$(echo_node test_mode no_test_info)"
    if [[ $AMBOSO_LVL_REC -lt 3 ]] ; then {
      app "$(echo_node no_test_info recursion_lt_3)"
      printf "\033[1;33m[DEBUG]    bone dir (NO -K passed to this call): ( $cases_dir )\e[0m\n" >&2
      printf "\033[1;33m           kulpo dir (NO -K passed to this amboso call): ( $errors_dir )\e[0m\n" >&2 #&& usage && exit 1
    } else {
      app "$(echo_node no_test_info recursion_ge_3)"
      app "$(echo_node recursion_ge_3 end_node)"
      end_digraph
      #Deep case: we're running a test, calling a program that calls amboso in test mode.
      printf "\033[1;33m[DEBUG]    bone dir (NO -K passed to this call): ( $cases_dir )\e[0m\n" >&2
      printf "\033[1;33m           kulpo dir (NO -K passed to this amboso call): ( $errors_dir )\e[0m\n" >&2 #&& usage && exit 1

      printf "\n\033[1;31m[PANIC]    Running  \"$(basename $prog_name)\" using test mode in a program that will be called by test mode is not supported.\e[0m\n\n" >&2 #&& usage && exit 1
      echo_timer "$amboso_start_time"  "Test calling \"$(basename $prog_name)\" in test mode to run a test with..." "1"
      exit 1
    }
    fi
  }
  fi

  #Check if we are printing help info and exiting early
  if [[ $smallhelp_flag -gt 0 ]]; then {
      app "$(echo_node silence_check doing_help)"
      app "$(echo_node doing_help end_node)"
      end_digraph
    if [[ $AMBOSO_LVL_REC -gt 1 ]] ; then {
      printf "[AMBOSO]    can't ask for help on a recursive call, try running \"$prog_name -h\" from a shell. ( depth $((${AMBOSO_LVL_REC}-1)) )\n\n        args: (\"$*\")\n" >&2
      echo_timer "$amboso_start_time"  "Recursive help?" "1"
      exit 1
    }
    fi
    echo_amboso_version
    amboso_usage

    printf "Try running with with -H for more info.\n\n"
    #"$prog_name" -H -D "$milestones_dir" | less
    echo_timer "$amboso_start_time"  "Show help" "2"
    exit 0
  }
  fi
  #Check if we are printing Help info and exiting early
  if [[ $bighelp_flag -gt 0 ]]; then {
      app "$(echo_node silence_check doing_big_help)"
      app "$(echo_node doing_big_help end_node)"
      end_digraph
    if [[ $AMBOSO_LVL_REC -gt 1 ]] ; then {
      printf "[AMBOSO]    can't ask for help on a recursive call, try running \"$prog_name -H\" from a shell. ( depth $((${AMBOSO_LVL_REC}-1)) )\n\n        args: (\"$*\")\n" >&2
      echo_timer "$amboso_start_time"  "Recursive bighelp?" "1"
      exit 1
    }
    fi
    echo_amboso_version
    amboso_help
    echo_timer "$amboso_start_time"  "Show big help" "2"
    exit 0
  }
  fi

  #Syncpoint: we assert we know these names after this. WIP

  #TODO: check if scripts_dir is needed anywhere... why
  scripts_dir="$milestones_dir" # MUST BE SET before checking for -S and -E
  set_amboso_stego_info "$milestones_dir/stego.lock" "$verbose_flag"
  if [[ ! $? -eq 0 ]] ; then {
    printf "\033[1;31m[CRITICAL]    Could not set amboso stego info.\033[0m\n"
    exit 1
  }
  fi

  # LEGACY
  #      set_supported_versions "$scripts_dir" # Might as well do it now
  #      set_source_info "$milestones_dir"
  #      kazoj_dir="${sources_info[3]}" #TODO: don't think this should be overwritten here if assigned earlier
  #      use_automake_version="${sources_info[4]}"
  #      set_tests_info "$kazoj_dir"
  set_supported_tests "$kazoj_dir"

  if [[ $verbose_flag -gt 1 ]]; then {
      printf "\033[1;36m[FETCH]    Fetching remote tags\e[0m\n" >&2
      echo_tag_info $version
  }
  fi

  if [[ $verbose_flag -gt 1 ]]; then { #WIP
      printf "\033[1;35m[VERB]    SYNCPOINT:  listing tag names\e[0m\n" >&2
      echo_supported_tags "$milestones_dir" >&2
      echo_tests_info "$kazoj_dir" >&2
  }
  fi

  #If we're in test mode and test dir was not set, we check if "./kazoj" is a directory and use that. If it isn't, we may get the name from stego.lock. If that is not a directory, we quit immediately.
  if [[ -z $kazoj_dir && $test_mode_flag -gt 0 ]] ; then {

    #TODO Do we need to do further checks for amboso_testflag_version?
    printf "\033[1;31m[ERROR]    kazoj_dir was not set, while in test mode.\033[0m\n"
    exit 3

    # LEGACY
    #
    #if [[ "$amboso_currvers" > "$amboso_testflag_version" || "$amboso_currvers" = "$amboso_testflag_version" ]] ; then {
    #   if [[ -d "./kazoj" ]]; then {
    #     kazoj_dir="./kazoj"
    #     set_tests_info "$kazoj_dir"
    #     set_supported_tests "$kazoj_dir"
    #     [[ $quiet_flag -eq 0 || $verbose_flag -gt 0 ]] && printf "\033[1;33m[DEBUG]  No -K flag on a test run (amboso > $amboso_testflag_version), using \"./kazoj\" as tests dir.\e[0m\n" >&2
    #   } else {
    #     [[ $quiet_flag -eq 0 || $verbose_flag -gt 0 ]] && printf "\033[1;33m[DEBUG]  No -K flag on a test run (amboso > $amboso_testflag_version), reading stego.lock.\e[0m\n" >&2
    #     set_supported_tests "$kazoj_dir"
    #     [[ $quiet_flag -eq 0 || $verbose_flag -gt 0 ]] && printf "\033[1;33m[DEBUG]  No -K flag on a test run (amboso > $amboso_testflag_version), reading stego.lock.\e[0m\n" >&2
    #   }
    #   fi
    #} else {
    #   printf "\033[1;31m[ERROR]    No -K flag on a test run, amboso version is < ($amboso_testflag_version).\n    Quitting.\e[0m\n" #>&2
    #   echo_timer "$amboso_start_time"  "No -K on test run" "3"
    #   exit 0
    #}
    #fi
    #
  }
  fi

  #Check if we are printing tag list for current mode and exiting early
  if [[ $small_list_flag -gt 0 ]]; then {
    if [[ $git_mode_flag -gt 0 || $base_mode_flag -gt 0 ]] ; then {
      echo_supported_tags "$milestones_dir"
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
      echo_supported_tags "$milestones_dir"
      echo_othermode_tags "$milestones_dir"
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
    [[ $verbose_flag -gt 0 || $quiet_flag -eq 0 ]] && printf "\033[1;31m[ASSERT-FALSE]    makefile_version was empty.\e[0m\n" >&2
    exit 1
  }
  fi

  #We notify of missing -E argument if we're in verbose mode or not in quiet mode
  if [[ -z $exec_entrypoint ]] ; then {
    [[ $verbose_flag -gt 0 || $quiet_flag -eq 0 ]] && printf "\033[1;31m[ASSERT-FALSE]    exec_entrypoint was empty.\e[0m\n" >&2
    exit 1
  }
  fi

  #We notify of missing -S argument if we're in verbose mode or not in quiet mode
  if [[ -z $source_name ]] ; then {
    [[ $verbose_flag -gt 0 || $quiet_flag -eq 0 ]] && printf "\033[1;31m[ASSERT-FALSE]    source_name was empty.\e[0m\n" >&2
    exit 1
  }
  fi

  #We notify of missing -A argument if we're in verbose mode or not in quiet mode
  if [[ -z $use_autoconf_version ]] ; then {
    [[ $verbose_flag -gt 0 || $quiet_flag -eq 0 ]] && printf "\033[1;31m[ASSERT-FALSE]    use_autoconf_version was empty.\e[0m\n" >&2
    exit 1
  }
  fi

  #Display needed values if in verbose mose
  [[ $verbose_flag -gt 0 || $quiet_flag -eq 0 ]]  && [[ ! $dir_flag -gt 0 ]] && printf "\033[0;32m[INFO]    Using target dir: ( $scripts_dir ).\e[0m\n" >&2
  [[ $verbose_flag -gt 0 || $quiet_flag -eq 0 ]] && [[ ! $exec_was_set -gt 0 ]] && printf "\033[0;32m[INFO]    Using target bin: ( $exec_entrypoint ).\e[0m\n" >&2
  [[ $verbose_flag -gt 0 || $quiet_flag -eq 0 ]] && [[ ! $sourcename_was_set -gt 0 ]] && printf "\033[0;32m[INFO]    Using source file name: ( $source_name ).\e[0m\n" >&2
  [[ $verbose_flag -gt 0 || $quiet_flag -eq 0 ]] && [[ ! $vers_make_flag -gt 0 ]] && printf "\033[0;32m[INFO]    Using tag for make support: ( $makefile_version ) as first tag compiled with make.\e[0m\n" >&2
  [[ $verbose_flag -gt 0 || $quiet_flag -eq 0 ]] && [[ ! $vers_autoconf_flag -gt 0 ]] && printf "\033[0;32m[INFO]    Using tag for automake support: ( $use_autoconf_version ) as first tag compiled with automake.\e[0m\n" >&2
  [[ $verbose_flag -gt 0 || $quiet_flag -eq 0 ]] && [[ $test_mode_flag -gt 0 && ! $test_info_was_set -gt 0 ]] && printf "\033[0;32m[INFO]    Using tests dir: ( $kazoj_dir ).\e[0m\n" >&2

  #Check if we are doing init and we're not in test mode
  #Which means we want to build all tags
  #TODO: Why is this checked before determining if we're doing build mode or test mode?
  if [[ $init_flag -gt 0 && $test_mode_flag -eq 0 && $small_test_mode_flag -eq 0 ]] ; then {
    if [[ $quiet_flag -eq 0 && $verbose_flag -gt 1 ]]; then { #WIP
        printf "\033[1;35m[VERB]    Init mode (no -tT): build all tags\e[0m\n" >&2
        echo_supported_tags "$milestones_dir" >&2
    }
    fi
    app "$(echo_node silence_check doing_init)"

    count_bins=0
    start_t_init=`date +%s.%N`
    for i in $(seq 0 $(($tot_vers-1))); do
      init_vers="${supported_versions[$i]}"
      [[ $quiet_flag -eq 0 ]] && printf "[INIT]    Trying to build ( $init_vers ) ( $(($i+1)) / $tot_vers )\n" >&2
      #Build this vers
      #Init mode ALWAYS tries building, even if we have the binary already ATM
      #Save verbose flag
      verb=""
      buildm=""
      gitm=""
      basem=""
      quietm=""
      silentm=""
      packm=""
      ignore_gitcheck=""
      showtimem=""
      [[ $ignore_git_check_flag -gt 0 ]] && ignore_gitcheck="X"
      [[ $show_time_flag -gt 0 ]] && showtimem="w"
      [[ $pack_flag -gt 0 ]] && packm="z" #Pass pack op mode
      [[ $silent_flag -gt 0 ]] && silentm="s" #Pass silent mode
      [[ $verbose_flag -gt 0 ]] && verb="V" #Pass verbose mode
      [[ $build_flag -gt 0 ]] && buildm="b" #Pass build op mode
      [[ $base_mode_flag -gt 0 ]] && basem="B" #We make sure to pass on eventual base mode to the subcalls
      [[ $git_mode_flag -gt 0 ]] && gitm="g" #We make sure to pass on eventual git mode to the subcalls
      [[ $quiet_flag -gt 0 ]] && quietm="q" #We make sure to pass on eventual quiet mode to the subcalls
      #First pass sets the verbose flag but redirects stderr to /dev/null
      [[ $verbose_flag -gt 0 ]] && printf "\033[0;35m[VERB]    Running \"$(dirname "$(basename $prog_name)") -Y $amboso_start_time -M $makefile_version -S $source_name -E $exec_entrypoint -D $scripts_dir -b$verb$gitm$basem$quietm$silentm$packm$ignore_gitcheck$showtimem $init_vers\" ( $(($i+1)) / $tot_vers )\033[0m\n" >&2
      "$prog_name" -Y "$amboso_start_time" -M "$makefile_version" -S "$source_name" -E "$exec_entrypoint" -D "$scripts_dir" -b"$verb""$gitm""$basem""$quietm""$silentm""$packm""$ignore_gitcheck""$showtimem" "$init_vers" 2>/dev/null
      if [[ $? -eq 0 ]] ; then {
        [[ $verbose_flag -gt 0 ]] && printf "\033[0;32m[INIT]    $init_vers binary ready.\e[0m\n" >&2
        count_bins=$(($count_bins +1))
      } else {
        verbose_hint=""
        [[ $verbose_flag -lt 1 ]] && verbose_hint="Run with -V <lvl> to see more info."
        printf "\n\033[1;31m[INIT]    Failed build for $init_vers binary. $verbose_hint\e[0m\n\n"
        #try building again to get more output, since we discarded stderr before
        #
        #we could just pass -v to the first call if we have it on
        if [[ $verbose_flag -gt 0 || $quiet_flag -eq 0 ]]; then {
          printf "[INIT]    Checking errors, running \033[1;33m$(basename "$prog_name") -bV$packm$ignore_gitcheck $init_vers\e[0m.\n" >&2
      ("$prog_name" -Y "$amboso_start_time" -M "$makefile_version" -S "$source_name" -D "$scripts_dir" -E "$exec_entrypoint" -V 2 -b"$gitm""$basem""$packm""$ignore_gitcheck""$showtimem" "$init_vers") >&2
        }
        fi
      }
      fi
    done
    end_t_init=`date +%s.%N`
    runtime_init=$( printf "$end_t_init - $start_t_init\n" | bc -l )
    display_zero=$(printf "$runtime_init\n" | cut -d '.' -f 1)
    if [[ -z $display_zero ]]; then {
      display_zero="0"
    } else {
      display_zero=""
    }
    fi
    printf "\033[0;34m[INIT]    Took $display_zero$runtime_init seconds, ( $count_bins / $tot_vers ) binaries ready.\e[0m\n"
    #We don't quit after the full build.
    #exit 0
  }
  fi

  if [[ $init_flag -gt 0 && $test_mode_flag -gt 0 ]] && [[ $verbose_flag -gt 0 || $quiet_flag -eq 0 ]] ; then {
    printf "\033[0;35m[TEST]    [-i]\e[0m    Will record all tests.\n" >&2
  }
  fi
  if [[ $purge_flag -gt 0 && $test_mode_flag -gt 0 ]] && [[ $verbose_flag -gt 0 || $quiet_flag -eq 0 ]] ; then {
    :
    #echo -e "\033[0;35m[TEST]    [-p]\e[0m    Will clean all tests." >&2
  }
  fi
  if [[ $build_flag -gt 0 && $test_mode_flag -gt 0 ]] && [[ $verbose_flag -gt 0 || $quiet_flag -eq 0 ]] ; then {
    printf "\033[0;35m[TEST]    [-b]\e[0m    Will record test query.\n" >&2
  }
  fi
  if [[ $delete_flag -gt 0 && $test_mode_flag -gt 0 ]] && [[ $verbose_flag -gt 0 || $quiet_flag -eq 0 ]] ; then {
    :
    #echo -e "\033[0;35m[TEST]    [-d]\e[0m    Will clean test query." >&2
  }
  fi

  #If we have -t and not -T, we check all tests and EXIT
  #WIP
  if [[ $small_test_mode_flag -gt 0 && $test_mode_flag -eq 0 ]] ; then {
    app "$(echo_node silence_check doing_test_macro)"
    app "$(echo_node doing_test_macro end_node)"
    end_digraph
    if [[ $quiet_flag -eq 0 ]] ; then {
      printf "\033[1;33m[DEBUG]    -t assert: shortcut to run \"$prog_name\" with -T\n"
      printf "\033[1;33m[DEBUG]    will pass: ( -qVbw ) to subcall, if asserted.\n\n"
    }
    fi
    quietm=""
    verbm=""
    buildm=""
    showtimem=""
    [[ $show_time_flag -gt 0 ]] && showtimem="w"
    [[ $quiet_flag -gt 0 ]] && quietm="q"
    [[ $verbose_flag -gt 0 ]] && verbm="V"
    [[ $build_flag -gt 0 ]] && buildm="b"
    [[ $init_flag -gt 0 ]] && buildm="b" && printf "\033[1;31m[DEBUG]    Recording all tests with -ti is deprecated.\n\n        Feature will be dropped in next major update.\n\n"

    tot_successes=0
    tot_failures=0
    start_t_tests=`date +%s.%N`
    for i in $(seq 0 $(($tot_tests-1))); do {
      [[ $quiet_flag -eq 0 ]] && printf "\033[1;35m[TEST-MACRO]    Running:  \"$prog_name -Y $amboso_start_time -T$quietm$verbm$buildm$showtimem -K $kazoj_dir -D $milestones_dir ${supported_tests[$i]}\"\e[0m\n" >&2
      start_t_curr_test=`date +%s.%N`
      "$prog_name" -Y "$amboso_start_time" -T"$quietm$verbm$buildm""$showtimem" -K "$kazoj_dir" -D "$milestones_dir" "${supported_tests[$i]}"
      retcod="$?"
      if [[ $retcod -eq 0 ]] ; then {
        tot_successes=$(($tot_successes+1))
      } else {
        tot_failures=$(($tot_failures+1))
      }
      fi
      if [[ $retcod -eq 69 ]] ; then {
        printf "\033[1;31m[PANIC]    A test call returned 69 while in macro mode. Doing the same.\e[0m\n\n"
        echo_timer "$amboso_start_time"  "Test returned 69" "1"
        exit 69
      }
      fi
      end_t_curr_test=`date +%s.%N`
      runtime_curr_test=$( printf "$end_t_curr_test - $start_t_curr_test\n" | bc -l )
      display_zero=$(printf "$runtime_curr_test\n" | cut -d '.' -f 1)
      if [[ -z $display_zero ]]; then {
        display_zero="0"
      } else {
        display_zero=""
      }
      fi
      [[ $quiet_flag -eq 0 ]] && printf "\033[0;34m[TEST]  ($(($i+1))/$tot_tests)  took $display_zero$runtime_curr_test seconds.\e[0m\n"
    }
    done
    end_t_tests=`date +%s.%N`
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
    printf "\033[1;35m[TEST]    Successes: {\033[0m\033[1;32m%s\033[1;35m}\033[0m\n" "$tot_successes"
    printf "\033[1;35m[TEST]    Failures: {\033[0m\033[1;31m%s\033[1;35m}\033[0m\n" "$tot_failures"
    exit $tot_failures
  } elif [[ $small_test_mode_flag -gt 0 && $test_mode_flag -gt 0 ]] ; then {
    printf "\033[1;31m[PANIC]    [-t] used with [-T].\n\n        -t is a shortcut to run as -T on all tests found.\e[0m\n\n"
    echo_timer "$amboso_start_time"  "Wrong test flag usage" "1"
    exit 1
    echo "UNREACHABLE"
  }
  fi

  #Version argument is mandatory outside of:
    # purge or init mode (when not in test mode
    # init mode or FULL test mode (when in test mode)
  #check arg num
  # nothing else is allowed
  #shift all the options
  for i in $(seq 0 $(( $tot_opts - 2 )) ); do {
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

  if [[ $quiet_flag -eq 0 && $verbose_flag -gt 1 ]]; then { #WIP
      printf "\033[1;35m[VERB]    SYNCPOINT: shifted args, query was: ( $query ).\e[0m\n" >&2
  }
  fi

  tot_left_args=$(( $# ))
  if [[ $tot_left_args -gt 1 ]]; then {
    printf "\n\033[1;31m[ERROR]    Unknown argument: \"$2\" (ignoring other $(($tot_left_args-1)) args).\e[0m\n\n"
    amboso_usage
    echo_timer "$amboso_start_time"  "Unknown arg [$2]" "1"
    exit 1
  }
  fi

  #If we don't have init or purge flag, we bail on a missing version argument
  if [[ $tot_left_args -lt 1 && $purge_flag -eq 0 && $init_flag -eq 0 && $test_mode_flag -eq 0 ]]; then {
    app "$(echo_node silence_check missing_query)"
    app "$(echo_node missing_query end_node)"
    end_digraph
    printf "\033[1;31m[ERROR]    Missing query.\e[0m\n\n"
    printf "\033[1;33m           Run with -h for help.\e[0m\n\n"
    echo_timer "$amboso_start_time"  "Missing query" "1"
    return 1
  } elif [[ $tot_left_args -lt 1 && $test_mode_flag -gt 0 ]] ; then {
    app "$(echo_node silence_check missing_test_query)"
    app "$(echo_node missing_test_query end_node)"
    end_digraph
    #If in test mode, we still whine about a target test
    printf "\033[1;31m[ERROR]    Missing test query.\e[0m\n\n"
    printf "\033[1;33m           Run with -h for help.\e[0m\n\n"
    printf "can we do init/purge?\n" #TODO wth does this mean
  }
  fi
  #Check if we are doing a test
  if [[ $test_mode_flag -gt 0 ]]; then {
    app "$(echo_node recursion_lt_3 doing_test)"
    if [[ $quiet_flag -eq 0 && $verbose_flag -gt 1 ]]; then { #WIP
        printf "\033[1;35m[VERB]    Test mode (-T was on).\e[0m\n" >&2
        [[ $small_test_mode_flag -gt 0 ]] && printf "\033[1;35m[VERB]    (-t was on).\e[0m\n" >&2
        echo_tests_info "$kazoj_dir" >&2
    }
    fi
    test_name=""
    test_type=""
    test_path=""
    [[ $verbose_flag -gt 0 ]] && printf "\033[0;35m[TEST]    Checking if query $query is a testcase.\e[0m\n" >&2
    for i in $(seq 0 $(($count_tests_names-1))); do {
      current_item="${read_tests_files[$i]}"
      [[ $verbose_flag -gt 0 ]] && printf "\033[0;35m[TEST]    Checking case ($i/$count_tests_names): $current_item\e[0m\n" >&2
      #echo "checking $current_item"
      if [[ $query = "$current_item" ]]; then {
        test_type="casetest"
        test_name="$query"
        test_path="$kazoj_dir/$cases_dir/${read_tests_files[$i]}"
        break; #done looking
      }
      fi
    }
    done
    if [[ -z $test_name ]] ; then {
      [[ $verbose_flag -gt 0 ]] && printf "\033[0;35m[TEST]    Checking if query $query is a error testcase.\e[0m\n" >&2
      for i in $(seq 0 $(($count_errortests_names-1))); do {
        current_item="${read_errortests_files[$i]}"
        [[ $verbose_flag -gt 0 ]] && printf "\033[0;35m[TEST]    Checking error case ($i/$count_errortests_names): $current_item\e[0m\n" >&2
        #echo "checking $current_item"
        if [[ $query = "$current_item" ]] ; then {
      test_type="errortest"
      test_name="$query"
      test_path="$kazoj_dir/$errors_dir/${read_errortests_files[$i]}"
      break; #done looking
        }
        fi
      }
      done
    }
    fi

    if [[ $quiet_flag -eq 0 ]]; then { #WIP
        printf "\033[0;34m[TEST]    Expected:\n\n    type:  $test_type\n\n    name:  $test_name\n    path:  $test_path\n\e[0m\n" >&2
    }
    fi

    if [[ -z $test_path ]]; then {
      if [[ $quiet_flag -eq 0 ]] ; then {
        flaginit=""
        flagbuild=""
        [[ $build_flag -gt 0 ]] && flagbuild="b"
        [[ $init_flag -gt 0 ]] && flaginit="t"
        printf "\033[0;35m[VERB]    Test path was empty but we have [-$flagbuild$flaginit].\e[0m\n" >&2
      }
      fi
      if [[ -z $test_path && -z $query ]] ; then {
        [[ $quiet_flag -eq 0 ]] && printf "\033[0;35m[VERB]    testpath was empty, query was empty. Should quit.\e[0m\n" >&2
        keep_run_txt=""
        if [[ $init_flag -gt 0 ]] ; then {
          keep_run_txt="[INIT]"
          printf "\033[1;33m[TEST]    ( \"empty\"[$query] ) is not a supported tag. $keep_run_txt.\e[0m\n" >&2
          echo_timer "$amboso_start_time"  "Empty test query" "1"
          exit 1
        }
        fi
        printf "\033[0;35m[VERB]    UNREACHABLE.\e[0m\n"
        exit 1
      } elif [[ -z $test_path && ! -z $query ]] ; then {
        [[ $quiet_flag -eq 0 ]] && printf "\033[0;35m[VERB]    testpath was empty, query was not empty: ( $query ).\e[0m\n" >&2
        keep_run_txt=""
        if [[ $init_flag -gt 0 ]] ; then {
          keep_run_txt="[INIT]"
          printf "\033[1;33m[TEST]    ( $query ) is not a supported tag, we quit at this point. $keep_run_txt.\e[0m\n" >&2
          echo_timer "$amboso_start_time"  "Unsupported test query [$query]" "3"
          exit 0
        }
        fi
        [[ $build_flag -gt 0 ]] && keep_run_txt="[BUILD]" && printf "\033[1;33m[TEST]    ( $query ) is not a supported tag, but we continue to $keep_run_txt.\e[0m\n" >&2
      } else {
        [[ $verbose_flag -gt 0 || $quiet_flag -eq 0 ]] && printf "\033[0;33m[TEST] expected:\n  $test_type\n\n  name: $test_name\n  path: $test_path\e[0m\n"# >&2
        printf "\033[0;32m[TEST]    target: ( $test_path ).\e[0m\n\n"
      }
      fi
    } elif [[ -z $test_path && -z $query ]] ; then {
      #Panic
      printf "\033[1;31m[ERROR]    ( $test_name : at  $test_path ) is not a supported test.\e[0m\n\n"
      printf "\033[1;33m           Run with -h for help.\e[0m\n\n"
      echo_timer "$amboso_start_time"  "Unsupported test name [$test_name] at [$test_path]" "1"
      exit 1
    }
    fi

    relative_testpath="$test_path"

    if [[ $build_flag -gt 0 ]] ; then {
      printf "\033[0;34m[TEST]    \"-b\" is set, Recording: ( $relative_testpath ).\e[0m\n" >&2
      #record_test "$relative_testpath"
    } elif [[ $delete_flag -gt 0 ]] ; then {
      :
      #echo -e "\033[0;34m[TEST]    \"-d\" is set, Deleting: ( $relative_testpath ).\e[0m" >&2
      #delete_test "$relative_testpath"
    } elif [[ $init_flag -gt 0 ]] ; then {
      #echo "UNREACHABLE." && exit 1
      printf "\033[0;34m[TEST]    \"-i\" is set, Recording ALL: ( $relative_testpath ).\e[0m\n"
      printf "\033[1;33m[DEBUG]    ( $tot_tests ) total tests ready.\e[0m\n" >&2
      for i in $(seq 0 $(($tot_tests-1))); do {
        TEST="${supported_tests[$i]}"
        verb=""
        quietm=""
        showtimem=""
        [[ $show_time_flag -gt 0 ]] && showtimem="w"
        [[ $quiet_flag -gt 0 ]] && quietm="q" #We make sure to pass on eventual quiet flag mode to the subcalls
        [[ $verbose_flag -gt 0 ]] && verb="V" && printf "\n[TEST]    Recording ALL: ( $(($i+1)) / $tot_tests ) ( $TEST )\n" >&2
        printf "\033[1;35m[TEST]    Running:\e[0m    \033[1;34m\"$prog_name -K $kazoj_dir -D $scripts_dir -bT$quietm$verb$showtimem $TEST 2>/dev/null \"\e[0m\n"
        start_t=`date +%s.%N`
        ( "$prog_name" -Y "$amboso_start_time" -K "$kazoj_dir" -D "$scripts_dir" -b"$quietm""$verb""$showtimem"T "$TEST" 2>/dev/null ; exit "$?")
        record_res="$?"
        if [[ $record_res -eq 69 ]]; then {
          printf "\033[1;31m[PANIC]    Unsupported: a test call returned 69. Will do the same.\e[0m\n\n" &&
          echo_timer "$amboso_start_time"  "Record Test call returned 69" "1"
          exit 69
        }
        fi
        end_t=`date +%s.%N`
        runtime=$( printf "$end_t - $start_t\n" | bc -l )
        printf "\n[TEST]    took $runtime s ( $TEST )\n" >&2
      }
      done
      #init_all_tests "$relative_testpath"
    } elif [[ $purge_flag -gt 0 ]] ; then {
      :
      #echo "[TEST]    Deleting ALL: ( $relative_testpath )."
      #purge_all_tests "$relative_testpath"
    }
    fi
    if [[ -z $relative_testpath && $init_flag -eq 0 ]] ; then {
      #Exit 0 as intended behaviour FIXME
      printf "\033[1;31m[TEST]    Can't proceed further with no valid target path, query was ( $query ).\e[0m\n"
      printf "\033[1;31m[TEST]    Supported tests:\e[0m\n"
      echo_tests_info "$kazoj_dir"
      printf "\033[1;31m[TEST]    Quitting.\e[0m\n"
      echo_timer "$amboso_start_time"  "Invalid target path [$relative_testpath]" "1"
      exit 1
    }
    fi
    if [[ -z $relative_testpath && $init_flag -eq 1 && ! -z $query ]] ; then {
      #Exit 0 as intended behaviour FIXME
      printf "\033[1;31m[ERROR]    Can't proceed even with -i flag, with no testpath. ( p: $relative_testpath ) can't be be ( q: $query ).\e[0m\n"
      echo_timer "$amboso_start_time"  "Invalid target path (-i) [$relative_testpath]" "1"
      exit 0
    }
    fi
    if [[ -z $relative_testpath && $init_flag -eq 1 && -z $query ]] ; then {
      printf "\033[1;31m[ERROR]    Can't proceed with no query.  ( q: $query, p: $relative_testpath ).\e[0m\n"
      echo_timer "$amboso_start_time"  "Empty test query [$query]" "1"
      exit 1
    }
    fi
    run_tmp_out="$(mktemp)"
    run_tmp_escout="$(mktemp)"
    run_tmp_err="$(mktemp)"
    run_tmp_escerr="$(mktemp)"
    [[ $verbose_flag -gt 0 ]] && printf "\033[0;33m[TEST]    Created tempfiles.\e[0m\n" >&2
    printf "\033[0;36m[TEST]    Running:\e[0m    \033[1;35m\"$relative_testpath\"\e[0m\n"
    run_test "$relative_testpath" >>"$run_tmp_out" 2>>"$run_tmp_err"
    ran_res="$?"

    if [[ $ran_res -eq 69 ]] ; then {
      printf "\033[1;31m[WARN]    Test call returned 69, we clean tmpfiles and follow suit.\e[0m\n"
      #Delete tmpfiles
      rm -f "$run_tmp_out" || printf "\033[1;31m[ERROR]    Failed removing tmpfile ($run_tmp_out). Why?\e[0m\n\n"
      [[ $verbose_flag -gt 0 ]] && printf "\033[0;32m[TEST]    Removed tempfile \"$run_tmp_out\".\e[0m\n" >&2
      rm -f "$run_tmp_err" || printf "\033[1;31m[ERROR]    Failed removing tmpfile ($run_tmp_err). Why?\e[0m\n\n"
      [[ $verbose_flag -gt 0 ]] && printf "\033[0;32m[TEST]    Removed tempfile \"$run_tmp_err\".\e[0m\n" >&2
      rm -f "$run_tmp_escout" || printf "\033[1;31m[ERROR]    Failed removing tmpfile ($run_tmp_escout). Why?\n\n"
      [[ $verbose_flag -gt 0 ]] && printf "\033[0;32m[TEST]    Removed tempfile \"$run_tmp_escout\".\e[0m\n" >&2
      rm -f "$run_tmp_escerr" || printf "\033[1;31m[ERROR]    Failed removing tmpfile ($run_tmp_escerr). Why?\n\n"
      [[ $verbose_flag -gt 0 ]] && printf "\033[0;32m[TEST]    Removed tempfile \"$run_tmp_escerr\".\e[0m\n" >&2
      printf "\033[1;31m[PANIC]    Quitting with 69.\e[0m\n"
      echo_timer "$amboso_start_time"  "Test run ended with 69" "1"
      exit 69
    }
    fi
    #echo "r: $ran_res" >> "$run_tmp_out"
    escape_colorcodes_tee "$run_tmp_out" "$run_tmp_escout"
    escape_colorcodes_tee "$run_tmp_err" "$run_tmp_escerr"
    if [[ $build_flag -gt 0 ]] ; then {
      cp "$run_tmp_escout" "$relative_testpath.stdout" || printf "Failed replacing stdout with new file.\n"
      cp "$run_tmp_escerr" "$relative_testpath.stderr" || printf "Failed replacing stderr with new file.\n"
    } else {
      [[ $quiet_flag -eq 0 || $verbose_flag -gt 0 ]] && printf "\033[1;33m[TEST]    Won't record, no [-b].\e[0m\n\n"
    }
    fi
    rm -f "$run_tmp_out" || printf "\033[1;31m[ERROR]    Failed removing tmpfile ($run_tmp_out). Why?\e[0m\n\n"
    [[ $verbose_flag -gt 0 ]] && printf "\033[0;32m[TEST]    Removed tempfile \"$run_tmp_out\".\e[0m\n" >&2
    rm -f "$run_tmp_err" || printf "\033[1;31m[ERROR]    Failed removing tmpfile ($run_tmp_err). Why?\e[0m\n\n"
    [[ $verbose_flag -gt 0 ]] && printf "\033[0;32m[TEST]    Removed tempfile \"$run_tmp_err\".\e[0m\n" >&2
    #Testing diff for escaped stdout
    ( diff "$run_tmp_escout" "$relative_testpath".stdout ) 2>/dev/null 1>&2
    diff_res="$?"
    out_res=""
    if [[ "$diff_res" -eq 0 ]]; then {
      out_res="pass"
      if [[ ! -z "$run_tmp_escout" ]] ; then { #FIXME: SC2157 && ! -z "$relative_testpath".stdout ]]; then {
        #This one doesn't go on stderr since we still want it in recursive calls:
        [[ $verbose_flag -gt 0 ]] && printf "\033[0;32m[TEST]    Pass, both outputs are not empty.\e[0m\n"
      } elif [[ -z "$run_tmp_escout" ]]; then {
        [[ $verbose_flag -gt 0 ]] && printf "\033[0;35m[TEST]    Pass, current stdout is empty. Is that expected?\e[0m\n">&2
      } #FIXME: SC2157 elif [[ -z "$relative_testpath.stdout" ]]; then {
        #[[ $verbose_flag -gt 0 ]] && printf "\033[0;35m[TEST]    Pass, registered stdout is empty. Is that expected?\e[0m\n" >&2
      #}
      fi
      if [[ $verbose_flag -gt 0 && $quiet_flag -eq 0 ]]; then {
        printf "\n\033[0;32m[TEST]    (stdout) Expected:\e[0m\n"
        cat "$relative_testpath.stdout"
        printf "\n\033[0;32m[TEST]    (stdout) Found:\e[0m\n"
        cat "$run_tmp_escout"
      }
      fi
    } else {
      out_res="fail"
      if [[ $quiet_flag -eq 0 ]]; then {
        printf "\n\033[1;31m[TEST]    (stdout) Expected:\e[0m\n"
        cat "$relative_testpath.stdout"
        printf "\n\033[1;31m[TEST]    (stdout) Found:\e[0m\n"
        cat "$run_tmp_escout"
      }
      fi
      printf "\033[1;31m[TEST]    Failed: stdout changed.\e[0m\n"
      #cat "$run_tmp_escout"
    }
    fi
    rm -f "$run_tmp_escout" || printf "\033[1;31m[ERROR]    Failed removing tmpfile ($run_tmp_escout). Why?\n\n"
    [[ $verbose_flag -gt 0 ]] && printf "\033[0;32m[TEST]    Removed tempfile \"$run_tmp_escout\".\e[0m\n" >&2
    #Testing diff for escaped stderr
    ( diff "$run_tmp_escerr" "$relative_testpath".stderr ) 2>/dev/null 1>&2
    diff_res="$?"
    if [[ "$diff_res" -eq 0 ]]; then {
      err_res="pass"
      if [[ ! -z "$run_tmp_escerr" ]]; then { #FIXME SC2157 && ! -z "$relative_testpath.stderr" ]]; then {
        #This one doesn't go on stderr since we still want it in recursive calls:
        [[ $verbose_flag -gt 0 ]] && printf "\033[0;32m[TEST]    Pass, both stderrs are not empty.\e[0m\n"
      } elif [[ -z "$run_tmp_escerr" ]]; then {
        [[ $verbose_flag -gt 0 ]] && printf "\033[0;35m[TEST]    Pass, current run stderr is empty. Is that expected?\e[0m\n">&2
      } #FIXME SC2157 elif [[ -z "$relative_testpath.stderr" ]]; then {
       # [[ $verbose_flag -gt 0 ]] && printf "\033[0;35m[TEST]    Pass, registered stderr is empty. Is that expected?\e[0m\n" >&2
      #}
      fi
      if [[ $verbose_flag -gt 0 && $quiet_flag -eq 0 ]]; then {
        printf "\n\033[0;32m[TEST]    (stderr) Expected:\e[0m\n"
        cat "$relative_testpath.stderr"
        printf "\n\033[0;32m[TEST]    (stderr) Found:\e[0m\n"
        cat "$run_tmp_escerr"
      }
      fi
      #cat "$run_tmp_escerr"
    } else {
      err_res="fail"
      if [[ $quiet_flag -eq 0 ]]; then {
        printf "\n\033[1;31m[TEST]    (stderr) Expected:\e[0m\n"
        cat "$relative_testpath.stderr"
        printf "\n\033[1;31m[TEST]    (stderr) Found:\e[0m\n"
        cat "$run_tmp_escerr"
      }
      fi
      printf "\033[1;31m[TEST]    Failed: stderr changed.\e[0m\n"
      #cat "$run_tmp_escerr"
    }
    fi
    rm -f "$run_tmp_escerr" || printf "\033[1;31m[ERROR]    Failed removing tmpfile ($run_tmp_escerr). Why?\n\n"
    [[ $verbose_flag -gt 0 ]] && printf "\033[0;32m[TEST]    Removed tempfile \"$run_tmp_escerr\".\e[0m\n" >&2
    if [[ $build_flag -gt 0 ]] ; then {
      #We simulate success since we're recording
      printf "\033[1;33m[TEST]    Phony pass (recording).\e[0m\n"
      [[ $verbose_flag -gt 0 ]] && printf "\033[0;33m    (out: $out_res)\e[0m\n"
      [[ $verbose_flag -gt 0 ]] && printf "\033[0;33m    (err: $err_res)\e[0m\n"
      echo_timer "$amboso_start_time"  "Phony test pass" "3"
      exit 0 #We return earlier
    } elif [[ $out_res = "pass" && $err_res = "pass" ]]; then {
      printf "\033[1;32m[TEST]    Passed.\e[0m\n"
      echo_timer "$amboso_start_time"  "Test pass" "2"
      exit 0 #We return earlier
    } elif [[ $out_res = "fail" ]] ; then {
     : #echo "failed" #We echoed before
    } elif [[ $err_res = "fail" ]] ; then {
     : #echo "failed" #We echoed before
    } else {
      printf "\033[1;31m[ERROR]    Unexpected values (o:$out_res/e:$err_res) should be either pass or fail.\e[0m. How?\n"
    }
    fi
    echo_timer "$amboso_start_time"  "Test fail" "1"
    exit 1
  }
  fi
  #End of test mode block

  #We expect $scripts_dir to end with /
  version=""
  for i in $(seq 0 $(($tot_vers-1))); do
    [[ $query = "${supported_versions[$i]}" ]] && version="$query" && script_path="${scripts_dir}v${version}"
  done

  if [[ -z $version ]]; then {
    #We only freak out if we don't have test_mode, purge or init flags on
    if [[ $test_mode_flag -eq 0 && $purge_flag -eq 0 && $init_flag -eq 0 ]] ; then {
      app "$(echo_node silence_check query_invalid)"
      app "$(echo_node query_invalid end_node)"
      end_digraph
      printf "\033[1;31m[ERROR]    ( $query ) is not a supported tag.\e[0m\n\n"
      printf "\033[1;33m           Run with -h for help.\e[0m\n\n"
      echo_timer "$amboso_start_time"  "Invalid query [$query]" "1"
      exit 1
    } elif [[ ! -z $query && $test_mode_flag -gt 0 ]] ; then { #If we're in test mode, gently tell the user that the version is not supported
      keep_run_txt=""
      [[ $init_flag -gt 0 ]] && keep_run_txt="${mode_txt}[INIT]"
      [[ $purge_flag -gt 0 ]] && keep_run_txt="${mode_txt}[PURGE]"
      printf "\n\033[1;33m[DEBUG]    ( $query ) is not a supported test. $keep_run_txt.\e[0m\n" >&2
      echo_timer "$amboso_start_time"  "Invalid test query [$query]" "1"
      exit 1;
    }
    fi
  }
  fi
  #We now should have a valid $version value, outside of purge or init mode

  if [[ $gen_C_headers_set -gt 0 && $gen_C_headers_flag -gt 0 ]]; then {
      printf "\033[1;36m[AMBOSO]    Generate C header for [$version].\e[0m\n" >&2
      gen_C_headers $gen_C_headers_destdir $version $exec_entrypoint
  }
  fi

  has_makefile=0
  if [[ $version > $makefile_version || $version = "$makefile_version" ]] ; then
    has_makefile=1
  fi

  can_automake=0
  if [[ $version > $use_autoconf_version || $version = "$use_autoconf_version" ]] ; then
    can_automake=1
  fi

  #If we can't find the file we may try to build it
  if [[ ! -f "$script_path/$exec_entrypoint" && ! -z $version ]] ; then {
    if [[ $init_flag -eq 0 ]] ; then {
      app "$(echo_node silence_check query_success_not_ready)"
    }
    fi
    printf "\n\033[1;33m[QUERY]    ( $version ) binary not found in ( $script_path ).\e[0m\n" #>&2
    if [[ $verbose_flag -gt 0 ]] ; then {
        echo_tag_info $version
    }
    fi
    if [[ ! $build_flag -gt 0 ]] ; then { #We exit here if we don't want to try building and we're not going to purge
      printf "\033[0;33m[DEBUG]    To try building, run with -b flag\e[0m\n\n" >&2
      if [[ ! $purge_flag -gt 0 ]] ; then {
       app "$(echo_node query_success_not_ready end_node)"
       end_digraph
       echo_timer "$amboso_start_time"  "No build flag" "1"
       exit 1 # quit if we're not purging
      }
      fi
    } else {
      if [[ ! -d "$script_path" ]] ; then
        printf "\033[1;31m[ERROR]    '$script_path' is not a valid directory.\n    Check your supported versions for details on ( $version ).\e[0m\n\n" >&2
        app "$(echo_node query_success_not_ready end_node)"
        end_digraph
        echo_timer "$amboso_start_time"  "Invalid path [$script_path]" "1"
        exit 1
      fi
      #we try to build
      tool_txt="single file gcc"
      app "$(echo_node query_success_not_ready building)"
      if [[ $has_makefile -gt 0 ]]; then { #Make mode
        tool_txt="make"
        if [[ $can_automake -gt 0 ]] ; then { #We support automake by doing autoreconf and ./configure before running make.
          tool_txt="automake"
          printf "\033[0;33m[MODE]    target ( $version ) >= ( $use_autoconf_version ), can autoconf.\e[0m\n" >&2
          autoreconf
          if [[ $? -ne 0 ]] ; then {
            printf "\033[1;33m[WARN]\033[0m    autoreconf failed. Doing {\033[1;34mautomake --add-missing\033[0m}\n" >&2
            automake --add-missing
            autoreconf
          }
          fi
          configure_arg=""
          if [[ "$pass_autoconf_arg_flag" -eq 1 ]] ; then {
              configure_arg="$(cat "$autoconf_arg_file")"
              printf "\033[1;34m[CONF]    Running \"\033[1;36m%s\033[1;34m\"\033[0m\n" "./configure $configure_arg"
          }
          fi
          ./configure "$configure_arg"
          configure_res="$?"
          if [[ "$configure_res" -ne 0 ]]; then {
              printf "\033[1;33m[WARN]    ./configure returned {\033[1;31m%s\033[1;33m}\033[0m\n" "$configure_res"
          }
          fi
          printf "\033[0;32m[INFO]    Done 'autoreconf' and './configure'.\e[0m\n" >&2
        }
        fi
        printf "\033[0;33m[MODE]    target ( $version ) >= ( $makefile_version ), has Makefile.\e[0m\n" >&2
        [[ $verbose_flag -gt 0 ]] && printf "\033[0;33m[BUILD]    Building ( $version ), using make.\e[0m\n" >&2
        curr_dir=$(realpath .)
        start_t=`date +%s.%N`
        if [[ $git_mode_flag -eq 0 && $base_mode_flag -eq 1 ]] ; then { #Building in base mode, we cd into target directory before make
          [[ $verbose_flag -gt 0 ]] && printf "\033[0;35m[BUILD]    Running in base mode, expecting full source in $script_path.\e[0m\n" #>&2
          cd $script_path || { printf "\033[1;31m[CRITICAL]    cd failed. Quitting.\n"; exit 4 ; }; make >&2
          comp_res=$?
        } else { #Building in git mode, we checkout the tag and move the binary after the build
          [[ $verbose_flag -gt 0 ]] && printf "\033[0;34m[BUILD]    Running in git mode, checking out ( $version ).\e[0m\n" #>&2
          git checkout "$version" 2>/dev/null #Repo goes back to tagged state
          checkout_res=$?
          if [[ $checkout_res -gt 0 ]] ; then { #Checkout failed, we don't build and we set comp_res
            printf "\033[1;31m[ERROR]    Checkout of ( $version ) failed, this stego.lock tag does not work for the repo.\e[0m\n" #>&2
            comp_res=1
          } else { #Checkout successful, we build
            git submodule update --init --recursive #We set all submodules to commit state
            make >&2 #Never try to build if checkout fails
            comp_res=$?
            #Output is expected to be in the main dir:
            if [[ ! -e ./$exec_entrypoint ]] ; then {
              printf "\033[1;31m[ERROR]    $exec_entrypoint not found at $(pwd).\e[0m\n" #>&2
            } else {
              mv "./$exec_entrypoint" "$script_path" #All files generated during the build should be ignored by the repo, to avoid conflict when checking out
              [[ $verbose_flag -gt 0 ]] && printf "\033[0;33m[BUILD]    Moved $exec_entrypoint to $script_path.\e[0m\n" #>&2
            }
            fi
            git switch - #We get back to starting repo state
            switch_res="$?"
            if [[ $switch_res -gt 0 ]]; then {
              printf "\n\033[1;31m[ERROR]    Can't finish checking out ($version).\n    You may have a dirty index and may need to run \033[1;35\"git restore .\"\e[0m.\n Abort.\n\n"
              echo_timer "$amboso_start_time"  "Failed checkout" "1"
              exit 1
            }
            fi
            git submodule update --init --recursive #We set all submodules to commit state
            [[ $quiet_flag -eq 0 ]] && printf "\033[0;32m[BUILD]    Switched back to starting commit.\e[0m\n"
          }
          fi
        }
        fi
        end_t=`date +%s.%N`
        runtime=$( printf "$end_t - $start_t\n" | bc -l )
        cd "$curr_dir" || { printf "\033[1;31m[CRITICAL]    cd failed. Quitting.\n"; exit 4; };
      } else { #Straight gcc mode
        [[ $verbose_flag -gt 0 ]] && printf "\033[0;33m[MODE]    target ( $version ) < ( $makefile_version ), single file build with gcc.\e[0m\n" >&2
        [[ $verbose_flag -gt 0 ]] && printf "\033[0;33m[BUILD]    Building ( $version ), using gcc call.\e[0m\n" >&2
        #echo "" >&2 #new line for error output
        if [[ -z $source_name ]]; then {
          printf "\n\033[1;31m[WTF-ERROR]    Missing source file name. ( $version ).\e[0m\n\n"
          amboso_usage
          echo_timer "$amboso_start_time"  "Missing source name for [$version]" "1"
          exit 1
        }
        fi
        [[ $pack_flag -gt 0 ]] && printf "\n\033[1;33m[PACK]    -z is not supported for ($tool_txt). TAG < ($makefile_version).\n\n    \033[1;35Current: ($version @ $source_name).\e[0m\n\n"

        start_t=`date +%s.%N`
        if [[ $git_mode_flag -eq 0 ]] ; then { #Building in base mode, we cd into target directory before make
          [[ $verbose_flag -gt 0 ]] && printf "\033[0;35m[BUILD]    Running in base mode, expecting full source in $script_path.\e[0m\n" #>&2
          gcc "$script_path"/"$source_name" -o "$script_path"/"$exec_entrypoint" -lm 2>&2
          comp_res=$?
        } else { #Building in git mode, we checkout the tag and move the binary after the build
          [[ $verbose_flag -gt 0 ]] && printf "\033[0;34m[BUILD]    Running in git mode, checking out ( $version ).\e[0m\n" #>&2
          git checkout "$version" 2>/dev/null #Repo goes back to tagged state
          checkout_res=$?
          if [[ $checkout_res -gt 0 ]] ; then { #Checkout failed, we set comp_res and don't build
            printf "\033[1;31m[ERROR]    Checkout of ( $version ) failed, stego.lock may be listing a tag name not on the repo.\e[0m\n"
            comp_res=1
          } else {
            git submodule update --init --recursive 2>/dev/null#We set all submodules to commit state
            gcc "./$source_name" -o "$script_path"/"$exec_entrypoint" -lm 2>&2 #Never try to build if checkout fails
            comp_res=$?
            #All files generated during the build should be ignored by the repo, to avoid conflict when checking out
            git switch - 2>/dev/null #We get back to starting repo state
            switch_res="$?"
            if [[ $switch_res -gt 0 ]]; then {
              printf "\n\033[1;31m[ERROR]    Can't finish checking out ($version). Abort.\n"
              echo_timer "$amboso_start_time"  "Failed checkout for [$version]" "1"
              exit 1
            }
            fi
            [[ $verbose_flag -gt 0 ]] && printf "\033[0;32m[BUILD]    Switched back to starting commit.\e[0m\n" >&2
          }
          fi
        }
        fi
        end_t=`date +%s.%N`
        runtime=$( printf "$end_t - $start_t\n" | bc -l )
      }
      fi
      #Check compilation result
      if [[ $comp_res -eq 0 ]] ; then
        printf "\033[1;32m[BUILD]    Done Building ( $version ) , took $runtime seconds, using ( $tool_txt ).\e[0m\n"
        app "$(echo_node building build_success)"
      else
        printf "\033[1;31m[ERROR]    Build for ( $version ) failed, quitting.\e[0m\n\n" >&2
        app "$(echo_node building build_fail)"
        app "$(echo_node build_fail end_node)"
        end_digraph
        echo_timer "$amboso_start_time"  "Failed build for [$version]" "1"
        exit 1
      fi

    }
    fi

  } elif [[ ! -z $version ]] ; then { #Binary was present, we notify if we were running with build flag
    if [[ $init_flag -eq 0 ]] ; then {
      app "$(echo_node silence_check query_success_ready)"
    } else {
      app "$(echo_node doing_init query_success_ready)"
    }
    fi
    printf "\n\033[1;32m[QUERY]    ( $version ) binary is ready at ( $script_path ) .\e[0m\n\n" >&2
    if [[ $verbose_flag -gt 0 ]] ; then {
        echo_tag_info $version
    }
    fi
    if [[ $build_flag -gt 0 ]] ; then {
      printf "\033[0;33m[BUILD]    Found binary for ( $version ), won't build.\e[0m\n" >&2
      app "$(echo_node query_success_ready build_success)"

    }
    fi
    #Check if we're packing the ready version
    if [[ $pack_flag -gt 0 ]] ; then {
      #We just leverage make pack and assume it's ready to roll
      printf "\033[0;35m[PACK]    Running in base mode, expecting full source in $script_path.\e[0m\n" #>&2
      make pack
      pack_res=$?
      if [[ $pack_res -gt 0 ]] ; then { #make pack failed
        printf "\033[1;31m[PACK]    Packing ($version) in base mode, failed.\n    Expected source at ($script_path).\e[0m\n" #>&2
      } else {
        printf "\033[1;32m[PACK]    Packed ($version):\n    from  ($script_path)\e[0m\n" #>&2
      }
      fi
    }
    fi

  } elif [[ ! -z $query ]] ; then {
    app "$(echo_node silence_check query_invalid)"
    printf "\033[1;31m[QUERY]    ( $query ) invalid query, run with -V <lvl> to see more.\e[0m\n"
    if [[ $verbose_flag -gt 0 ]] ; then {
        echo_tag_info $version
    }
    fi
  }
  fi

  #We check the run flag to run the binary
  if [[ ! -z $version && $run_flag -eq 1 && -x $script_path/$exec_entrypoint ]] ; then {
    if [[ $build_flag -gt 0 && $comp_res -eq 0 ]]; then { #The second condition is needed to catch running a freshly built tag
      app "$(echo_node build_success running)"
    } else {
      app "$(echo_node query_success_ready running)"
    }
    fi
    printf "\n\033[0;32m[DEBUG]    Running script $script_path/$exec_entrypoint\e[0m\n"
    #echo -n "."
    #sleep 1
    #echo ""
    ( cd "$script_path" || { printf "\033[1;31m[CRITICAL]    cd failed. Quitting.\n"; exit 4 ;} ; ./"$exec_entrypoint" )
  } elif [[ ! -z $version && $run_flag -eq 0  ]] ; then {
    printf "\033[0;33m[DEBUG]    Running without -r flag, won't run.\e[0m\n" >&2
  } elif [[ -z $version && $run_flag -gt 0 ]] ; then {
    [[ $verbose_flag -gt 0 ]] && printf "\033[0;33m[DEBUG]    Running with -r but requested an empty tag ( $version )!\e[0m\n" >&2
  }
  fi

  #Check if we are deleting and exiting early
  #We skipped first deletion pass if purge mode is requested, since we will enter here later
  if [[ $delete_flag -gt 0 && $purge_flag -eq 0 ]] ; then {
    if [[ $run_flag -gt 0 ]] ; then {
      app "$(echo_node running deleting)"
    } elif [[ $build_flag -gt 0 ]] ; then {
      app "$(echo_node build_success deleting)"
    } else {
      app "$(echo_node query_success_ready deleting)"
    }
    fi
      clean_res=1
    if [[ $has_makeclean -gt 0 && $base_mode_flag -gt 0 ]] ; then { #Running in git mode skips make clean
      tool_txt="make clean"
      has_bin=0
      curr_dir=$(realpath .)
      delete_path="$scripts_dir""v""$version"
        if [[ ! -d $delete_path ]] ; then {
          printf "\033[1;31m[ERROR]    '$delete_path' is not a valid directory.\n    Check your supported versions for details on ( $version ).\e[0m\n\n" #>&2
        } elif [[ -x $scripts_dir/v$version/$exec_entrypoint ]] ; then { #Executable exists
          has_bin=1 && printf "\033[0;33m[DELETE]   ( $version ) has an executable.\e[0m\n\n" >&2
          cd "$delete_path" || { printf "\033[1;31m[CRITICAL]    cd failed. Quitting.\n"; exit 4 ;}; make clean 2>/dev/null #1>&2
          clean_res=$?
          cd "$curr_dir" || { printf "\033[1;31m[CRITICAL]    cd failed. Quitting.\n"; exit 4 ;};
          echo_timer "$amboso_start_time"  "Did delete, res was [$clean_res]" "3"
          exit "$clean_res"
        } else {
          [[ $verbose_flag -gt 0 ]] && printf "\033[0;31m[DELETE]   ( $versions ) does not have an executable at ( $delete_path ).\e[0m\n\n" # >&2
          app "$(echo_node deleting no_target_error)"
          app "$(echo_node no_target_error end_node)"
          end_digraph
          echo_timer "$amboso_start_time"  "Nothing to delete" "1"
          exit 1
        }
        fi
    } else { #Doesn't have Makefile, build method 2. Running in git mode also skips using make clean
      tool_txt="rm"
      has_bin=0
      if [[ -x $scripts_dir"/v$version"/"$exec_entrypoint" ]] ; then {
        has_bin=1 && [[ $verbose_flag -gt 0 ]] && printf "\033[0;33m[DELETE]    ( $version ) has an executable.\e[0m\n" >&2
      }
      fi
      rm "$(realpath "$scripts_dir"/"v$version/$exec_entrypoint")" #2>/dev/null
      clean_res=$?
      if [[ $clean_res -eq 0 ]] ; then {
        printf "\033[0;32m[DELETE]    Success on ( $version ).\e[0m\n"
        app "$(echo_node deleting delete_success)"
        app "$(echo_node delete_success end_node)"
        end_digraph
      } else {
        printf "\033[0;31m[DELETE]    Failure on ( $version ).\e[0m\n"
        app "$(echo_node deleting delete_fail)"
        app "$(echo_node delete_fail end_node)"
        end_digraph
      }
      fi
      echo_timer "$amboso_start_time"  "Did delete, res was [$clean_res]" "3"
      exit "$clean_res"
    }
    fi
  }
  fi

  #Check if we are purging
  if [[ purge_flag -gt 0 ]]; then
    if [[ $run_flag -gt 0 ]] ; then {
      app "$(echo_node running purging)"
    } elif [[ $build_flag -gt 0 ]] ; then {
      app "$(echo_node build_success purging)"
    } else {
      app "$(echo_node query_success_ready purging)"
    }
    fi
    #echo "" >&2 #This newline can be redirected when doing recursion for init mode
    tot_removed=0
    tool_txt="rm"
    has_bin=0
    for i in $(seq 0 $(($tot_vers-1)) ); do
      clean_res=1
      has_makeclean=0
      purge_vers=${supported_versions[$i]}
      if [[ -x $scripts_dir/v$purge_vers/$exec_entrypoint ]] ; then {
        has_bin=1 #&& [[ $verbose_flag -gt 0 ]] && echo -e "\033[0;32m[DELETE]    $version has an executable.\e[0m\n" >&2
      } else {
        continue; #We just skip the version
      }
      fi
      if [[ $purge_vers > "$makefile_version" || $purge_vers = "$makefile_version" ]] ; then
        [[ $git_mode_flag -eq 0 ]] && has_makeclean=1 && tool_txt="make clean" #We never use make clean for purge, if in git mode
      fi

      ## Rerun with -d
      verb=""
      gitm=""
      basem=""
      quietm=""
      silentm=""
      packm=""
      ignore_gitcheck=""
      showtimem=""
      [[ $show_time_flag -gt 0 ]] && showtimem="w"
      [[ $ignore_git_check_flag -gt 0 ]] && ignore_gitcheck="X"
      [[ $pack_flag -gt 0 ]] && packm="z"
      [[ $silent_flag -gt 0 ]] && silentm="s"
      [[ $verbose_flag -gt 0 ]] && verb="V" && printf "\n[PURGE]    Trying to delete ( $purge_vers ) ( $(($i+1)) / $tot_vers )\n" >&2
      [[ $base_mode_flag -gt 0 ]] && basem="B" #We make sure to pass on eventual base mode to the subcalls
      [[ $git_mode_flag -gt 0 ]] && gitm="g" #We make sure to pass on eventual git mode to the subcalls
      [[ $quiet_flag -gt 0 ]] && quietm="q" #We make sure to pass on eventual quiet flag mode to the subcalls
      if [[ $quiet_flag -eq 0 ]] ; then {
        printf "\033[1;35m[PURGE]    Running \"$(basename "$prog_name") -Y $amboso_start_time-M $makefile_version -S $source_name -E $exec_entrypoint -D $scripts_dir -d$verb$gitm$basem$quietm$silentm$packm$ignore_gitcheck$showtimem $purge_vers 2>/dev/null\"\e[0m\n"
      }
      fi
      ( $prog_name -Y "$amboso_start_time" -M "$makefile_version" -S "$source_name" -E "$exec_entrypoint" -D "$scripts_dir" -d"$verb""$gitm""$basem""$quietm""$silentm""$packm""$ignore_gitcheck""$showtimem" "$purge_vers" ) 2>/dev/null
      clean_res="$?"
      #To be sure delete OP is gonna be the returning op here, we assume pack just never makes the script return, so it will always go to delete OP safely.

      #Check clean result
      if [[ $clean_res -eq 0 && $has_bin -gt 0 ]] ; then {
        #we advance the count
        tot_removed=$(($tot_removed +1))
        [[ $verbose_flag -gt 0 ]] && printf "\033[0;33m[PURGE]    Removed ( $purge_vers ) using ( $tool_txt ).\e[0m\n" >&2
      } else {
        verbose_hint=""
        [[ $verbose_flag -lt 1 ]] && verbose_hint="Run with -V <lvl> to see more info."
        printf "\n\033[1;31m[PURGE]    Failed delete for ( $purge_vers ) binary. $verbose_hint\e[0m\n\n"
        [[ $verbose_flag -gt 0 ]] && printf "\033[0;31m[PURGE]    Failed removing ( $purge_vers ) using ( $tool_txt ). $verbose_hint\e[0m\n" #>&2
        #try deleting again to get more output, since we discarded stderr before
        #
        #we could just pass -v to the first call if we have it on
        if [[ $verbose_flag -gt 0 ]]; then {
          printf "[PURGE]    Verbose flag was asserted as ($verbose_flag).\n" >&2
          printf "[PURGE]    Checking errors, running \033[1;33m$(basename "$prog_name") -V 2 -d $purge_vers\e[0m.\n" >&2
          ("$prog_name" -Y "$amboso_start_time" -M "$makefile_version" -S "$source_name" -D "$scripts_dir" -E "$exec_entrypoint" -V 2 -d"$gitm""$basem""$ignore_gitcheck""$showtimem" "$purge_vers") #>&2
        }
        fi
      }
      fi

    done
    if [[ $tot_removed -gt 0 ]] ; then {
      printf "\033[0;33m[PURGE]    Purged ( $tot_removed / $tot_vers ) versions, quitting.\e[0m\n\n"
      app "$(echo_node purging purging_success)"
      app "$(echo_node purging_success end_node)"
    } else {
      printf "\n\033[0;33m[PURGE]    No binaries to purge found.\e[0m\n\n"
      app "$(echo_node purging purging_fail)"
      app "$(echo_node purging_fail end_node)"
    }
    fi
  fi

  if [[ $delete_flag -eq 0 ]]; then {
      #We need to close cfg dump
      if [[ $run_flag -gt 0 ]] ; then {
        app "$(echo_node running end_node)"
      } elif [[ $build_flag -gt 0 ]] ; then {
        app "$(echo_node build_success end_node)"
      } else {
        app "$(echo_node query_success_ready end_node)"
      }
      fi
  }
  fi

  end_digraph
  echo_timer "$amboso_start_time"  "Run" "6"
  exit 0

}

amboso_main() {
  if [[ ! $# -eq 0 ]] ; then {
    cmd="$(printf -- "$1" | cut -f1 -d'-')"
    if [[ ! -z $cmd ]] ; then {
      printf "COMMAND: {$cmd}\n"
      if [[ $cmd = "quit" ]] ; then {
        unset AMBOSO_LVL_REC
        exit 0
      }
      fi
      if [[ $cmd = "version" ]] ; then {
        (amboso_parse_args "-v")
        unset AMBOSO_LVL_REC
        return
      }
      fi
      if [[ $cmd = "build" ]] ; then {
        (amboso_parse_args "-Xb" "latest")
        unset AMBOSO_LVL_REC
        return
      }
      fi
      if [[ $cmd = "init" ]] ; then {
          (amboso_init_proj "$2")
        unset AMBOSO_LVL_REC
        return
      }
      fi
      if [[ $cmd = "help" ]] ; then {
        printf "\033[1;35m[AMBOSO-MAIN]\033[0m    Quick commands:\n\n"
        printf "    build        Build latest version\n\n"
        printf "    init         Prepare current dir for an amboso project\n\n"
        printf "    version      Print amboso version\n\n"
        printf "    quit         Quit amboso\n\n"
        printf "    help         Print this message\n\n"
        printf "\033[1;35m[AMBOSO-MAIN]\033[0m    Amboso help (-h):\n\n"
        (amboso_parse_args "-Xh")
        unset AMBOSO_LVL_REC
        return
      }
      fi
    }
    fi
    (amboso_parse_args "$@")
    res="$?"
    unset AMBOSO_LVL_REC
    return "$res"
  } else { # Repl
    while read -e -p "[AMBOSO-MAIN]$ " line ;
    do {
      cmd="$(printf -- "${line}" | cut -f1 -d'-')"
      if [[ ! -z $cmd ]] ; then {
        printf "COMMAND: {$cmd}\n"
        if [[ $cmd = "quit" ]] ; then {
          unset AMBOSO_LVL_REC
          exit 0
        }
        fi
        if [[ $cmd = "version" ]] ; then {
          (amboso_parse_args "-v")
          unset AMBOSO_LVL_REC
          return

        }
        fi
        if [[ $cmd = "build" ]] ; then {
          (amboso_parse_args "-Xb"  "latest")
          unset AMBOSO_LVL_REC
          return
        }
        fi
        if [[ $cmd = "init" ]] ; then {
          (amboso_init_proj "$2")
          unset AMBOSO_LVL_REC
          return
        }
        fi
        if [[ $cmd = "help" ]] ; then {
          printf "\033[1;35m[AMBOSO-MAIN]\033[0m    Quick commands:\n\n"
          printf "    build        Build latest version\n\n"
          printf "    init         Prepare current dir for an amboso project\n\n"
          printf "    version      Print amboso version\n\n"
          printf "    quit         Quit amboso\n\n"
          printf "    help         Print this message\n\n"
          printf "\033[1;35m[AMBOSO-MAIN]\033[0m    Amboso help (-h):\n\n"
          (amboso_parse_args "-Xh")
          unset AMBOSO_LVL_REC
          return
        }
        fi
      }
      fi
      printf "\033[1;35m[CMDLINE]\033[0m    \"\033[1;36m$line\033[0m\"\n"
      (amboso_parse_args "$line")
      res="$?"
      unset AMBOSO_LVL_REC
    }
    done < "${1:-/dev/stdin}"
  }
  fi

  return "$res"
}
