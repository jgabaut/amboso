#!/bin/bash

expected_AMBOSO_API_LVL="2.0.0-rc1"

verbose_flag=1
tell_uname_flag=0
quiet_flag=0
#Function to try sourcing amboso_fn.sh
source_amboso_api() {
  if [ "$(basename "$(pwd)")" = "amboso" ] ; then {
    amboso_fn_path="$(realpath "$(pwd)")/amboso_fn.sh"
    if [ -f "$amboso_fn_path" ] ; then {
      [ "$verbose_flag" -gt 1 ] && printf "\033[0;35m[PREP]    Running inside amboso dir. Sourcing: \"%s\".\e[0m\n" "$amboso_fn_path">&2
      # shellcheck source=./amboso_fn.sh
      . "${amboso_fn_path}";
      source_res="$?"
      if [ "$source_res" -ne 0 ] ; then {
        printf "\033[1;31m[PREP]    Failed loading amboso_fn.\n\n    Using file: \"%s\".\e[0m\n" "$amboso_fn_path" >&2
        exit 3
      }
      fi
    } else {
      printf "\033[1;31m[ERROR]    Couldn't load amboso_fn, check your symlinks.\e[0m\n"
      exit 2
    }
    fi
  } else {
    amboso_fn_path="$(realpath "$(pwd)")/amboso/amboso_fn.sh"
    found_amboso_dir=0
    [ "$verbose_flag" -gt 1 ] && printf "\033[0;33m[PREP]    Assuming we are running in super-repo. Sourcing: \"%s\".\e[0m\n" "$amboso_fn_path" >&2
    [ -d "$(realpath "$(pwd)")"/amboso ] && found_amboso_dir=1
    [ "$verbose_flag" -gt 1 ] && [ "$found_amboso_dir" -gt 0 ] && printf "\033[0;32m[PREP]    Found amboso dir.\e[0m\n" >&2
    if [ -f "$amboso_fn_path" ] ; then {
      [ "$verbose_flag" -gt 1 ] && printf "\033[0;35m[PREP]    Valid file at: \"%s\".\e[0m\n" "$amboso_fn_path" >&2
      # shellcheck source=./amboso_fn.sh
      . "${amboso_fn_path}";
      source_res="$?"
      [ "$source_res" -ne 0 ] && printf "\033[1;31m[PREP]    Failed loading amboso_fn.\n\n    Using file: \"%s\".\e[0m\n" "$amboso_fn_path" >&2
    } else {
      [ "$quiet_flag" -eq 0 ] && printf "\033[0;31m[WARN]    \"%s\" was not a valid file. Not in valid super-repo.\e[0m\n" "$amboso_fn_path" >&2
      try_default=1
    }
    fi
    if [ "$try_default" -eq 1 ] && [ -f "/usr/local/bin/amboso_fn.sh" ] ; then { #We only enter here if we failed sourcing
      #We need one more error message to show me are missing functions because of an amboso directory with no file.
      if [ "$found_amboso_dir" -gt 0 ] ; then {
        printf "\033[1;31m[WARN]   Deprecated amboso dir (< 1.4.3) found, as it doesn't provide a function api marker.\e[0m\n\n" >&2
        exit 3
      }
      fi
      amboso_fn_path="/usr/local/bin/amboso_fn.sh"
      [ "$quiet_flag" -eq 0 ] && printf "\033[0;35m[WARN]    Fallback to default path for amboso_fn. Sourcing: \"%s\".\e[0m\n" "$amboso_fn_path" >&2
      # shellcheck source=/usr/local/bin/amboso_fn.sh
      . "$amboso_fn_path";
      source_res="$?"
      if [ "$source_res" -ne 0 ] ; then {
        printf "\033[1;31m[PREP]    Failed loading amboso_fn. Quitting.\n\n    Using file: \"%s\".\e[0m\n" "$amboso_fn_path" >&2
        exit 3
      }
      fi
    }
    fi
  }
  fi

  if [ "$source_res" -ne 0 ] ; then {
    printf "\033[1;31m[PANIC]    Failed sourcing amboso_fn. Expected path: \"%s\".\e[0m\n" "$amboso_fn_path"
    exit 2
  }
  fi
  [ "$verbose_flag" -gt 1 ] && printf "\033[0;32m[PREP]    Done loading functions.\e[0m\n" >&2
  [ "$verbose_flag" -gt 1 ] && printf "\033[0;37m[PREP]    \"\$AMBOSO_API_LVL\" is: (\033[0;34m %s \033[0;37m, expected { \033[1;33m%s\033[0;37m } ).\e[0m\n" "$AMBOSO_API_LVL" "$expected_AMBOSO_API_LVL" >&2
  [ "$tell_uname_flag" -eq 1 ] && print_sysinfo
  if expr "'$expected_AMBOSO_API_LVL" \> "'$AMBOSO_API_LVL" >/dev/null ; then {
    printf "\033[1;31m[PANIC]    AMBOSO_API_LVL not supported. Needed { \033[1;35m%s\033[1;31m } , { \033[1;33m%s\033[1;31m } is too low.\n\n    Maybe check your \"amboso_fn.sh\" file.\n\e[0m\n" "$expected_AMBOSO_API_LVL" "$AMBOSO_API_LVL"
    printf "\033[1;31m[PANIC]    Couldn't load functions. Quitting.\e[0m\n"
    exit 2
  } elif expr "'$AMBOSO_API_LVL" \> "'$expected_AMBOSO_API_LVL" >/dev/null ; then {
    [ "$verbose_flag" -gt 0 ] && printf "\033[0;31m[WARN]    AMBOSO_API_LVL is greater than expected. Needed { \033[1;35m%s\033[0;31m } , { \033[1;34m%s\033[0;31m } is higher.\e[0m\n" "$expected_AMBOSO_API_LVL" "$AMBOSO_API_LVL" >&2
    [ "$verbose_flag" -gt 0 ] && printf "\n\033[1;31m[WARN]    Continuing run with unexpected AMBOSO_API_LVL: Needed { \033[1;35m%s\033[1;31m } , { \033[1;34m%s\033[1;31m } is higher.\e[0m\n" "$expected_AMBOSO_API_LVL" "$AMBOSO_API_LVL"
    #exit 2
  } elif [ "$AMBOSO_API_LVL" = "$expected_AMBOSO_API_LVL" ] ; then {
    [ "$verbose_flag" -gt 0 ] && printf "\033[0;32m[PREP]   Running with \"\$AMBOSO_API_LVL\" [ \033[1;35m%s\033[0;32m ]; min is { \033[1;36m%s\033[0;32m }.\e[0m\n" "$AMBOSO_API_LVL" "$expected_AMBOSO_API_LVL" >&2
  }
  fi
}

printf "[TEST]    source_amboso_api()\n"
source_amboso_api
printf "[RES]    {$?}\n"