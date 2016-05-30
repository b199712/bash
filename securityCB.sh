#! /bin/sh
# CB change security
# modify test result


#mode	ssid	disable
#mode	ssid	wep	open/shared	hex/ascii	64/128/152	1~4	key
#mode	ssid	psk/psk2	tkip/aes	key	keyLength
#mode	ssid	wpa/wpa2	tkip/aes	PEAP/TTLS	MSCHAP/MSCHAPV2	id	password

saveApply()
{
	uci commit wireless
	luci-reload network lanip
}

pingtest()
{
#echo $1
#echo $secur

	result=$(ping -c 5 192.168.1.1 | grep loss | cut -c 24)
	if [ $result -gt 1 ]; then
		uci set result.$secur.$1="pass"
		echo "ping AP pass"

	else
		uci set result.$secur.$1="failure"
		echo "ping AP failure"

	fi
	uci commit result	
}

disable()
{
	uci set wireless.$interface.encryption=none	
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
	eapMeth=$3
	eapAuth=$4
	id=$5
	password=$6
	
	uci set wireless.$interface.encryption="$encryption"
	uci set wireless.$interface.PreferBSSIDEnable=0
	uci set wireless.$interface.eap_type=$eapMeth
	uci set wireless.$interface.auth=$eapAuth
	uci set wireless.$interface.identity=$id
	uci set wireless.$interface.password=$password
}

mode=$1
ssid=$2
secur=$3

#set interface 2.4G is w0_index19 and 5G is w1_index19
if [ $mode -eq 2 ]; then
	interface="w0_index19"
elif [ $mode -eq 5 ]; then
	interface="w1_index19"
else
	echo "ERROR: Wrong mode."
	exit 0
fi

uci set wireless.$interface.ssid=$ssid


#
#echo "SSID: $ssid"
#echo "SECUR: $secur"
#


#choice security type
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
	wpa $3 $4 $5 $6 $7 $8
	;;
*)
	echo "ERROR: Wrong security type."
	exit 1
esac

saveApply
sleep 10

case $secur in
"disable")
	pingtest $ssid
	;;
"wep")
	pingtest $4"_"$5"_"$6
	;;
"psk" | "psk2")
	pingtest $4"_"$6
	;;
"wpa" | "wpa2")
	pingtest $4"_"$5"_"$6
	;;
*)
	echo "ERROR: Wrong security type."
	exit 1
esac
