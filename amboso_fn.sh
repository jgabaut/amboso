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

AMBOSO_API_LVL="1.8.0"
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

	if [[ $verbose_flag -gt 1 ]] ; then {
		for tag in "${read_versions[@]}"; do
		if [[ " ${repo_tags[*]} " =~ " $tag " ]]; then
			if [[ $verbose_flag -gt 0 ]] ; then {
				shown_tag="\033[1;32m$tag\e[0m"
				printf "[AMBOSO]  Read Tag $shown_tag exists in the repo.\n" >&2
			}
			fi
		else {
			if [[ $verbose_flag -gt 0 ]] ; then {
				shown_tag="\033[1;31m$tag\e[0m"
				printf "[AMBOSO]  Read Tag $shown_tag is missing in the repo.\n" >&2
			}
			fi
		}
		fi
		done
	}
	fi

	for tag in "${supported_versions[@]}"; do
    	if [[ " ${repo_tags[*]} " =~ " $tag " ]]; then {
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

function set_supported_versions {
  dir=$1
  [[ ! -f $dir/stego.lock ]] && printf "\033[1;31m[ERROR]    Can't find \"stego.lock\" in ( $dir ).\e[0m\n\n" && exit 1
  git_tags_count=0
  base_tags_count=0
  j=0
  k=0
  i=0

  while IFS= read -r line; do {
    #Skip the first five lines, reserved for header, source file and target executable names, test folder, and versions header
    [[ $j -lt 7 ]] && j=$((j+1)) && continue

    was_git_tag=0
    was_base_tag=0
    for tag in $(printf "$line\n" | grep -v '^?' | cut -d '#' -f 1 | cut -d ' ' -f 1 | grep -v '^$'); do {
      read_git_mode_tags[git_tags_count]="$tag"
      git_tags_count=$(($git_tags_count+1))
      was_git_tag=1
    }
    done
    for tag in $(printf "$line\n" | grep '^?'| cut -d '?' -f2 | cut -d '#' -f 1 | cut -d ' ' -f1 | grep -v '^$'); do {
      read_base_mode_tags[base_tags_count]="$tag"
      base_tags_count=$(($base_tags_count+1))
      was_base_tag=1
    }
    done

    #echo "Text read from file: ( $line )"
    #echo "Text read from file, no comments: ( $( echo "$line" | cut -d '#' -f 1 ) )"
    if [[ $base_mode_flag -gt 0 && $was_base_tag -gt 0 ]] ; then {
      read_versions[k]=${read_base_mode_tags[$k]}
      k=$((k+1))
    } elif [[ $git_mode_flag -gt 0 && $was_git_tag -gt 0 ]] ; then {
      read_versions[k]=${read_git_mode_tags[$k]}
      k=$((k+1))
    }
    fi
  }
  done < "$dir/stego.lock" 2>/dev/null
  #echo "version array size is " "${#read_versions[@]}" >&2
  count_git_versions="${#read_git_mode_tags[@]}"
  count_base_versions="${#read_base_mode_tags[@]}"
  #echo "$count_versions"
  #echo "version array contents are: ( ${read_versions[@]} )" >&2
  if [[ $base_mode_flag -gt 0 ]] ; then {
    for i in $(seq 0 $(($count_base_versions-1))); do
      supported_versions[i]=${read_base_mode_tags[$i]}
    done
  } else {
    for i in $(seq 0 $(($count_git_versions-1))); do
      supported_versions[i]=${read_git_mode_tags[$i]}
    done
  }
  fi

  tot_vers=${#supported_versions[@]}
}

function set_source_info {
  dir=$1
  [[ ! -f $dir/stego.lock ]] && printf "\033[1;31m[ERROR]    Can't find \"stego.lock\" in ( $dir ). Try running with -D to specify the right directory.\e[0m\n\n" && exit 1
  j=0
  k=0
  while IFS= read -r line; do
    #Skip the first line header
    [[ $j -lt 1 ]] && j=$((j+1)) && continue

    #echo "Text read from file: ( $line )"
    #echo "Text read from file, no comments: ( $( echo "$line" | cut -d '#' -f 1 ) )"
    sources_info[k]=$(printf "$line\n" | cut -d '#' -f 1 | cut -d ' ' -f 1 )
    k=$((k+1))
    [[ $k -eq 5 ]] && break #we only read the first four lines
  done < "$dir/stego.lock" 2>/dev/null
  #echo "source info array size is " "${#sources_info[@]}" >&2
  count_source_infos="${#sources_info[@]}"
  #echo "$count_source_infos"
  #echo "source info array contents are: ( ${sources_info[@]} )" >&2
}

function set_tests_info {
  dir="$1"
  if [[ ! -f "$dir"/kazoj.lock ]] ; then {
    printf "\033[1;31m[ERROR]    Can't find \"kazoj.lock\" in \"$dir\". Try running with -K to specify the right directory.\e[0m\n\n"
    return 1
  }
  fi
  j=0
  k=0
  while IFS="$(printf '\n')" read -r line; do
    #Skip the first and third line header
    [[ $j -lt 1 || $j -eq 2 ]] && j=$((j+1)) && continue
    #echo "Text read from file: ( $line )"
    #echo "Text read from file, no comments: ( $( echo "$line" | cut -d '#' -f 1 ) )"
    tests_info[k]=$(printf "$line\n" | cut -d '#' -f 1 | cut -d ' ' -f 1 )
    k=$((k+1))
    j=$((j+1))
    [[ $k -lt 2 ]] || break #we only read two values
  done < "$dir/kazoj.lock" 2>/dev/null
  #echo "test info array size is " "${#tests_info[@]}" >&2
  count_tests_infos="${#tests_info[@]}"
  if [[ $count_tests_infos -eq 0 ]] ; then {
    printf "\033[0;31m[WARN]\e[0m    \"\$count_tests_infos\" was 0 after doing set_tests_info().\n\n"
    return 1
  }
  fi
  #echo "$count_tests_infos"
  #echo "test info array contents are: ( ${tests_info[@]} )" >&2
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
    -V    verbose    More verbose output, can be >1
    -lL    list    Lists all valid tags (-L ignores current build mode to check for tags)
    -q    quiet    Less output (useful but not well implemented, recommended on recursive calls)
    -s    silent    Way less output (Some output expected on stderr before the flag is applied)
    -c    control    Output dotfile \'amboso_cfg.dot\' while running.
    -w    watch    Always display timers regardless of verbosity.
    -X    experimental    Ignore the result of git_mode_check, which would stop git mode runs early when git status is not clean.
    -C [...] START_TIME    Set start time of the program.
    -W     Warranty    Prints warranty information, as per GPL-3.0 license.

  [...]    TAG_QUERY    Ask a tag for current mode

        Reports if target executable name for TAG_QUERY was found at BINDIR/vTAG_QUERY/EXECNAME.\n"

}

function amboso_usage {
  printf "Usage:  $(basename "$prog_name") [(-D|-K|-M|-S|-E|-G|-C|-x) ...ARGS] [-TBtg] [-bripd] [-hHvVlLqcwXW] [TAG_QUERY]\n"
  printf "    Query for a build version ( or stego files parser, with -x).\n"
}

function escape_colorcodes_tee {
  file="$1"
  outfile="$2"
  printf "" >"$outfile"
  #sed -r 's/\/\\3/g' "$file"
  #sed -e 's/\\033\[/COLOR[/g' -e 's/COLOR\[1;3/"<colorTag[Heavy,/g' -e 's/COLOR\[0;3/"<colorTag[Light,/g' -e 's/\\e\[0m/\]>"/g' "$file" >>"$outfile"
  #sed 's/\x1B\[\([0-9]\{1,2\}\(;[0-9]\{1,2\}\)\?\)\?[mGK]//g' <"$file"
  cat -e "$file" | tee "$outfile"
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

    awk '{
        # Remove leading and trailing whitespaces
        gsub(/^[ \t]+|[ \t]+$/, "")

        # Remove trailing comments outside quotes
        gsub(/#[^\n"]*$/, "")

        # Skip empty lines
        if ($0 == "") {
            next
        }

        if ($0 ~ /^\s*\[[^A-Z_\[\]\\\/\$]+\]\s*$/) {
            # Extract and set the current scope
            if (match($0, /^\s*\[\s*([^A-Z_\[\]]+)\s*\]\s*$/, a)) {
                current_scope=gensub(/\s*$/, "", "g", a[1])
                scopes[current_scope]++
            } else {
                print "\033[1;31m[LINT]\033[0m    Invalid header:    \033[1;31m" $0 "\033[0m" > "/dev/stderr"
                error_flag=1
            }
        } else if ($0 ~ /^[^A-Z=\[\]_\$\\\/{}]+ *= *[^A-Z=\[\]\${}]+$/) {
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
        } else if ($0 ~ /^[^A-Z=\[\]\$\\_\/{}]+ *$/) {
            # Check if the line only has a left value (no equals sign and right value)

            # Trim leading and trailing whitespaces
            gsub(/^[ \t]+|[ \t]+$/, "")

            # Extract the left value
            left_value=gensub(/^ *"?([^"]+)"? *$/, "\\1", "g", $0)

            # Trim trailing whitespaces from left value
            gsub(/[ \t]+$/, "", left_value)

            # Check if left value contains disallowed characters
            if (index(left_value, " ") > 0 || (index(left_value, "\"") > 0 && index(left_value, "\"#") == 0)) {
                print "\033[1;31m[LINT]\033[0m    Invalid left side (contains spaces or disallowed characters):    \033[1;31m" left_value "\033[0m" > "/dev/stderr"
                error_flag=1
            } else {
                if (current_scope == "main") {
                    left_value = "main_" left_value
                }
                if (left_value ~ /^[^0-9]+ *$/) {
                    values[current_scope "_" left_value ]=null  # Treat it as NULL "value"
                } else {
                    values[current_scope "_" left_value ]=0  # Treat it as 0 "value"
                }
                if (!(current_scope in scopes)) {
                    scopes[current_scope]++
                }
            }
        } else if ($0 ~ /^[^A-Z_\[\]\$\\\/{}]+ *= *{[^}A-Z\\\$#\]\[]+ *}$/) {
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
      } elif [[ $variable = "build_make-vers" ]]; then {
        printf "ANVIL_MAKE_VERS: {$value}\n"
      } elif [[ $variable = "build_automake-vers" ]]; then {
        printf "ANVIL_AUTOMAKE_VERS: {$value}\n"
      } elif [[ $variable = "build_tests" ]]; then {
        printf "ANVIL_TESTDIR: {$value}\n"
      }
      fi
    } elif [[ $scope = "versions" ]] ; then {
        tag="$(printf "$variable\n" | cut -f2 -d'_')"
        if [[ $tag == \?* ]] ; then {
          printf "ANVIL_BASE_VERSION: {$tag}\n"
        } else {
          printf "ANVIL_GIT_VERSION: {$tag}\n"
        }
        fi
    } elif [[ $scope = "tests" ]] ; then {
        test_dir="$value"
        if [[ $variable = "tests_tests-dir" ]] ; then {
          printf "ANVIL_BONE_DIR: {$test_dir}\n"
        } elif [[ $variable = "tests_errortests-dir" ]] ; then {
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
      } elif [[ $variable = "build_make-vers" ]]; then {
        [[ $verbose -gt 0 ]] && printf "ANVIL_MAKE_VERS: {$value}\n"
        [[ $verbose -gt 0 ]] && printf "makefile_version: {$value} <- {$makefile_version}\n\n"
        makefile_version="$value"
        sources_info[2]="$makefile_version"
      } elif [[ $variable = "build_automake-vers" ]]; then {
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
        tag="$(printf "$variable\n" | cut -f2 -d'_')"
        if [[ $tag == \?* ]] ; then {
          [[ $verbose -gt 0 ]] && printf "ANVIL_BASE_VERSION: {$tag}\n"
          cut_tag="$(printf "$tag\n" | cut -f2 -d'?')"
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
        if [[ $variable = "tests_tests-dir" ]] ; then {
          [[ $verbose -gt 0 ]] && printf "ANVIL_BONE_DIR: {$read_dir}\n"
          tests_info[0]="$read_dir"
          cases_dir="${tests_info[0]}"
        } elif [[ $variable = "tests_errortests-dir" ]] ; then {
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

  [[ $verbose -gt 0 ]] && printf "\033[1;34m[INFO]    Read {$tot_vers} tags.\033[0m\n"
  return 0
}
