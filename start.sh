file=/etc/config/result
START=$(date +%s)
if [ -e $file ]; then
	echo "exists"
else
#	touch $file
#	chmod 644 $file
	echo "no exists"
fi

cbResult="null"
defaultKey=0
mode=$1
ssidNum=0

#disable for 8 SSID
for i in  $(seq 0 7)
do
	ssid="SST$i"
	cbResult=`echo $(securityCB.sh $mode $ssid disable)|awk '{print match($0,"ping AP pass")}'`;
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
			cbResult=`echo $(securityCB.sh $mode "SST0" wep $authType $inputType $keyLength $defaultKey $key)|awk '{print match($0,"ping AP pass")}'`;

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
			ssid="SST$ssidNum"

			if [ $k -eq 0 ]; then
				keyLength="63"
				key=123456789012345678901234567890123456789012345678901234567890123
			else
				keyLength="64"
				key=1234567890123456789012345678901234567890123456789012345678901234
			fi

			cbResult=`echo $(securityCB.sh $mode $ssid $securityMode $encryption $key $keyLength)|awk '{print match($0,"ping AP pass")}'`;
#securityCB.sh $mode $ssid $securityMode $encryption $key $keyLength 
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
		
		for k in $(seq 0 1)
		do
			if [ $k -eq 0 ]; then
				eapMethod="TTLS"
			else
				eapMethod="PEAP"
			fi

			for l in $(seq 0 1)
			do
				
				if [ $ssidNum -ge 8 ]; then
					ssidNum=0
				fi
				ssid="SST$ssidNum"

				if [ $l -eq 0 ]; then
					eapAuth="MSCHAP"
				else
					eapAuth="MSCHAPV2"
				fi

				id=sqa
				password=sqa
				cbResult=`echo $(securityCB.sh $mode $ssid $securityMode $encryption $eapMethod $eapAuth $id $password)|awk '{print match($0,"ping AP pass")}'`;
				ssidNum=$((ssidNum+1))
			done
		done
	done
done

END=$(date +%s)
DIFF=$(($END-$START))
echo "It took $DIFF seconds"
