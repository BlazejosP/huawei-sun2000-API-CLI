#!/bin/bash

# Tool for login and get data from Huawei FusionSolar https://eu5.fusionsolar.huawei.com
# This tool use oficial FusionSolar API described here https://forum.huawei.com/enterprise/en/communicate-with-fusionsolar-through-an-openapi-account/thread/591478-100027 by manufacturer 
# You must have installed on your linux tools like jq, httpie, curl
#
# sudo apt-get install jq
# sudo apt-get install httpie
# sudo apt install curl
#
# To use this script you need account on Huawei FusionSolar https://eu5.fusionsolar.huawei.com and developer privilege.
# Contact service team at eu_inverter_support@huawei.com to create an openAPI account for your plant.
# in email like this
#Hi, I hereby request an openAPI user account to access the data from my inverter(s) through the new #FusionSolar API:
#
#System name: <--here data-->
#
#Username: <--here data-->
#
#Plant Name: <--here data-->
#
#SN Inverter: <--here data-->

# Configuration section
#----------------------
userName="<--here data-->" #your login name to openAPI user account
systemCode="<--here data-->" #Password of the third-party system openAPI user account
#----------------------

Error_Codes_List () {

#Errors which are possible during login and connection to Huawei SolarFussion API based on documentation SmartPVMS.V300R006C10_API_Northbound.Interface.Reference.1.pdf pages 109-110. and own experiments.
  
if [ $1 == "0"  ];
then
	echo "Normal Status"
elif [ $1 == "20001"  ];
then	
	echo "The third-party system ID does not exist."
elif [ $1 == "305"  ] || [ $1 = "306" ];
then	
	echo "You are not in the login state. You need to log in again."
elif [ $1 == "401"  ];
then	
	echo "You do not have the related data interface permission."
elif [ $1 == "407"  ];
then	
	echo "The interface access frequency is too high."
elif [ $1 == "413"  ];
then	
	echo "Your IP is locked."
elif [ $1 == "20002"  ];
then	
	echo "The third-party system is forbidden."
elif [ $1 == "20003"  ];
then	
	echo "The third-party system has expired."
elif [ $1 == "20004"  ];
then	
	echo "The server is abnormal."
elif [ $1 == "20005"  ];
then	
	echo "The device ID cannot be empty."
elif [ $1 == "20006"  ];
then	
	echo "Some devices do not match the device type."
elif [ $1 == "20007"  ];
then	
	echo "The system does not have the desired power plant resources."
elif [ $1 == "20008"  ];
then	
	echo "The system does not have the desired device resources."
elif [ $1 == "20009"  ];
then	
	echo "Queried KPIs are not configured in the system."
elif [ $1 == "20010"  ];
then	
	echo "The plant list cannot be empty."
elif [ $1 == "20011"  ];
then	
	echo "The device list cannot be empty."
elif [ $1 == "20012"  ];
then	
	echo "The query time cannot be empty."
elif [ $1 == "20013"  ];
then	
	echo "The device type is incorrect. The interface does not support operations on some devices."
elif [ $1 == "20014" ] || [ $1 = "20015" ];
then	
	echo "A maximum of 100 plants can be queried at a time."
elif [ $1 == "20016" ] || [ $1 = "20017" ];
then	
	echo "A maximum of 100 devices can be queried at a time."
elif [ $1 == "20018"  ];
then	
	echo "A maximum of 10 devices can be manipulated at a time."
elif [ $1 == "20019"  ];
then	
	echo "The switch type is incorrect. 1 and 2 indicate switch-on and switch-off respectively."
elif [ $1 == "20020"  ];
then	
	echo "The upgrade package specific to the device version cannot be found"
elif [ $1 == "20021"  ];
then	
	echo "The upgrade file does not exist."
elif [ $1 == "20022"  ];
then	
	echo "The upgrade records of the devices in the system are not found."
elif [ $1 == "20023"  ];
then	
	echo "The query start time cannot be later than the query end time."
elif [ $1 == "20024"  ];
then	
	echo "The language cannot be empty."
elif [ $1 == "20025"  ];
then	
	echo "The language parameter value is incorrect."
elif [ $1 == "20026"  ];
then	
	echo "Only data of the latest 365 days can be queried."
elif [ $1 == "20027"  ];
then	
	echo "The query time period cannot span more than 31 days."
else
	echo "Unknown error."
fi

}

# Login to FusionSolarAPI with Username and Password
logowanie=$(echo '{userName: "'$userName'", systemCode: "'$systemCode'"}'| http --print=hb --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/login  Content-Type:'application/json'  Cookie:'Cookie_1=value; web-auth=true;')


#show as answer of of API for question
#echo $logowanie

#coping a long string with answer to new variable from which we extract JOSN answer
logowanie_for_josn_extraction=$(echo $logowanie)


IFS=';'
array=( $logowanie )
#echo "value = ${array[4]}"
logowanie=${array[4]}
jsesionid=${array[6]}

IFS=':'
array=( $logowanie )
#echo "value = ${array[4]}"
logowanie=${array[4]}


IFS='='
array=( $logowanie )
xsrf_token=${array[1]}


IFS=':'
array=( $jsesionid )
jsesionid=${array[1]}

IFS='='
array=( $jsesionid )
jsesionid=${array[1]}

#echo ""
#echo "XSRF-TOKEN: "$xsrf_token
#echo "JSESSIONID: "$jsesionid
#echo ""

#extracting from rubish string JOSN answer part
array2=( $logowanie_for_josn_extraction )


usucesfully_login=$(echo ${array2[7]})
sucesfully_login=$(echo ${array2[11]})

if [[ $usucesfully_login =~ "false"  ]];
	then		
			echo ""
			echo -e "Login to server \e[41mError :(\e[0m"
			josn=$(echo ${array2[7]})
elif [[ $sucesfully_login =~ "true"  ]];
	then			
			echo ""
			echo -e "Login to server \e[42mOK :)\e[0m"
			josn=$(echo ${array2[11]})
else
	echo ""
	echo -e "Problems with conection to Huawei Server" 
fi
#echo $josn


josn_final=`echo "$josn" | grep -o '{.*'`

#show response from API in JOSN
#echo $josn_final | jq


success=$(echo ''$josn_final''  | jq '.success' )
buildCode=$(echo ''$josn_final''  | jq '.buildCode' )
failCode=$(echo ''$josn_final''  | jq '.failCode' )
message=$(echo ''$josn_final''  | jq '.message' )
data=$(echo ''$josn_final''  | jq '.data' )

if [[ $usucesfully_login =~ "false"  ]];
	then		
		params=$(echo ''$josn_final''  | jq '.params' )	
			currentTime=$(echo ''$josn_final''  | jq '.params.currentTime' )
			systemCode=$(echo ''$josn_final''  | jq '.params.systemCode' )
			userName=$(echo ''$josn_final''  | jq '.params.userName' )
elif [[ $sucesfully_login =~ "true"  ]];
	then
		params=$(echo ''$josn_final''  | jq '.params' )	
fi


#removing " on begining and end
buildCode=`echo "$buildCode" | grep -o '[[:digit:]]'`

#echo "Request success or failure flag: " $success
if [[ $success == "true"  ]];
	then	
		echo "Username & Password accepted by Huawei Server"
		login_status=true
elif [[ $success == "false" ]];
	then
		echo "Username & Password not accepted by Huawei Server"
		login_status=false
else
	echo ""
	echo -e "\e[41mNetwork Error :(\e[0m" 
	echo "Returned data: "$data
	#program stops
	exit
fi

#echo "Error code: " $failCode " (0: Normal)"
# we call to function with errors list
Error_Codes_List $failCode

#echo "Optional message: " $message
if [[ ! $message == "\"\""  ]];
then	
	echo "Optional message: " $message
fi

echo "Build Code: "$buildCode

if [[ $usucesfully_login =~ "false"  ]];
then	
	#shorter time for read in unix
	local curent_time_actually=$(echo ${currentTime::-3})
	local curent_time_actually=$(date -d @$curent_time_actually)
	echo "Time of your Request to API: "$curent_time_actually
	
	echo "Your data:"
	echo "	Username: "$userName
	echo "	Password: "$systemCode

fi
		
if [[ $sucesfully_login =~ "true"  ]];
then	
	if [[ ! $params == "null"  ]];
	then	
		echo "Request parameter: "$params
	fi
fi


if [[ ! $data == "null"  ]];
then	
	echo "Returned data: "$data
fi

echo ""


# Request to API getStationList
getStationList=$(printf '{ }'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getStationList  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')

#echo $getStationList 


AlarmID=$(echo ''$getStationList''  | jq '.failCode' )
AlarmID=$(expr $AlarmID)

	if [[ $AlarmID == 0 ]];
		
		#Alarm severity 3=Major 2=Minor 1=Warning
		then
			opis_bledow=$(echo "No Errors device working correctly" )
			Alarm_severity=0
	
		elif [$AlarmID -ge 2001]
		then
			opis_bledow=$(echo "High String Input Voltage" )
			Alarm_severity=3
			Possible_cause=$(echo "Excessive PV modules are connected in series in the PV array. Therefore, the open-circuit voltage exceeds the maximum input voltage of the SUN2000.")

		elif [$AlarmID -ge 2002]
		then
			opis_bledow=$(echo "DC Arc Fault" )
			Alarm_severity=3
			Possible_cause=$(echo "The PV string power cable arcs or is in poor contact.")
	
		elif [$AlarmID -ge 2011]
		then
			opis_bledow=$(echo "String Reversed" )
			Alarm_severity=3
			Possible_cause=$(echo "The PV string is reversely connected.")
	
		elif [$AlarmID -ge 2012]
		then
			opis_bledow=$(echo "String Current Backfeed" )
			Alarm_severity=1
			Possible_cause=$(echo "Only a few PV modules are connected in series in the PV string. Therefore, the end voltage is lower than that of other PV strings")

		elif [$AlarmID -ge 2013]
		then
			opis_bledow=$(echo "Abnormal String" )
			Alarm_severity=1
			Possible_cause=$(echo " ")
	
		elif [$AlarmID -ge 2021]
		then
			opis_bledow=$(echo "AFCI Self-test Fault" )
			Alarm_severity=3
			Possible_cause=$(echo " ")
	

		elif [$AlarmID -ge 2031]
		then
			opis_bledow=$(echo "Power grid phase wire short-circuit to PE" )
			Alarm_severity=3
			Possible_cause=$(echo "Cause ID = 1 The impedance of the output phase wire is low or short-circuited to PE")	

		elif [$AlarmID -ge 2032]
		then
			opis_bledow=$(echo "Grid Failure" )
			Alarm_severity=3
			Possible_cause=$(echo "Cause ID = 1 The power grid experiences an outage. The AC circuit is disconnected or the AC switch is off.")

		elif [$AlarmID -ge 2033]
		then
			opis_bledow=$(echo "Grid Undervoltage" )
			Alarm_severity=3
			Possible_cause=$(echo "Cause ID = 1 The power grid voltage is below the lower threshold or the undervoltage duration exceeds the value specified by LVRT")

		elif [$AlarmID -ge 2034]
		then
			opis_bledow=$(echo "Grid Overvoltage" )
			Alarm_severity=3
			Possible_cause=$(echo "Cause ID = 1 The power grid voltage is beyond the upper threshold or the overvoltage duration exceeds the value specified by HVRT.")
		
		elif [$AlarmID -ge 2035]
		then
			opis_bledow=$(echo "Unbalanced Grid Voltage" )
			Alarm_severity=3
			Possible_cause=$(echo "Cause ID = 1 The difference between grid phase voltages exceeds the upper threshold.")

		elif [$AlarmID -ge 2036]
		then
			opis_bledow=$(echo "Grid Overfrequency" )
			Alarm_severity=3
			Possible_cause=$(echo "Cause ID = 1 Power grid exception: The actual power grid frequency is higher than the standard requirement for the local power grid.")

		elif [$AlarmID -ge 2037]
		then
			opis_bledow=$(echo "Grid Underfrequency" )
			Alarm_severity=3
			Possible_cause=$(echo "Cause ID = 1 Power grid exception: The actual power grid frequency is lower than the standard requirement for the local power grid.")
	
		elif [$AlarmID -ge 2038]
		then
			opis_bledow=$(echo "Grid Frequency Instability" )
			Alarm_severity=3
			Possible_cause=$(echo "Cause ID = 1 Power grid exception: The actual grid frequency change rate does not comply with the local power grid standard.")
	
		elif [$AlarmID -ge 2039]
		then
			opis_bledow=$(echo "Output Overcurrent" )
			Alarm_severity=3
			Possible_cause=$(echo "Cause ID = 1 The power grid voltage drops dramatically or the power grid is short-circuited. As a result, the SUN2000 transient output current exceeds the upper threshold and therefore the protection is triggered.")
										
		elif [$AlarmID -ge 2040]
		then
			opis_bledow=$(echo "Large DC of Output current" )
			Alarm_severity=3
			Possible_cause=$(echo "Cause ID = 1 The DC component of the SUN2000 output current exceeds the specified upper threshold.")

		elif [$AlarmID -ge 2051]
		then
			opis_bledow=$(echo "Abnormal Leakage Current" )
			Alarm_severity=3
			Possible_cause=$(echo "Cause ID = 1 The insulation impedance of the input side to PE decreases when the SUN2000 is operating.")
	
		elif [$AlarmID -ge 2061]
		then
			opis_bledow=$(echo "Abnormal Ground" )
			Alarm_severity=3
			Possible_cause=$(echo "Cause ID = 1 The N cable or ground cable is not connected or When a PV array is grounded, the inverter output is not connected to an isolation transformer.")												
	
		elif [$AlarmID -ge 2062]
		then
			opis_bledow=$(echo "Low Insulation Resistance" )
			Alarm_severity=3
			Possible_cause=$(echo "Cause ID = 1 PV arrays are short-circuited with PE. Or the ambient air of the PV array is damp and the insulation between the PV array and the ground is poor.")
		
		elif [$AlarmID -ge 2063]
		then
			opis_bledow=$(echo "High Temperature" )
			Alarm_severity=3
			Possible_cause=$(echo "Cause ID = 1 The SUN2000 is installed in a place with poor ventilation. Or The ambient temperature is too high. Or The SUN2000 is not working properly.")
		
		elif [$AlarmID -ge 2064]
		then
			opis_bledow=$(echo "Abnormal Equipment" )
			Alarm_severity=3
			Possible_cause=$(echo "Cause ID = 1–12 An unrecoverable fault has occurred on a circuit inside the SUN2000.")
	
		elif [$AlarmID -ge 2065]
		then
			opis_bledow=$(echo "Upgrade Failed" )
			Alarm_severity=2
			Possible_cause=$(echo "Cause ID = 1, 2 and 4 The upgrade does not complete normally. NOTE Upgrade the inverter again if it is stuck in initialization state without generating any alarms and cannot be restored to the normal state during the upgrade when the PV inputs are disconnected and reconnected next time.")

		elif [$AlarmID -ge 2066]
		then
			opis_bledow=$(echo "License Expired" )
			Alarm_severity=1
			Possible_cause=$(echo "Cause ID = 1 The privilege certificate has entered the grace period. Or the privilege feature will be invalid soon.")	

		elif [$AlarmID -ge 61440]
		then
			opis_bledow=$(echo "Abnormal Monitor Unit" )
			Alarm_severity=2
			Possible_cause=$(echo "Cause ID = 1 The flash memory is insufficient. Or the flash memory has bad sectors.")

		elif [$AlarmID -ge 2067]
		then
			opis_bledow=$(echo "Power collector fault" )
			Alarm_severity=3
			Possible_cause=$(echo "Cause ID = 1 The power meter communication is interrupted.")
	
		elif [$AlarmID -ge 2068]
		then
			opis_bledow=$(echo "Abnormal energy storage device" )
			Alarm_severity=2
			Possible_cause=$(echo " ")

		elif [$AlarmID -ge 2070]
		then
			opis_bledow=$(echo "Active islanding" )
			Alarm_severity=3
			Possible_cause=$(echo " ")
		
		elif [$AlarmID -ge 2071]
		then
			opis_bledow=$(echo "Passive islanding" )
			Alarm_severity=3
			Possible_cause=$(echo " ")

		elif [$AlarmID -ge 2072]
		then
			opis_bledow=$(echo "Transient AC overvoltage" )
			Alarm_severity=3
			Possible_cause=$(echo "Cause ID = 1 The inverter detects that the phase voltage exceeds the transient AC overvoltage protection threshold.")

		elif [$AlarmID -ge 2080]
		then
			opis_bledow=$(echo "Abnormal PV module configuration" )
			Alarm_severity=3
			Possible_cause=$(echo " ")

		else	
			echo "nothing propably problem with server where is service connection"
			Alarm_severity=1
		
	fi

echo $opis_bledow

curent_time=$(echo ''$getStationList''  | jq '.params' )
curent_time=$(echo ''$curent_time''  | jq '.currentTime' )


curent_time_actually=$(echo ${curent_time::-3})

#shorter time for read in unix
#curent_time=${curent_time::-3}

#echo $curent_time
#data=$(date -d @'$curent_time')
#echo $data

data=$(echo ''$getStationList''  | jq '.data[]' )

capacity=$(echo ''$data''  | jq '.capacity' )
owner_phone=$(echo ''$data''  | jq '.linkmanPho' )
station_Addres=$(echo ''$data''  | jq '.stationAddr' )
station_Code=$(echo ''$data''  | jq '.stationCode' )
station_Linkman=$(echo ''$data''  | jq '.stationLinkman' )
station_Name=$(echo ''$data''  | jq '.stationName' )
#echo $station_Code
#echo $station_Name

#removing " on begining and end
#station_Addres="$(echo "$station_Addres" | tr -d '[:punct:]')"


# Request to API getStationRealKpi
getStationRealKpi=$(printf '{"stationCodes": '$station_Code'}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getStationRealKpi  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')



#echo $getStationRealKpi | jq

data_RealKpi=$(echo ''$getStationRealKpi''  | jq '.data[]' )
data_RealKpi=$(echo ''$data_RealKpi''  | jq '.dataItemMap' )

Day_power=$(echo ''$data_RealKpi''  | jq '.day_power' )
month_power=$(echo ''$data_RealKpi''  | jq '.month_power' )
total_power=$(echo ''$data_RealKpi''  | jq '.total_power' )
day_income=$(echo ''$data_RealKpi''  | jq '.day_income' )
total_income=$(echo ''$data_RealKpi''  | jq '.total_income' )

#removing " on begining and end
Day_power=`echo "$Day_power" | grep -o '[[:digit:]].*[[:digit:]]'`
month_power=`echo "$month_power" | grep -o '[[:digit:]].*[[:digit:]]'`
total_power=`echo "$total_power" | grep -o '[[:digit:]].*[[:digit:]]'`



#echo $data_RealKpi | jq



# Request to API getDevList
getDevList=$(printf '{"stationCodes": '$station_Code'}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getDevList  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')


#echo $getDevList | jq

getDevList=$(echo ''$getDevList''  | jq '.data[]' )

device_Name=$(echo ''$getDevList''  | jq '.devName' )
device_TypeId=$(echo ''$getDevList''  | jq '.devTypeId' )
esnCode=$(echo ''$getDevList''  | jq '.esnCode' )
Id=$(echo ''$getDevList''  | jq '.id' )
inverter_Type=$(echo ''$getDevList''  | jq '.invType' )
latitude=$(echo ''$getDevList''  | jq '.latitude' )
longitude=$(echo ''$getDevList''  | jq '.longitude' )
software_Version=$(echo ''$getDevList''  | jq '.softwareVersion' )
stationCode=$(echo ''$getDevList''  | jq '.stationCode' )

#echo $device_Name | jq

#Removing both " from string
inverter_Type="$(echo "$inverter_Type" | tr -d '[:punct:]')"


# Request to API getKpiStationHour
getKpiStationHour=$(printf '{"stationCodes": '$station_Code', "collectTime": '$curent_time'}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getKpiStationHour  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')

# echo $getKpiStationHour | jq '.data[]'
# echo $getKpiStationHour | jq '.data[].collectTime, .data[].dataItemMap.inverter_power'

hour_of_the_day=( $(echo ''$getKpiStationHour''  | jq '.data[].collectTime' ) )
power_iverted=( $(echo ''$getKpiStationHour''  | jq '.data[].dataItemMap.inverter_power' ) )
power_profit=( $(echo ''$getKpiStationHour''  | jq '.data[].dataItemMap.power_profit' ) )



# Conversion of long variable string with hours in unix format to bash array 
eval "hour_of_the_day_array=(${hour_of_the_day})"

#we cut last three digits for corect time and date  in loop + corect timezone for grafana
count=0
for s in "${hour_of_the_day_array[@]}"; do 
    date_with_cut_three_digits=$(echo ${s::-3})

    #convert UCT timestamp to CEST  we add +1h in secounds
    date_with_cut_three_digits=$(( $date_with_cut_three_digits+3600 ))

    hour_of_the_day_array[$count]=$date_with_cut_three_digits
    (( count++ ))
done

# Conversion of long variable string with hourly inverter production to array
eval "power_iverted_array=(${power_iverted})"



#Tested variable to text file for checking what is on output
#truncate=$(truncate -s0 wyjscie.txt)
#echo $hour_of_the_day >> wyjscie.txt

#printf '%s\n' "${hour_of_the_day_array[@]}"
# echo "Number of positions in array ""${#hour_of_the_day_array[@]}"
#printf '%s\n' "${power_iverted[@]}"
# echo "Number of positions in array ""${#power_iverted_array[@]}"
# printf '%s\n' "${power_profit[@]}"



# Request to API getKpiStationDay
getKpiStationDay=$(printf '{"stationCodes": '$station_Code', "collectTime": '$curent_time'}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getKpiStationDay  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')


# echo $getKpiStationDay | jq

day=( $(echo ''$getKpiStationDay''  | jq '.data[].collectTime' ) )
power_iverted_whole_day=( $(echo ''$getKpiStationDay''  | jq '.data[].dataItemMap.inverter_power' ) )
power_profit_whole_day=( $(echo ''$getKpiStationDay''  | jq '.data[].dataItemMap.power_profit' ) )
perpower_ratio_whole_day=( $(echo ''$getKpiStationDay''  | jq '.data[].dataItemMap.perpower_ratio' ) )
reduction_total_co2_whole_day=( $(echo ''$getKpiStationDay''  | jq '.data[].dataItemMap.reduction_total_co2' ) )
reduction_total_coal_whole_day=( $(echo ''$getKpiStationDay''  | jq '.data[].dataItemMap.reduction_total_coal' ) )



# Conversion of long variable string with days in unix format to bash array 
eval "day_array=(${day})"

#we cut last three digits for corect time and date  in loop
count_day=0
for s in "${day_array[@]}"; do 
    day_with_cut_three_digits=$(echo ${s::-3})

    #convert UCT timestamp to CEST we add -1h in secounds
    #day_with_cut_three_digits=$(( $day_with_cut_three_digits-3600 ))

    day_array[$count_day]=$day_with_cut_three_digits
    (( count_day++ ))
done

# Conversion of long variable string with daily inverter production to array
eval "power_iverted_whole_day_array=(${power_iverted_whole_day})"

# Conversion of long variable string with daily perPower to array
eval "perpower_ratio_whole_day_array=(${perpower_ratio_whole_day})"

# Conversion of long variable string with daily co2 reduction to array
eval "reduction_total_co2_whole_day_array=(${reduction_total_co2_whole_day})"

# Conversion of long variable string with daily coal reduction to array
eval "reduction_total_coal_whole_day_array=(${reduction_total_coal_whole_day})"

#printf '%s\n' "${day[@]}"
#printf '%s\n' "${day_array[@]}"
#echo "Number of positions in array ""${#hour_of_the_day_array[@]}"
#echo '\n'
#printf '%s\n' "${power_iverted_whole_day[@]}"
#printf '%s\n' "${power_iverted_whole_day_array[@]}"
#echo '\n'
# printf '%s\n' "${power_profit_whole_day[@]}"
#printf '%s\n' "${perpower_ratio_whole_day[@]}"
#echo '\n'
#printf '%s\n' "${reduction_total_co2_whole_day[@]}"
#echo '\n'
#printf '%s\n' "${reduction_total_coal_whole_day[@]}"
#echo '\n'

# Request to API getKpiStationMonth
getKpiStationMonth=$(printf '{"stationCodes": '$station_Code', "collectTime": '$curent_time'}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getKpiStationMonth  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')

# echo $getKpiStationMonth | jq

month=( $(echo ''$getKpiStationMonth''  | jq '.data[].collectTime' ) )
power_iverted_whole_month=( $(echo ''$getKpiStationMonth''  | jq '.data[].dataItemMap.inverter_power' ) )
power_profit_whole_month=( $(echo ''$getKpiStationMonth''  | jq '.data[].dataItemMap.power_profit' ) )
perpower_ratio_whole_month=( $(echo ''$getKpiStationMonth''  | jq '.data[].dataItemMap.perpower_ratio' ) )
reduction_total_co2_whole_month=( $(echo ''$getKpiStationMonth''  | jq '.data[].dataItemMap.reduction_total_co2' ) )
reduction_total_coal_whole_month=( $(echo ''$getKpiStationMonth''  | jq '.data[].dataItemMap.reduction_total_coal' ) )

# Conversion of long variable string with months in unix format to bash array 
eval "month_array=(${month})"

#we cut last three digits for corect time and date  in loop
count_month=0
for s in "${month_array[@]}"; do 
    month_with_cut_three_digits=$(echo ${s::-3})
    month_array[$count_month]=$month_with_cut_three_digits
    (( count_month++ ))
done

# Conversion of long variable string with monthly inverter production to array
eval "power_iverted_whole_month_array=(${power_iverted_whole_month})"

# Conversion of long variable string with monthly inverter DC/AC conversion losses to array
eval "perpower_ratio_whole_month_array=(${perpower_ratio_whole_month})"

# Conversion of long variable string with monthly co2 reduction to array
eval "reduction_total_co2_whole_month_array=(${reduction_total_co2_whole_month})"

# Conversion of long variable string with monthly coal reduction to array
eval "reduction_total_coal_whole_month_array=(${reduction_total_coal_whole_month})"


# printf '%s\n' "${month[@]}"
# printf '%s\n' "${month_array[@]}"
# echo '\n'	
# printf '%s\n' "${power_iverted_whole_month[@]}"
# printf '%s\n' "${power_iverted_whole_month_array[@]}"
# printf '%s\n' "${power_profit_whole_month[@]}"
# echo '\n'
# printf '%s\n' "${perpower_ratio_whole_month[@]}"
# printf '%s\n' "${perpower_ratio_whole_month_array[@]}"
# echo '\n'
# printf '%s\n' "${reduction_total_co2_whole_month[@]}"
# echo '\n'
# printf '%s\n' "${reduction_total_coal_whole_month[@]}"

# Request to API getKpiStationYear
getKpiStationYear=$(printf '{"stationCodes": '$station_Code', "collectTime": '$curent_time'}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getKpiStationYear  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')


# echo $getKpiStationYear | jq

year=( $(echo ''$getKpiStationYear''  | jq '.data[].collectTime' ) )
installed_capacity_year=( $(echo ''$getKpiStationYear''  | jq '.data[].dataItemMap.installed_capacity' ) )
power_iverted_year=( $(echo ''$getKpiStationYear''  | jq '.data[].dataItemMap.inverter_power' ) )
power_profit_year=( $(echo ''$getKpiStationYear''  | jq '.data[].dataItemMap.power_profit' ) )
perpower_ratio_year=( $(echo ''$getKpiStationYear''  | jq '.data[].dataItemMap.perpower_ratio' ) )
reduction_total_co2_year=( $(echo ''$getKpiStationYear''  | jq '.data[].dataItemMap.reduction_total_co2' ) )
reduction_total_coal_year=( $(echo ''$getKpiStationYear''  | jq '.data[].dataItemMap.reduction_total_coal' ) )
reduction_total_tree_year=( $(echo ''$getKpiStationYear''  | jq '.data[].dataItemMap.reduction_total_tree' ) )

# Conversion of long variable string with year in unix format to bash array 
eval "year_array=(${year})"

#we cut last three digits for corect time and date  in loop
count_year=0
for s in "${year_array[@]}"; do 
    year_with_cut_three_digits=$(echo ${s::-3})
    year_array[$count_year]=$year_with_cut_three_digits
    (( count_year++ ))
done

# Conversion of long variable string with yearly inverter production to array
eval "power_iverted_year_array=(${power_iverted_year})"

# Conversion of long variable string with yearly inverter DC/AC conversion losses to array
eval "perpower_ratio_year_array=(${perpower_ratio_year})"

# Conversion of long variable string with yearly co2 reduction to array
eval "reduction_total_co2_year_array=(${reduction_total_co2_year})"

# Conversion of long variable string with yearly coal reduction to array
eval "reduction_total_coal_year_array=(${reduction_total_coal_year})"

# Conversion of long variable string with yearly trees to array
eval "reduction_total_tree_year_array=(${reduction_total_tree_year})"


# printf '%s\n' "${year[@]}"
# printf '%s\n' "${year_array[@]}"
# printf '%s\n' "${installed_capacity_year[@]}"
# printf '%s\n' "${power_iverted_year[@]}"
# printf '%s\n' "${power_profit_year[@]}"
# printf '%s\n' "${perpower_ratio_year[@]}"
# printf '%s\n' "${reduction_total_co2_year[@]}"
# printf '%s\n' "${reduction_total_coal_year[@]}"
# printf '%s\n' "${reduction_total_tree_year[@]}"














# Sending data to influxDB

# alarms
curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=alarms value='$AlarmID' '$curent_time_actually''

curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=severity value='$Alarm_severity' '$curent_time_actually''


# Static data to influxDB Solar instalation capacity and adress
curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'capacity=Nominalna_Wydajnosc value='$capacity''

# Static data to influxDB Solar instalation capacity and adress
# curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne' --data-binary "capacity=adres value=\"$station_Addres\""

#Daily power production
curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=day value='$Day_power''

#Mothly power production
curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=month value='$month_power''

#Total power production
curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=total value='$total_power''

#Device model
# curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne' --data-binary "Power=name value=$inverter_Type"



# Add in loop series of data to influxDB for each hour of the actual day
count_hours=0
for s in "${hour_of_the_day_array[@]}"; do 

	#Hourly power production today
	curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=hourly value='${power_iverted_array[$count_hours]}' '${hour_of_the_day_array[$count_hours]}''
	(( count_hours++ ))
done

Number_of_hours=$(echo ${#hour_of_the_day_array[@]})
Number_of_hours=$(( $Number_of_hours-1 ))

#Hourly power production today last hour
	curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=hourly value='${power_iverted_array[$Number_of_hours]}' '${hour_of_the_day_array[$Number_of_hours]}''


#echo $Number_of_hours
#echo ${power_iverted_array[$Number_of_hours]}
#echo ${hour_of_the_day_array[$Number_of_hours]}


# Add in loop series of data to influxDB for each day of the actual month
count_days=0
for s in "${day_array[@]}"; do 

	#daily power production in actual month
	curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=daily value='${power_iverted_whole_day_array[$count_days]}' '${day_array[$count_days]}''

	#daily DC/AC conversion losses in inverter during production in actual month
	curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=perpower_ratio value='${perpower_ratio_whole_day_array[$count_days]}' '${day_array[$count_days]}''
	
	#daily Co2 reduction in actual month
	curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=daily_co2 value='${reduction_total_co2_whole_day_array[$count_days]}' '${day_array[$count_days]}''

	#daily coal reduction in actual month
	curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=daily_coal value='${reduction_total_coal_whole_day_array[$count_days]}' '${day_array[$count_days]}''

	(( count_days++ ))
done


# Add in loop series of data to influxDB for each month of the actual year
count_months=0
for s in "${month_array[@]}"; do 

	#mothly power production in actual year
	curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=monthly value='${power_iverted_whole_month_array[$count_months]}' '${month_array[$count_months]}''

	#mothly DC/AC conversion losses in inverter during production in actual year
	curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=monthly_perpower_ratio value='${perpower_ratio_whole_month_array[$count_months]}' '${month_array[$count_months]}''

	#mothly Co2 reduction in actual year
	curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=monthly_co2 value='${reduction_total_co2_whole_month_array[$count_months]}' '${month_array[$count_months]}''

	#mothly coal reduction in actual year
	curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=monthly_coal value='${reduction_total_coal_whole_month_array[$count_months]}' '${month_array[$count_months]}''

	(( count_months++ ))
done

# Add in loop series of data to influxDB for each year 
count_years=0
for s in "${year_array[@]}"; do 

	#yearly power production
	curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=yearly value='${power_iverted_year_array[$count_years]}''

	#yearly power production
	#curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=yearly value='${power_iverted_year_array[$count_years]}' '${year_array[$count_years]}''

	#yearly DC/AC conversion losses in inverter during production
	curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=yearly_perpower_ratio value='${perpower_ratio_year_array[$count_years]}''

	#yearly DC/AC conversion losses in inverter during production
	#curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=yearly_perpower_ratio value='${perpower_ratio_year_array[$count_years]}' '${year_array[$count_years]}''

	#yearly Co2 reduction
	curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=yearly_co2 value='${reduction_total_co2_year_array[$count_years]}''

	#yearly Co2 reduction
	#curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=yearly_co2 value='${reduction_total_co2_year_array[$count_years]}' '${year_array[$count_years]}''

	#yearly coal reduction
	curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=yearly_coal value='${reduction_total_coal_year_array[$count_years]}''

	#yearly coal reduction
	#curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=yearly_coal value='${reduction_total_coal_year_array[$count_years]}' '${year_array[$count_years]}''

	#yearly trees
	curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=yearly_trees value='${reduction_total_tree_year_array[$count_years]}''

	#yearly trees
	#curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=yearly_trees value='${reduction_total_tree_year_array[$count_years]}' '${year_array[$count_years]}''

	(( count_years++ ))
done







