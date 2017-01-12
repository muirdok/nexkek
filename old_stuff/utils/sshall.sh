#!/bin/bash
cat inventory.kek | while read line
do
    for word in $line
    do
	echo "DO IT FOR $word"
       ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@$word
    done
done
