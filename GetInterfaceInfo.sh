#! /usr/bin/bash

TotalControllers=`ip link show | grep -i -c 'BROADCAST'`

temp=`ip link show | grep -i 'BROADCAST' | cut -d ':' -f2 | tr -d ' '`

declare -a IOPorts1
declare -a IOPorts2

for (( counter=0 ; counter < $TotalControllers ; counter++ ))
do
	offset=$(($counter+1))
	IOPorts1[$counter]=`echo $temp|cut -f$offset -d" "`
	if (ethtool -i ${IOPorts1[$counter]}) &> /dev/null; then
		IOPorts2[$counter]=`ethtool -i ${IOPorts1[$counter]}|grep 'bus-info'|cut -f3- -d :`
	fi
done

for ((counter=0 ; counter < $TotalControllers ; counter++))
do
	AdapterName=`lspci -v | grep ${IOPorts2[$counter]} -A 1 | grep 'Subsystem'|cut -f2- -d" "`
	EthernetController=`lspci -v |grep ${IOPorts2[$counter]} | cut -f4- -d" "`
	DeviceID=`lspci -n | grep ${IOPorts2[$counter]} |cut -f3- -d " "`
	DriverName=`ethtool -i ${IOPorts1[$counter]} | grep -i 'driver' | cut -f2 -d" "`
	DriverVersion=`ethtool -i ${IOPorts1[$counter]} | grep -m 1 -i 'version'| cut -f2 -d" "`
	echo "${IOPorts1[$counter]}"
	echo "    Make/Model = $AdapterName"
	echo "    Ethernet controller = $EthernetController"
	echo "    VenID:DevID = $DeviceID"
	echo "    Driver name = $DriverName"
	echo "    Driver version = $DriverVersion"
done
exit 0
