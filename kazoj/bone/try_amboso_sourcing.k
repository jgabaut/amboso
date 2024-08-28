#!/bin/bash

expected_AMBOSO_API_LVL="2.0.7"

verbose_flag=1
tell_uname_flag=0
quiet_flag=0

#Function to try sourcing amboso_fn.sh
source_amboso_api() {
  local force="$1"
  [[ -z "$force" ]] && force=0
  local source_res=1
  if [[ "$force" -eq 1 ]] ; then {
    if [ -f "/usr/local/bin/amboso_fn.sh" ] ; then { #We only enter here if we force sourcing from global anvil
      #We need one more message to show me are forcing this.
      printf "[WARN]    Forcing source from global path -> {%s}\n" "$std_amboso_global_path" >&2
      amboso_fn_path="/usr/local/bin/amboso_fn.sh"
      [ "$quiet_flag" -eq 0 ] && printf "[WARN]    Fallback to default path for amboso_fn. Sourcing: \"%s\".\n" "$amboso_fn_path" >&2
      # shellcheck source=/usr/local/bin/amboso_fn.sh
      . "$amboso_fn_path";
      source_res="$?"
      if [ "$source_res" -ne 0 ] ; then {
        printf "[PREP]    Failed loading amboso_fn. Quitting.\n\n    Using file: \"%s\".\n" "$amboso_fn_path" >&2
        exit 3
      }
      fi
    }
    fi
  }
  fi
  if [[ "$source_res" -ne 0 && "$(basename "$(pwd)")" = "amboso" ]] ; then {
    amboso_fn_path="$(realpath "$(pwd)")/amboso_fn.sh"
    if [ -f "$amboso_fn_path" ] ; then {
      [ "$verbose_flag" -gt 1 ] && printf "[PREP]    Running inside amboso dir. Sourcing: \"%s\".\n" "$amboso_fn_path">&2
      # shellcheck source=./amboso_fn.sh
      . "${amboso_fn_path}";
      source_res="$?"
      if [ "$source_res" -ne 0 ] ; then {
        printf "[PREP]    Failed loading amboso_fn.\n\n    Using file: \"%s\".\n" "$amboso_fn_path" >&2
        exit 3
      }
      fi
    } else {
      printf "[ERROR]    Could not load amboso_fn, check your symlinks.\e[0m\n"
      exit 2
    }
    fi
  } elif [[ "$source_res" -ne 0 ]]; then {
    amboso_fn_path="$(realpath "$(pwd)")/amboso/amboso_fn.sh"
    found_amboso_dir=0
    [ "$verbose_flag" -gt 1 ] && printf "[PREP]    Assuming we are running in super-repo. Sourcing: \"%s\".\n" "$amboso_fn_path" >&2
    if [ -d "$(realpath "$(pwd)")"/amboso ]; then {
        found_amboso_dir=1
    }
    fi
    [ "$verbose_flag" -gt 1 ] && [ "$found_amboso_dir" -gt 0 ] && printf "[PREP]    Found amboso dir.\n" >&2
    if [ -f "$amboso_fn_path" ] ; then {
      [ "$verbose_flag" -gt 1 ] && printf "[PREP]    Valid file at: \"%s\".\n" "$amboso_fn_path" >&2
      # shellcheck source=./amboso_fn.sh
      . "${amboso_fn_path}";
      source_res="$?"
      [ "$source_res" -ne 0 ] && printf "[PREP]    Failed loading amboso_fn.\n\n    Using file: \"%s\".\n" "$amboso_fn_path" >&2
    } else {
      [ "$quiet_flag" -eq 0 ] && printf "[WARN]    \"%s\" was not a valid file. Not in valid super-repo.\n" "$amboso_fn_path" >&2
      try_default=1
    }
    fi
    if [ "$try_default" -eq 1 ] && [ -f "/usr/local/bin/amboso_fn.sh" ] ; then { #We only enter here if we failed sourcing
      #We need one more error message to show me are missing functions because of an amboso directory with no file.
      if [ "$found_amboso_dir" -gt 0 ] ; then {
        printf "[WARN]   Deprecated amboso dir (< 1.4.3) found, as it doesn't provide a function api marker.\n" >&2
        exit 3
      }
      fi
      amboso_fn_path="/usr/local/bin/amboso_fn.sh"
      [ "$quiet_flag" -eq 0 ] && printf "[WARN]    Fallback to default path for amboso_fn. Sourcing: \"%s\".\n" "$amboso_fn_path" >&2
      # shellcheck source=/usr/local/bin/amboso_fn.sh
      . "$amboso_fn_path";
      source_res="$?"
      if [ "$source_res" -ne 0 ] ; then {
        printf "[PREP]    Failed loading amboso_fn. Quitting.\n\n    Using file: \"%s\".\n" "$amboso_fn_path" >&2
        exit 3
      }
      fi
    }
    fi
  }
  fi

  if [ "$source_res" -ne 0 ] ; then {
    printf "[PANIC]    Failed sourcing amboso_fn. Expected path: \"%s\".\n" "$amboso_fn_path"
    exit 2
  }
  fi
  [ "$verbose_flag" -gt 1 ] && printf "[PREP]    Done loading functions.\n" >&2
  [ "$verbose_flag" -gt 1 ] && printf "[PREP]    \"\$AMBOSO_API_LVL\" is: ( %s , expected { %s } ).\n" "$AMBOSO_API_LVL" "$expected_AMBOSO_API_LVL" >&2
  [ "$tell_uname_flag" -eq 1 ] && print_sysinfo
  if expr "'$expected_AMBOSO_API_LVL" \> "'$AMBOSO_API_LVL" >/dev/null ; then {
    if [[ "$AMBOSO_API_LVL" < "2.1.x" ]] ; then {
        printf "[WARN]    Minimal amboso 2.0.x API found.\n"
        printf "[WARN]    Keep running with API {%s}.\n" "$AMBOSO_API_LVL"
        lesser_res=0
    } else {
        printf "[PANIC]    Unexpected AMBOSO_API_LVL. Needed { %s } , { %s } is too low.\n\n    Check your \"amboso_fn.sh\" file.\n\n" "$expected_AMBOSO_API_LVL" "$AMBOSO_API_LVL"
        lesser_res=255
        if [[ "$AMBOSO_API_LVL" < "1.4.3" ]] ; then {
            printf "[WARN]    amboso_fn.sh does not contain AMBOSO_API_LVL.\n"
            lesser_res=1
        } elif [[ "$AMBOSO_API_LVL" > "1.4.2" && "$AMBOSO_API_LVL" < "1.6.6" ]] ; then {
            printf "[WARN]    Unstable amboso version detected.\n"
            lesser_res=2
        } elif [[ "$AMBOSO_API_LVL" > "1.6.5" && "$AMBOSO_API_LVL" < "1.7.4" ]] ; then {
            printf "[WARN]    Legacy stego.lock format is not supported.\n"
            lesser_res=3
        } elif [[ "$AMBOSO_API_LVL" > "1.7.4" && "$AMBOSO_API_LVL" < "1.9.6" ]] ; then {
            printf "[WARN]    Incompatible -C flag, test mode\n"
            lesser_res=4
        } elif [[ "$AMBOSO_API_LVL" < "2.0.0" ]] ;  then {
            printf "[WARN]    Deprecated amboso 1.x API found.\n"
            lesser_res=5
        } elif [[ "$AMBOSO_API_LVL" = "2.0.0" ]] ; then {
            printf "[WARN]    Minimal amboso 2.0 API found.\n"
            lesser_res=0
        }
        fi
        }
    fi
    if [[ "$lesser_res" -ne 0 ]] ; then {
        printf "[PANIC]    Could not load functions. Quitting.\n"
        exit "$lesser_res"
        exit 1
    }
    fi
  } elif expr "'$AMBOSO_API_LVL" \> "'$expected_AMBOSO_API_LVL" >/dev/null ; then {
    [ "$verbose_flag" -gt 0 ] && printf "[WARN]    AMBOSO_API_LVL is greater than expected. Needed { %s } , { %s } is higher.\n" "$expected_AMBOSO_API_LVL" "$AMBOSO_API_LVL" >&2
    [ "$verbose_flag" -gt 0 ] && printf "\n[WARN]    Continuing run with unexpected AMBOSO_API_LVL: Needed { %s } , { %s } is higher.\n" "$expected_AMBOSO_API_LVL" "$AMBOSO_API_LVL"
    #exit 2
  } elif [ "$AMBOSO_API_LVL" = "$expected_AMBOSO_API_LVL" ] ; then {
    [ "$verbose_flag" -gt 0 ] && printf "[PREP]   Running with \"\$AMBOSO_API_LVL\" [ %s ]; min is { %s }.\e[0m\n" "$AMBOSO_API_LVL" "$expected_AMBOSO_API_LVL" >&2
  }
  fi
}

printf "[TEST]    source_amboso_api()\n"
source_amboso_api #Don't force global source
printf "[RES]    {$?}\n"
