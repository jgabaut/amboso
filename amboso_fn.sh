at () {
    echo -n "{ call: [$(( ${#BASH_LINENO[@]} - 1 ))] "
    for ((i=${#BASH_LINENO[@]}-1;i>=0;i--)); do
    printf '<%s:%s> ' "${FUNCNAME[i]}" "${BASH_LINENO[i]}";
    done
    echo "$LINENO"
}

backtrace () {
   #[[ $tracing -eq 0 ]] && echo -n "{ [MAIN] at: $trace_line } -> {"
   if [[ $trace_line -eq 0 ]] ; then {
     echo -e "\n\n\n\n{ [$(( $trace_line ))] [ trace at) "
   } else {
     at echo -e "["
   }
   fi
   trace_line=1
   while caller "$trace_line"
   do
      #echo "]"
      trace_line=$((trace_line+1))
      #echo -n "at [ $(( $trace_line  )) ] ["
   done
   echo "} -> "
}

trace () {
  if [[ $trace_flag -gt 0 ]] ; then {
   backtrace
  } else {
   :
  }
  fi
}

function echo_current_tags {
  echo -e "[DEBUG]    Current flags:\n"
  echo -en "           [MODE]    -"
  [[ $small_test_mode_flag -gt 0 ]] && echo -n "t"
  [[ $test_mode_flag -gt 0 ]] && echo -n "T"
  [[ $git_mode_flag -gt 0 ]] && echo -n "g"
  [[ $base_mode_flag -gt 0 ]] && echo -n "B"
  echo ""
  echo -en "           [OP]    -"
  [[ $verbose_flag -gt 0 ]] && echo -n "V"
  [[ $quiet_flag -gt 0 ]] && echo -n "q"
  [[ $init_flag -gt 0 ]] && echo -n "i"
  [[ $build_flag -gt 0 ]] && echo -n "b"
  [[ $purge_flag -gt 0 ]] && echo -n "p"
  [[ $delete_flag -gt 0 ]] && echo -n "d"
  [[ $small_list_flag -gt 0 ]] && echo -n "l"
  [[ $big_list_flag -gt 0 ]] && echo -n "L"
  [[ $bighelp_flag -gt 0 ]] && echo -n "H"
  [[ $smallhelp_flag -gt 0 ]] && echo -n "h"
  [[ $version_flag -eq 1 ]] && echo -n "v"
  [[ $version_flag -gt 1 ]] && echo -n "v" #One more level to this option
  echo -e "\n"
}

function echo_amboso_version {
  echo "$amboso_version"
}
function echo_amboso_version_short {
  echo "$amboso_currvers"
}

function set_supported_versions {
  dir=$1
  [[ ! -f $dir/stego.lock ]] && echo -e "\033[1;31m[ERROR]    Can't find \"stego.lock\" in ( $dir ).\e[0m\n" && exit 1
  git_tags_count=0
  base_tags_count=0
  j=0
  k=0
  i=0

  while IFS= read -r line; do {
    #Skip the first five lines, reserved for header, source file and target executable names, test folder, and versions header
    [[ $j -lt 6 ]] && j=$((j+1)) && continue

    was_git_tag=0
    was_base_tag=0
    for tag in $(echo "$line" | grep -v '^?' | cut -d '#' -f 1 | cut -d ' ' -f 1 | grep -v '^$'); do {
      read_git_mode_tags[git_tags_count]="$tag"
      git_tags_count=$(($git_tags_count+1))
      was_git_tag=1
    }
    done
    for tag in $(echo "$line" | grep '^?'| cut -d '?' -f2 | cut -d '#' -f 1 | cut -d ' ' -f1 | grep -v '^$'); do {
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
  [[ ! -f $dir/stego.lock ]] && echo -e "\033[1;31m[ERROR]    Can't find \"stego.lock\" in ( $dir ). Try running with -D to specify the right directory.\e[0m\n" && exit 1
  j=0
  k=0
  while IFS= read -r line; do
    #Skip the first line header
    [[ $j -lt 1 ]] && j=$((j+1)) && continue

    #echo "Text read from file: ( $line )"
    #echo "Text read from file, no comments: ( $( echo "$line" | cut -d '#' -f 1 ) )"
    sources_info[k]=$(echo "$line" | cut -d '#' -f 1 | cut -d ' ' -f 1 )
    k=$((k+1))
    [[ $k -eq 4 ]] && break #we only read the first three lines
  done < "$dir/stego.lock" 2>/dev/null
  #echo "source info array size is " "${#sources_info[@]}" >&2
  count_source_infos="${#sources_info[@]}"
  #echo "$count_source_infos"
  #echo "source info array contents are: ( ${sources_info[@]} )" >&2
}

function set_tests_info {
  dir="$1"
  [[ ! -f "$dir"/kazoj.lock ]] && echo -e "\033[1;31m[ERROR]    Can't find \"kazoj.lock\" in ( $dir ). Try running with -K to specify the right directory.\e[0m\n" && exit 1
  j=0
  k=0
  while IFS="\n" read -r line; do
    #Skip the first and third line header
    [[ $j -lt 1 || $j -eq 2 ]] && j=$((j+1)) && continue
    #echo "Text read from file: ( $line )"
    #echo "Text read from file, no comments: ( $( echo "$line" | cut -d '#' -f 1 ) )"
    tests_info[k]=$(echo "$line" | cut -d '#' -f 1 | cut -d ' ' -f 1 )
    k=$((k+1))
    j=$((j+1))
    [[ $k -lt 2 ]] || break #we only read two values
  done < "$dir/kazoj.lock" 2>/dev/null
  #echo "test info array size is " "${#tests_info[@]}" >&2
  count_tests_infos="${#tests_info[@]}"
  #echo "$count_tests_infos"
  #echo "test info array contents are: ( ${tests_info[@]} )" >&2
}

function set_supported_tests {
  kazoj_dir=$1
  set_tests_info "$1"
  cases_dir="${tests_info[0]}"
  errors_dir="${tests_info[1]}"
  tests_filecount=0
  errors_filecount=0
  skipped=0
  i=0

  #tests loop
  cases_path="$kazoj_dir/$cases_dir"
  errorcases_path="$kazoj_dir/$errors_dir"
  for FILE in $(ls "$cases_path") ; do {
    test_fp="$cases_path/$FILE"
    extens=$(echo "$(realpath $FILE)" | cut -d '.' -f '2')
    if [[ $extens = "stderr" || $extens = "stdout" ]] ; then {
      skipped=$((skipped+1))
      [[ $verbose_flag -gt 1 && $quiet_flag -eq 0 ]] && echo -e "\033[0;37m[PREP-TEST]    Skip record $FILE (at $(dirname $test_fp)).\e[0m" >&2
      continue
    }
    fi
    if ! [[ -f $test_fp && -x $test_fp ]] ; then {
      skipped=$((skipped+1))
      echo -e "\033[0;36m[PREP-TEST]    Skip test \"$FILE\" (at $(dirname $test_fp)), not an executable.\e[0m" >&2
      continue
    }
    fi
    read_tests_files["$tests_filecount"]="$FILE"
    tests_filecount=$(($tests_filecount+1))
  }
  done
  #errors loop
  for FILE in $(ls "$errorcases_path"); do {
    test_fp="$errorcases_path/$FILE"
    extens=$(echo "$(realpath $FILE)" | cut -d '.' -f '2')
    if [[ $extens = "stderr" || $extens = "stdout" ]] ; then {
      skipped=$((skipped+1))
      [[ $verbose_flag -gt 0 && $quiet_flag -eq 0 ]] && echo -e "\033[0;37m[PREP-TEST]    Skip record $FILE (at $(dirname $test_fp)).\e[0m" >&2
      continue
    }
    fi
    if ! [[ -f $test_fp && -x $test_fp ]] ; then {
      skipped=$((skipped+1))
      echo -e "\033[0;36m[PREP-TEST]    Skip errtest \"$FILE\" (at $(basename $test_fp)), not an executable.\e[0m" >&2
      continue
    }
    fi
    read_errortests_files["$errors_filecount"]="$FILE"
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
  echo -e "\033[1;33m[DEBUG]    Tests dir is: ( $kazoj_dir ).\e[0m" >&2
  echo -e "\033[1;33m[DEBUG]    Cases dir is: ( $echoed_cases_dir ).\e[0m" >&2
  echo -e "\033[1;33m[DEBUG]      ( $count_tests_names ) cases ready.\e[0m" >&2
  if [[ $big_list_flag -gt 0 ]] ; then {
    for i in $(seq 0 $(($count_tests_names-1))) ; do {
      echo -e "\033[1;33m[DEBUG]      ( ${read_tests_files[$i]} ).\e[0m" >&2
    }
    done
  }
  fi
  echo -e "\033[1;33m[DEBUG]    Errors dir is: ( $echoed_errors_dir ).\e[0m" >&2
  echo -e "\033[1;33m[DEBUG]      ( $count_errortests_names ) error cases ready.\e[0m" >&2
  if [[ $big_list_flag -gt 0 ]] ; then {
    for i in $(seq 0 $(($count_errortests_names-1))) ; do {
      echo -e "\033[1;33m[DEBUG]      ( ${read_errortests_files[$i]} ).\e[0m" >&2
    }
    done
  }
  fi
  echo -e "\033[1;33m[DEBUG]    ( $tot_tests ) total tests ready.\e[0m" >&2
  #echo "$count_tests_infos"
  #echo "test info array contents are: ( ${tests_info[@]} )" >&2
}

function echo_othermode_tags {
  dir="$1"
  set_supported_versions "$dir"

  #Print remaining read versions not available in current mode
  if [[ $base_mode_flag -gt 0 ]] ; then {
    mode_txt="\033[1;34mgit\e[0m"
    echo -e "  ( $count_git_versions ) supported tags when running in ( $mode_txt ) mode."
    echo -e "  Run again in ( $mode_txt ) mode to use them."
    for i in $(seq 0 $(($count_git_versions-1))); do {
      (( $i % 4 == 0)) && [[ $i -ne 0 ]] && echo -en "\n"
      echo -en "    \033[0;33m${read_git_mode_tags[i]}\e[0m"
    }
    done
  } else {
    mode_txt="\033[1;31mbase\e[0m"
    echo -e "  ( $count_base_versions ) supported tags when running in ( $mode_txt ) mode."
    echo -e "  Run again in ( $mode_txt ) mode to use them."
    for i in $(seq 0 $(($count_base_versions-1))); do {
      (( $i % 4 == 0)) && [[ $i -ne 0 ]] && echo -en "\n"
      echo -en "    \033[0;33m${read_base_mode_tags[i]}\e[0m"
    }
    done
  }
  fi
  echo ""
}

function echo_supported_tags {
  mode_txt="\033[1;34mgit\e[0m"
  [[ $base_mode_flag -gt 0 ]] && mode_txt="\033[1;31mbase\e[0m"
  dir="$1"
  set_supported_versions "$dir"
  echo -e "  ( $tot_vers ) supported tags for current mode ( $mode_txt )."
  for i in $(seq 0 $(($tot_vers-1))); do { #Print currently supported versions (only ones conforming to mode)
    (( $i % 4 == 0)) && [[ $i -ne 0 ]] && echo -en "\n"
    echo -en "    \033[1;32m${supported_versions[i]}\e[0m"
  }
  done
  echo ""
}

function echo_options {
  echo -e "\n    [MODES]:\n"
  echo -e "        -B        base mode\n"
  echo -e "                Uses full source builds. Not recommended.\n"
  echo -e "        -g        git mode\n"
  echo -e "                Uses git checkouts of supported tags. Enabled by default.\n"
  echo -e "        -T        test mode\n"
  echo -e "                Tries the queried test.\n"
  echo -e "    [OPERATIONS]:\n"
  echo -e "        -b        build\n"
  echo -e "                Tries building the binary if it's not available.\n"
  echo -e "        -r        run\n"
  echo -e "                Specifies you want to run the tag.\n"
  echo -e "        -d        delete\n"
  echo -e "                Deletes queried tag binary and quits.\n"
  echo -e "        -i        init\n"
  echo -e "                Tries building all supported versions.\n"
  echo -e "        -p        purge\n"
  echo -e "                Removes all tags binaries and quits.\n"
  echo -e "    [OPTIONS]:\n"
  echo -e "        -D TARGET_DIR        directory\n"
  echo -e "                Specifies target directory\n"
  echo -e "        -E TARGET_EXEC       executable\n"
  echo -e "                Specifies target executable name\n"
  echo -e "        -S TARGET_SOURCE       sourcename\n"
  echo -e "                Specifies sourcefile name for single file mode.\n"
  echo -e "        -M MAKEFILE_SUPPORT       tagname\n"
  echo -e "                Specifies a tag name for lowest version to support make.\n"
  echo -e "        -K TEST_FOLDER       path\n"
  echo -e "                Specifies a relative dirname for test folder.\n"
  echo -e "    [INFO]:\n"
  echo -e "        -l/L        list\n"
  echo -e "                Prints supported tags for current mode (all modes if L) and quits.\n"
  echo -e "        -q        quiet\n"
  echo -e "                Less debug output, recursive.\n"
  echo -e "        -V        verbose\n"
  echo -e "                More debug output.\n"
  echo -e "        -h/H        help\n"
  echo -e "                Prints help info (paged if -h) and quits.\n"
  echo -e "        -v        version\n"
  echo -e "                Prints version message and quits.\n"
}

function git_mode_check {
  is_git_repo=0
  #Check if we're inside a repo
  git rev-parse --is-inside-work-tree 2>/dev/null 1>&2
  is_git_repo="$?"
  [[ $is_git_repo -gt 0 ]] && echo -e "\n\033[1;31m[ERROR]    Not running in a git repo. Try running with -B to use base mode.\e[0m\n" && exit 1
  [[ $verbose_flag -gt 0 ]] && echo -e "\033[1;34m[MODE]    Running in git mode.\e[0m" >&2
}

function usage {
  echo -e "Usage: $(basename $prog_name) [OPTION]... VERSION_QUERY\n"
  echo "    Query for a build version"
  #echo_supported_tags "$milestones_dir"
  #echo ""
  #echo_othermode_tags "$milestones_dir"
  echo_options
}

function escape_colorcodes_tee {
  file="$1"
  outfile="$2"
  echo "" >"$outfile"
  #sed -r 's/\/\\3/g' "$file"
  #sed -e 's/\\033\[/COLOR[/g' -e 's/COLOR\[1;3/"<colorTag[Heavy,/g' -e 's/COLOR\[0;3/"<colorTag[Light,/g' -e 's/\\e\[0m/\]>"/g' "$file" >>"$outfile"
  #sed 's/\x1B\[\([0-9]\{1,2\}\(;[0-9]\{1,2\}\)\?\)\?[mGK]//g' <"$file"
  cat -e "$file" | tee "$outfile"
}

function escape_colorcodes {
  file="$1"
  outfile="$2"
  echo "" >"$outfile"
  #sed -r 's/\/\\3/g' "$file"
  #sed -e 's/\\033\[/COLOR[/g' -e 's/COLOR\[1;3/"<colorTag[Heavy,/g' -e 's/COLOR\[0;3/"<colorTag[Light,/g' -e 's/\\e\[0m/\]>"/g' "$file" >>"$outfile"
  #sed 's/\x1B\[\([0-9]\{1,2\}\(;[0-9]\{1,2\}\)\?\)\?[mGK]//g' <"$file"
  cat -e "$file" >"$outfile"
}

function record_test {
  tfp="$1" # test_file_path
  echo "" > "$tfp.stdout"
  echo "" > "$tfp.stderr"
  tmp_stdout="$(mktemp)"
  tmp_stderr="$(mktemp)"
  run_test "$tfp" >>"$tmp_stdout" 2>>"$tmp_stderr"
  res="$?"
  #echo "r: $res" >> "$tmp_stdout"
  escape_colorcodes_tee "$tmp_stdout" "$tfp.stdout"
  escape_colorcodes_tee "$tmp_stderr" "$tfp.stderr"
  rm -f "$tmp_stdout" || echo "\033[1;31m[ERROR]    Failed removing tmpfile ($tmp_stdout). Why?\n"
  [[ $verbose_flag -gt 0 ]] && echo -e "\033[0;32m[TEST]    Removed tempfile "$tmp_stdout".\e[0m" >&2
  rm -f "$tmp_stderr" || echo "\033[1;31m[ERROR]    Failed removing tmpfile ($tmp_stderr). Why?\n"
  [[ $verbose_flag -gt 0 ]] && echo -e "\033[0;32m[TEST]    Removed tempfile "$tmp_stderr".\e[0m" >&2
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
  tfp="$1" # test_file_path
  (
    echo "deleting $tfp" 2>/dev/null
    exit "$?"
  )
  res="$?"

  if [[ $res -eq 0 ]]; then {
    echo -e "\033[0;32m[TEST]    Deleted $tfp.\e[0m" >&2
  } else {
    echo -e "\033[1;31m[TEST]    Failed deleting $tfp. How?\e[0m" >&2
  }
  fi
}
