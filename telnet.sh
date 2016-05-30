#! /usr/bin/sh
mac=(0 1 2 3 4 5 6 7 8 9 a b c d e f)
declare -a num

#echo "IP address:"
read -p "Please keyin IP address: " address
#echo "Mode"
read -p "please keyin your mode: " mode
{
 sleep 1
 echo admin
 sleep 1
 echo admin
 sleep 1
 echo "wless${mode}"
 sleep 1
 echo network
 sleep 1
 for ssid in $(seq 1 1)
 do
 	echo ssidp ${ssid}
 	sleep 3
 	echo macfilter
 	sleep 3
 	for aclmode in $(seq 1 2)
 	do
 		echo acl $aclmode
 		sleep 3
 		for i in $(seq 0 31)
 		do
 			for k in $(seq 0 11)
 			do
 				counter=$(($RANDOM % 16))
				if [ $k = 10 ] && [ $(($counter % 2)) = 1 ]; then
					counter=$(($counter + 1))
					if [ $counter = 16 ]; then
						counter=0		
					fi
				fi
 				num[$k]=${mac[$counter]}
 			done
 			echo "add ${num[11]}${num[10]}:${num[9]}${num[8]}:${num[7]}${num[6]}:${num[5]}${num[4]}:${num[3]}${num[2]}:${num[1]}${num[0]}"
 			sleep 3
 		done
 	done
 	echo "exit"
 	sleep 3
 	echo "exit"
 	sleep 3
 done
} | telnet $address
exit 0
