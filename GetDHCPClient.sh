#!/bin/bash
declare -r filepath=/var/lib/dhcp/dhcpd.leases
declare -a ip
declare -a row
declare -i count=0
declare -i repeat=0
if [ -e $filepath ]; then
	DATE=$(date +"%Y/%m/%d")
	NOW=$(date -d $(date +"%H:%M:%S") '+%s')
	startArray=($(cat $filepath |awk '$1=="lease" {print NR}'))
	#temp=$(cat $filepath |awk '$1=="lease" {print NR}')
	#echo $temp >> start.txt
	#IFS=' ' read -a startArray <<< "$(cat start.txt)"
	#rm start.txt
	#echo ${#startArray[@]}
	#echo $temp
	for i in "${startArray[@]}"
	do
		tempIP=$(cat $filepath |tail -n+${i}|head -n 1|awk '{print $2}')
		for j in $(seq 0 ${#ip[@]})
		do
			if [ "$tempIP" == "${ip[$j]}" ]; then
				#echo "tempIP=$tempIP j=$j count=$count i=$i"
				row[$j]=${i}
				((repeat++))
			fi
		done
		if [ $repeat -eq 0 ]; then
			ip[$count]=${tempIP}
			row[$count]=${i}
			((count++))
		fi
		repeat=0
	done
	count=0

	for i in "${row[@]}"
	do
		tempTime=$(cat $filepath |tail -n+$(($i+2))|head -n 1|awk '{print $3 " " $4}'|sed 's/;//')
		endTime=$(($(date -d "$tempTime" '+%s')+28800))

		if [ $endTime -gt $NOW ]; then
			#leaseTime[$count]= date -d "1970-01-01 $endTime seconds" +"%Y-%m-%d %H:%M:%S"

			tempMAC=$(cat $filepath |tail -n+$(($i+6))|head -n 1|awk '{print $3}'|sed 's/;//')

			if [ "$tempMAC" == "" ]; then
				tempMAC=$(cat $filepath |tail -n+$(($i+5))|head -n 1|awk '{print $3}'|sed 's/;//')
			fi

			leaseTime=$(date -d "1970-01-01 UTC $endTime seconds" +"%Y-%m-%d %H:%M:%S")
			echo ${ip[$count]} $tempMAC $leaseTime

		fi
		((count++))
	done

	#echo ${#row[@]}
	#echo ${#endArray[@]}
else
	echo $filepath does not exist
fi
exit 0
