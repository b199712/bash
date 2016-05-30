checkSSID()
{
	for i in $(seq 0 7)
	do
		if [ $(uci get wireless.$interface$i.WLANEnable) -eq 0 ]; then
			#uci set wireless.$interface$i.WLANEnable=1
			echo "ssid$i is not open"		
		fi
		
		if [ $(uci get wireless.$interface$i.ssid) != "SST$i" ]; then
			#uci set wireless.$interface$i.ssid="SST$i"
			echo "ssid$i is not SST$i"
		fi
	done
}

ssidNum=0
mode=$1
radiusServer=192.168.1.254
srvSecret=12345678

if [ $mode -eq 2 ]; then
	interface="w0_index"
elif [ $mode -eq 5 ]; then
	interface="w1_index"
else
	echo "ERROR: Wrong mode."
	exit 0
fi

checkSSID

for i in  $(seq 0 7)
do
	securityAP.sh $interface $i disable
#echo $i
done

#wep
for i in $(seq 0 1)
do
	


	if [ $i -eq 0 ]; then
		authType="open"
	else
		authType="shared"
	fi
	
	for j in $(seq 0 1)
	do
		if [ $j -eq 0 ]; then
			inputType="hex"
		else
			inputType="ascii"
		fi
		
		for k in $(seq 0 2)
		do
			defaultKey=$((defaultKey+1))
			if [ $defaultKey -ge 5 ]; then
				defaultKey=1
			fi	

			case $k in
			0)
				keyLength=64
				if [ $j -eq 0 ]; then
					key=1234567890
				else
					key=12345
				fi
				;;
			1)
				keyLength=128
				if [ $j -eq 0 ]; then
					key=12345678901234567890123456
				else
					key=1234567890123
				fi
				;;
			2)
				keyLength=152
				if [ $j -eq 0 ]; then
					key=12345678901234567890123456789012
				else
					key=1234567890123456
				fi
				;;
			esac

#echo $interface 0 wep $authType $inputType $keyLength $defaultKey $key
			securityAP.sh $interface 0 wep $authType $inputType $keyLength $defaultKey $key
#sleep 10

		done
	done
done

#psk
for i in $(seq 0 1)
do
	
	if [ $i -eq 0 ]; then
		securityMode="psk"
	else
		securityMode="psk2"
	fi
	
	for j in $(seq 0 1)
	do
		if [ $j -eq 0 ]; then
			encryption="tkip"
		else
			encryption="aes"
		fi
		
		for k in $(seq 0 1)
		do
			if [ $k -eq 0 ]; then
				keyLength="63"
				key=123456789012345678901234567890123456789012345678901234567890123
			else
				keyLength="64"
				key=1234567890123456789012345678901234567890123456789012345678901234
			fi

			#cbResult=`echo $(securityCB.sh $mode $ssid $securityMode $encryption $key $keyLength)|awk '{print match($0,"ping AP pass")}'`;
#echo $interface $ssidNum $securityMode $encryption $key
			securityAP.sh $interface $ssidNum $securityMode $encryption $key
#			echo $cbResult

			ssidNum=$((ssidNum+1))
		done
	done
done

#wpa
for i in $(seq 0 1)
do
	
	if [ $i -eq 0 ]; then
		securityMode="wpa"
	else
		securityMode="wpa2"
	fi
	
	for j in $(seq 0 1)
	do
		if [ $j -eq 0 ]; then
			encryption="tkip"
		else
			encryption="aes"
		fi

		if [ $ssidNum -ge 8 ]; then
			ssidNum=0
		fi
		
		echo $interface $ssidNum $securityMode $encryption $radiusServer $srvSecret
		securityAP.sh $interface $ssidNum $securityMode $encryption $radiusServer $srvSecret
		ssidNum=$((ssidNum+1))
	done
done

