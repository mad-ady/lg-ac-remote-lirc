#!/bin/bash -f
RATE=192000        # output file sampling rate[Hz]
BIT=16             # output file bit depth
SOX_CMD=`which sox`  # sox command path
# CHIP has following features
# - On-chip 24-bit DAC for play-back
# - Support 192K and 96K sample
# (from Allwinner R8 User Manual V1.1 Chapter 22 Audio Codec)

#code originally taken from https://bbs.nextthing.co/t/installing-lirc-on-c-h-i-p/2449/4
#and changed to output square wave instead of sine


# check args
if [ $# != 2 ]; then
    echo "error : arg error."
    echo "$0 <INPUT_FILE> <OUTPUT_FILE>"
    exit 1
fi
if [ ! -r ${1} ]; then
    echo "error : not found or can't read input file (${1})"
    echo "$0 <INPUT_FILE> <OUTPUT_FILE>"
    exit 1
fi

# check sox command
if [ ! -x ${SOX_CMD} ]; then
    echo "error : not found or can't execute sox command (${SOX_CMD})"
    exit 1
fi

# check output file name
if echo "${2}" | egrep -q '\.wav$' ; then
    OUTPUTFILE="${2}"
else
    OUTPUTFILE="${2}.wav"
fi

# check input data
INPUTDATA=`cat ${1} | tr "\012" " "` # load inputfile
if echo "${INPUTDATA}" | fgrep -q 'space' ; then
    INPUTDATA_SNIP=`echo "${INPUTDATA}" | sed -e 's/^[^u]*/p/'` # skip to 1st pulse
    INPUTDATA="" # clear
    STATE=0 ; ADD_FLG=0
    for data in ${INPUTDATA_SNIP}
    do
        # check ADD_FLG
        if [ $ADD_FLG != 0 ]; then
            STATE=${ADD_FLG} ; ADD_FLG=0 # flag handling
            ADD_NUM=`echo "${INPUTDATA}"   | sed -e 's/^.* \([0-9]*\)$/\1/'` # get    prev data
            INPUTDATA=`echo "${INPUTDATA}" | sed -e 's/^\(.*\) [0-9]*$/\1/'` # remove prev data
            data=`echo "${data} + ${ADD_NUM}" | bc` # add data now + prev
            INPUTDATA="${INPUTDATA} ${data}"
            continue
        fi

        # check pulse or space
        if [ $data = "pulse" -o $data = "space" ]; then
            if [ $STATE = $data ]; then
                ADD_FLG=$data # double line detected!
                continue
            else
                STATE=$data # next state
                continue
            fi
        fi

        INPUTDATA="${INPUTDATA} $data"
    done # end for INPUTDATA_SNIP

fi




# calc sampling period[us]
SMP_PERI=`echo "scale=3;1000000/${RATE}" | bc`

# set sox command option
SOX_OPT="-r ${RATE} -b ${BIT} -n ${OUTPUTFILE}"

STATE="pulse"
for data in ${INPUTDATA}
do
    LEN=`echo "${data}/${SMP_PERI}"|bc`  # get length[sample]
    if [ $STATE = "pulse" ]; then
#        SOX_OPT="${SOX_OPT} synth ${LEN}s sine 19k 0 0 sine 19k 0 50" # sine wave 19kHz 2ch phase shift
	SOX_OPT="${SOX_OPT} synth ${LEN}s square 10 0 0" # square wave 10Hz
        STATE="space"  # next state
    else
        SOX_OPT="${SOX_OPT} pad 0s ${LEN}s :" # add blank to tail
        STATE="pulse"  # next state
    fi
done

SOX_OPT=`echo "${SOX_OPT}" | sed -e 's/:$//'`

# execute sox
#echo $SOX_CMD $SOX_OPT
$SOX_CMD $SOX_OPT
