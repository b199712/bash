#! /bin/sh
# AP change security


#mode	ssidNum	disable
#mode	ssidNum	wep	open/shared	hex/ascii	64/128/152	1~4	key
#mode	ssidNum	psk/psk2	tkip/aes	key
#mode	ssidNum	wpa/wpa2	tkip/aes	serverIP	serverSecret

saveApply()
{
	#uci commit wireless
	#luci-reload network lanip
	echo "CPass"
	echo "CPass"
	echo "CPass"
	echo "CPass"
	echo "CPass"
}

checkSSID()
{

	if [ $(uci get wireless.$interface.WLANEnable) -eq 0 ]; then
		uci set wireless.$interface.WLANEnable=1
	fi
	
	if [ $(uci get wireless.$interface.ssid) != "$ssid" ]; then
		uci set wireless.$interface.ssid="$ssid"
	fi
}

disable()
{

	uci set wireless.$interface.encryption=none
	
	#echo "AP change security to disable successful."
}

wep()
{
	encryption="wep $1"
	inputType=$2
	keyLength=$3
	defaultKey=$4
	key=$5

	#choice input type hex is 1 and ascii is 2
	if [ $inputType = "hex" ]; then
		uci set wireless.$interface.WepInputMethod=1
	elif [ $inputType = "ascii" ]; then
		uci set wireless.$interface.WepInputMethod=2
	else
		echo "ERROR:Input wrong input type"
		exit 0
	fi
	
	uci set wireless.$interface.PreferBSSIDEnable=0
	uci set wireless.$interface.encryption="$encryption"
	uci set wireless.$interface.WepKeyLen=$keyLength
	#set key index and key
	for i in $(seq 1 4)
	do
		if [ $defaultKey -eq $i ]; then
			uci set wireless.$interface.WepKeyIdx=$i
			uci set wireless.$interface.key$i=$key
		else
			uci set wireless.$interface.key$i=""
		fi
	done
}

psk()
{
	encryption="$1 $2"
	key=$3
	
	uci set wireless.$interface.PreferBSSIDEnable=0
	uci set wireless.$interface.encryption="$encryption"
	uci set wireless.$interface.key=$key
		
}

wpa()
{
	encryption="$1 $2"
	server=$3
	srvSecret=$4
	
	uci set wireless.$interface.encryption="$encryption"	
	uci set wireless.$interface.PreferBSSIDEnable=0
	uci set wireless.$interface.WLANWpaRadiusSrvSecret=$srvSecret
	uci set wireless.$interface.server=$server
}

#interface=$1$2
mode=$1
ssidNum=$2
ssid="SST$2"
secur=$3


#set interface 2.4G is w0_index19 and 5G is w1_index19
if [ $mode -eq 2 ]; then
	interface="w0_index$2"
elif [ $mode -eq 5 ]; then
	interface="w1_index$2"
else
	echo "ERROR: Wrong mode."
	exit 0
fi


#uci set wireless.$interface$2.ssid=$ssid

checkSSID

#choice security type
#if [ $secur = "disable" ]; then
#	disable
#elif [ $secur = "wep" ]; then
#	wep $3 $4 $5 $6 $7
#elif [ $secur = "psk" ] || [ $secur = "psk2" ]; then
#	echo "psk $3 $4 $5"
#elif [ $secur = "wpa" ] || [ $secur = "wpa2" ]; then
#	echo "wpa $3 $4 $5 $6 $7 $8"
#else
#	echo "ERROR: Wrong security type."
#	exit 0
#fi

case $secur in
"disable")
	disable
	;;
"wep")
	wep $4 $5 $6 $7 $8
	;;
"psk" | "psk2")
	psk $3 $4 $5
	;;
"wpa" | "wpa2")
	wpa $3 $4 $5 $6
	;;
*)
	echo "ERROR: Wrong security type."
	exit 1
esac

saveApply

#sleep 5

