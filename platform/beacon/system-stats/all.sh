#!/bin/bash
SERVER=$1
PORT=$2

cd `dirname $0`/scripts
function allStats() {
    (for i in ./*.sh; do
        timeout 5 $i
    done) | sort | uniq | grep '|g$'
}

if [[ ! -z $SERVER ]] && [[ ! -z $PORT ]]; then
    echo "Sending stats to server $SERVER:$PORT"
    allStats > /tmp/stats.txt
    NLINES=`cat /tmp/stats.txt | wc -l`
    for I in `seq 0 $((NLINES / 10))`; do
        START=$((I * 10 + 1))
        END=$((START + 9))
        END=$((END > NLINES ? NLINES : END))
        if [[ $START -le $END ]]; then
            cat /tmp/stats.txt | sed -n ${START},${END}p | /bin/nc -q 1 -w 1 -u $SERVER $PORT
            if [[ $END -ge $NLINES ]]; then
                exit 0
            fi
            sleep 5
        fi
    done
else
    allStats
fi
