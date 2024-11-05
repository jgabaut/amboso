#!/bin/bash
amboso_build_step() {
    local target_dir_path="$1"
    local target_tag="$2"
    local target_binary="$3"
    local target_source="$4"
    local has_config_script_args="$5"
    local config_script_arg="$6"
    local has_CFLAGS="$7"
    local arg_CFLAGS="$8"
    if [[ ! -d "$target_dir_path" ]] ; then
      if [[ "$std_amboso_version" > "$min_amboso_v_treegen" || "$std_amboso_version" = "$min_amboso_v_treegen" ]] ; then {
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
          git switch - #We get back to starting repo state
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
          git switch - 2>/dev/null #We get back to starting repo state
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
