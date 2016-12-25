#FOR creating difrent types of pools
#
#
#
#
######################################
POOLNAME=tank

function get_luns {
	i=1
	cat luns.lst | while read line
	do
	    for word in $line
	    do
		lun_array[$i]=$word
		let i=i+1
	    done
	done
}

function start_vdb {
	echo "RUN VDBENCH on BACKGROUNG"
	/opt/vdbench/vdbench.bash -f vdb.conf > /dev/null 2>&1 &
	VDB_PID=$!
	echo "VDBENCH PID is $VDB_PID"
}

function run_trim {
	echo "START TRIM"
	time zpool trim $POOLNAME
        sleep 5
	while true; do  
			zpool status $POOLNAME
			sleep 1
			status=$(zpool status tank | awk '/trim/ {print($2)}')
			[ $status = "completed" ] && break
		done
	
}

#difrent types of pool
case "$1" in
  "mirror")
    get_luns
    zpool create -f $POOLNAME mirror ${lun_array[1]} ${lun_array[2]} log ${lun_array[3]} cache ${lun_array[4]} special ${lun_array[5]} 
    ;;
  "raidz")
    get_luns
    zpool create -f $POOLNAME raidz ${lun_array[1]} ${lun_array[2]} log ${lun_array[3]} cache ${lun_array[4]} special ${lun_array[5]}
    ;;
  "raidz2")
    get_luns
    zpool create -f $POOLNAME raidz2 ${lun_array[1]} ${lun_array[2]} ${lun_array[6]} ${lun_array[7]} log ${lun_array[3]} cache ${lun_array[4]} special ${lun_array[5]}
    ;;
  "raidz3")
    get_luns
    zpool create -f $POOLNAME raidz3 ${lun_array[1]} ${lun_array[2]} ${lun_array[6]} ${lun_array[7]} log ${lun_array[3]} cache ${lun_array[4]} special ${lun_array[5]}
    ;;
  "raid10")
    get_luns
    zpool create -f $POOLNAME mirror ${lun_array[1]} ${lun_array[2]} mirror ${lun_array[6]} ${lun_array[7]} mirror ${lun_array[8]} ${lun_array[9]}  log ${lun_array[3]} cache ${lun_array[4]} special ${lun_array[5]}
    ;;
 "destroy")
    pkill -9 java
    zpool destroy -f $POOLNAME
    ;;
 "test")
    start_vdb
    echo "Wait 60 seconds to fill ... STAGE 1"
    sleep 60
    pkill -9 java
    start_vdb
    echo "Wait 60 seconds to fill ... STAGE 2"
    sleep 60
    run_trim
   ;;
  *)
    echo "You have failed to specify what to do correctly."
    exit 1
    ;;
esac
