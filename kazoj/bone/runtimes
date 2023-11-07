#!/bin/bash

function run_args_gt {
  args="$1"
  target="$2"
  tstart=`date +%s.%N`
  ./amboso -B$args >/dev/null 2>/dev/null
  run_exitcode="$?"
  tend=`date +%s.%N`
  runtime=$( echo "$tend - $tstart" | bc -l )
  display_zero=$(echo $runtime | cut -d '.' -f 1)
  if [[ -z $display_zero ]]; then {
    display_zero="0"
  } else {
    display_zero=""
  }
  fi
  runtime="$display_zero$runtime"
  #echo -e "[ARGS: "$args"] {$msg}"
  #echo -e "Took $runtime seconds."
  if [[ $runtime > $target ]] ; then {
    return 0
  } else {
    echo -e "[ $args ] < [ $comment ] FAIL:    timed [ $runtime ] < [ $target ]."
    return 1
  }
  fi
}

function echo_tr_msg {
  res="$1"
  [[ $res -eq 0 ]] || exit
  time="$2"
  comment="$3"
  echo -e "$comment e: $run_exitcode r: $res"
}

function time_test_asc {
  stuff="$1"
  txt="$2"
  run_args_gt "$stuff" "$runtime" "$2"
  echo_tr_msg "$?" "$runtime" "$txt"
}

#Need to set the lowest time
run_args_gt "v" "0"
echo_tr_msg "$?" "$runtime" "[VERS]    $(./amboso -vv)"

#time_test_asc "H" "[HELP]" #May be faster than asking just the version??
#time_test_asc "Bbd 0.1.0" "[BASE][BUILD][DELETE] 0.1.0" #May be faster than -Bqbd
#time_test_asc "Bqbrd 0.1.0" "[BASE][QUIET][BUILD][RUN][DELETE] 0.1.0" #May be faster than -Bqbd
#time_test_asc "Bbrd 0.1.0" "[BASE][BUILD][RUN][DELETE] 0.1.0" #May be faster than -Bqbd
time_test_asc "Bqbd 0.1.0" "[BASE][QUIET][BUILD][DELETE] 0.1.0"
time_test_asc "BbdV 0.1.0" "[BASE][BUILD][DELETE][VERB] 0.1.0"
#time_test_asc "BbdrV 0.1.0" "[BASE][BUILD][RUN][DELETE][VERB] 0.1.0" #May be faster than -BbdV

time_test_asc "Bqip" "[BASE][QUIET][INIT][PURGE]"
#time_test_asc "Bqirp 0.1.0" "[BASE][QUIET][INIT][RUN][PURGE]" #May be faster than -Bqip
time_test_asc "Bip" "[BASE][INIT][PURGE]"
#time_test_asc "Birp 0.1.0" "[BASE][INIT][RUN][PURGE]" May be faster than -Bip


time_test_asc "BipV" "[BASE][INIT][PURGE][VERB]"
#time_test_asc "BirpV 0.1.0" "[BASE][INIT][RUN][PURGE][VERB]" #May be faster than -BipV

echo -e "\n    SUCCESS:    all timed commands took longer than the one before."
