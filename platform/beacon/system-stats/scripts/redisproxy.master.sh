#!/bin/bash
for i in 6421 6422 6423 6424 6425 6426 6427 6428 6429 6430 6431
do
  echo -n "system.`hostname -s`.redisproxy.master$i:"
  (echo -e " info replication\n\n quit\n" | nc -q 1 172.17.0.1 $i | grep role:master) > /dev/null 2> /dev/null && echo "1|g" || echo "0|g"
done
