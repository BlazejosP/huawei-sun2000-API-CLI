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

inverter_state () {
# List of possible Inverter Status (inverter_state) Description by Huawei. Based on documentation SmartPVMS.V300R006C10_API_Northbound.Interface.Reference.1.pdf pages 87-88 and own obseration of device status


if [ $1 == "000"  ] ||  [ $1 == "0" ];
then
	printf "Standby: initializing"
elif [ $1 == "001"  ] ||  [ $1 == "1" ];
then	
	printf "Standby: insulation resistance detection"
elif [ $1 == "002"  ] ||  [ $1 == "2" ];
then	
	printf "Standby: sunlight detection"
elif [ $1 == "003"  ] ||  [ $1 == "3" ];
then	
	printf "Standby: power grid detection"
elif [ $1 == "100"  ];
then	
	printf "Startup"
elif [ $1 == "200"  ];
then	
	printf "On-grid"
elif [ $1 == "201"  ];
then	
	printf "Grid connection: power limited"
elif [ $1 == "202"  ];
then	
	printf "Grid connection: self-derating"
elif [ $1 == "300"  ];
then	
	printf "Shutdown: unexpected shutdown"	
elif [ $1 == "301"  ];
then	
	printf "Shutdown: commanded shutdown"
elif [ $1 == "302"  ];
then	
	printf "Shutdown: OVGR"
elif [ $1 == "303"  ];
then	
	printf "Shutdown: communication disconnection"	
elif [ $1 == "304"  ];
then	
	printf "Shutdown: limited power"
elif [ $1 == "305"  ];
then	
	printf "Shutdown: manual startup is required"
elif [ $1 == "306"  ];
then	
	printf "Shutdown: DC switch disconnected"
elif [ $1 == "401"  ];
then	
	printf "Grid schedule: cosφ-P curve"
elif [ $1 == "402"  ];
then	
	printf "Grid schedule: Q-U curve"
elif [ $1 == "500"  ];
then	
	printf "Spot-check ready"
elif [ $1 == "501"  ];
then	
	printf "Spot-checking"
elif [ $1 == "600"  ];
then	
	printf "Inspecting"
elif [ $1 == "700"  ];
then	
	printf "AFCI self-test"
elif [ $1 == "800"  ];
then	
	printf "I-V scanning"
elif [ $1 == "900"  ];
then	
	printf "DC input detection"
elif [ $1 == "a000"  ] ||  [ $1 == "A000" ];
then	
	printf "Standby: No sunlight"
elif [ $1 == "b000"  ] ||  [ $1 == "B000" ];
then	
	printf "Communication disconnection (written by the SmartLogger)"
elif [ $1 == "c000"  ] ||  [ $1 == "C000" ];
then	
	printf "Loading (written by the SmartLogger)"
else
	echo "Unknown state"
fi


} 

Device_type_ID () {
# List of possible smart devices in Power Plant by Huawei. Based on documentation SmartPVMS.V300R006C10_API_Northbound.Interface.Reference.1.pdf pages 28-30 
if [ $1 == "1"  ];
then
	printf "	Smart String Inverter"
elif [ $1 == "2"  ];
then	
	echo "		SmartLogger"
elif [ $1 == "3"  ];
then	
	echo "		String"
elif [ $1 == "6"  ];
then	
	echo "		Bay"
elif [ $1 == "7"  ];
then	
	echo "		Busbar"
elif [ $1 == "8"  ];
then	
	echo "		Transformer"
elif [ $1 == "9"  ];
then	
	echo "		Transformer meter"
elif [ $1 == "10"  ];
then	
	echo "		EMI"
elif [ $1 == "11"  ];
then	
	echo "		AC combiner box"
elif [ $1 == "13"  ];
then	
	echo "		DPU"
elif [ $1 == "14"  ];
then	
	echo "		Central Inverter"
elif [ $1 == "15"  ];
then	
	echo "		DC combiner box"
elif [ $1 == "16"  ];
then	
	echo "		General device"
elif [ $1 == "17"  ];
then	
	echo "		Grid meter"
elif [ $1 == "18"  ];
then	
	echo "		Step-up station"
elif [ $1 == "19"  ];
then	
	echo "		Factory-used energy generation area meter"
elif [ $1 == "20"  ];
then	
	echo "		Solar power forecasting system"
elif [ $1 == "21"  ];
then	
	echo "		Factory-used energy non-generation area meter"
elif [ $1 == "22"  ];
then	
	echo "		PID"
elif [ $1 == "23"  ];
then	
	echo "		Virtual device of plant monitoring system"
elif [ $1 == "24"  ];
then	
	echo "		Power quality device"
elif [ $1 == "25"  ];
then	
	echo "		Step-up transformer"
elif [ $1 == "26"  ];
then	
	echo "		Photovoltaic grid-connection cabinet"
elif [ $1 == "27"  ];
then	
	echo "		Photovoltaic grid-connection panel"
elif [ $1 == "37"  ];
then	
	echo "		Pinnet SmartLogger"
elif [ $1 == "38"  ];
then	
	echo "		Smart Energy Center"
elif [ $1 == "39"  ];
then	
	echo "		Battery"
elif [ $1 == "40"  ];
then	
	echo "		Smart Backup Box"
elif [ $1 == "45"  ];
then	
	echo "		MBUS"
elif [ $1 == "46"  ];
then	
	echo "		Optimizer"
elif [ $1 == "47"  ];
then	
	echo "		Power Sensor"
elif [ $1 == "52"  ];
then	
	echo "		SAJ data logger"
elif [ $1 == "53"  ];
then	
	echo "		High voltage bay of the main transformer"
elif [ $1 == "54"  ];
then	
	echo "		Main transformer"
elif [ $1 == "55"  ];
then	
	echo "		Low voltage bay of the main transformer"
elif [ $1 == "56"  ];
then	
	echo "		Bus bay"
elif [ $1 == "57"  ];
then	
	echo "		Line bay"
elif [ $1 == "58"  ];
then	
	echo "		Plant transformer bay"
elif [ $1 == "59"  ];
then	
	echo "		SVC/SVG bay"
elif [ $1 == "60"  ];
then	
	echo "		Bus tie/section bay"
elif [ $1 == "61"  ];
then	
	echo "		Plant power supply device"
elif [ $1 == "62"  ];
then	
	printf "	Dongle"
elif [ $1 == "63"  ];
then	
	echo "		Distributed SmartLogger"
elif [ $1 == "70"  ];
then	
	echo "		Safety box"
else
	echo "		Unknown Device"
fi

}

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


function in_case_of_error_with_connection_to_API {

	local immediately=$(echo ''$1''  | jq '.data.immediately' )
		if [[ $immediately == true ]];
			then
				local when_relogin="NOW"
		elif [[ $immediately == false ]];
			then
				local when_relogin="NOT NOW"
		else
				local when_relogin="Don't know when"
		fi	

		local message=$(echo ''$1''  | jq '.data.message' )
		echo "Message: "$when_relogin" "$message

}


function login_to_API {

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


}



function getStationList {

# Request to API getStationList
local getStationList=$(printf '{ }'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getStationList  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')

#show result of qustion in JOSN
#echo $getStationList  | jq


local success=$(echo ''$getStationList''  | jq '.success' )
local buildCode=$(echo ''$getStationList''  | jq '.buildCode' )
local failCode=$(echo ''$getStationList''  | jq '.failCode' )
local message=$(echo ''$getStationList''  | jq '.message' )

# we take actually time for other question to API too
curent_time=$(echo ''$getStationList''  | jq '.params' )
	curent_time=$(echo ''$curent_time''  | jq '.currentTime' )

curent_time_actually=$(echo ${curent_time::-3})

#shorter time for read in unix
#curent_time=${curent_time::-3}

#echo $curent_time
#data=$(date -d @'$curent_time')
#echo $data

local data=$(echo ''$getStationList''  | jq '.data[]' )
	local aidType=$(echo ''$data''  | jq '.aidType' )
	local buildState=$(echo ''$data''  | jq '.buildState' )
	local combineType=$(echo ''$data''  | jq '.combineType' )
	local capacity=$(echo ''$data''  | jq '.capacity' ) # in kWp Kilo-Watt-pik
	local owner_phone=$(echo ''$data''  | jq '.linkmanPho' )
	local station_Addres=$(echo ''$data''  | jq '.stationAddr' )
	local station_Code=$(echo ''$data''  | jq '.stationCode' )
	local station_Linkman=$(echo ''$data''  | jq '.stationLinkman' )
	local station_Name=$(echo ''$data''  | jq '.stationName' )
	#echo $station_Code
	#echo $station_Name
	
	
# Conversion of long variable string with answers to array
eval "stations_aidType_array=(${aidType})"
eval "stations_buildState_array=(${buildState})"
eval "stations_combineType_array=(${combineType})"
eval "stations_capacity_array=(${capacity})"
eval "stations_owner_phone_array=(${owner_phone})"
eval "stations_Addres_array=(${station_Addres})"
eval "stations_Code_array=(${station_Code})"
eval "stations_Linkman_array=(${station_Linkman})"
eval "stations_Name_array=(${station_Name})"

#printf '%s\n' "${stations_aidType_array[@]}"
#printf '%s\n' "${stations_buildState_array[@]}"
#printf '%s\n' "${stations_combineType_array[@]}"
#printf '%s\n' "${stations_capacity_array[@]}"
#printf '%s\n' "${stations_owner_phone_array[@]}"
#printf '%s\n' "${stations_Addres_array[@]}"
#printf '%s\n' "${stations_Code_array[@]}"
#printf '%s\n' "${stations_Linkman_array[@]}"
#printf '%s\n' "${stations_Name_array[@]}"

#count number of plants in your possesion
number_of_plants=${#stations_Name_array[@]}

#removing " on begining and end
#station_Addres="$(echo "$station_Addres" | tr -d '[:punct:]')"

#removing " on begining and end
local buildCode=`echo "$buildCode" | grep -o '[[:digit:]]'`
local buildState=`echo "$buildState" | grep -o '[[:digit:]]'`
local combineType=`echo "$combineType" | grep -o '[[:digit:]]'`

#echo "Request success or failure flag: " $success
if [[ $success == "true"  ]];
	then	
		echo ""
		echo -e "API \e[4mgetStationList\e[0m connection \e[42mOK\e[0m"
		getStationList_connection=true
elif [[ $success == "false" ]];
	then
		echo ""
		echo -e "API \e[4mgetStationList\e[0m connection \e[41mError\e[0m"
		getStationList_connection=false
else
	echo ""
	echo -e "\e[41mNetwork Error :(\e[0m" 
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


if [[ $success == "true"  ]];
then	
	echo "Build Code: "$buildCode
fi
#echo "Current Time: "$curent_time
#shorter time for read in unix
if [[ $success == "true"  ]];
	then	
		curent_time_actually=$(echo ${curent_time::-3})
		curent_time_actually=$(date -d @$curent_time_actually)
		echo "Time of your Request to API: "$curent_time_actually
fi

local count=0
for s in "${#stations_Name_array[@]}"; do
	local number_plant=$(( $count+1 ))
	echo ""
	echo -e "	\e[93mPlant "$number_plant": \e[0m\e[1m"${stations_Code_array[$count]}"\e[0m"
	if [[ ! ${stations_Name_array[$count]} == null  ]];
		then
		echo "	Plant Name: "${stations_Name_array[$count]}
	fi
	if [[ ! ${stations_Addres_array[$count]} == null  ]];
		then
		echo "	Address of the plant: "${stations_Addres_array[$count]}
	fi
	if [[ ! ${stations_capacity_array[$count]} == null  ]];
		then
		echo "	Installed capacity: "${stations_capacity_array[$count]}" kWp"
	fi
	if [[ ! ${stations_Linkman_array[$count]} == null  ]];
		then
		echo "	Plant contact: "${stations_Linkman_array[$count]}
	fi
	if [[ ! ${stations_owner_phone_array[$count]} == null  ]];
		then
		echo "	Contact phone number :"${stations_owner_phone_array[$count]}
	fi
	
	if [[ ! ${stations_buildState_array[$count]} == null  ]];
		then
	
		if [[ ${stations_buildState_array[$count]} == 1 ]];
			then	
			plant_status="Not built"
		elif [[ ${stations_buildState_array[$count]} == 2 ]];
			then
			plant_status="Under construction"
		elif [[ ${stations_buildState_array[$count]} == 3 ]];
			then
			plant_status="Grid-connected"
		else
			plant_status="Unknown"
		fi
		echo "	Plant Status: "$plant_status
	fi
	
	if [[ ! ${stations_combineType_array[$count]} == null  ]];
		then
		
		if [[ ${stations_combineType_array[$count]} == 1 ]];
			then	
			Grid_connection_type="Utility"
		elif [[ ${stations_combineType_array[$count]} == 2 ]];
			then
			Grid_connection_type="C&I plant"
		elif [[ ${stations_combineType_array[$count]} == 3 ]];
			then
			Grid_connection_type="Residential plant"
		else
			Grid_connection_type="Unknown"
		fi
		echo "	Grid connection type: "$Grid_connection_type
	fi
	
	if [[ ! ${stations_aidType_array[$count]}  == null  ]];
		then
		if [[ ${stations_aidType_array[$count]} == 0 ]];
			then	
			Poverty_alleviation_plant_flag="Yes"
		elif [[ ${stations_aidType_array[$count]} == 1 ]];
			then
			Poverty_alleviation_plant_flag="No"
		else
			Poverty_alleviation_plant_flag="Unknown"
		fi
		echo "	Poverty alleviation plant: "$Poverty_alleviation_plant_flag
	fi


	echo ""
    (( count++ ))
done

# in case of error
if [[ $success == "false"  ]];
	then	
	#fuction which works with connection error	
	in_case_of_error_with_connection_to_API $getStationList
fi


}



function getDevList {

# Request to API getDevList
local getDevList=$(printf '{"stationCodes": "'$1'"}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getDevList  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')

#show result of qustion in JOSN
#echo $getDevList | jq

local success=$(echo ''$getDevList''  | jq '.success' )
local buildCode=$(echo ''$getDevList''  | jq '.buildCode' )
local failCode=$(echo ''$getDevList''  | jq '.failCode' )
local message=$(echo ''$getDevList''  | jq '.message' )

local data=$(echo ''$getDevList''  | jq '.data[]' )
	local device_Name=$(echo ''$data''  | jq '.devName' )
	local device_TypeId=$(echo ''$data''  | jq '.devTypeId' )
	local esnCode=$(echo ''$data''  | jq '.esnCode' )
	local Id=$(echo ''$data''  | jq '.id' )
	local inverter_Type=$(echo ''$data''  | jq '.invType' )
	local latitude=$(echo ''$data''  | jq '.latitude' )
	local longitude=$(echo ''$data''  | jq '.longitude' )
	local software_Version=$(echo ''$data''  | jq '.softwareVersion' )
	local stationCode=$(echo ''$data''  | jq '.stationCode' )

local parms=$(echo ''$getDevList''  | jq '.params' )
	local currentTime=$(echo ''$parms''  | jq '.currentTime' )
	local stationCodes=$(echo ''$parms''  | jq '.stationCodes' )

#echo $device_Name | jq



# Conversion of long variable string with answers to array
eval "device_Name_array=(${device_Name})"
eval "device_TypeId_array=(${device_TypeId})"
eval "device_esnCode_array=(${esnCode})"
eval "device_Id_array=(${Id})"
eval "device_inverter_Type_array=(${inverter_Type})"
eval "device_latitude_array=(${latitude})"
eval "device_longitude_array=(${longitude})"
eval "device_software_Version_array=(${software_Version})"
eval "device_stationCode_array=(${stationCode})"

#printf '%s\n' "${device_Name_array[@]}"
#printf '%s\n' "${device_TypeId_array[@]}"
#printf '%s\n' "${device_esnCode_array[@]}"
#printf '%s\n' "${device_Id_array[@]}"
#printf '%s\n' "${device_inverter_Type_array[@]}"
#printf '%s\n' "${device_latitude_array[@]}"
#printf '%s\n' "${device_longitude_array[@]}"
#printf '%s\n' "${device_software_Version_array[@]}"
#printf '%s\n' "${device_stationCode_array[@]}"

#count number of devices in station taken from number of postions in one array
local number_of_devices=${#device_Name_array[@]}

#Removing both " from string
local buildCode=`echo "$buildCode" | grep -o '[[:digit:]]'`
local inverter_Type="$(echo "$inverter_Type" | tr -d '[:punct:]')"


#echo "Request success or failure flag: " $success
if [[ $success == "true"  ]];
	then	
		echo ""
		echo -e "API \e[4mgetDevList\e[0m connection \e[42mOK\e[0m"
		getDevList_connection=true
elif [[ $success == "false" ]];
	then
		echo ""
		echo -e "API \e[4mgetDevList\e[0m connection \e[41mError\e[0m"
		getDevList_connection=false
else
	echo ""
	echo -e "\e[41mNetwork Error :(\e[0m" 
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


if [[ $success == "true"  ]];
then	
	echo "Build Code: "$buildCode
fi


#echo "Current Time: "$currentTime
#shorter time for read in unix
if [[ $success == "true"  ]];
	then	
		local curent_time_actually=$(echo ${currentTime::-3})
		local curent_time_actually=$(date -d @$curent_time_actually)
		echo "Time of your Request to API: "$curent_time_actually
#fi

echo ""
echo -e "\e[93mPlant "$2": \e[0m\e[1m"${device_stationCode_array[$count]}"\e[0m"
echo "Number of devices: "$number_of_devices
echo ""

local count=0
for s in "${device_Name_array[@]}"; do 
	local number_of_device=$(( $count+1 ))
	echo -e "	\e[93mDevice "$number_of_device":\e[0m ${device_Id_array[$count]}"
	#echo "	Device type ID: "${device_TypeId_array[$count]}
	# we call to function with Devices ID list
	
	Device_type_ID ${device_TypeId_array[$count]}

	if [ ! -z "${device_inverter_Type_array[$count]}" ]
	then
		echo "	Inverter Type: "${device_inverter_Type_array[$count]}
	fi
	
	echo "	Device Name: "${device_Name_array[$count]}
	echo "	Device SN: "${device_esnCode_array[$count]}
	
	
	if [[ ! $1 == ${device_stationCode_array[$count]}  ]];
	then	
		echo "	Plant name: "${device_stationCode_array[$count]}
	fi
		
	echo "	Software version: "${device_software_Version_array[$count]}
	
	if [[ ! ${device_longitude_array[$count]} == null  ]];
	then	
		echo "	longitude: "${device_longitude_array[$count]}
	fi
	if [[ ! ${device_latitude_array[$count]} == null  ]];
	then	
		echo "	latitude: "${device_latitude_array[$count]}
	fi
	echo ""
    (( count++ ))
done

fi

# in case of error
if [[ $success == "false"  ]];
	then	
	#fuction which works with connection error	
	in_case_of_error_with_connection_to_API $getDevList
fi

echo ""

}


function getStationRealKpi {


# Request to API getStationRealKpi
local getStationRealKpi=$(printf '{"stationCodes": "'$1'"}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getStationRealKpi  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')


#show result of qustion in JOSN
#echo $getStationRealKpi | jq

local success=$(echo ''$getStationRealKpi''  | jq '.success' )
local buildCode=$(echo ''$getStationRealKpi''  | jq '.buildCode' )
local failCode=$(echo ''$getStationRealKpi''  | jq '.failCode' )
local  message=$(echo ''$getStationRealKpi''  | jq '.message' )

local data_RealKpi=$(echo ''$getStationRealKpi''  | jq '.data[]' )
	local stationCode=$(echo ''$data_RealKpi''  | jq '.stationCode' )
	local data_RealKpi=$(echo ''$data_RealKpi''  | jq '.dataItemMap' )
		local Day_power=$(echo ''$data_RealKpi''  | jq '.day_power' )
		local month_power=$(echo ''$data_RealKpi''  | jq '.month_power' )
		local total_power=$(echo ''$data_RealKpi''  | jq '.total_power' )
		local day_income=$(echo ''$data_RealKpi''  | jq '.day_income' )
		local total_income=$(echo ''$data_RealKpi''  | jq '.total_income' )
		local real_health_state=$(echo ''$data_RealKpi''  | jq '.real_health_state' )

local data_RealKpi=$(echo ''$getStationRealKpi''  | jq '.params' )
	local currentTime=$(echo ''$data_RealKpi''  | jq '.currentTime' )
	local stationCodes=$(echo ''$data_RealKpi''  | jq '.stationCodes' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local Day_power="$(echo "$Day_power" | tr -d '"')"
local month_power="$(echo "$month_power" | tr -d '"')"
local total_power="$(echo "$total_power" | tr -d '"')"
local day_income="$(echo "$day_income" | tr -d '"')"
local total_income="$(echo "$total_income" | tr -d '"')"
local real_health_state="$(echo "$real_health_state" | tr -d '"')"
local stationCodes="$(echo "$stationCodes" | tr -d '"')"
local stationCode="$(echo "$stationCode" | tr -d '"')"
#echo $data_RealKpi | jq


# Here comma is our delimiter value to array of stations codes given by user as a parameter in question
IFS="," read -a stationCodes_array <<< $stationCodes

#echo "My array Station Codes: ${stationCodes_array[@]}"
#echo "Number of elements in the array Station Code: ${#stationCodes_array[@]}"

# Conversion of long variable string with answers to array
eval "stationCode_array=(${stationCode})"
eval "Day_power_array=(${Day_power})"
eval "month_power_array=(${month_power})"
eval "total_power_array=(${total_power})"
eval "day_income_array=(${day_income})"
eval "total_income_array=(${total_income})"
eval "real_health_state_array=(${real_health_state})"

#echo "Request success or failure flag: " $success
if [[ $success == "true"  ]];
	then	
		echo ""
		echo -e "API \e[4mgetStationRealKpi\e[0m connection \e[42mOK\e[0m"
		getStationRealKpi_connection=true
elif [[ $success == "false" ]];
	then
		echo ""
		echo -e "API \e[4mgetStationRealKpi\e[0m connection \e[41mError\e[0m"
		getStationRealKpi_connection=false
else
	echo ""
	echo -e "\e[41mNetwork Error :(\e[0m" 
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


if [[ $success == "true"  ]];
then	
	echo "Build Code: "$buildCode
fi

#echo "Current Time: "$currentTime
#shorter time for read in unix
if [[ $success == "true"  ]];
	then	
		local curent_time_actually=$(echo ${currentTime::-3})
		local curent_time_actually=$(date -d @$curent_time_actually)
		echo "Time of your Request to API: "$curent_time_actually

echo ""
echo "Numbers of plants to check: "${#stationCodes_array[@]}


local count=0
for s in "${#stationCode_array[@]}"; do
	local number_plant=$(( $count+1 ))
	echo ""
	echo -e "	\e[93mPlant "$number_plant": \e[0m\e[1m"${stationCode_array[$count]}"\e[0m"
	
	if [[ ${real_health_state_array[$count]} == 1 ]];
		then	
		plant_healt="Disconnected"
	elif [[ ${real_health_state_array[$count]} == 2 ]];
		then
		plant_healt="Faulty"
	elif [[ ${real_health_state_array[$count]} == 3 ]];
		then
		plant_healt="Healthy"
	else
		plant_healt="Unknown"
	fi
	echo "	Plant Status: "$plant_healt
	
	echo "	Daily energy: "${Day_power_array[$count]}" kWh"
	echo "	Monthly energy: "${month_power_array[$count]}" kWh"
	echo "	Lifetime energy: "${total_power_array[$count]}" kWh"
	echo "	Daily revenue: "${day_income_array[$count]}" ¥"
	echo "	Total revenue: "${total_income_array[$count]}" ¥"
	echo ""
	(( count++ ))
done

fi

# in case of error
if [[ $success == "false"  ]];
	then
	#fuction which works with connection error	
	in_case_of_error_with_connection_to_API $getStationRealKpi
fi

echo ""


}



function getKpiStationHour {

# Request to API getKpiStationHour
local getKpiStationHour=$(printf '{"stationCodes": "'$1'", "collectTime": '$2'}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getKpiStationHour  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')

#echo $getKpiStationHour | jq
#echo $getKpiStationHour | jq '.data[]'
#echo $getKpiStationHour | jq '.data[].collectTime, .data[].dataItemMap.inverter_power'

local success=$(echo ''$getKpiStationHour''  | jq '.success' )
local buildCode=$(echo ''$getKpiStationHour''  | jq '.buildCode' )
local failCode=$(echo ''$getKpiStationHour''  | jq '.failCode' )
local message=$(echo ''$getKpiStationHour''  | jq '.message' )


local hour_of_the_day=( $(echo ''$getKpiStationHour''  | jq '.data[].collectTime' ) )
	local stationCode=( $(echo ''$getKpiStationHour''  | jq '.data[].stationCode' ) )
		local radiation_intensity=( $(echo ''$getKpiStationHour''  | jq '.data[].dataItemMap.radiation_intensity' ) )
		local theory_power=( $(echo ''$getKpiStationHour''  | jq '.data[].dataItemMap.theory_power' ) )
		local power_inverted=( $(echo ''$getKpiStationHour''  | jq '.data[].dataItemMap.inverter_power' ) )
		local ongrid_power=( $(echo ''$getKpiStationHour''  | jq '.data[].dataItemMap.ongrid_power' ) )
		local power_profit=( $(echo ''$getKpiStationHour''  | jq '.data[].dataItemMap.power_profit' ) )

local data_getKpiStationHour=$(echo ''$getKpiStationHour''  | jq '.params' )
	local currentTime=$(echo ''$data_getKpiStationHour''  | jq '.currentTime' )
	local collectTime=$(echo ''$data_getKpiStationHour''  | jq '.collectTime' )
	local stationCodes=$(echo ''$data_getKpiStationHour''  | jq '.stationCodes' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"


# Here comma is our delimiter value to array of stations codes given by user as a parameter in question
IFS="," read -a stationCodes_array <<< $stationCodes

# Conversion of long variable string with hours in unix format to bash array 
eval "hour_of_the_day_array=(${hour_of_the_day})"

#we cut last three digits for corect time and date  in loop + corect timezone for grafana
count=0
for s in "${hour_of_the_day_array[@]}"; do 
    local date_with_cut_three_digits=$(echo ${s::-3})

    #convert UCT timestamp to CEST we add +1h in secounds
    local date_with_cut_three_digits=$(( $date_with_cut_three_digits+3600 ))

    hour_of_the_day_array[$count]=$date_with_cut_three_digits
    (( count++ ))
done

# Conversion of long variable string with hourly inverter production to array
eval "stationCode_array=(${stationCode})"
eval "radiation_intensity_array=(${radiation_intensity})"
eval "theory_power_array=(${theory_power})"
eval "power_inverted_array=(${power_inverted})"
eval "ongrid_power_array=(${ongrid_power})"
eval "power_profit_array=(${power_profit})"

#Tested variable to text file for checking what is on output
#truncate=$(truncate -s0 wyjscie.txt)
#echo $hour_of_the_day >> wyjscie.txt

#printf '%s\n' "${hour_of_the_day_array[@]}"
#echo "Number of positions in array ""${#hour_of_the_day_array[@]}"
#printf '%s\n' "${stationCode_array[@]}"
#echo "Number of positions in array ""${#stationCode_array[@]}"
#printf '%s\n' "${radiation_intensity_array[@]}"
#echo "Number of positions in array ""${#radiation_intensity_array[@]}"
#printf '%s\n' "${theory_power_array[@]}"
#echo "Number of positions in array ""${#theory_power_array[@]}"
#printf '%s\n' "${power_inverted_array[@]}"
#echo "Number of positions in array ""${#power_inverted_array[@]}"
#printf '%s\n' "${ongrid_power_array=[@]}"
#echo "Number of positions in array ""${#ongrid_power_array[@]}"
#printf '%s\n' "${power_profit_array[@]}"
#echo "Number of positions in array ""${#power_profit_array[@]}"

#echo "Request success or failure flag: " $success
if [[ $success == "true"  ]];
	then	
		echo ""
		echo -e "API \e[4mgetKpiStationHour\e[0m connection \e[42mOK\e[0m"
		getKpiStationHour_connection=true
elif [[ $success == "false" ]];
	then
		echo ""
		echo -e "API \e[4mgetKpiStationHour\e[0m connection \e[41mError\e[0m"
		getKpiStationHour_connection=false
else
	echo ""
	echo -e "\e[41mNetwork Error :(\e[0m" 
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


if [[ $success == "true"  ]];
then	
	echo "Build Code: "$buildCode
fi


local curent_time_actually=$(echo ${currentTime::-3})
local curent_time_of_request=$(echo ${collectTime::-3})
local difference_in_secounds=$(( $curent_time_actually-$curent_time_of_request ))

local curent_time_of_request=$(date -d @$curent_time_of_request)
echo "Time of your Request to API: "$curent_time_of_request

echo "Response time: "$difference_in_secounds" s"
#local curent_time_actually=$(date -d @$curent_time_actually)
#echo "Actuall time: "$curent_time_actually
		


if [[ $success == "true"  ]];
	then
	
	echo ""
	echo "Numbers of plants to check: "${#stationCodes_array[@]}
	echo ""
	echo -e "\e[93m"$(date "+%d %B %Y" -d @${hour_of_the_day_array[$c]})"\e[0m"
	echo ""
	
	for (( c=0; c<=((${#stationCode_array[@]}-1)); c++ )); do
			echo -e "\e[1m	"$(date "+%X %Z" -d @${hour_of_the_day_array[$c]})" \e[0m"${number_plant_array[$c]}" "${stationCode_array[$c]}
			if [[ ! ${radiation_intensity_array[$c]} == null  ]];
			then	
				echo -e "	Total irradiation: "${radiation_intensity_array[$c]}" kWh/m2"
			fi
			if [[ ! ${theory_power_array[$c]} == null  ]];
			then	
				echo -e "	Theoretical energy: "${theory_power_array[$c]}" kWh"
			fi
			if [[ ! ${power_inverted_array[$c]} == null  ]];
			then	
				echo -e "	Inverter energy: "${power_inverted_array[$c]}" kWh"
			fi
			if [[ ! ${ongrid_power_array[$c]} == null  ]];
			then	
				echo -e "	Feed-in energy: "${ongrid_power_array[$c]}" kWh"
			fi
			if [[ ! ${power_profit_array[$c]} == null  ]];
			then	
				echo -e "	Energy revenue: "${power_profit_array[$c]}" ¥"
			fi
			echo ""
	done

fi

# in case of error
if [[ $success == "false"  ]];
	then
	#fuction which works with connection error	
	in_case_of_error_with_connection_to_API $getKpiStationHour
		
fi

echo ""


}


function getKpiStationDay {

# Request to API getKpiStationDay
local getKpiStationDay=$(printf '{"stationCodes": "'$1'", "collectTime": '$2'}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getKpiStationDay  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')


#echo $getKpiStationDay | jq


local success=$(echo ''$getKpiStationDay''  | jq '.success' )
local buildCode=$(echo ''$getKpiStationDay''  | jq '.buildCode' )
local failCode=$(echo ''$getKpiStationDay''  | jq '.failCode' )
local message=$(echo ''$getKpiStationDay''  | jq '.message' )

	local day_of_the_month=( $(echo ''$getKpiStationDay''  | jq '.data[].collectTime' ) )
	local stationCode=( $(echo ''$getKpiStationDay''  | jq '.data[].stationCode' ) )
		local installed_capacity=( $(echo ''$getKpiStationDay''  | jq '.data[].dataItemMap.installed_capacity' ) )
		local radiation_intensity=( $(echo ''$getKpiStationDay''  | jq '.data[].dataItemMap.radiation_intensity' ) )	
		local theory_power=( $(echo ''$getKpiStationDay''  | jq '.data[].dataItemMap.theory_power' ) )
		local performance_ratio=( $(echo ''$getKpiStationDay''  | jq '.data[].dataItemMap.performance_ratio' ) )	
		local power_inverted_whole_day=( $(echo ''$getKpiStationDay''  | jq '.data[].dataItemMap.inverter_power' ) )
		local ongrid_power=( $(echo ''$getKpiStationDay''  | jq '.data[].dataItemMap.ongrid_power' ) )
		local use_power=( $(echo ''$getKpiStationDay''  | jq '.data[].dataItemMap.use_power' ) )		
		local power_profit_whole_day=( $(echo ''$getKpiStationDay''  | jq '.data[].dataItemMap.power_profit' ) )		
		local perpower_ratio_whole_day=( $(echo ''$getKpiStationDay''  | jq '.data[].dataItemMap.perpower_ratio' ) )
		local reduction_total_co2_whole_day=( $(echo ''$getKpiStationDay''  | jq '.data[].dataItemMap.reduction_total_co2' ) )
		local reduction_total_coal_whole_day=( $(echo ''$getKpiStationDay''  | jq '.data[].dataItemMap.reduction_total_coal' ) )
		local reduction_total_tree_whole_day=( $(echo ''$getKpiStationDay''  | jq '.data[].dataItemMap.reduction_total_tree' ) )


local data_getKpiStationDay=$(echo ''$getKpiStationDay''  | jq '.params' )
	local currentTime=$(echo ''$data_getKpiStationDay''  | jq '.currentTime' )
	local collectTime=$(echo ''$data_getKpiStationDay''  | jq '.collectTime' )
	local stationCodes=$(echo ''$data_getKpiStationDay''  | jq '.stationCodes' )


#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"


# Here comma is our delimiter value to array of stations codes given by user as a parameter in question
IFS="," read -a stationCodes_array <<< $stationCodes


# Conversion of long variable string with days in unix format to bash array 
eval "day_array=(${day_of_the_month})"

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
eval "stationCode_array=(${stationCode})"
eval "installed_capacity_array=(${installed_capacity})"
eval "radiation_intensity_array=(${radiation_intensity})"
eval "theory_power_array=(${theory_power})"
eval "performance_ratio_array=(${performance_ratio})"
eval "power_inverted_whole_day_array=(${power_inverted_whole_day})"
eval "ongrid_power_array=(${ongrid_power})"
eval "use_power_array=(${use_power})"
eval "power_profit_whole_day_array=(${power_profit_whole_day})"
eval "perpower_ratio_whole_day_array=(${perpower_ratio_whole_day})"
eval "reduction_total_co2_whole_day_array=(${reduction_total_co2_whole_day})"
eval "reduction_total_coal_whole_day_array=(${reduction_total_coal_whole_day})"
eval "reduction_total_tree_whole_day_array=(${reduction_total_tree_whole_day})"

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



#echo "Request success or failure flag: " $success
if [[ $success == "true"  ]];
	then	
		echo ""
		echo -e "API \e[4mgetKpiStationDay\e[0m connection \e[42mOK\e[0m"
		getKpiStationDay_connection=true
elif [[ $success == "false" ]];
	then
		echo ""
		echo -e "API \e[4mgetKpiStationDay\e[0m connection \e[41mError\e[0m"
		getKpiStationDay_connection=false
else
	echo ""
	echo -e "\e[41mNetwork Error :(\e[0m" 
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


if [[ $success == "true"  ]];
then	
	echo "Build Code: "$buildCode
fi


local curent_time_actually=$(echo ${currentTime::-3})
local curent_time_of_request=$(echo ${collectTime::-3})
local difference_in_secounds=$(( $curent_time_actually-$curent_time_of_request ))

local curent_time_of_request=$(date -d @$curent_time_of_request)
echo "Time of your Request to API: "$curent_time_of_request

echo "Response time: "$difference_in_secounds" s"
#local curent_time_actually=$(date -d @$curent_time_actually)
#echo "Actuall time: "$curent_time_actually
		
if [[ $success == "true"  ]];
	then
	
	echo ""
	echo "Numbers of plants to check: "${#stationCodes_array[@]}
	echo ""
	echo -e "\e[93m"$(date "+%B %Y" -d @${day_array[$c]})"\e[0m"
	echo ""
	
	
	for (( c=0; c<=((${#stationCode_array[@]}-1)); c++ )); do
		echo -e "\e[1m	"$(date "+%A %d %B %Y" -d @${day_array[$c]})" \e[0m"${number_plant_array[$c]}" "${stationCode_array[$c]}
		if [[ ! ${installed_capacity_array[$c]} == null  ]];
			then	
				echo -e "	Installed capacity: "${installed_capacity_array[$c]}" kWp"				
		fi
		if [[ ! ${radiation_intensity_array[$c]} == null  ]];
			then	
				echo -e "	Total irradiation: "${radiation_intensity_array[$c]}" kWh/m2" 				
		fi
		if [[ ! ${theory_power_array[$c]} == null  ]];
			then	
				echo -e "	Theoretical energy: "${theory_power_array[$c]}" kWh"				
		fi
		if [[ ! ${performance_ratio_array[$c]} == null  ]];
			then	
				echo -e "	Electricity generation efficiency: "${performance_ratio_array[$c]}" kWh" 				
		fi
		if [[ ! ${power_inverted_whole_day_array[$c]} == null  ]];
			then	
				echo -e "	Inverter energy: "${power_inverted_whole_day_array[$c]}" kWh"				
		fi
		if [[ ! ${ongrid_power_array[$c]} == null  ]];
			then	
				echo -e "	Feed-in energy: "${ongrid_power_array[$c]}" kWh"				
		fi
		if [[ ! ${use_power_array[$c]} == null  ]];
			then	
				echo -e "	Power consumption: "${use_power_array[$c]}" kWh"				
		fi
		if [[ ! ${power_profit_whole_day_array[$c]} == null  ]];
			then	
				echo -e "	Energy revenue: "${power_profit_whole_day_array[$c]}" ¥" 				
		fi
		if [[ ! ${perpower_ratio_whole_day_array[$c]} == null  ]];
			then	
				echo -e "	Equivalent utilization hours: "${perpower_ratio_whole_day_array[$c]}" h" 				
		fi
		if [[ ! ${reduction_total_co2_whole_day_array[$c]} == null  ]];
			then	
				echo -e "	CO2 reduction: "${reduction_total_co2_whole_day_array[$c]}" t" 				
		fi
		if [[ ! ${reduction_total_coal_whole_day_array[$c]} == null  ]];
			then	
				echo -e "	Standard coal savings: "${reduction_total_coal_whole_day_array[$c]}" t" 				
		fi
		if [[ ! ${reduction_total_tree_whole_day_array[$c]} == null  ]];
			then	
				echo -e "	Equivalent tree planting: "${reduction_total_tree_whole_day_array[$c]}" tree" 				
		fi
		echo ""
	done
	
fi

# in case of error
if [[ $success == "false"  ]];
	then
	#fuction which works with connection error	
	in_case_of_error_with_connection_to_API $getKpiStationDay
		
fi

echo ""


}




function getKpiStationMonth {

# Request to API getKpiStationMonth
local getKpiStationMonth=$(printf '{"stationCodes": "'$1'", "collectTime": '$2'}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getKpiStationMonth  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')

#echo $getKpiStationMonth | jq

local success=$(echo ''$getKpiStationMonth''  | jq '.success' )
local buildCode=$(echo ''$getKpiStationMonth''  | jq '.buildCode' )
local failCode=$(echo ''$getKpiStationMonth''  | jq '.failCode' )
local message=$(echo ''$getKpiStationMonth''  | jq '.message' )

	local stationCode=( $(echo ''$getKpiStationMonth''  | jq '.data[].stationCode' ) )
	local month=( $(echo ''$getKpiStationMonth''  | jq '.data[].collectTime' ) )
		local installed_capacity=( $(echo ''$getKpiStationMonth''  | jq '.data[].dataItemMap.installed_capacity' ) )
		local radiation_intensity=( $(echo ''$getKpiStationMonth''  | jq '.data[].dataItemMap.radiation_intensity' ) )	
		local theory_power=( $(echo ''$getKpiStationMonth''  | jq '.data[].dataItemMap.theory_power' ) )
		local performance_ratio=( $(echo ''$getKpiStationMonth''  | jq '.data[].dataItemMap.performance_ratio' ) )	
		local power_inverted_whole_month=( $(echo ''$getKpiStationMonth''  | jq '.data[].dataItemMap.inverter_power' ) )
		local ongrid_power=( $(echo ''$getKpiStationMonth''  | jq '.data[].dataItemMap.ongrid_power' ) )
		local use_power=( $(echo ''$getKpiStationMonth''  | jq '.data[].dataItemMap.use_power' ) )
		local power_profit_whole_month=( $(echo ''$getKpiStationMonth''  | jq '.data[].dataItemMap.power_profit' ) )
		local perpower_ratio_whole_month=( $(echo ''$getKpiStationMonth''  | jq '.data[].dataItemMap.perpower_ratio' ) )
		local reduction_total_co2_whole_month=( $(echo ''$getKpiStationMonth''  | jq '.data[].dataItemMap.reduction_total_co2' ) )
		local reduction_total_coal_whole_month=( $(echo ''$getKpiStationMonth''  | jq '.data[].dataItemMap.reduction_total_coal' ) )
		local reduction_total_tree_whole_month=( $(echo ''$getKpiStationMonth''  | jq '.data[].dataItemMap.reduction_total_tree' ) )
	
local data_getKpiStationMonth=$(echo ''$getKpiStationMonth''  | jq '.params' )
	local currentTime=$(echo ''$data_getKpiStationMonth''  | jq '.currentTime' )
	local collectTime=$(echo ''$data_getKpiStationMonth''  | jq '.collectTime' )
	local stationCodes=$(echo ''$data_getKpiStationMonth''  | jq '.stationCodes' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"


# Here comma is our delimiter value to array of stations codes given by user as a parameter in question
IFS="," read -a stationCodes_array <<< $stationCodes


# Conversion of long variable string with months in unix format to bash array 
eval "month_array=(${month})"

#we cut last three digits for corect time and date  in loop
count_month=0
for s in "${month_array[@]}"; do 
    month_with_cut_three_digits=$(echo ${s::-3})
    month_array[$count_month]=$month_with_cut_three_digits
    (( count_month++ ))
done

# Conversion of long variable string to array
eval "stationCode_array=(${stationCode})"
eval "installed_capacity_whole_month_array=(${installed_capacity})"
eval "radiation_intensity_whole_month_array=(${radiation_intensity})"
eval "theory_power_whole_month_array=(${theory_power})"
eval "performance_ratio_whole_month_array=(${performance_ratio})"
eval "power_inverted_whole_month_array=(${power_inverted_whole_month})"
eval "ongrid_power_whole_month_array=(${ongrid_power})"
eval "use_power_whole_month_array=(${use_power})"
eval "power_profit_whole_month_array=(${power_profit_whole_month})"
eval "perpower_ratio_whole_month_array=(${perpower_ratio_whole_month})"
eval "reduction_total_co2_whole_month_array=(${reduction_total_co2_whole_month})"
eval "reduction_total_coal_whole_month_array=(${reduction_total_coal_whole_month})"
eval "reduction_total_tree_whole_month_array=(${reduction_total_tree_whole_month})"


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


#echo "Request success or failure flag: " $success
if [[ $success == "true"  ]];
	then	
		echo ""
		echo -e "API \e[4mgetKpiStationMonth\e[0m connection \e[42mOK\e[0m"
		getKpiStationMonth_connection=true
elif [[ $success == "false" ]];
	then
		echo ""
		echo -e "API \e[4mgetKpiStationMonth\e[0m connection \e[41mError\e[0m"
		getKpiStationMonth_connection=false
else
	echo ""
	echo -e "\e[41mNetwork Error :(\e[0m" 
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


if [[ $success == "true"  ]];
then	
	echo "Build Code: "$buildCode
fi


local curent_time_actually=$(echo ${currentTime::-3})
local curent_time_of_request=$(echo ${collectTime::-3})
local difference_in_secounds=$(( $curent_time_actually-$curent_time_of_request ))

local curent_time_of_request=$(date -d @$curent_time_of_request)
echo "Time of your Request to API: "$curent_time_of_request

echo "Response time: "$difference_in_secounds" s"
#local curent_time_actually=$(date -d @$curent_time_actually)
#echo "Actuall time: "$curent_time_actually

if [[ $success == "true"  ]];
	then
	
	echo ""
	echo "Numbers of plants to check: "${#stationCodes_array[@]}
	echo ""
	echo -e "\e[93m"$(date "+%Y" -d @${month_array[0]})"\e[0m"
	echo ""
	
	
	for (( c=0; c<=((${#stationCode_array[@]}-1)); c++ )); do
		echo -e "\e[1m	"$(date "+%B %Y" -d @${month_array[$c]})" \e[0m"${number_plant_array[$c]}" "${stationCode_array[$c]}
		if [[ ! ${installed_capacity_whole_month_array[$c]} == null  ]];
			then	
				echo -e "	Installed capacity: "${installed_capacity_whole_month_array[$c]}" kWp"				
		fi
		if [[ ! ${radiation_intensity_whole_month_array[$c]} == null  ]];
			then	
				echo -e "	Total irradiation: "${radiation_intensity_whole_month_array[$c]}" kWh/m2" 				
		fi
		if [[ ! ${theory_power_whole_month_array[$c]} == null  ]];
			then	
				echo -e "	Theoretical energy: "${theory_power_whole_month_array[$c]}" kWh"				
		fi
		if [[ ! ${performance_ratio_whole_month_array[$c]} == null  ]];
			then	
				echo -e "	Electricity generation efficiency: "${performance_ratio_whole_month_array[$c]}" kWh" 				
		fi
		if [[ ! ${power_inverted_whole_month_array[$c]} == null  ]];
			then	
				echo -e "	Inverter energy: "${power_inverted_whole_month_array[$c]}" kWh"				
		fi
		if [[ ! ${ongrid_power_whole_month_array[$c]} == null  ]];
			then	
				echo -e "	Feed-in energy: "${ongrid_power_whole_month_array[$c]}" kWh"				
		fi
		if [[ ! ${use_power_whole_month_array[$c]} == null  ]];
			then	
				echo -e "	Power consumption: "${use_power_whole_month_array[$c]}" kWh"				
		fi
		if [[ ! ${power_profit_whole_month_array[$c]} == null  ]];
			then	
				echo -e "	Energy revenue: "${power_profit_whole_month_array[$c]}" ¥" 				
		fi
		if [[ ! ${perpower_ratio_whole_month_array[$c]} == null  ]];
			then	
				echo -e "	Equivalent utilization hours: "${perpower_ratio_whole_month_array[$c]}" h" 				
		fi
		if [[ ! ${reduction_total_co2_whole_month_array[$c]} == null  ]];
			then	
				echo -e "	CO2 reduction: "${reduction_total_co2_whole_month_array[$c]}" t" 				
		fi
		if [[ ! ${reduction_total_coal_whole_month_array[$c]} == null  ]];
			then	
				echo -e "	Standard coal savings: "${reduction_total_coal_whole_month_array[$c]}" t" 				
		fi
		if [[ ! ${reduction_total_tree_whole_month_array[$c]} == null  ]];
			then	
				echo -e "	Equivalent tree planting: "${reduction_total_tree_whole_month_array[$c]}" tree" 				
		fi
		echo ""
	done
	
fi

# in case of error
if [[ $success == "false"  ]];
	then
	#fuction which works with connection error	
	in_case_of_error_with_connection_to_API $getKpiStationMonth
		
fi

echo ""
}



function getKpiStationYear {


# Request to API getKpiStationYear
local getKpiStationYear=$(printf '{"stationCodes": "'$1'", "collectTime": '$2'}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getKpiStationYear  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')


#echo $getKpiStationYear | jq

local success=$(echo ''$getKpiStationYear''  | jq '.success' )
local buildCode=$(echo ''$getKpiStationYear''  | jq '.buildCode' )
local failCode=$(echo ''$getKpiStationYear''  | jq '.failCode' )
local message=$(echo ''$getKpiStationYear''  | jq '.message' )

	local stationCode=( $(echo ''$getKpiStationYear''  | jq '.data[].stationCode' ) )
	local year=( $(echo ''$getKpiStationYear''  | jq '.data[].collectTime' ) )
		local installed_capacity_year=( $(echo ''$getKpiStationYear''  | jq '.data[].dataItemMap.installed_capacity' ) )
		local radiation_intensity=( $(echo ''$getKpiStationYear''  | jq '.data[].dataItemMap.radiation_intensity' ) )
		local theory_power=( $(echo ''$getKpiStationYear''  | jq '.data[].dataItemMap.theory_power' ) )
		local performance_ratio=( $(echo ''$getKpiStationYear''  | jq '.data[].dataItemMap.performance_ratio' ) )	
		local power_iverted_year=( $(echo ''$getKpiStationYear''  | jq '.data[].dataItemMap.inverter_power' ) )
		local ongrid_power=( $(echo ''$getKpiStationYear''  | jq '.data[].dataItemMap.ongrid_power' ) )
		local use_power=( $(echo ''$getKpiStationYear''  | jq '.data[].dataItemMap.use_power' ) )
		local power_profit_year=( $(echo ''$getKpiStationYear''  | jq '.data[].dataItemMap.power_profit' ) )
		local perpower_ratio_year=( $(echo ''$getKpiStationYear''  | jq '.data[].dataItemMap.perpower_ratio' ) )
		local reduction_total_co2_year=( $(echo ''$getKpiStationYear''  | jq '.data[].dataItemMap.reduction_total_co2' ) )
		local reduction_total_coal_year=( $(echo ''$getKpiStationYear''  | jq '.data[].dataItemMap.reduction_total_coal' ) )
		local reduction_total_tree_year=( $(echo ''$getKpiStationYear''  | jq '.data[].dataItemMap.reduction_total_tree' ) )

local data_getKpiStationYear=$(echo ''$getKpiStationYear''  | jq '.params' )
	local currentTime=$(echo ''$data_getKpiStationYear''  | jq '.currentTime' )
	local collectTime=$(echo ''$data_getKpiStationYear''  | jq '.collectTime' )
	local stationCodes=$(echo ''$data_getKpiStationYear''  | jq '.stationCodes' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"

# Here comma is our delimiter value to array of stations codes given by user as a parameter in question
IFS="," read -a stationCodes_array <<< $stationCodes


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
eval "stationCode_array=(${stationCode})"
eval "installed_capacity_whole_year_array=(${installed_capacity_year})"
eval "radiation_intensity_whole_year_array=(${radiation_intensity})"
eval "theory_power_whole_year_array=(${theory_power})"
eval "performance_ratio_whole_year_array=(${performance_ratio})"
eval "power_iverted_year_array=(${power_iverted_year})"
eval "ongrid_power_year_array=(${ongrid_power})"
eval "use_power_year_array=(${use_power})"
eval "power_profit_year_array=(${power_profit_year})"
eval "perpower_ratio_year_array=(${perpower_ratio_year})"
eval "reduction_total_co2_year_array=(${reduction_total_co2_year})"
eval "reduction_total_coal_year_array=(${reduction_total_coal_year})"
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

#echo "Request success or failure flag: " $success
if [[ $success == "true"  ]];
	then	
		echo ""
		echo -e "API \e[4mgetKpiStationYear\e[0m connection \e[42mOK\e[0m"
		getKpiStationYear_connection=true
elif [[ $success == "false" ]];
	then
		echo ""
		echo -e "API \e[4mgetKpiStationYear\e[0m connection \e[41mError\e[0m"
		getKpiStationYear_connection=false
else
	echo ""
	echo -e "\e[41mNetwork Error :(\e[0m" 
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


if [[ $success == "true"  ]];
then	
	echo "Build Code: "$buildCode
fi


local curent_time_actually=$(echo ${currentTime::-3})
local curent_time_of_request=$(echo ${collectTime::-3})
local difference_in_secounds=$(( $curent_time_actually-$curent_time_of_request ))

local curent_time_of_request=$(date -d @$curent_time_of_request)
echo "Time of your Request to API: "$curent_time_of_request

echo "Response time: "$difference_in_secounds" s"
#local curent_time_actually=$(date -d @$curent_time_actually)
#echo "Actuall time: "$curent_time_actually

if [[ $success == "true"  ]];
	then
	
	echo ""
	echo "Numbers of plants to check: "${#stationCodes_array[@]}
	echo ""
	echo ""
	
	for (( c=0; c<=((${#stationCode_array[@]}-1)); c++ )); do
		echo -e "\e[1m	"$(date "+%Y" -d @${year_array[$c]})" \e[0m"${stationCode_array[$c]}
		if [[ ! ${installed_capacity_whole_year_array[$c]} == null  ]];
			then	
				echo -e "	Installed capacity: "${installed_capacity_whole_year_array[$c]}" kWp"				
		fi
		if [[ ! ${radiation_intensity_whole_year_array[$c]} == null  ]];
			then	
				echo -e "	Total irradiation: "${radiation_intensity_whole_year_array[$c]}" kWh/m2" 				
		fi
		if [[ ! ${theory_power_whole_year_array[$c]} == null  ]];
			then	
				echo -e "	Theoretical energy: "${theory_power_whole_year_array[$c]}" kWh"				
		fi
		if [[ ! ${performance_ratio_whole_year_array[$c]} == null  ]];
			then	
				echo -e "	Electricity generation efficiency: "${performance_ratio_whole_year_array[$c]}" kWh" 				
		fi
		if [[ ! ${power_iverted_year_array[$c]} == null  ]];
			then	
				echo -e "	Inverter energy: "${power_iverted_year_array[$c]}" kWh"				
		fi
		if [[ ! ${ongrid_power_year_array[$c]} == null  ]];
			then	
				echo -e "	Feed-in energy: "${ongrid_power_year_array[$c]}" kWh"				
		fi
		if [[ ! ${use_power_year_array[$c]} == null  ]];
			then	
				echo -e "	Power consumption: "${use_power_year_array[$c]}" kWh"				
		fi
		if [[ ! ${power_profit_year_array[$c]} == null  ]];
			then	
				echo -e "	Energy revenue: "${power_profit_year_array[$c]}" ¥" 				
		fi
		if [[ ! ${perpower_ratio_year_array[$c]} == null  ]];
			then	
				echo -e "	Equivalent utilization hours: "${perpower_ratio_year_array[$c]}" h" 				
		fi
		if [[ ! ${reduction_total_co2_year_array[$c]} == null  ]];
			then	
				echo -e "	CO2 reduction: "${reduction_total_co2_year_array[$c]}" t" 				
		fi
		if [[ ! ${reduction_total_coal_year_array[$c]} == null  ]];
			then	
				echo -e "	Standard coal savings: "${reduction_total_coal_year_array[$c]}" t" 				
		fi
		if [[ ! ${reduction_total_tree_year_array[$c]} == null  ]];
			then	
				echo -e "	Equivalent tree planting: "${reduction_total_tree_year_array[$c]}" tree" 				
		fi
		echo ""
	done
	
fi

# in case of error
if [[ $success == "false"  ]];
	then
	#fuction which works with connection error	
	in_case_of_error_with_connection_to_API $getKpiStationYear
		
fi

echo ""


}



function getDevRealKpi {


# Request to API getKpiStationYear
local getDevRealKpi=$(printf '{"devIds": "'$1'", "devTypeId": "'$2'"}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getDevRealKpi  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')

#echo $getDevRealKpi | jq

local success=$(echo ''$getDevRealKpi''  | jq '.success' )
local buildCode=$(echo ''$getDevRealKpi''  | jq '.buildCode' )
local failCode=$(echo ''$getDevRealKpi''  | jq '.failCode' )
local message=$(echo ''$getDevRealKpi''  | jq '.message' )


#we have inverter
if [[ $2 == 1  ]];
then	

	local devId=$(echo ''$getDevRealKpi''  | jq '.data[].devId' )
		local inverter_state=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.inverter_state' )
		local ab_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.ab_u' )
		local bc_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.bc_u' )
		local ca_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.ca_u' )
		local a_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.a_u' )
		local b_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.b_u' )
		local c_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.c_u' )
		local a_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.a_i' )
		local b_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.b_i' )
		local c_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.c_i' )
		local efficiency=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.efficiency' )
		local temperature=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.temperature' )
		local power_factor=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.power_factor' )
		local elec_freq=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.elec_freq' )
		local active_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.active_power' )
		local reactive_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.reactive_power' )
		local day_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.day_cap' )
		local mppt_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.mppt_power' )
		local pv1_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv1_u' )
		local pv2_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv2_u' )
		local pv3_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv3_u' )
		local pv4_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv4_u' )
		local pv5_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv5_u' )
		local pv6_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv6_u' )
		local pv7_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv7_u' )
		local pv8_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv8_u' )
		local pv9_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv9_u' )
		local pv10_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv10_u' )
		local pv11_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv11_u' )
		local pv12_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv12_u' )
		local pv13_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv13_u' )
		local pv14_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv14_u' )
		local pv15_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv15_u' )
		local pv16_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv16_u' )
		local pv17_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv17_u' )
		local pv18_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv18_u' )
		local pv19_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv19_u' )
		local pv20_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv20_u' )
		local pv21_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv21_u' )
		local pv22_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv22_u' )
		local pv23_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv23_u' )
		local pv24_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv24_u' )
		local pv1_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv1_i' )
		local pv2_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv2_i' )
		local pv3_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv3_i' )
		local pv4_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv4_i' )
		local pv5_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv5_i' )
		local pv6_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv6_i' )
		local pv7_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv7_i' )
		local pv8_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv8_i' )
		local pv9_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv9_i' )
		local pv10_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv10_i' )
		local pv11_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv11_i' )
		local pv12_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv12_i' )
		local pv13_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv13_i' )
		local pv14_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv14_i' )
		local pv15_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv15_i' )
		local pv16_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv16_i' )
		local pv17_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv17_i' )
		local pv18_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv18_i' )
		local pv19_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv19_i' )
		local pv20_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv20_i' )
		local pv21_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv21_i' )
		local pv22_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv22_i' )
		local pv23_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv23_i' )
		local pv24_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv24_i' )
		local total_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.total_cap' )
		local open_time=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.open_time' )
		local close_time=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.close_time' )
		local mppt_total_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.mppt_total_cap' )
		local mppt_1_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.mppt_1_cap' )
		local mppt_2_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.mppt_2_cap' )
		local mppt_3_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.mppt_3_cap' )
		local mppt_4_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.mppt_4_cap' )
		local mppt_5_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.mppt_5_cap' )
		local mppt_6_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.mppt_6_cap' )
		local mppt_7_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.mppt_7_cap' )
		local mppt_8_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.mppt_8_cap' )
		local mppt_9_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.mppt_9_cap' )
		local mppt_10_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.mppt_10_cap' )
		local run_state=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.run_state' )

local data_getDevRealKpi=$(echo ''$getDevRealKpi''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevRealKpi''  | jq '.currentTime' )
	local devIds=$(echo ''$data_getDevRealKpi''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevRealKpi''  | jq '.devTypeId' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "inverter_state_array=(${inverter_state})"
		eval "ab_u_array=(${ab_u})"
		eval "bc_u_array=(${bc_u})"
		eval "ca_u_array=(${ca_u})"
		eval "a_u_array=(${a_u})"
		eval "b_u_array=(${b_u})"
		eval "c_u_array=(${c_u})"
		eval "a_i_array=(${a_i})"
		eval "b_i_array=(${b_i})"
		eval "c_i_array=(${c_i})"
		eval "efficiency_array=(${efficiency})"
		eval "temperature_array=(${temperature})"
		eval "power_factor_array=(${power_factor})"
		eval "elec_freq_array=(${elec_freq})"
		eval "active_power_array=(${active_power})"
		eval "reactive_power_array=(${reactive_power})"
		eval "day_cap_array=(${day_cap})"
		eval "mppt_power_array=(${mppt_power})"
		eval "pv1_u_array=(${pv1_u})"
		eval "pv2_u_array=(${pv2_u})"
		eval "pv3_u_array=(${pv3_u})"
		eval "pv4_u_array=(${pv4_u})"
		eval "pv5_u_array=(${pv5_u})"
		eval "pv6_u_array=(${pv6_u})"
		eval "pv7_u_array=(${pv7_u})"
		eval "pv8_u_array=(${pv8_u})"
		eval "pv9_u_array=(${pv9_u})"
		eval "pv10_u_array=(${pv10_u})"
		eval "pv11_u_array=(${pv11_u})"
		eval "pv12_u_array=(${pv12_u})"
		eval "pv13_u_array=(${pv13_u})"
		eval "pv14_u_array=(${pv14_u})"
		eval "pv15_u_array=(${pv15_u})"
		eval "pv16_u_array=(${pv16_u})"
		eval "pv17_u_array=(${pv17_u})"
		eval "pv18_u_array=(${pv18_u})"
		eval "pv19_u_array=(${pv19_u})"
		eval "pv20_u_array=(${pv20_u})"
		eval "pv21_u_array=(${pv21_u})"
		eval "pv22_u_array=(${pv22_u})"
		eval "pv23_u_array=(${pv23_u})"
		eval "pv24_u_array=(${pv24_u})"
		eval "pv1_i_array=(${pv1_i})"
		eval "pv2_i_array=(${pv2_i})"
		eval "pv3_i_array=(${pv3_i})"
		eval "pv4_i_array=(${pv4_i})"
		eval "pv5_i_array=(${pv5_i})"
		eval "pv6_i_array=(${pv6_i})"
		eval "pv7_i_array=(${pv7_i})"
		eval "pv8_i_array=(${pv8_i})"
		eval "pv9_i_array=(${pv9_i})"
		eval "pv10_i_array=(${pv10_i})"
		eval "pv11_i_array=(${pv11_i})"
		eval "pv12_i_array=(${pv12_i})"
		eval "pv13_i_array=(${pv13_i})"
		eval "pv14_i_array=(${pv14_i})"
		eval "pv15_i_array=(${pv15_i})"
		eval "pv16_i_array=(${pv16_i})"
		eval "pv17_i_array=(${pv17_i})"
		eval "pv18_i_array=(${pv18_i})"
		eval "pv19_i_array=(${pv19_i})"
		eval "pv20_i_array=(${pv20_i})"
		eval "pv21_i_array=(${pv21_i})"
		eval "pv22_i_array=(${pv22_i})"
		eval "pv23_i_array=(${pv23_i})"
		eval "pv24_i_array=(${pv24_i})"
		eval "total_cap_array=(${total_cap})"
		eval "open_time_array=(${open_time})"
		eval "close_time_array=(${close_time})"
		eval "mppt_total_cap_array=(${mppt_total_cap})"
		eval "mppt_1_cap_array=(${mppt_1_cap})"
		eval "mppt_2_cap_array=(${mppt_2_cap})"
		eval "mppt_3_cap_array=(${mppt_3_cap})"
		eval "mppt_4_cap_array=(${mppt_4_cap})"
		eval "mppt_5_cap_array=(${mppt_5_cap})"
		eval "mppt_6_cap_array=(${mppt_6_cap})"	
		eval "mppt_7_cap_array=(${mppt_7_cap})"	
		eval "mppt_8_cap_array=(${mppt_8_cap})"	
		eval "mppt_9_cap_array=(${mppt_9_cap})"	
		eval "mppt_10_cap_array=(${mppt_10_cap})"	
		eval "run_state_array=(${run_state})"	

#if device is Central inverter
elif [[ $2 == 14  ]];
then

	local devId=$(echo ''$getDevRealKpi''  | jq '.data[].devId' )
		local inverter_state=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.inverter_state' )
		local day_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.day_cap' )
		local total_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.total_cap' )
		local temperature=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.temperature' )
		local center_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.center_u' )
		local center_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.center_i' )
		local center_i_1=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.center_i_1' )
		local center_i_2=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.center_i_2' )
		local center_i_3=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.center_i_3' )
		local center_i_4=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.center_i_4' )
		local center_i_5=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.center_i_5' )
		local center_i_6=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.center_i_6' )
		local center_i_7=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.center_i_7' )
		local center_i_8=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.center_i_8' )
		local center_i_9=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.center_i_9' )
		local center_i_10=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.center_i_10' )
		local mppt_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.mppt_power' )
		local a_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.a_u' )
		local b_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.b_u' )
		local c_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.c_u' )
		local a_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.a_i' )
		local b_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.b_i' )
		local c_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.c_i' )		
		local power_factor=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.power_factor' )
		local elec_freq=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.elec_freq' )
		local active_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.active_power' )
		local reactive_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.reactive_power' )		
		local open_time=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.open_time' )
		local close_time=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.close_time' )	
		local aop=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.aop' )	
		local run_state=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.run_state' )
		

local data_getDevRealKpi=$(echo ''$getDevRealKpi''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevRealKpi''  | jq '.currentTime' )
	local devIds=$(echo ''$data_getDevRealKpi''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevRealKpi''  | jq '.devTypeId' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "inverter_state_array=(${inverter_state})"
		eval "day_cap_array=(${day_cap})"
		eval "total_cap_array=(${total_cap})"
		eval "temperature_array=(${temperature})"		
		eval "center_u_array=(${center_u})"
		eval "center_i_array=(${center_i})"
		eval "center_i_1_array=(${center_i_1})"
		eval "center_i_2_array=(${center_i_2})"
		eval "center_i_3_array=(${center_i_3})"
		eval "center_i_4_array=(${center_i_4})"
		eval "center_i_5_array=(${center_i_5})"
		eval "center_i_6_array=(${center_i_6})"
		eval "center_i_7_array=(${center_i_7})"
		eval "center_i_8_array=(${center_i_8})"
		eval "center_i_9_array=(${center_i_9})"
		eval "center_i_10_array=(${center_i_10})"
		eval "mppt_power_array=(${mppt_power})"		
		eval "a_u_array=(${a_u})"
		eval "b_u_array=(${b_u})"
		eval "c_u_array=(${c_u})"
		eval "a_i_array=(${a_i})"
		eval "b_i_array=(${b_i})"
		eval "c_i_array=(${c_i})"	
		eval "power_factor_array=(${power_factor})"
		eval "elec_freq_array=(${elec_freq})"
		eval "active_power_array=(${active_power})"
		eval "reactive_power_array=(${reactive_power})"
		eval "open_time_array=(${open_time})"
		eval "close_time_array=(${close_time})"		
		eval "aop_array=(${aop})"			
		eval "run_state_array=(${run_state})"			
	
	
# device is Smart Energy Center	
elif [[ $2 == 38  ]];
then


	local devId=$(echo ''$getDevRealKpi''  | jq '.data[].devId' )
		local inverter_state=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.inverter_state' )
		local ab_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.ab_u' )
		local bc_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.bc_u' )
		local ca_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.ca_u' )
		local a_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.a_u' )
		local b_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.b_u' )
		local c_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.c_u' )
		local a_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.a_i' )
		local b_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.b_i' )
		local c_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.c_i' )
		local efficiency=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.efficiency' )
		local temperature=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.temperature' )
		local power_factor=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.power_factor' )
		local elec_freq=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.elec_freq' )
		local active_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.active_power' )
		local reactive_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.reactive_power' )
		local day_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.day_cap' )
		local mppt_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.mppt_power' )
		local pv1_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv1_u' )
		local pv2_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv2_u' )
		local pv3_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv3_u' )
		local pv4_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv4_u' )
		local pv5_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv5_u' )
		local pv6_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv6_u' )
		local pv7_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv7_u' )
		local pv8_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv8_u' )
		local pv1_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv1_i' )
		local pv2_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv2_i' )
		local pv3_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv3_i' )
		local pv4_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv4_i' )
		local pv5_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv5_i' )
		local pv6_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv6_i' )
		local pv7_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv7_i' )
		local pv8_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv8_i' )
		local total_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.total_cap' )
		local open_time=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.open_time' )
		local close_time=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.close_time' )
		local mppt_1_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.mppt_1_cap' )
		local mppt_2_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.mppt_2_cap' )
		local mppt_3_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.mppt_3_cap' )
		local mppt_4_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.mppt_4_cap' )
		local run_state=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.run_state' )		

local data_getDevRealKpi=$(echo ''$getDevRealKpi''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevRealKpi''  | jq '.currentTime' )
	local devIds=$(echo ''$data_getDevRealKpi''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevRealKpi''  | jq '.devTypeId' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "inverter_state_array=(${inverter_state})"
		eval "ab_u_array=(${ab_u})"
		eval "bc_u_array=(${bc_u})"
		eval "ca_u_array=(${ca_u})"
		eval "a_u_array=(${a_u})"
		eval "b_u_array=(${b_u})"
		eval "c_u_array=(${c_u})"
		eval "a_i_array=(${a_i})"
		eval "b_i_array=(${b_i})"
		eval "c_i_array=(${c_i})"
		eval "efficiency_array=(${efficiency})"
		eval "temperature_array=(${temperature})"
		eval "power_factor_array=(${power_factor})"
		eval "elec_freq_array=(${elec_freq})"
		eval "active_power_array=(${active_power})"
		eval "reactive_power_array=(${reactive_power})"
		eval "day_cap_array=(${day_cap})"
		eval "mppt_power_array=(${mppt_power})"
		eval "pv1_u_array=(${pv1_u})"
		eval "pv2_u_array=(${pv2_u})"
		eval "pv3_u_array=(${pv3_u})"
		eval "pv4_u_array=(${pv4_u})"
		eval "pv5_u_array=(${pv5_u})"
		eval "pv6_u_array=(${pv6_u})"
		eval "pv7_u_array=(${pv7_u})"
		eval "pv8_u_array=(${pv8_u})"
		eval "pv1_i_array=(${pv1_i})"
		eval "pv2_i_array=(${pv2_i})"
		eval "pv3_i_array=(${pv3_i})"
		eval "pv4_i_array=(${pv4_i})"
		eval "pv5_i_array=(${pv5_i})"
		eval "pv6_i_array=(${pv6_i})"
		eval "pv7_i_array=(${pv7_i})"
		eval "pv8_i_array=(${pv8_i})"
		eval "total_cap_array=(${total_cap})"
		eval "open_time_array=(${open_time})"
		eval "close_time_array=(${close_time})"
		eval "mppt_1_cap_array=(${mppt_1_cap})"
		eval "mppt_2_cap_array=(${mppt_2_cap})"
		eval "mppt_3_cap_array=(${mppt_3_cap})"
		eval "mppt_4_cap_array=(${mppt_4_cap})"
		eval "run_state_array=(${run_state})"		

# device is DC combiner box
elif [[ $2 == 15  ]];
then


	local devId=$(echo ''$getDevRealKpi''  | jq '.data[].devId' )
		local inverter_state=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.inverter_state' )
		local dc_i1=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.dc_i1' )
		local dc_i2=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.dc_i2' )
		local dc_i3=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.dc_i3' )
		local dc_i4=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.dc_i4' )
		local dc_i5=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.dc_i5' )
		local dc_i6=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.dc_i6' )
		local dc_i7=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.dc_i7' )
		local dc_i8=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.dc_i8' )
		local dc_i9=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.dc_i9' )
		local dc_i10=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.dc_i10' )
		local dc_i11=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.dc_i11' )
		local dc_i12=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.dc_i12' )
		local dc_i13=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.dc_i13' )
		local dc_i14=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.dc_i14' )
		local dc_i15=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.dc_i15' )
		local dc_i16=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.dc_i16' )
		local dc_i17=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.dc_i17' )
		local dc_i18=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.dc_i18' )
		local dc_i19=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.dc_i19' )
		local dc_i20=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.dc_i20' )		
		local photc_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.photc_i' )
		local photc_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.photc_u' )
		local temperature=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.temperature' )
		local thunder_count=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.thunder_count' )
		local run_state=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.run_state' )		

local data_getDevRealKpi=$(echo ''$getDevRealKpi''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevRealKpi''  | jq '.currentTime' )
	local devIds=$(echo ''$data_getDevRealKpi''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevRealKpi''  | jq '.devTypeId' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "dc_i1_array=(${dc_i1})"
		eval "dc_i2_array=(${dc_i2})"	
		eval "dc_i3_array=(${dc_i3})"	
		eval "dc_i4_array=(${dc_i4})"	
		eval "dc_i5_array=(${dc_i5})"	
		eval "dc_i6_array=(${dc_i6})"	
		eval "dc_i7_array=(${dc_i7})"	
		eval "dc_i8_array=(${dc_i8})"	
		eval "dc_i9_array=(${dc_i9})"	
		eval "dc_i10_array=(${dc_i10})"	
		eval "dc_i11_array=(${dc_i11})"	
		eval "dc_i12_array=(${dc_i12})"	
		eval "dc_i13_array=(${dc_i13})"	
		eval "dc_i14_array=(${dc_i14})"	
		eval "dc_i15_array=(${dc_i15})"	
		eval "dc_i16_array=(${dc_i16})"	
		eval "dc_i17_array=(${dc_i17})"	
		eval "dc_i18_array=(${dc_i18})"	
		eval "dc_i19_array=(${dc_i19})"	
		eval "dc_i20_array=(${dc_i20})"		
		eval "photc_i_array=(${photc_i})"	
		eval "photc_u_array=(${photc_u})"
		eval "temperature_array=(${temperature})"	
		eval "thunder_count_array=(${thunder_count})"
		eval "run_state_array=(${run_state})"

# device is EMI
elif [[ $2 == 10  ]];
then

	local devId=$(echo ''$getDevRealKpi''  | jq '.data[].devId' )
		local temperature=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.temperature' )
		local pv_temperature=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.pv_temperature' )
		local wind_speed=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.wind_speed' )
		local wind_direction=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.wind_direction' )
		local radiant_total=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.radiant_total' )
		local radiant_line=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.radiant_line' )
		local horiz_radiant_line=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.horiz_radiant_line' )
		local horiz_radiant_total=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.horiz_radiant_total' )		
		local run_state=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.run_state' )

local data_getDevRealKpi=$(echo ''$getDevRealKpi''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevRealKpi''  | jq '.currentTime' )
	local devIds=$(echo ''$data_getDevRealKpi''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevRealKpi''  | jq '.devTypeId' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "temperature_array=(${temperature})"
		eval "pv_temperature_array=(${pv_temperature})"
		eval "wind_speed_array=(${wind_speed})"
		eval "wind_direction_array=(${wind_direction})"
		eval "radiant_total_array=(${radiant_total})"
		eval "radiant_line_array=(${radiant_line})"
		eval "horiz_radiant_line_array=(${horiz_radiant_line})"
		eval "horiz_radiant_total_array=(${horiz_radiant_total})"
		eval "run_state_array=(${run_state})"

# device is Meter (Grid meter)
elif [[ $2 == 17  ]];
then

	local devId=$(echo ''$getDevRealKpi''  | jq '.data[].devId' )
		local ab_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.ab_u' )
		local bc_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.bc_u' )
		local ca_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.ca_u' )
		local a_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.a_u' )
		local b_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.b_u' )
		local c_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.c_u' )
		local a_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.a_i' )
		local b_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.b_i' )
		local c_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.c_i' )
		local active_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.active_power' )
		local power_factor=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.power_factor' )
		local active_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.active_cap' )
		local reactive_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.reactive_power' )
		local reverse_active_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.reverse_active_cap' )
		local forward_reactive_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.forward_reactive_cap' )
		local reverse_reactive_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.reverse_reactive_cap' )
		local active_power_a=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.active_power_a' )
		local active_power_b=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.active_power_b' )
		local active_power_c=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.active_power_c' )
		local reactive_power_a=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.reactive_power_a' )
		local reactive_power_b=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.reactive_power_b' )
		local reactive_power_c=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.reactive_power_c' )
		local total_apparent_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.total_apparent_power' )
		local grid_frequency=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.grid_frequency' )
		local reverse_active_peak=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.reverse_active_peak' )
		local reverse_active_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.reverse_active_power' )
		local reverse_active_valley=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.reverse_active_valley' )
		local reverse_active_top=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.reverse_active_top' )
		local positive_active_peak=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.positive_active_peak' )
		local positive_active_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.positive_active_power' )
		local positive_active_valley=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.positive_active_valley' )
		local positive_active_top=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.positive_active_top' )
		local reverse_reactive_peak=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.reverse_reactive_peak' )
		local reverse_reactive_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.reverse_reactive_power' )
		local reverse_reactive_valley=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.reverse_reactive_valley' )
		local reverse_reactive_top=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.reverse_reactive_top' )
		local positive_reactive_peak=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.positive_reactive_peak' )
		local positive_reactive_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.positive_reactive_power' )
		local positive_reactive_valley=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.positive_reactive_valley' )
		local positive_reactive_top=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.positive_reactive_top' )
		

local data_getDevRealKpi=$(echo ''$getDevRealKpi''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevRealKpi''  | jq '.currentTime' )
	local devIds=$(echo ''$data_getDevRealKpi''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevRealKpi''  | jq '.devTypeId' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "ab_u_array=(${ab_u})"
		eval "bc_u_array=(${bc_u})"
		eval "ca_u_array=(${ca_u})"
		eval "a_u_array=(${a_u})"
		eval "b_u_array=(${b_u})"
		eval "c_u_array=(${c_u})"
		eval "a_i_array=(${a_i})"
		eval "b_i_array=(${b_i})"
		eval "c_i_array=(${c_i})"
		eval "active_power_array=(${active_power})"
		eval "power_factor_array=(${power_factor})"
		eval "active_cap_array=(${active_cap})"
		eval "reactive_power_array=(${reactive_power})"
		eval "reverse_active_cap_array=(${reverse_active_cap})"
		eval "forward_reactive_cap_array=(${forward_reactive_cap})"
		eval "reverse_reactive_cap_array=(${reverse_reactive_cap})"
		eval "active_power_a_array=(${active_power_a})"
		eval "active_power_b_array=(${active_power_b})"
		eval "active_power_c_array=(${active_power_c})"
		eval "reactive_power_a_array=(${reactive_power_a})"
		eval "reactive_power_b_array=(${reactive_power_b})"
		eval "reactive_power_c_array=(${reactive_power_c})"
		eval "total_apparent_power_array=(${total_apparent_power})"
		eval "grid_frequency_array=(${grid_frequency})"
		eval "reverse_active_peak_array=(${reverse_active_peak})"
		eval "reverse_active_power_array=(${reverse_active_power})"
		eval "reverse_active_valley_array=(${reverse_active_valley})"
		eval "reverse_active_top_array=(${reverse_active_top})"
		eval "positive_active_peak_array=(${positive_active_peak})"
		eval "positive_active_power_array=(${positive_active_power})"
		eval "positive_active_valley_array=(${positive_active_valley})"
		eval "positive_active_top_array=(${positive_active_top})"
		eval "reverse_reactive_peak_array=(${reverse_reactive_peak})"		
		eval "reverse_reactive_power_array=(${reverse_reactive_power})"
		eval "reverse_reactive_valley_array=(${reverse_reactive_valley})"
		eval "reverse_reactive_top_array=(${reverse_reactive_top})"
		eval "positive_reactive_peak_array=(${positive_reactive_peak})"
		eval "positive_reactive_power_array=(${positive_reactive_power})"
		eval "positive_reactive_valley_array=(${positive_reactive_valley})"
		eval "positive_reactive_top_array=(${positive_reactive_top})"
		
# device is Power Sensor
elif [[ $2 == 47  ]];
then	
	local devId=$(echo ''$getDevRealKpi''  | jq '.data[].devId' )
		local meter_status=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.meter_status' )
		local meter_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.meter_u' )
		local meter_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.meter_i' )
		local active_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.active_power' )
		local reactive_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.reactive_power' )		
		local power_factor=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.power_factor' )
		local grid_frequency=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.grid_frequency' )		
		local active_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.active_cap' )
		local reverse_active_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.reverse_active_cap' )
		local run_state=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.run_state' )

		

local data_getDevRealKpi=$(echo ''$getDevRealKpi''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevRealKpi''  | jq '.currentTime' )
	local devIds=$(echo ''$data_getDevRealKpi''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevRealKpi''  | jq '.devTypeId' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "meter_status_array=(${meter_status})"
		eval "meter_u_array=(${meter_u})"
		eval "meter_i_array=(${meter_i})"
		eval "active_power_array=(${active_power})"
		eval "reactive_power_array=(${reactive_power})"		
		eval "power_factor_array=(${power_factor})"
		eval "grid_frequency_array=(${grid_frequency})"
		eval "active_cap_array=(${active_cap})"
		eval "reverse_active_cap_array=(${reverse_active_cap})"
		eval "run_state_array=(${run_state})"	

# device is Battery
elif [[ $2 == 39  ]];
then
	local devId=$(echo ''$getDevRealKpi''  | jq '.data[].devId' )
		local battery_status=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.battery_status' )
		local max_charge_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.max_charge_power' )
		local max_discharge_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.max_discharge_power' )
		local ch_discharge_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.ch_discharge_power' )
		local busbar_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.busbar_u' )		
		local battery_soc=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.battery_soc' )
		local battery_soh=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.battery_soh' )		
		local ch_discharge_model=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap. ch_discharge_model' )
		local charge_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.charge_cap' )
		local discharge_cap=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.discharge_cap' )
		local run_state=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.run_state' )
	

local data_getDevRealKpi=$(echo ''$getDevRealKpi''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevRealKpi''  | jq '.currentTime' )
	local devIds=$(echo ''$data_getDevRealKpi''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevRealKpi''  | jq '.devTypeId' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "battery_status_array=(${battery_status})"
		eval "max_charge_power_array=(${max_charge_power})"
		eval "max_discharge_power_array=(${max_discharge_power})"
		eval "ch_discharge_power_array=(${ch_discharge_power})"
		eval "busbar_u_array=(${busbar_u})"
		eval "battery_soc_array=(${battery_soc})"		
		eval "battery_soh_array=(${battery_soh})"
		eval "ch_discharge_model_array=(${ch_discharge_model})"
		eval "charge_cap_array=(${charge_cap})"
		eval "discharge_cap_array=(${discharge_cap})"
		eval "run_state_array=(${run_state})"	
		
# device is Transformer
elif [[ $2 == 8  ]];
then
	local devId=$(echo ''$getDevRealKpi''  | jq '.data[].devId' )
		local ab_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.ab_u' )
		local bc_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.bc_u' )
		local ca_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.ca_u' )
		local a_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.a_u' )
		local b_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.b_u' )
		local c_u=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.c_u' )
		local a_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.a_i' )
		local b_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.b_i' )
		local c_i=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.c_i' )
		local active_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.active_power' )
		local reactive_power=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.reactive_power' )
		local power_factor=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.power_factor' )
		local elec_freq=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.elec_freq' )		
		local run_state=$(echo ''$getDevRealKpi''  | jq '.data[].dataItemMap.run_state' )
	

local data_getDevRealKpi=$(echo ''$getDevRealKpi''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevRealKpi''  | jq '.currentTime' )
	local devIds=$(echo ''$data_getDevRealKpi''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevRealKpi''  | jq '.devTypeId' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "ab_u_array=(${ab_u})"
		eval "bc_u_array=(${bc_u})"
		eval "ca_u_array=(${ca_u})"
		eval "a_u_array=(${a_u})"
		eval "b_u_array=(${b_u})"
		eval "c_u_array=(${c_u})"
		eval "a_i_array=(${a_i})"
		eval "b_i_array=(${b_i})"
		eval "c_i_array=(${c_i})"		
		eval "active_power_array=(${active_power})"
		eval "reactive_power_array=(${reactive_power})"		
		eval "power_factor_array=(${power_factor})"
		eval "elec_freq_array=(${elec_freq})"
		eval "run_state_array=(${run_state})"	
fi

										
# Here comma is our delimiter value to array of stations codes given by user as a parameter in question
IFS="," read -a devIds_array <<< $devIds
IFS="," read -a devTypeId_array <<< $devTypeId

#echo "Request success or failure flag: " $success
if [[ $success == "true"  ]];
	then	
		echo ""
		echo -e "API \e[4mgetDevRealKpi\e[0m connection \e[42mOK\e[0m"
		getDevRealKpi_connection=true
elif [[ $success == "false" ]];
	then
		echo ""
		echo -e "API \e[4mgetDevRealKpi\e[0m connection \e[41mError\e[0m"
		getDevRealKpi_connection=false
else
	echo ""
	echo -e "\e[41mNetwork Error :(\e[0m" 
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


if [[ $success == "true"  ]];
then	
	echo "Build Code: "$buildCode
fi


local curent_time_actually=$(echo ${currentTime::-3})
local curent_time_of_request=$(date -d @$curent_time_actually)
echo "Time of your Request to API: "$curent_time_of_request

# if we have inverter
if [[ $success == "true"  ]] && [[  $2 == 1  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""
	echo ""
	
	for (( c=0; c<=((${#devIds_array[@]}-1)); c++ )) 
	do
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$c]}
		echo -e "\e[0m ID: "${devId_array[$c]}
		
		if [[ ! ${inverter_state_array[$c]} == null  ]];
		then	
			printf "	Inverter status: "
			#decimal number to hexdecimal
			local hex=$( printf "%x" ${inverter_state_array[$c]} );
			#echo $hex
			#function to check inverter status
			inverter_state $hex
			echo ""			
		fi
		
		#special loop  for checking if inverter is diconected
		if [[ ! $hex == "0"  ]];
		then
		
				
		if [[ ! ${ab_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid AB voltage: "${ab_u_array[$c]}" V"				
		fi
		if [[ ! ${bc_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid BC voltage: "${bc_u_array[$c]}" V"				
		fi
		if [[ ! ${ca_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid CA voltage: "${ca_u_array[$c]}" V"				
		fi
		if [[ ! ${a_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase A voltage: "${a_u_array[$c]}" V"				
		fi
		if [[ ! ${b_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase B voltage: "${b_u_array[$c]}" V"				
		fi
		if [[ ! ${c_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase C voltage: "${c_u_array[$c]}" V"				
		fi
		if [[ ! ${a_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase A current: "${a_i_array[$c]}" A"				
		fi
		if [[ ! ${b_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase B current: "${b_i_array[$c]}" A"				
		fi
		if [[ ! ${c_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase C current: "${c_i_array[$c]}" A"				
		fi
		if [[ ! ${efficiency_array[$c]} == null  ]];
		then	
			echo -e "	Inverter conversion efficiency (manufacturer): "${efficiency_array[$c]}" %"				
		fi
		if [[ ! ${temperature_array[$c]} == null  ]];
		then	
			echo -e "	Device internal temperature: "${temperature_array[$c]}" °C"				
		fi
		if [[ ! ${power_factor_array[$c]} == null  ]];
		then	
			echo -e "	Power factor: "${power_factor_array[$c]}			
		fi
		if [[ ! ${elec_freq_array[$c]} == null  ]];
		then	
			echo -e "	Grid frequency: "${elec_freq_array[$c]}" Hz"			
		fi
		if [[ ! ${active_power_array[$c]} == null  ]];
		then	
			echo -e "	Active power: "${active_power_array[$c]}" Kw"			
		fi
		if [[ ! ${reactive_power_array[$c]} == null  ]];
		then	
			echo -e "	Output reactive power: "${reactive_power_array[$c]}" Kvar"			
		fi
		if [[ ! ${day_cap_array[$c]} == null  ]];
		then	
			echo -e "	Daily energy: "${day_cap_array[$c]}" Kwh"			
		fi
				if [[ ! ${mppt_power_array[$c]} == null  ]];
		then	
			echo -e "	MPPT (Maximum Power Point Tracking) total input power: "${mppt_power_array[$c]}" Kw"			
		fi
		if [[ ! ${pv1_u_array[$c]} == null  ]];
		then	
			echo -e "	PV1 input voltage: "${pv1_u_array[$c]}" V"			
		fi
		if [[ ! ${pv2_u_array[$c]} == null  ]];
		then	
			echo -e "	PV2 input voltage: "${pv2_u_array[$c]}" V"			
		fi
		if [[ ! ${pv3_u_array[$c]} == null  ]];
		then	
			echo -e "	PV3 input voltage: "${pv3_u_array[$c]}" V"			
		fi
		if [[ ! ${pv4_u_array[$c]} == null  ]];
		then	
			echo -e "	PV4 input voltage: "${pv4_u_array[$c]}" V"	
		fi		
		if [[ ! ${pv5_u_array[$c]} == null  ]];
		then	
			echo -e "	PV5 input voltage: "${pv5_u_array[$c]}" V"			
		fi
		if [[ ! ${pv6_u_array[$c]} == null  ]];
		then	
			echo -e "	PV6 input voltage: "${pv6_u_array[$c]}" V"			
		fi
		if [[ ! ${pv7_u_array[$c]} == null  ]];
		then	
			echo -e "	PV7 input voltage: "${pv7_u_array[$c]}" V"			
		fi
		if [[ ! ${pv8_u_array[$c]} == null  ]];
		then	
			echo -e "	PV8 input voltage: "${pv8_u_array[$c]}" V"			
		fi
		if [[ ! ${pv9_u_array[$c]} == null  ]];
		then	
			echo -e "	PV9 input voltage: "${pv9_u_array[$c]}" V"			
		fi
		if [[ ! ${pv10_u_array[$c]} == null  ]];
		then	
			echo -e "	PV10 input voltage: "${pv10_u_array[$c]}" V"			
		fi
		if [[ ! ${pv11_u_array[$c]} == null  ]];
		then	
			echo -e "	PV11 input voltage: "${pv11_u_array[$c]}" V"			
		fi
		if [[ ! ${pv12_u_array[$c]} == null  ]];
		then	
			echo -e "	PV12 input voltage: "${pv12_u_array[$c]}" V"			
		fi
		if [[ ! ${pv13_u_array[$c]} == null  ]];
		then	
			echo -e "	PV13 input voltage: "${pv13_u_array[$c]}" V"			
		fi
		if [[ ! ${pv14_u_array[$c]} == null  ]];
		then	
			echo -e "	PV14 input voltage: "${pv14_u_array[$c]}" V"			
		fi
		if [[ ! ${pv15_u_array[$c]} == null  ]];
		then	
			echo -e "	PV15 input voltage: "${pv15_u_array[$c]}" V"			
		fi
		if [[ ! ${pv16_u_array[$c]} == null  ]];
		then	
			echo -e "	PV16 input voltage: "${pv16_u_array[$c]}" V"			
		fi
		if [[ ! ${pv17_u_array[$c]} == null  ]];
		then	
			echo -e "	PV17 input voltage: "${pv17_u_array[$c]}" V"			
		fi
		if [[ ! ${pv18_u_array[$c]} == null  ]];
		then	
			echo -e "	PV18 input voltage: "${pv18_u_array[$c]}" V"			
		fi
		if [[ ! ${pv19_u_array[$c]} == null  ]];
		then	
			echo -e "	PV19 input voltage: "${pv19_u_array[$c]}" V"			
		fi
		if [[ ! ${pv20_u_array[$c]} == null  ]];
		then	
			echo -e "	PV20 input voltage: "${pv20_u_array[$c]}" V"			
		fi
		if [[ ! ${pv21_u_array[$c]} == null  ]];
		then	
			echo -e "	PV21 input voltage: "${pv21_u_array[$c]}" V"			
		fi
		if [[ ! ${pv22_u_array[$c]} == null  ]];
		then	
			echo -e "	PV22 input voltage: "${pv22_u_array[$c]}" V"			
		fi
		if [[ ! ${pv23_u_array[$c]} == null  ]];
		then	
			echo -e "	PV23 input voltage: "${pv23_u_array[$c]}" V"			
		fi
		if [[ ! ${pv24_u_array[$c]} == null  ]];
		then	
			echo -e "	PV24 input voltage: "${pv24_u_array[$c]}" V"			
		fi
				if [[ ! ${pv1_i_array[$c]} == null  ]];
		then	
			echo -e "	PV1 input current: "${pv1_i_array[$c]}" A"			
		fi
		if [[ ! ${pv2_i_array[$c]} == null  ]];
		then	
			echo -e "	PV2 input current: "${pv2_i_array[$c]}" A"			
		fi
		if [[ ! ${pv3_i_array[$c]} == null  ]];
		then	
			echo -e "	PV3 input current: "${pv3_i_array[$c]}" A"			
		fi
		if [[ ! ${pv4_i_array[$c]} == null  ]];
		then	
			echo -e "	PV4 input current: "${pv4_i_array[$c]}" A"			
		fi
		if [[ ! ${pv5_i_array[$c]} == null  ]];
		then	
			echo -e "	PV5 input current: "${pv5_i_array[$c]}" A"			
		fi
		if [[ ! ${pv6_i_array[$c]} == null  ]];
		then	
			echo -e "	PV6 input current: "${pv6_i_array[$c]}" A"			
		fi
		if [[ ! ${pv7_i_array[$c]} == null  ]];
		then	
			echo -e "	PV7 input current: "${pv7_i_array[$c]}" A"			
		fi
		if [[ ! ${pv8_i_array[$c]} == null  ]];
		then	
			echo -e "	PV8 input current: "${pv8_i_array[$c]}" A"			
		fi
		if [[ ! ${pv9_i_array[$c]} == null  ]];
		then	
			echo -e "	PV9 input current: "${pv9_i_array[$c]}" A"			
		fi
		if [[ ! ${pv10_i_array[$c]} == null  ]];
		then	
			echo -e "	PV10 input current: "${pv10_i_array[$c]}" A"			
		fi
		if [[ ! ${pv11_i_array[$c]} == null  ]];
		then	
			echo -e "	PV11 input current: "${pv11_i_array[$c]}" A"			
		fi
		if [[ ! ${pv12_i_array[$c]} == null  ]];
		then	
			echo -e "	PV12 input current: "${pv12_i_array[$c]}" A"			
		fi
		if [[ ! ${pv13_i_array[$c]} == null  ]];
		then	
			echo -e "	PV13 input current: "${pv13_i_array[$c]}" A"			
		fi
		if [[ ! ${pv14_i_array[$c]} == null  ]];
		then	
			echo -e "	PV14 input current: "${pv14_i_array[$c]}" A"			
		fi
		if [[ ! ${pv15_i_array[$c]} == null  ]];
		then	
			echo -e "	PV15 input current: "${pv15_i_array[$c]}" A"			
		fi
		if [[ ! ${pv16_i_array[$c]} == null  ]];
		then	
			echo -e "	PV16 input current: "${pv16_i_array[$c]}" A"			
		fi
		if [[ ! ${pv17_i_array[$c]} == null  ]];
		then	
			echo -e "	PV17 input current: "${pv17_i_array[$c]}" A"			
		fi
		if [[ ! ${pv18_i_array[$c]} == null  ]];
		then	
			echo -e "	PV18 input current: "${pv18_i_array[$c]}" A"			
		fi
		if [[ ! ${pv19_i_array[$c]} == null  ]];
		then	
			echo -e "	PV19 input current: "${pv19_i_array[$c]}" A"			
		fi
		if [[ ! ${pv20_i_array[$c]} == null  ]];
		then	
			echo -e "	PV20 input current: "${pv20_i_array[$c]}" A"			
		fi
		if [[ ! ${pv21_i_array[$c]} == null  ]];
		then	
			echo -e "	PV21 input current: "${pv21_i_array[$c]}" A"			
		fi
		if [[ ! ${pv22_i_array[$c]} == null  ]];
		then	
			echo -e "	PV22 input current: "${pv22_i_array[$c]}" A"			
		fi
		if [[ ! ${pv23_i_array[$c]} == null  ]];
		then	
			echo -e "	PV23 input current: "${pv23_i_array[$c]}" A"			
		fi
		if [[ ! ${pv24_i_array[$c]} == null  ]];
		then	
			echo -e "	PV24 input current: "${pv24_i_array[$c]}" A"			
		fi
		if [[ ! ${total_cap_array[$c]} == null  ]];
		then	
			echo -e "	Cumulative energy: "${total_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${open_time_array[$c]} == null  ]];
		then	
			local startup_time=$(date -d @${open_time_array[$c]})	
			echo -e "	Inverter last startup time: "$startup_time					
		fi
		if [[ ! ${close_time_array[$c]} == null  ]];
		then	
			local shutdown_time=$(date -d @${close_time_array[$c]})
			echo -e "	Inverter last shutdown time: "$shutdown_time		
		fi
		if [[ ! ${mppt_total_cap_array[$c]} == null  ]];
		then	
			echo -e "	Total DC input energy: "${mppt_total_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_1_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 1 DC cumulative energy: "${mppt_1_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_2_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 2 DC cumulative energy: "${mppt_2_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_3_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 3 DC cumulative energy: "${mppt_3_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_4_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 4 DC cumulative energy: "${mppt_4_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_5_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 5 DC cumulative energy: "${mppt_5_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_6_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 6 DC cumulative energy: "${mppt_6_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_7_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 7 DC cumulative energy: "${mppt_7_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_8_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 8 DC cumulative energy: "${mppt_8_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_9_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 9 DC cumulative energy: "${mppt_9_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_10_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 10 DC cumulative energy: "${mppt_10_cap_array[$c]}" Kwh"			
		fi
		
		#special for checking if inverter is diconected 
		else
			echo -e "	No any Real-time data when device is disconected!"
		
		#special loop finish for checking if inverter is diconected 
		fi

		if [[ ! ${run_state_array[$c]} == null  ]];
		then	
			if [[ ${run_state_array[$c]} == 0  ]];
			then
			device_status="Disconnected"
			elif [[ ${run_state_array[$c]} == 1  ]];
			then
			device_status="Connected but Standby"
			elif [[ ${run_state_array[$c]} == 2  ]];
			then
			device_status="Connected"
			else
			device_status="Unknow"
			fi
			echo -e "	Status: "$device_status			
		fi
	done
fi

# if we have central inverter
if [[ $success == "true"  ]] && [[  $2 == 14  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""
	echo ""
	
	for (( c=0; c<=((${#devIds_array[@]}-1)); c++ )); do
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$c]}
		echo -e "\e[0m ID: "${devId_array[$c]}
		
		if [[ ! ${inverter_state_array[$c]} == null  ]];
		then	
			printf "	Inverter status: "
			#decimal number to hexdecimal
			local hex=$( printf "%x" ${inverter_state_array[$c]} );
			#echo $hex
			#function to check inverter status
			inverter_state $hex
			echo ""			
		fi
		if [[ ! ${day_cap_array[$c]} == null  ]];
		then	
			echo -e "	Daily energy: "${day_cap_array[$c]}" KWh"				
		fi
		if [[ ! ${total_cap_array[$c]} == null  ]];
		then	
			echo -e "	Cumulative energy: "${total_cap_array[$c]}" kWh"				
		fi
		if [[ ! ${temperature_array[$c]} == null  ]];
		then	
			echo -e "	Device internal temperature: "${temperature_array[$c]}" °C"				
		fi
		if [[ ! ${center_u_array[$c]} == null  ]];
		then	
			echo -e "	DC voltage: "${center_u_array[$c]}" V"				
		fi
		if [[ ! ${center_i_array[$c]} == null  ]];
		then	
			echo -e "	DC current: "${center_i_array[$c]}" A"				
		fi
		if [[ ! ${center_i_1_array[$c]} == null  ]];
		then	
			echo -e "	#1 current value: "${center_i_1_array[$c]}" A"				
		fi
		if [[ ! ${center_i_2_array[$c]} == null  ]];
		then	
			echo -e "	#2 current value: "${center_i_2_array[$c]}" A"				
		fi
		if [[ ! ${center_i_3_array[$c]} == null  ]];
		then	
			echo -e "	#3 current value: "${center_i_3_array[$c]}" A"				
		fi
		if [[ ! ${center_i_4_array[$c]} == null  ]];
		then	
			echo -e "	#4 current value: "${center_i_4_array[$c]}" A"				
		fi
		if [[ ! ${center_i_5_array[$c]} == null  ]];
		then	
			echo -e "	#5 current value: "${center_i_5_array[$c]}" A"				
		fi
		if [[ ! ${center_i_6_array[$c]} == null  ]];
		then	
			echo -e "	#6 current value: "${center_i_6_array[$c]}" A"				
		fi			
		if [[ ! ${center_i_7_array[$c]} == null  ]];
		then	
			echo -e "	#7 current value: "${center_i_7_array[$c]}" A"				
		fi
		if [[ ! ${center_i_8_array[$c]} == null  ]];
		then	
			echo -e "	#8 current value: "${center_i_8_array[$c]}" A"				
		fi
		if [[ ! ${center_i_9_array[$c]} == null  ]];
		then	
			echo -e "	#9 current value: "${center_i_9_array[$c]}" A"				
		fi
		if [[ ! ${center_i_10_array[$c]} == null  ]];
		then	
			echo -e "	#10 current value: "${center_i_10_array[$c]}" A"				
		fi
		if [[ ! ${mppt_power_array[$c]} == null  ]];
		then	
			echo -e "	MPPT (Maximum Power Point Tracking) total input power: "${mppt_power_array[$c]}" Kw"			
		fi
		if [[ ! ${a_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase A voltage: "${a_u_array[$c]}" V"				
		fi
		if [[ ! ${b_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase B voltage: "${b_u_array[$c]}" V"				
		fi
		if [[ ! ${c_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase C voltage: "${c_u_array[$c]}" V"				
		fi
		if [[ ! ${a_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase A current: "${a_i_array[$c]}" A"				
		fi
		if [[ ! ${b_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase B current: "${b_i_array[$c]}" A"				
		fi
		if [[ ! ${c_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase C current: "${c_i_array[$c]}" A"				
		fi
		if [[ ! ${power_factor_array[$c]} == null  ]];
		then	
			echo -e "	Power factor: "${power_factor_array[$c]}			
		fi
		if [[ ! ${elec_freq_array[$c]} == null  ]];
		then	
			echo -e "	Grid frequency: "${elec_freq_array[$c]}" Hz"			
		fi
		if [[ ! ${active_power_array[$c]} == null  ]];
		then	
			echo -e "	Active power: "${active_power_array[$c]}" Kw"			
		fi
		if [[ ! ${reactive_power_array[$c]} == null  ]];
		then	
			echo -e "	Output reactive power: "${reactive_power_array[$c]}" Kvar"			
		fi
		if [[ ! ${open_time_array[$c]} == null  ]];
		then	
			local startup_time=$(date -d @${open_time_array[$c]})	
			echo -e "	Inverter last startup time: "$startup_time
					
		fi
		if [[ ! ${close_time_array[$c]} == null  ]];
		then	
			local shutdown_time=$(date -d @${close_time_array[$c]})
			echo -e "	Inverter last shutdown time: "$shutdown_time		
		fi
		if [[ ! ${aop_array[$c]} == null  ]];
		then	
			echo -e "	Production reliability: "${aop_array[$c]}" %"			
		fi
		if [[ ! ${run_state_array[$c]} == null  ]];
		then	
			if [[ ${run_state_array[$c]} == 0  ]];
			then
			device_status="Disconnected"
			elif [[ ${run_state_array[$c]} == 1  ]];
			then
			device_status="Connected"
			else
			device_status="Unknow"
			fi
			echo -e "	Status: "$device_status			
	fi
	done
fi

# device is Smart Energy Center
if [[ $success == "true"  ]] && [[  $2 == 38  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""
	echo ""
	
	for (( c=0; c<=((${#devIds_array[@]}-1)); c++ )); do
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$c]}
		echo -e "\e[0m ID: "${devId_array[$c]}
		
		if [[ ! ${inverter_state_array[$c]} == null  ]];
		then	
			printf "	Inverter status: "
			#decimal number to hexdecimal
			local hex=$( printf "%x" ${inverter_state_array[$c]} );
			#echo $hex
			#function to check inverter status
			inverter_state $hex
			echo ""			
		fi
		if [[ ! ${ab_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid AB voltage: "${ab_u_array[$c]}" V"				
		fi
		if [[ ! ${bc_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid BC voltage: "${bc_u_array[$c]}" V"				
		fi
		if [[ ! ${ca_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid CA voltage: "${ca_u_array[$c]}" V"				
		fi
		if [[ ! ${a_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase A voltage: "${a_u_array[$c]}" V"				
		fi
		if [[ ! ${b_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase B voltage: "${b_u_array[$c]}" V"				
		fi
		if [[ ! ${c_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase C voltage: "${c_u_array[$c]}" V"				
		fi
		if [[ ! ${a_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase A current: "${a_i_array[$c]}" A"				
		fi
		if [[ ! ${b_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase B current: "${b_i_array[$c]}" A"				
		fi
		if [[ ! ${c_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase C current: "${c_i_array[$c]}" A"				
		fi
		if [[ ! ${efficiency_array[$c]} == null  ]];
		then	
			echo -e "	Inverter conversion efficiency (manufacturer): "${efficiency_array[$c]}" %"				
		fi
		if [[ ! ${temperature_array[$c]} == null  ]];
		then	
			echo -e "	Device internal temperature: "${temperature_array[$c]}" °C"				
		fi
		if [[ ! ${power_factor_array[$c]} == null  ]];
		then	
			echo -e "	Power factor: "${power_factor_array[$c]}			
		fi
		if [[ ! ${elec_freq_array[$c]} == null  ]];
		then	
			echo -e "	Grid frequency: "${elec_freq_array[$c]}" Hz"			
		fi
		if [[ ! ${active_power_array[$c]} == null  ]];
		then	
			echo -e "	Active power: "${active_power_array[$c]}" Kw"			
		fi
		if [[ ! ${reactive_power_array[$c]} == null  ]];
		then	
			echo -e "	Output reactive power: "${reactive_power_array[$c]}" Kvar"			
		fi
		if [[ ! ${day_cap_array[$c]} == null  ]];
		then	
			echo -e "	Daily energy: "${day_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_power_array[$c]} == null  ]];
		then	
			echo -e "	MPPT (Maximum Power Point Tracking) total input power: "${mppt_power_array[$c]}" Kw"			
		fi
		if [[ ! ${pv1_u_array[$c]} == null  ]];
		then	
			echo -e "	PV1 input voltage: "${pv1_u_array[$c]}" V"			
		fi
		if [[ ! ${pv2_u_array[$c]} == null  ]];
		then	
			echo -e "	PV2 input voltage: "${pv2_u_array[$c]}" V"			
		fi
		if [[ ! ${pv3_u_array[$c]} == null  ]];
		then	
			echo -e "	PV3 input voltage: "${pv3_u_array[$c]}" V"			
		fi
		if [[ ! ${pv4_u_array[$c]} == null  ]];
		then	
			echo -e "	PV4 input voltage: "${pv4_u_array[$c]}" V"			
		if [[ ! ${pv5_u_array[$c]} == null  ]];
		then	
			echo -e "	PV5 input voltage: "${pv5_u_array[$c]}" V"			
		fi
		if [[ ! ${pv6_u_array[$c]} == null  ]];
		then	
			echo -e "	PV6 input voltage: "${pv6_u_array[$c]}" V"			
		fi
		if [[ ! ${pv7_u_array[$c]} == null  ]];
		then	
			echo -e "	PV7 input voltage: "${pv7_u_array[$c]}" V"			
		fi
		if [[ ! ${pv8_u_array[$c]} == null  ]];
		then	
			echo -e "	PV8 input voltage: "${pv8_u_array[$c]}" V"			
		fi
		if [[ ! ${pv1_i_array[$c]} == null  ]];
		then	
			echo -e "	PV1 input current: "${pv1_i_array[$c]}" A"			
		fi
		if [[ ! ${pv2_i_array[$c]} == null  ]];
		then	
			echo -e "	PV2 input current: "${pv2_i_array[$c]}" A"			
		fi
		if [[ ! ${pv3_i_array[$c]} == null  ]];
		then	
			echo -e "	PV3 input current: "${pv3_i_array[$c]}" A"			
		fi
		if [[ ! ${pv4_i_array[$c]} == null  ]];
		then	
			echo -e "	PV4 input current: "${pv4_i_array[$c]}" A"			
		fi
		if [[ ! ${pv5_i_array[$c]} == null  ]];
		then	
			echo -e "	PV5 input current: "${pv5_i_array[$c]}" A"			
		fi
		if [[ ! ${pv6_i_array[$c]} == null  ]];
		then	
			echo -e "	PV6 input current: "${pv6_i_array[$c]}" A"			
		fi
		if [[ ! ${pv7_i_array[$c]} == null  ]];
		then	
			echo -e "	PV7 input current: "${pv7_i_array[$c]}" A"			
		fi
		if [[ ! ${pv8_i_array[$c]} == null  ]];
		then	
			echo -e "	PV8 input current: "${pv8_i_array[$c]}" A"			
		fi
		if [[ ! ${total_cap_array[$c]} == null  ]];
		then	
			echo -e "	Cumulative energy: "${total_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${open_time_array[$c]} == null  ]];
		then	
			local startup_time=$(date -d @${open_time_array[$c]})	
			echo -e "	Inverter last startup time: "$startup_time					
		fi
		if [[ ! ${close_time_array[$c]} == null  ]];
		then	
			local shutdown_time=$(date -d @${close_time_array[$c]})
			echo -e "	Inverter last shutdown time: "$shutdown_time		
		fi
		if [[ ! ${mppt_total_cap_array[$c]} == null  ]];
		then	
			echo -e "	Total DC input energy: "${mppt_total_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_1_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 1 DC cumulative energy: "${mppt_1_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_2_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 2 DC cumulative energy: "${mppt_2_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_3_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 3 DC cumulative energy: "${mppt_3_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_4_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 4 DC cumulative energy: "${mppt_4_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${run_state_array[$c]} == null  ]];
		then	
			if [[ ${run_state_array[$c]} == 0  ]];
			then
			device_status="Disconnected"
			elif [[ ${run_state_array[$c]} == 1  ]];
			then
			device_status="Connected"
			else
			device_status="Unknow"
			fi
			echo -e "	Status: "$device_status			
		fi
	fi
	done
fi

# device is DC combiner box
if [[ $success == "true"  ]] && [[ $2 == 15  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""
	echo ""
	
	for (( c=0; c<=((${#devIds_array[@]}-1)); c++ )); do
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$c]}
		echo -e "\e[0m ID: "${devId_array[$c]}
					
		
		if [[ ! ${dc_i1_array[$c]} == null  ]];
		then	
			echo -e "	#1 current value: "${dc_i1_array[$c]}" A"				
		fi
		if [[ ! ${dc_i2_array[$c]} == null  ]];
		then	
			echo -e "	#2 current value: "${dc_i2_array[$c]}" A"				
		fi
		if [[ ! ${dc_i3_array[$c]} == null  ]];
		then	
			echo -e "	#3 current value: "${dc_i3_array[$c]}" A"				
		fi
		if [[ ! ${dc_i4_array[$c]} == null  ]];
		then	
			echo -e "	#4 current value: "${dc_i4_array[$c]}" A"				
		fi
		if [[ ! ${dc_i5_array[$c]} == null  ]];
		then	
			echo -e "	#5 current value: "${dc_i5_array[$c]}" A"				
		fi
		if [[ ! ${dc_i6_array[$c]} == null  ]];
		then	
			echo -e "	#6 current value: "${dc_i6_array[$c]}" A"				
		fi
		if [[ ! ${dc_i7_array[$c]} == null  ]];
		then	
			echo -e "	#7 current value: "${dc_i7_array[$c]}" A"				
		fi
		if [[ ! ${dc_i8_array[$c]} == null  ]];
		then	
			echo -e "	#8 current value: "${dc_i8_array[$c]}" A"				
		fi
		if [[ ! ${dc_i9_array[$c]} == null  ]];
		then	
			echo -e "	#9 current value: "${dc_i9_array[$c]}" A"				
		fi
		if [[ ! ${dc_i10_array[$c]} == null  ]];
		then	
			echo -e "	#10 current value: "${dc_i10_array[$c]}" A"				
		fi
		if [[ ! ${dc_i11_array[$c]} == null  ]];
		then	
			echo -e "	#11 current value: "${dc_i11_array[$c]}" A"				
		fi
		if [[ ! ${dc_i12_array[$c]} == null  ]];
		then	
			echo -e "	#12 current value: "${dc_i12_array[$c]}" A"				
		fi
		if [[ ! ${dc_i13_array[$c]} == null  ]];
		then	
			echo -e "	#13 current value: "${dc_i13_array[$c]}" A"				
		fi
		if [[ ! ${dc_i14_array[$c]} == null  ]];
		then	
			echo -e "	#14 current value: "${dc_i14_array[$c]}" A"				
		fi
		if [[ ! ${dc_i15_array[$c]} == null  ]];
		then	
			echo -e "	#15 current value: "${dc_i15_array[$c]}" A"				
		fi
		if [[ ! ${dc_i16_array[$c]} == null  ]];
		then	
			echo -e "	#16 current value: "${dc_i16_array[$c]}" A"				
		fi
		if [[ ! ${dc_i17_array[$c]} == null  ]];
		then	
			echo -e "	#17 current value: "${dc_i17_array[$c]}" A"				
		fi
		if [[ ! ${dc_i18_array[$c]} == null  ]];
		then	
			echo -e "	#18 current value: "${dc_i18_array[$c]}" A"				
		fi
		if [[ ! ${dc_i19_array[$c]} == null  ]];
		then	
			echo -e "	#19 current value: "${dc_i19_array[$c]}" A"				
		fi
		if [[ ! ${dc_i20_array[$c]} == null  ]];
		then	
			echo -e "	#20 current value: "${dc_i20_array[$c]}" A"				
		fi
		if [[ ! ${photc_i_array[$c]} == null  ]];
		then	
			echo -e "	PV current: "${photc_i_array[$c]}" A"				
		fi
		if [[ ! ${photc_u_array[$c]} == null  ]];
		then	
			echo -e "	PV voltage: "${photc_u_array[$c]}" V"				
		fi
		if [[ ! ${temperature_array[$c]} == null  ]];
		then	
			echo -e "	Device internal temperature: "${temperature_array[$c]}" °C"				
		fi
		if [[ ! ${thunder_count_array[$c]} == null  ]];
		then	
			echo -e "	Number of lightning strikes: "${thunder_count_array[$c]}" Times"				
		if [[ ! ${run_state_array[$c]} == null  ]];
		then	
			if [[ ${run_state_array[$c]} == 0  ]];
			then
			device_status="Disconnected"
			elif [[ ${run_state_array[$c]} == 1  ]];
			then
			device_status="Connected"
			else
			device_status="Unknow"
			fi
			echo -e "	Status: "$device_status			
		fi
		
	fi
	done
fi

# device is EMI
if [[ $success == "true"  ]] && [[ $2 == 10  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""
	echo ""
	
	for (( c=0; c<=((${#devIds_array[@]}-1)); c++ )); do
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$c]}
		echo -e "\e[0m ID: "${devId_array[$c]}
					
		
		if [[ ! ${temperature_array[$c]} == null  ]];
		then	
			echo -e "	Temperature: "${temperature_array[$c]}" °C"				
		fi			
		if [[ ! ${pv_temperature_array[$c]} == null  ]];
		then	
			echo -e "	PV temperature: "${pv_temperature_array[$c]}" °C"				
		fi	
		if [[ ! ${wind_speed_array[$c]} == null  ]];
		then	
			echo -e "	Wind speed: "${wind_speed_array[$c]}" m/s"				
		fi	
		if [[ ! ${wind_direction_array[$c]} == null  ]];
		then	
			echo -e "	Wind direction: "${wind_direction_array[$c]}" Degree"				
		fi	
		if [[ ! ${radiant_total_array[$c]} == null  ]];
		then	
			echo -e "	Total irradiation: "${radiant_total_array[$c]}" MJ/m 2"				
		fi	
		if [[ ! ${radiant_line_array[$c]} == null  ]];
		then	
			echo -e "	Irradiation intensity: "${radiant_line_array[$c]}" W/m 2"				
		fi	
		if [[ ! ${horiz_radiant_line_array[$c]} == null  ]];
		then	
			echo -e "	Horizontal irradiation intensity: "${horiz_radiant_line_array[$c]}" W/m 2"				
		fi	
		if [[ ! ${horiz_radiant_total_array[$c]} == null  ]];
		then	
			echo -e "	Horizontal irradiation: "${horiz_radiant_total_array[$c]}" MJ/m 2"				
		fi
		if [[ ! ${run_state_array[$c]} == null  ]];
		then	
			if [[ ${run_state_array[$c]} == 1  ]];
			then
			device_status="Disconnected"
			elif [[ ${run_state_array[$c]} == 2  ]];
			then
			device_status="Connected"
			else
			device_status="Unknow"
			fi
			echo -e "	Status: "$device_status			
		fi

	done
fi


# device is Meter (Grid meter)
if [[ $success == "true"  ]] && [[ $2 == 17  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""
	echo ""
	
	for (( c=0; c<=((${#devIds_array[@]}-1)); c++ )); do
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$c]}
		echo -e "\e[0m ID: "${devId_array[$c]}
					
		
		if [[ ! ${ab_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid AB voltage: "${ab_u_array[$c]}" V"				
		fi
		if [[ ! ${bc_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid BC voltage: "${bc_u_array[$c]}" V"				
		fi
		if [[ ! ${ca_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid CA voltage: "${ca_u_array[$c]}" V"				
		fi
		if [[ ! ${a_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase A voltage: "${a_u_array[$c]}" V"				
		fi
		if [[ ! ${b_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase B voltage: "${b_u_array[$c]}" V"				
		fi
		if [[ ! ${c_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase C voltage: "${c_u_array[$c]}" V"				
		fi
		if [[ ! ${a_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase A current: "${a_i_array[$c]}" A"				
		fi
		if [[ ! ${b_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase B current: "${b_i_array[$c]}" A"				
		fi
		if [[ ! ${c_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase C current: "${c_i_array[$c]}" A"				
		fi
		if [[ ! ${active_power_array[$c]} == null  ]];
		then	
			echo -e "	Active power: "${active_power_array[$c]}" Kw"		
		fi
		if [[ ! ${power_factor_array[$c]} == null  ]];
		then	
			echo -e "	Power factor: "${power_factor_array[$c]}			
		fi
		if [[ ! ${active_cap_array[$c]} == null  ]];
		then	
			echo -e "	Active power (Kilowatt hour of positive active power): "${active_cap_array[$c]}" kWh"			
		fi
		if [[ ! ${reactive_power_array[$c]} == null  ]];
		then	
			echo -e "	Output reactive power: "${reactive_power_array[$c]}" Kvar"			
		fi
		if [[ ! ${reverse_active_cap_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative active power: "${reverse_active_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${forward_reactive_cap_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of positive reactive power: "${forward_reactive_cap_array[$c]}" Kwh"			
		fi		
		if [[ ! ${reverse_reactive_cap_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative reactive power: "${reverse_reactive_cap_array[$c]}" Kwh"			
		fi			
		if [[ ! ${active_power_a_array[$c]} == null  ]];
		then	
			echo -e "	Active power Pa: "${active_power_a_array[$c]}" Kw"			
		fi		
		if [[ ! ${active_power_b_array[$c]} == null  ]];
		then	
			echo -e "	Active power Pb: "${active_power_b_array[$c]}" Kw"			
		fi		
		if [[ ! ${active_power_c_array[$c]} == null  ]];
		then	
			echo -e "	Active power Pb: "${active_power_c_array[$c]}" Kw"			
		fi		
		if [[ ! ${reactive_power_a_array[$c]} == null  ]];
		then	
			echo -e "	Reactive power Qa: "${reactive_power_a_array[$c]}" kVar"			
		fi	
		if [[ ! ${reactive_power_b_array[$c]} == null  ]];
		then	
			echo -e "	Reactive power Qb: "${reactive_power_ab_array[$c]}" kVar"			
		fi
		if [[ ! ${reactive_power_c_array[$c]} == null  ]];
		then	
			echo -e "	Reactive power Qc: "${reactive_power_c_array[$c]}" kVar"			
		fi
		if [[ ! ${total_apparent_power_array[$c]} == null  ]];
		then	
			echo -e "	Total apparent power: "${total_apparent_power_array[$c]}" kVA"			
		fi
		if [[ ! ${grid_frequency_array[$c]} == null  ]];
		then	
			echo -e "	Grid frequency: "${grid_frequency_array[$c]}" Hz"			
		fi
		if [[ ! ${reverse_active_peak_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative active power (peak): "${reverse_active_peak_array[$c]}" Kwh"			
		fi
		if [[ ! ${reverse_active_power_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative active power (off): "${reverse_active_power_array[$c]}" Kwh"			
		fi
		if [[ ! ${reverse_active_valley_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative active power (shoulder): "${reverse_active_valley_array[$c]}" Kwh"			
		fi
		if [[ ! ${reverse_active_top_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative active power (sharp): "${reverse_active_top_array[$c]}" Kwh"			
		fi
		if [[ ! ${positive_active_peak_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of positive active power (peak): "${positive_active_peak_array[$c]}" Kwh"			
		fi
		if [[ ! ${positive_active_power_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of positive active power (off): "${positive_active_power_array[$c]}" Kwh"			
		fi
		if [[ ! ${positive_active_valley_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of positive active power (shoulder): "${positive_active_valley_array[$c]}" Kwh"			
		fi
		if [[ ! ${positive_active_top_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of positive active power (sharp): "${positive_active_top_array[$c]}" Kwh"			
		fi	
		if [[ ! ${reverse_reactive_peak_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of positive reactive power (peak): "${reverse_reactive_peak_array[$c]}" Kwh"			
		fi
		if [[ ! ${reverse_reactive_power_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of positive reactive power (off): "${reverse_reactive_power_array[$c]}" Kwh"			
		fi
		if [[ ! ${reverse_reactive_valley_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of positive reactive power (shoulder): "${reverse_reactive_valley_array[$c]}" Kwh"			
		fi
		if [[ ! ${reverse_reactive_top_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative reactive power (sharp): "${reverse_reactive_top_array[$c]}" Kwh"			
		fi
		if [[ ! ${positive_reactive_peak_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative reactive power (peak): "${positive_reactive_peak_array[$c]}" Kwh"			
		fi
		if [[ ! ${positive_reactive_power_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative reactive power (off): "${positive_reactive_power_array[$c]}" Kwh"			
		fi
		if [[ ! ${positive_reactive_valley_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative reactive power (shoulder): "${positive_reactive_valley_array[$c]}" Kwh"			
		fi
		if [[ ! ${positive_reactive_top_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative reactive power (sharp): "${positive_reactive_top_array[$c]}" Kwh"			
		fi

	done
fi

# device is Power Sensor
if [[ $success == "true"  ]] && [[ $2 == 47  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""
	echo ""
	
	for (( c=0; c<=((${#devIds_array[@]}-1)); c++ )); do
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$c]}
		echo -e "\e[0m ID: "${devId_array[$c]}
					
		if [[ ! ${meter_status_array[$c]} == null  ]];
		then	
			if [[ ${meter_status_array[$c]} == 0  ]];
			then
			meter_status="Offline"
			elif [[ ${meter_status_array[$c]} == 1  ]];
			then
			meter_status="Normal"
			else
			meter_status="Unknow"
			fi
			echo -e "	Meter status: "$meter_status
		fi
		if [[ ! ${meter_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid voltage: "${meter_u_array[$c]}" V"				
		fi
		if [[ ! ${meter_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid current: "${meter_i_array[$c]}" A"				
		fi
		if [[ ! ${active_power_array[$c]} == null  ]];
		then	
			echo -e "	Active power: "${active_power_array[$c]}" W"				
		fi
		if [[ ! ${reactive_power_array[$c]} == null  ]];
		then	
			echo -e "	Reactive power: "${reactive_power_array[$c]}" Var"				
		fi
		if [[ ! ${power_factor_array[$c]} == null  ]];
		then	
			echo -e "	Power factor: "${power_factor_array[$c]}				
		fi
		if [[ ! ${grid_frequency_array[$c]} == null  ]];
		then	
			echo -e "	Grid frequency: "${grid_frequency_array[$c]}" Hz"				
		fi
		if [[ ! ${active_cap_array[$c]} == null  ]];
		then	
			echo -e "	Active power (Kilowatt hour of positive active power): "${active_cap_array[$c]}" kWh"				
		fi
		if [[ ! ${reverse_active_cap_array[$c]} == null  ]];
		then	
			echo -e "	Rective power (Kilowatt hour of negative active power): "${reverse_active_cap_array[$c]}" kWh"				
		fi
		if [[ ! ${run_state_array[$c]} == null  ]];
		then	
			if [[ ${run_state_array[$c]} == 0  ]];
			then
			device_status="Disconnected"
			elif [[ ${run_state_array[$c]} == 1  ]];
			then
			device_status="Connected"
			else
			device_status="Unknow"
			fi
			echo -e "	Status: "$device_status			
		fi



	done
fi

# device is Battery
if [[ $success == "true"  ]] && [[ $2 == 39  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""
	echo ""
	
	for (( c=0; c<=((${#devIds_array[@]}-1)); c++ )); do
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$c]}
		echo -e "\e[0m ID: "${devId_array[$c]}
		
		if [[ ! ${battery_status_array[$c]} == null  ]];
		then	
			echo -e "	Battery operating status: "${battery_status_array[$c]}				
		fi
		if [[ ! ${max_charge_power_array[$c]} == null  ]];
		then	
			echo -e "	Maximum charging power: "${max_charge_power_array[$c]}" W"				
		fi		
		if [[ ! ${max_discharge_power_array[$c]} == null  ]];
		then	
			echo -e "	Maximum discharging power: "${max_discharge_power_array[$c]}" W"				
		fi		
		if [[ ! ${ch_discharge_power_array[$c]} == null  ]];
		then	
			echo -e "	Charging/Discharging power: "${ch_discharge_power_array[$c]}" W"				
		fi
		if [[ ! ${busbar_u_array[$c]} == null  ]];
		then	
			echo -e "	Battery voltage: "${busbar_u_array[$c]}" V"				
		fi	
		if [[ ! ${battery_soc_array[$c]} == null  ]];
		then	
			echo -e "	Battery SOC: "${battery_soc_array[$c]}" %"				
		fi		
		if [[ ! ${battery_soh_array[$c]} == null  ]];
		then	
			echo -e "	Battery SOH: "${battery_soh_array[$c]}				
		fi		
		if [[ ! ${ch_discharge_model_array[$c]} == null  ]];
		then	
			if [[ ${ch_discharge_model_array[$c]} == 0  ]];
			then
			Charging_discharging_model="None"
			elif [[ ${ch_discharge_model_array[$c]} == 1  ]];
			then
			Charging_discharging_model="Forced discharging/charging"
			elif [[ ${ch_discharge_model_array[$c]} == 2  ]];
			then
			Charging_discharging_model="Time of use electricity price"
			elif [[ ${ch_discharge_model_array[$c]} == 3  ]];
			then
			Charging_discharging_model="Fixed discharging/charging"
			elif [[ ${ch_discharge_model_array[$c]} == 4  ]];
			then
			Charging_discharging_model="Maximum Self-consumption energy"
			else
			Charging_discharging_model="Unknow"
			fi
			echo -e "	Charging & discharging mode: "$Charging_discharging_model				
		fi
		if [[ ! ${charge_cap_array[$c]} == null  ]];
		then	
			echo -e "	Charging capacity: "${charge_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${discharge_cap_array[$c]} == null  ]];
		then	
			echo -e "	Discharging capacity: "${discharge_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${run_state_array[$c]} == null  ]];
		then	
			if [[ ${run_state_array[$c]} == 0  ]];
			then
			device_status="Disconnected"
			elif [[ ${run_state_array[$c]} == 1  ]];
			then
			device_status="Connected"
			else
			device_status="Unknow"
			fi
			echo -e "	Status: "$device_status			
		fi


	done
fi

# device is Transformer
if [[ $success == "true"  ]] && [[ $2 == 8  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""
	echo ""
	
	for (( c=0; c<=((${#devIds_array[@]}-1)); c++ )); do
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$c]}
		echo -e "\e[0m ID: "${devId_array[$c]}
					
		if [[ ! ${ab_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid AB line voltage: "${ab_u_array[$c]}" V"				
		fi
		if [[ ! ${bc_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid BC line voltage: "${bc_u_array[$c]}" V"				
		fi
		if [[ ! ${ca_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid CA line voltage: "${ca_u_array[$c]}" V"				
		fi
		if [[ ! ${a_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase A voltage (AC output): "${a_u_array[$c]}" V"				
		fi
		if [[ ! ${b_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase B voltage (AC output): "${b_u_array[$c]}" V"				
		fi
		if [[ ! ${c_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase C voltage (AC output): "${c_u_array[$c]}" V"				
		fi
		if [[ ! ${a_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase A current (IA): "${a_i_array[$c]}" A"				
		fi
		if [[ ! ${b_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase B current (IB): "${b_i_array[$c]}" A"				
		fi
		if [[ ! ${c_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase C current (IC): "${c_i_array[$c]}" A"				
		fi		
		if [[ ! ${active_power_array[$c]} == null  ]];
		then	
			echo -e "	Active power: "${active_power_array[$c]}" Kw"			
		fi
		if [[ ! ${reactive_power_array[$c]} == null  ]];
		then	
			echo -e "	Reactive power: "${reactive_power_array[$c]}" Kvar"			
		fi
		if [[ ! ${power_factor_array[$c]} == null  ]];
		then	
			echo -e "	Power factor: "${power_factor_array[$c]}			
		fi
		if [[ ! ${elec_freq_array[$c]} == null  ]];
		then	
			echo -e "	Grid frequency: "${elec_freq_array[$c]}" Hz"			
		fi		
		if [[ ! ${run_state_array[$c]} == null  ]];
		then	
			if [[ ${run_state_array[$c]} == 0  ]];
			then
			device_status="Disconnected"
			elif [[ ${run_state_array[$c]} == 1  ]];
			then
			device_status="Connected"
			else
			device_status="Unknow"
			fi
			echo -e "	Status: "$device_status			
		fi
	done
fi

# in case of error
if [[ $success == "false"  ]];
	then
	#fuction which works with connection error	
	in_case_of_error_with_connection_to_API $getDevRealKpi
		
fi

echo ""


}


function getDevFiveMinutes {


# Request to API getKpiStationYear
local getDevFiveMinutes=$(printf '{"devIds": "'$1'", "devTypeId": "'$2'", "collectTime": '$3'}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getDevFiveMinutes  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')

#echo $getDevFiveMinutes | jq

local success=$(echo ''$getDevFiveMinutes''  | jq '.success' )
local buildCode=$(echo ''$getDevFiveMinutes''  | jq '.buildCode' )
local failCode=$(echo ''$getDevFiveMinutes''  | jq '.failCode' )
local message=$(echo ''$getDevFiveMinutes''  | jq '.message' )


#we have inverter
if [[ $2 == 1  ]];
then	

local devId=$(echo ''$getDevFiveMinutes''  | jq '.data[].devId' )
	local collectTime_every_five_minutes=$(echo ''$getDevFiveMinutes''  | jq '.data[].collectTime' )	
		local inverter_state=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.inverter_state' )		 
		local ab_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.ab_u' )
		local bc_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.bc_u' )
		local ca_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.ca_u' )
		local a_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.a_u' )
		local b_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.b_u' )
		local c_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.c_u' )
		local a_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.a_i' )
		local b_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.b_i' )
		local c_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.c_i' )
		local efficiency=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.efficiency' )
		local temperature=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.temperature' )
		local power_factor=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.power_factor' )
		local elec_freq=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.elec_freq' )
		local active_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.active_power' )
		local reactive_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.reactive_power' )
		local day_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.day_cap' )
		local mppt_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.mppt_power' )
		local pv1_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv1_u' )
		local pv2_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv2_u' )
		local pv3_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv3_u' )
		local pv4_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv4_u' )
		local pv5_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv5_u' )
		local pv6_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv6_u' )
		local pv7_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv7_u' )
		local pv8_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv8_u' )
		local pv9_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv9_u' )
		local pv10_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv10_u' )
		local pv11_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv11_u' )
		local pv12_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv12_u' )
		local pv13_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv13_u' )
		local pv14_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv14_u' )
		local pv15_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv15_u' )
		local pv16_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv16_u' )
		local pv17_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv17_u' )
		local pv18_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv18_u' )
		local pv19_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv19_u' )
		local pv20_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv20_u' )
		local pv21_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv21_u' )
		local pv22_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv22_u' )
		local pv23_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv23_u' )
		local pv24_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv24_u' )
		local pv1_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv1_i' )
		local pv2_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv2_i' )
		local pv3_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv3_i' )
		local pv4_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv4_i' )
		local pv5_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv5_i' )
		local pv6_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv6_i' )
		local pv7_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv7_i' )
		local pv8_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv8_i' )
		local pv9_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv9_i' )
		local pv10_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv10_i' )
		local pv11_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv11_i' )
		local pv12_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv12_i' )
		local pv13_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv13_i' )
		local pv14_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv14_i' )
		local pv15_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv15_i' )
		local pv16_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv16_i' )
		local pv17_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv17_i' )
		local pv18_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv18_i' )
		local pv19_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv19_i' )
		local pv20_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv20_i' )
		local pv21_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv21_i' )
		local pv22_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv22_i' )
		local pv23_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv23_i' )
		local pv24_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv24_i' )
		local total_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.total_cap' )
		local open_time=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.open_time' )
		local close_time=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.close_time' )
		local mppt_total_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.mppt_total_cap' )
		local mppt_1_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.mppt_1_cap' )
		local mppt_2_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.mppt_2_cap' )
		local mppt_3_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.mppt_3_cap' )
		local mppt_4_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.mppt_4_cap' )
		local mppt_5_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.mppt_5_cap' )
		local mppt_6_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.mppt_6_cap' )
		local mppt_7_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.mppt_7_cap' )
		local mppt_8_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.mppt_8_cap' )
		local mppt_9_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.mppt_9_cap' )
		local mppt_10_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.mppt_10_cap' )
		

local data_getDevFiveMinutes=$(echo ''$getDevFiveMinutes''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevFiveMinutes''  | jq '.currentTime' )
	local collectTime=$(echo ''$data_getDevFiveMinutes''  | jq '.collectTime' )
	local devIds=$(echo ''$data_getDevFiveMinutes''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevFiveMinutes''  | jq '.devTypeId' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "collectTime_array=(${collectTime_every_five_minutes})"
		eval "inverter_state_array=(${inverter_state})"
		eval "ab_u_array=(${ab_u})"
		eval "bc_u_array=(${bc_u})"
		eval "ca_u_array=(${ca_u})"
		eval "a_u_array=(${a_u})"
		eval "b_u_array=(${b_u})"
		eval "c_u_array=(${c_u})"
		eval "a_i_array=(${a_i})"
		eval "b_i_array=(${b_i})"
		eval "c_i_array=(${c_i})"
		eval "efficiency_array=(${efficiency})"
		eval "temperature_array=(${temperature})"
		eval "power_factor_array=(${power_factor})"
		eval "elec_freq_array=(${elec_freq})"
		eval "active_power_array=(${active_power})"
		eval "reactive_power_array=(${reactive_power})"
		eval "day_cap_array=(${day_cap})"
		eval "mppt_power_array=(${mppt_power})"
		eval "pv1_u_array=(${pv1_u})"
		eval "pv2_u_array=(${pv2_u})"
		eval "pv3_u_array=(${pv3_u})"
		eval "pv4_u_array=(${pv4_u})"
		eval "pv5_u_array=(${pv5_u})"
		eval "pv6_u_array=(${pv6_u})"
		eval "pv7_u_array=(${pv7_u})"
		eval "pv8_u_array=(${pv8_u})"
		eval "pv9_u_array=(${pv9_u})"
		eval "pv10_u_array=(${pv10_u})"
		eval "pv11_u_array=(${pv11_u})"
		eval "pv12_u_array=(${pv12_u})"
		eval "pv13_u_array=(${pv13_u})"
		eval "pv14_u_array=(${pv14_u})"
		eval "pv15_u_array=(${pv15_u})"
		eval "pv16_u_array=(${pv16_u})"
		eval "pv17_u_array=(${pv17_u})"
		eval "pv18_u_array=(${pv18_u})"
		eval "pv19_u_array=(${pv19_u})"
		eval "pv20_u_array=(${pv20_u})"
		eval "pv21_u_array=(${pv21_u})"
		eval "pv22_u_array=(${pv22_u})"
		eval "pv23_u_array=(${pv23_u})"
		eval "pv24_u_array=(${pv24_u})"
		eval "pv1_i_array=(${pv1_i})"
		eval "pv2_i_array=(${pv2_i})"
		eval "pv3_i_array=(${pv3_i})"
		eval "pv4_i_array=(${pv4_i})"
		eval "pv5_i_array=(${pv5_i})"
		eval "pv6_i_array=(${pv6_i})"
		eval "pv7_i_array=(${pv7_i})"
		eval "pv8_i_array=(${pv8_i})"
		eval "pv9_i_array=(${pv9_i})"
		eval "pv10_i_array=(${pv10_i})"
		eval "pv11_i_array=(${pv11_i})"
		eval "pv12_i_array=(${pv12_i})"
		eval "pv13_i_array=(${pv13_i})"
		eval "pv14_i_array=(${pv14_i})"
		eval "pv15_i_array=(${pv15_i})"
		eval "pv16_i_array=(${pv16_i})"
		eval "pv17_i_array=(${pv17_i})"
		eval "pv18_i_array=(${pv18_i})"
		eval "pv19_i_array=(${pv19_i})"
		eval "pv20_i_array=(${pv20_i})"
		eval "pv21_i_array=(${pv21_i})"
		eval "pv22_i_array=(${pv22_i})"
		eval "pv23_i_array=(${pv23_i})"
		eval "pv24_i_array=(${pv24_i})"
		eval "total_cap_array=(${total_cap})"
		eval "open_time_array=(${open_time})"
		eval "close_time_array=(${close_time})"
		eval "mppt_total_cap_array=(${mppt_total_cap})"
		eval "mppt_1_cap_array=(${mppt_1_cap})"
		eval "mppt_2_cap_array=(${mppt_2_cap})"
		eval "mppt_3_cap_array=(${mppt_3_cap})"
		eval "mppt_4_cap_array=(${mppt_4_cap})"
		eval "mppt_5_cap_array=(${mppt_5_cap})"
		eval "mppt_6_cap_array=(${mppt_6_cap})"	
		eval "mppt_7_cap_array=(${mppt_7_cap})"	
		eval "mppt_8_cap_array=(${mppt_8_cap})"	
		eval "mppt_9_cap_array=(${mppt_9_cap})"	
		eval "mppt_10_cap_array=(${mppt_10_cap})"	

#if device is Central inverter
elif [[ $2 == 14  ]];
then

local devId=$(echo ''$getDevFiveMinutes''  | jq '.data[].devId' )
	local collectTime_every_five_minutes=$(echo ''$getDevFiveMinutes''  | jq '.data[].collectTime' )	
		local inverter_state=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.inverter_state' )
		local day_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.day_cap' )
		local total_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.total_cap' )
		local temperature=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.temperature' )
		local center_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.center_u' )
		local center_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.center_i' )
		local center_i_1=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.center_i_1' )
		local center_i_2=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.center_i_2' )
		local center_i_3=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.center_i_3' )
		local center_i_4=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.center_i_4' )
		local center_i_5=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.center_i_5' )
		local center_i_6=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.center_i_6' )
		local center_i_7=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.center_i_7' )
		local center_i_8=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.center_i_8' )
		local center_i_9=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.center_i_9' )
		local center_i_10=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.center_i_10' )
		local mppt_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.mppt_power' )
		local a_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.a_u' )
		local b_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.b_u' )
		local c_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.c_u' )
		local a_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.a_i' )
		local b_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.b_i' )
		local c_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.c_i' )		
		local power_factor=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.power_factor' )
		local elec_freq=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.elec_freq' )
		local active_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.active_power' )
		local reactive_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.reactive_power' )		
		local open_time=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.open_time' )
		local close_time=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.close_time' )	
		local aop=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.aop' )	
		

local data_getDevFiveMinutes=$(echo ''$getDevFiveMinutes''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevFiveMinutes''  | jq '.currentTime' )
	local collectTime=$(echo ''$data_getDevFiveMinutes''  | jq '.collectTime' )
	local devIds=$(echo ''$data_getDevFiveMinutes''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevFiveMinutes''  | jq '.devTypeId' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "collectTime_array=(${collectTime_every_five_minutes})"
		eval "inverter_state_array=(${inverter_state})"
		eval "day_cap_array=(${day_cap})"
		eval "total_cap_array=(${total_cap})"
		eval "temperature_array=(${temperature})"		
		eval "center_u_array=(${center_u})"
		eval "center_i_array=(${center_i})"
		eval "center_i_1_array=(${center_i_1})"
		eval "center_i_2_array=(${center_i_2})"
		eval "center_i_3_array=(${center_i_3})"
		eval "center_i_4_array=(${center_i_4})"
		eval "center_i_5_array=(${center_i_5})"
		eval "center_i_6_array=(${center_i_6})"
		eval "center_i_7_array=(${center_i_7})"
		eval "center_i_8_array=(${center_i_8})"
		eval "center_i_9_array=(${center_i_9})"
		eval "center_i_10_array=(${center_i_10})"
		eval "mppt_power_array=(${mppt_power})"		
		eval "a_u_array=(${a_u})"
		eval "b_u_array=(${b_u})"
		eval "c_u_array=(${c_u})"
		eval "a_i_array=(${a_i})"
		eval "b_i_array=(${b_i})"
		eval "c_i_array=(${c_i})"	
		eval "power_factor_array=(${power_factor})"
		eval "elec_freq_array=(${elec_freq})"
		eval "active_power_array=(${active_power})"
		eval "reactive_power_array=(${reactive_power})"
		eval "open_time_array=(${open_time})"
		eval "close_time_array=(${close_time})"		
		eval "aop_array=(${aop})"					
	
	
# device is Smart Energy Center	
elif [[ $2 == 38  ]];
then


local devId=$(echo ''$getDevFiveMinutes''  | jq '.data[].devId' )
	local collectTime_every_five_minutes=$(echo ''$getDevFiveMinutes''  | jq '.data[].collectTime' )	
		local inverter_state=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.inverter_state' )
		local ab_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.ab_u' )
		local bc_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.bc_u' )
		local ca_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.ca_u' )
		local a_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.a_u' )
		local b_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.b_u' )
		local c_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.c_u' )
		local a_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.a_i' )
		local b_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.b_i' )
		local c_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.c_i' )
		local efficiency=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.efficiency' )
		local temperature=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.temperature' )
		local power_factor=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.power_factor' )
		local elec_freq=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.elec_freq' )
		local active_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.active_power' )
		local reactive_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.reactive_power' )
		local day_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.day_cap' )
		local mppt_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.mppt_power' )
		local pv1_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv1_u' )
		local pv2_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv2_u' )
		local pv3_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv3_u' )
		local pv4_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv4_u' )
		local pv5_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv5_u' )
		local pv6_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv6_u' )
		local pv7_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv7_u' )
		local pv8_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv8_u' )
		local pv1_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv1_i' )
		local pv2_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv2_i' )
		local pv3_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv3_i' )
		local pv4_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv4_i' )
		local pv5_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv5_i' )
		local pv6_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv6_i' )
		local pv7_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv7_i' )
		local pv8_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv8_i' )
		local total_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.total_cap' )
		local open_time=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.open_time' )
		local close_time=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.close_time' )
		local mppt_1_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.mppt_1_cap' )
		local mppt_2_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.mppt_2_cap' )
		local mppt_3_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.mppt_3_cap' )
		local mppt_4_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.mppt_4_cap' )		

local data_getDevFiveMinutes=$(echo ''$getDevFiveMinutes''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevFiveMinutes''  | jq '.currentTime' )
	local collectTime=$(echo ''$data_getDevFiveMinutes''  | jq '.collectTime' )
	local devIds=$(echo ''$data_getDevFiveMinutes''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevFiveMinutes''  | jq '.devTypeId' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "collectTime_array=(${collectTime_every_five_minutes})"
		eval "inverter_state_array=(${inverter_state})"
		eval "ab_u_array=(${ab_u})"
		eval "bc_u_array=(${bc_u})"
		eval "ca_u_array=(${ca_u})"
		eval "a_u_array=(${a_u})"
		eval "b_u_array=(${b_u})"
		eval "c_u_array=(${c_u})"
		eval "a_i_array=(${a_i})"
		eval "b_i_array=(${b_i})"
		eval "c_i_array=(${c_i})"
		eval "efficiency_array=(${efficiency})"
		eval "temperature_array=(${temperature})"
		eval "power_factor_array=(${power_factor})"
		eval "elec_freq_array=(${elec_freq})"
		eval "active_power_array=(${active_power})"
		eval "reactive_power_array=(${reactive_power})"
		eval "day_cap_array=(${day_cap})"
		eval "mppt_power_array=(${mppt_power})"
		eval "pv1_u_array=(${pv1_u})"
		eval "pv2_u_array=(${pv2_u})"
		eval "pv3_u_array=(${pv3_u})"
		eval "pv4_u_array=(${pv4_u})"
		eval "pv5_u_array=(${pv5_u})"
		eval "pv6_u_array=(${pv6_u})"
		eval "pv7_u_array=(${pv7_u})"
		eval "pv8_u_array=(${pv8_u})"
		eval "pv1_i_array=(${pv1_i})"
		eval "pv2_i_array=(${pv2_i})"
		eval "pv3_i_array=(${pv3_i})"
		eval "pv4_i_array=(${pv4_i})"
		eval "pv5_i_array=(${pv5_i})"
		eval "pv6_i_array=(${pv6_i})"
		eval "pv7_i_array=(${pv7_i})"
		eval "pv8_i_array=(${pv8_i})"
		eval "total_cap_array=(${total_cap})"
		eval "open_time_array=(${open_time})"
		eval "close_time_array=(${close_time})"
		eval "mppt_1_cap_array=(${mppt_1_cap})"
		eval "mppt_2_cap_array=(${mppt_2_cap})"
		eval "mppt_3_cap_array=(${mppt_3_cap})"
		eval "mppt_4_cap_array=(${mppt_4_cap})"	

# device is DC combiner box
elif [[ $2 == 15  ]];
then


local devId=$(echo ''$getDevFiveMinutes''  | jq '.data[].devId' )
	local collectTime_every_five_minutes=$(echo ''$getDevFiveMinutes''  | jq '.data[].collectTime' )	
		local inverter_state=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.inverter_state' )
		local dc_i1=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.dc_i1' )
		local dc_i2=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.dc_i2' )
		local dc_i3=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.dc_i3' )
		local dc_i4=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.dc_i4' )
		local dc_i5=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.dc_i5' )
		local dc_i6=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.dc_i6' )
		local dc_i7=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.dc_i7' )
		local dc_i8=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.dc_i8' )
		local dc_i9=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.dc_i9' )
		local dc_i10=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.dc_i10' )
		local dc_i11=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.dc_i11' )
		local dc_i12=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.dc_i12' )
		local dc_i13=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.dc_i13' )
		local dc_i14=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.dc_i14' )
		local dc_i15=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.dc_i15' )
		local dc_i16=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.dc_i16' )
		local dc_i17=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.dc_i17' )
		local dc_i18=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.dc_i18' )
		local dc_i19=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.dc_i19' )
		local dc_i20=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.dc_i20' )		
		local photc_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.photc_i' )
		local photc_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.photc_u' )
		local temperature=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.temperature' )
		local thunder_count=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.thunder_count' )		

local data_getDevFiveMinutes=$(echo ''$getDevFiveMinutes''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevFiveMinutes''  | jq '.currentTime' )
	local collectTime=$(echo ''$data_getDevFiveMinutes''  | jq '.currentTime' )
	local devIds=$(echo ''$data_getDevFiveMinutes''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevFiveMinutes''  | jq '.devTypeId' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "collectTime_array=(${collectTime_every_five_minutes})"
		eval "dc_i1_array=(${dc_i1})"
		eval "dc_i2_array=(${dc_i2})"	
		eval "dc_i3_array=(${dc_i3})"	
		eval "dc_i4_array=(${dc_i4})"	
		eval "dc_i5_array=(${dc_i5})"	
		eval "dc_i6_array=(${dc_i6})"	
		eval "dc_i7_array=(${dc_i7})"	
		eval "dc_i8_array=(${dc_i8})"	
		eval "dc_i9_array=(${dc_i9})"	
		eval "dc_i10_array=(${dc_i10})"	
		eval "dc_i11_array=(${dc_i11})"	
		eval "dc_i12_array=(${dc_i12})"	
		eval "dc_i13_array=(${dc_i13})"	
		eval "dc_i14_array=(${dc_i14})"	
		eval "dc_i15_array=(${dc_i15})"	
		eval "dc_i16_array=(${dc_i16})"	
		eval "dc_i17_array=(${dc_i17})"	
		eval "dc_i18_array=(${dc_i18})"	
		eval "dc_i19_array=(${dc_i19})"	
		eval "dc_i20_array=(${dc_i20})"		
		eval "photc_i_array=(${photc_i})"	
		eval "photc_u_array=(${photc_u})"
		eval "temperature_array=(${temperature})"	
		eval "thunder_count_array=(${thunder_count})"

# device is EMI
elif [[ $2 == 10  ]];
then

local devId=$(echo ''$getDevFiveMinutes''  | jq '.data[].devId' )
	local collectTime_every_five_minutes=$(echo ''$getDevFiveMinutes''  | jq '.data[].collectTime' )	
		local temperature=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.temperature' )
		local pv_temperature=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.pv_temperature' )
		local wind_speed=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.wind_speed' )
		local wind_direction=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.wind_direction' )
		local radiant_total=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.radiant_total' )
		local radiant_line=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.radiant_line' )
		local horiz_radiant_line=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.horiz_radiant_line' )
		local horiz_radiant_total=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.horiz_radiant_total' )

local data_getDevFiveMinutes=$(echo ''$getDevFiveMinutes''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevFiveMinutes''  | jq '.currentTime' )
	local collectTime=$(echo ''$data_getDevFiveMinutes''  | jq '.currentTime' )
	local devIds=$(echo ''$data_getDevFiveMinutes''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevFiveMinutes''  | jq '.devTypeId' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "collectTime_array=(${collectTime_every_five_minutes})"
		eval "temperature_array=(${temperature})"
		eval "pv_temperature_array=(${pv_temperature})"
		eval "wind_speed_array=(${wind_speed})"
		eval "wind_direction_array=(${wind_direction})"
		eval "radiant_total_array=(${radiant_total})"
		eval "radiant_line_array=(${radiant_line})"
		eval "horiz_radiant_line_array=(${horiz_radiant_line})"
		eval "horiz_radiant_total_array=(${horiz_radiant_total})"

# device is Meter (Grid meter)
elif [[ $2 == 17  ]];
then

local devId=$(echo ''$getDevFiveMinutes''  | jq '.data[].devId' )
	local collectTime_every_five_minutes=$(echo ''$getDevFiveMinutes''  | jq '.data[].collectTime' )	
		local ab_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.ab_u' )
		local bc_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.bc_u' )
		local ca_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.ca_u' )
		local a_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.a_u' )
		local b_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.b_u' )
		local c_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.c_u' )
		local a_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.a_i' )
		local b_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.b_i' )
		local c_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.c_i' )
		local active_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.active_power' )
		local power_factor=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.power_factor' )
		local active_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.active_cap' )
		local reactive_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.reactive_power' )
		local reverse_active_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.reverse_active_cap' )
		local forward_reactive_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.forward_reactive_cap' )
		local reverse_reactive_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.reverse_reactive_cap' )
		local active_power_a=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.active_power_a' )
		local active_power_b=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.active_power_b' )
		local active_power_c=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.active_power_c' )
		local reactive_power_a=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.reactive_power_a' )
		local reactive_power_b=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.reactive_power_b' )
		local reactive_power_c=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.reactive_power_c' )
		local total_apparent_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.total_apparent_power' )
		local grid_frequency=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.grid_frequency' )
		local reverse_active_peak=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.reverse_active_peak' )
		local reverse_active_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.reverse_active_power' )
		local reverse_active_valley=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.reverse_active_valley' )
		local reverse_active_top=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.reverse_active_top' )
		local positive_active_peak=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.positive_active_peak' )
		local positive_active_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.positive_active_power' )
		local positive_active_valley=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.positive_active_valley' )
		local positive_active_top=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.positive_active_top' )
		local reverse_reactive_peak=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.reverse_reactive_peak' )
		local reverse_reactive_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.reverse_reactive_power' )
		local reverse_reactive_valley=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.reverse_reactive_valley' )
		local reverse_reactive_top=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.reverse_reactive_top' )
		local positive_reactive_peak=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.positive_reactive_peak' )
		local positive_reactive_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.positive_reactive_power' )
		local positive_reactive_valley=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.positive_reactive_valley' )
		local positive_reactive_top=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.positive_reactive_top' )
		

local data_getDevFiveMinutes=$(echo ''$getDevFiveMinutes''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevFiveMinutes''  | jq '.currentTime' )
	local collectTime=$(echo ''$data_getDevFiveMinutes''  | jq '.currentTime' )
	local devIds=$(echo ''$data_getDevFiveMinutes''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevFiveMinutes''  | jq '.devTypeId' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "collectTime_array=(${collectTime_every_five_minutes})"
		eval "ab_u_array=(${ab_u})"
		eval "bc_u_array=(${bc_u})"
		eval "ca_u_array=(${ca_u})"
		eval "a_u_array=(${a_u})"
		eval "b_u_array=(${b_u})"
		eval "c_u_array=(${c_u})"
		eval "a_i_array=(${a_i})"
		eval "b_i_array=(${b_i})"
		eval "c_i_array=(${c_i})"
		eval "active_power_array=(${active_power})"
		eval "power_factor_array=(${power_factor})"
		eval "active_cap_array=(${active_cap})"
		eval "reactive_power_array=(${reactive_power})"
		eval "reverse_active_cap_array=(${reverse_active_cap})"
		eval "forward_reactive_cap_array=(${forward_reactive_cap})"
		eval "reverse_reactive_cap_array=(${reverse_reactive_cap})"
		eval "active_power_a_array=(${active_power_a})"
		eval "active_power_b_array=(${active_power_b})"
		eval "active_power_c_array=(${active_power_c})"
		eval "reactive_power_a_array=(${reactive_power_a})"
		eval "reactive_power_b_array=(${reactive_power_b})"
		eval "reactive_power_c_array=(${reactive_power_c})"
		eval "total_apparent_power_array=(${total_apparent_power})"
		eval "grid_frequency_array=(${grid_frequency})"
		eval "reverse_active_peak_array=(${reverse_active_peak})"
		eval "reverse_active_power_array=(${reverse_active_power})"
		eval "reverse_active_valley_array=(${reverse_active_valley})"
		eval "reverse_active_top_array=(${reverse_active_top})"
		eval "positive_active_peak_array=(${positive_active_peak})"
		eval "positive_active_power_array=(${positive_active_power})"
		eval "positive_active_valley_array=(${positive_active_valley})"
		eval "positive_active_top_array=(${positive_active_top})"
		eval "reverse_reactive_peak_array=(${reverse_reactive_peak})"		
		eval "reverse_reactive_power_array=(${reverse_reactive_power})"
		eval "reverse_reactive_valley_array=(${reverse_reactive_valley})"
		eval "reverse_reactive_top_array=(${reverse_reactive_top})"
		eval "positive_reactive_peak_array=(${positive_reactive_peak})"
		eval "positive_reactive_power_array=(${positive_reactive_power})"
		eval "positive_reactive_valley_array=(${positive_reactive_valley})"
		eval "positive_reactive_top_array=(${positive_reactive_top})"
		
# device is Power Sensor
elif [[ $2 == 47  ]];
then	

local devId=$(echo ''$getDevFiveMinutes''  | jq '.data[].devId' )
	local collectTime_every_five_minutes=$(echo ''$getDevFiveMinutes''  | jq '.data[].collectTime' )	
		local meter_status=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.meter_status' )
		local meter_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.meter_u' )
		local meter_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.meter_i' )
		local active_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.active_power' )
		local reactive_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.reactive_power' )		
		local power_factor=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.power_factor' )
		local grid_frequency=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.grid_frequency' )		
		local active_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.active_cap' )
		local reverse_active_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.reverse_active_cap' )

		

local data_getDevFiveMinutes=$(echo ''$getDevFiveMinutes''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevFiveMinutes''  | jq '.currentTime' )
	local collectTime=$(echo ''$data_getDevFiveMinutes''  | jq '.currentTime' )
	local devIds=$(echo ''$data_getDevFiveMinutes''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevFiveMinutes''  | jq '.devTypeId' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "collectTime_array=(${collectTime_every_five_minutes})"
		eval "meter_status_array=(${meter_status})"
		eval "meter_u_array=(${meter_u})"
		eval "meter_i_array=(${meter_i})"
		eval "active_power_array=(${active_power})"
		eval "reactive_power_array=(${reactive_power})"		
		eval "power_factor_array=(${power_factor})"
		eval "grid_frequency_array=(${grid_frequency})"
		eval "active_cap_array=(${active_cap})"
		eval "reverse_active_cap_array=(${reverse_active_cap})"

# device is Battery
elif [[ $2 == 39  ]];
then
local devId=$(echo ''$getDevFiveMinutes''  | jq '.data[].devId' )
	local collectTime_every_five_minutes=$(echo ''$getDevFiveMinutes''  | jq '.data[].collectTime' )
		local battery_status=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.battery_status' )
		local max_charge_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.max_charge_power' )
		local max_discharge_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.max_discharge_power' )
		local ch_discharge_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.ch_discharge_power' )
		local busbar_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.busbar_u' )		
		local battery_soc=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.battery_soc' )
		local battery_soh=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.battery_soh' )		
		local ch_discharge_model=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap. ch_discharge_model' )
		local charge_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.charge_cap' )
		local discharge_cap=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.discharge_cap' )
	

local data_getDevFiveMinutes=$(echo ''$getDevFiveMinutes''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevFiveMinutes''  | jq '.currentTime' )
	local collectTime=$(echo ''$data_getDevFiveMinutes''  | jq '.currentTime' )
	local devIds=$(echo ''$data_getDevFiveMinutes''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevFiveMinutes''  | jq '.devTypeId' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "collectTime_array=(${collectTime_every_five_minutes})"
		eval "battery_status_array=(${battery_status})"
		eval "max_charge_power_array=(${max_charge_power})"
		eval "max_discharge_power_array=(${max_discharge_power})"
		eval "ch_discharge_power_array=(${ch_discharge_power})"
		eval "busbar_u_array=(${busbar_u})"
		eval "battery_soc_array=(${battery_soc})"		
		eval "battery_soh_array=(${battery_soh})"
		eval "ch_discharge_model_array=(${ch_discharge_model})"
		eval "charge_cap_array=(${charge_cap})"
		eval "discharge_cap_array=(${discharge_cap})"
		
# device is Transformer
elif [[ $2 == 8  ]];
then
local devId=$(echo ''$getDevFiveMinutes''  | jq '.data[].devId' )
	local collectTime_every_five_minutes=$(echo ''$getDevFiveMinutes''  | jq '.data[].collectTime' )	
		local ab_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.ab_u' )
		local bc_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.bc_u' )
		local ca_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.ca_u' )
		local a_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.a_u' )
		local b_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.b_u' )
		local c_u=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.c_u' )
		local a_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.a_i' )
		local b_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.b_i' )
		local c_i=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.c_i' )
		local active_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.active_power' )
		local reactive_power=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.reactive_power' )
		local power_factor=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.power_factor' )
		local elec_freq=$(echo ''$getDevFiveMinutes''  | jq '.data[].dataItemMap.elec_freq' )		
	

local data_getDevFiveMinutes=$(echo ''$getDevFiveMinutes''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevFiveMinutes''  | jq '.currentTime' )
	local collectTime=$(echo ''$data_getDevFiveMinutes''  | jq '.currentTime' )
	local devIds=$(echo ''$data_getDevFiveMinutes''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevFiveMinutes''  | jq '.devTypeId' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "collectTime_array=(${collectTime_every_five_minutes})"
		eval "ab_u_array=(${ab_u})"
		eval "bc_u_array=(${bc_u})"
		eval "ca_u_array=(${ca_u})"
		eval "a_u_array=(${a_u})"
		eval "b_u_array=(${b_u})"
		eval "c_u_array=(${c_u})"
		eval "a_i_array=(${a_i})"
		eval "b_i_array=(${b_i})"
		eval "c_i_array=(${c_i})"		
		eval "active_power_array=(${active_power})"
		eval "reactive_power_array=(${reactive_power})"		
		eval "power_factor_array=(${power_factor})"
		eval "elec_freq_array=(${elec_freq})"
fi



# Here comma is our delimiter value to array of stations codes given by user as a parameter in question
IFS="," read -a devIds_array <<< $devIds
IFS="," read -a devTypeId_array <<< $devTypeId


#echo "Request success or failure flag: " $success
if [[ $success == "true"  ]];
	then	
		echo ""
		echo -e "API \e[4mgetDevFiveMinutes\e[0m connection \e[42mOK\e[0m"
		getDevFiveMinutes_connection=true
elif [[ $success == "false" ]];
	then
		echo ""
		echo -e "API \e[4mgetDevFiveMinutes\e[0m connection \e[41mError\e[0m"
		getDevFiveMinutes_connection=false
else
	echo ""
	echo -e "\e[41mNetwork Error :(\e[0m" 
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


if [[ $success == "true"  ]];
then	
	echo "Build Code: "$buildCode
fi


local curent_time_actually=$(echo ${currentTime::-3})
local curent_time_of_request=$(date -d @$curent_time_actually)
echo "Time of your Request to API: "$curent_time_of_request


# if we have inverter
if [[ $success == "true"  ]] && [[  $2 == 1  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""

	
	for (( a=0; a<=((${#devIds_array[@]}-1)); a++ )) 
	do
	
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$a]}
		echo -e "\e[0m ID: "${devId_array[$a]}
		echo ""
		echo -e "	Every 5 minutes data from day: \e[1m"$(date +"%d %B %Y" -d @$(echo ${collectTime_array[0]::-3}))"\e[0m"
		echo ""
		
		#loop for every 5 minutes
		for (( c=0; c<=((${#collectTime_array[@]}-1)); c++ )) 
		do
		

		#local collectTimeActually=$(echo ${collectTime_array[$c]::-3})
		echo -e "	\e[1m"$(date +"%H:%M" -d @$(echo ${collectTime_array[$c]::-3}))"\e[0m"
		
		if [[ ! ${inverter_state_array[$c]} == null  ]];
		then	
			printf "	Inverter status: "
			#decimal number to hexdecimal
			local hex=$( printf "%x" ${inverter_state_array[$c]} );
			#echo $hex
			#function to check inverter status
			inverter_state $hex
			echo ""			
		fi
		
		#special loop  for checking if inverter is disconnected
		#if [[ ! $hex == "0"  ]];
		#then
		
				
		if [[ ! ${ab_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid AB voltage: "${ab_u_array[$c]}" V"				
		fi
		if [[ ! ${bc_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid BC voltage: "${bc_u_array[$c]}" V"				
		fi
		if [[ ! ${ca_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid CA voltage: "${ca_u_array[$c]}" V"				
		fi
		if [[ ! ${a_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase A voltage: "${a_u_array[$c]}" V"				
		fi
		if [[ ! ${b_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase B voltage: "${b_u_array[$c]}" V"				
		fi
		if [[ ! ${c_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase C voltage: "${c_u_array[$c]}" V"				
		fi
		if [[ ! ${a_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase A current: "${a_i_array[$c]}" A"				
		fi
		if [[ ! ${b_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase B current: "${b_i_array[$c]}" A"				
		fi
		if [[ ! ${c_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase C current: "${c_i_array[$c]}" A"				
		fi
		if [[ ! ${efficiency_array[$c]} == null  ]];
		then	
			echo -e "	Inverter conversion efficiency (manufacturer): "${efficiency_array[$c]}" %"				
		fi
		if [[ ! ${temperature_array[$c]} == null  ]];
		then	
			echo -e "	Device internal temperature: "${temperature_array[$c]}" °C"				
		fi
		if [[ ! ${power_factor_array[$c]} == null  ]];
		then	
			echo -e "	Power factor: "${power_factor_array[$c]}			
		fi
		if [[ ! ${elec_freq_array[$c]} == null  ]];
		then	
			echo -e "	Grid frequency: "${elec_freq_array[$c]}" Hz"			
		fi
		if [[ ! ${active_power_array[$c]} == null  ]];
		then	
			echo -e "	Active power: "${active_power_array[$c]}" Kw"			
		fi
		if [[ ! ${reactive_power_array[$c]} == null  ]];
		then	
			echo -e "	Output reactive power: "${reactive_power_array[$c]}" Kvar"			
		fi
		if [[ ! ${day_cap_array[$c]} == null  ]];
		then	
			echo -e "	Daily energy: "${day_cap_array[$c]}" Kwh"			
		fi
				if [[ ! ${mppt_power_array[$c]} == null  ]];
		then	
			echo -e "	MPPT (Maximum Power Point Tracking) total input power: "${mppt_power_array[$c]}" Kw"			
		fi
		if [[ ! ${pv1_u_array[$c]} == null  ]];
		then	
			echo -e "	PV1 input voltage: "${pv1_u_array[$c]}" V"			
		fi
		if [[ ! ${pv2_u_array[$c]} == null  ]];
		then	
			echo -e "	PV2 input voltage: "${pv2_u_array[$c]}" V"			
		fi
		if [[ ! ${pv3_u_array[$c]} == null  ]];
		then	
			echo -e "	PV3 input voltage: "${pv3_u_array[$c]}" V"			
		fi
		if [[ ! ${pv4_u_array[$c]} == null  ]];
		then	
			echo -e "	PV4 input voltage: "${pv4_u_array[$c]}" V"	
		fi		
		if [[ ! ${pv5_u_array[$c]} == null  ]];
		then	
			echo -e "	PV5 input voltage: "${pv5_u_array[$c]}" V"			
		fi
		if [[ ! ${pv6_u_array[$c]} == null  ]];
		then	
			echo -e "	PV6 input voltage: "${pv6_u_array[$c]}" V"			
		fi
		if [[ ! ${pv7_u_array[$c]} == null  ]];
		then	
			echo -e "	PV7 input voltage: "${pv7_u_array[$c]}" V"			
		fi
		if [[ ! ${pv8_u_array[$c]} == null  ]];
		then	
			echo -e "	PV8 input voltage: "${pv8_u_array[$c]}" V"			
		fi
		if [[ ! ${pv9_u_array[$c]} == null  ]];
		then	
			echo -e "	PV9 input voltage: "${pv9_u_array[$c]}" V"			
		fi
		if [[ ! ${pv10_u_array[$c]} == null  ]];
		then	
			echo -e "	PV10 input voltage: "${pv10_u_array[$c]}" V"			
		fi
		if [[ ! ${pv11_u_array[$c]} == null  ]];
		then	
			echo -e "	PV11 input voltage: "${pv11_u_array[$c]}" V"			
		fi
		if [[ ! ${pv12_u_array[$c]} == null  ]];
		then	
			echo -e "	PV12 input voltage: "${pv12_u_array[$c]}" V"			
		fi
		if [[ ! ${pv13_u_array[$c]} == null  ]];
		then	
			echo -e "	PV13 input voltage: "${pv13_u_array[$c]}" V"			
		fi
		if [[ ! ${pv14_u_array[$c]} == null  ]];
		then	
			echo -e "	PV14 input voltage: "${pv14_u_array[$c]}" V"			
		fi
		if [[ ! ${pv15_u_array[$c]} == null  ]];
		then	
			echo -e "	PV15 input voltage: "${pv15_u_array[$c]}" V"			
		fi
		if [[ ! ${pv16_u_array[$c]} == null  ]];
		then	
			echo -e "	PV16 input voltage: "${pv16_u_array[$c]}" V"			
		fi
		if [[ ! ${pv17_u_array[$c]} == null  ]];
		then	
			echo -e "	PV17 input voltage: "${pv17_u_array[$c]}" V"			
		fi
		if [[ ! ${pv18_u_array[$c]} == null  ]];
		then	
			echo -e "	PV18 input voltage: "${pv18_u_array[$c]}" V"			
		fi
		if [[ ! ${pv19_u_array[$c]} == null  ]];
		then	
			echo -e "	PV19 input voltage: "${pv19_u_array[$c]}" V"			
		fi
		if [[ ! ${pv20_u_array[$c]} == null  ]];
		then	
			echo -e "	PV20 input voltage: "${pv20_u_array[$c]}" V"			
		fi
		if [[ ! ${pv21_u_array[$c]} == null  ]];
		then	
			echo -e "	PV21 input voltage: "${pv21_u_array[$c]}" V"			
		fi
		if [[ ! ${pv22_u_array[$c]} == null  ]];
		then	
			echo -e "	PV22 input voltage: "${pv22_u_array[$c]}" V"			
		fi
		if [[ ! ${pv23_u_array[$c]} == null  ]];
		then	
			echo -e "	PV23 input voltage: "${pv23_u_array[$c]}" V"			
		fi
		if [[ ! ${pv24_u_array[$c]} == null  ]];
		then	
			echo -e "	PV24 input voltage: "${pv24_u_array[$c]}" V"			
		fi
				if [[ ! ${pv1_i_array[$c]} == null  ]];
		then	
			echo -e "	PV1 input current: "${pv1_i_array[$c]}" A"			
		fi
		if [[ ! ${pv2_i_array[$c]} == null  ]];
		then	
			echo -e "	PV2 input current: "${pv2_i_array[$c]}" A"			
		fi
		if [[ ! ${pv3_i_array[$c]} == null  ]];
		then	
			echo -e "	PV3 input current: "${pv3_i_array[$c]}" A"			
		fi
		if [[ ! ${pv4_i_array[$c]} == null  ]];
		then	
			echo -e "	PV4 input current: "${pv4_i_array[$c]}" A"			
		fi
		if [[ ! ${pv5_i_array[$c]} == null  ]];
		then	
			echo -e "	PV5 input current: "${pv5_i_array[$c]}" A"			
		fi
		if [[ ! ${pv6_i_array[$c]} == null  ]];
		then	
			echo -e "	PV6 input current: "${pv6_i_array[$c]}" A"			
		fi
		if [[ ! ${pv7_i_array[$c]} == null  ]];
		then	
			echo -e "	PV7 input current: "${pv7_i_array[$c]}" A"			
		fi
		if [[ ! ${pv8_i_array[$c]} == null  ]];
		then	
			echo -e "	PV8 input current: "${pv8_i_array[$c]}" A"			
		fi
		if [[ ! ${pv9_i_array[$c]} == null  ]];
		then	
			echo -e "	PV9 input current: "${pv9_i_array[$c]}" A"			
		fi
		if [[ ! ${pv10_i_array[$c]} == null  ]];
		then	
			echo -e "	PV10 input current: "${pv10_i_array[$c]}" A"			
		fi
		if [[ ! ${pv11_i_array[$c]} == null  ]];
		then	
			echo -e "	PV11 input current: "${pv11_i_array[$c]}" A"			
		fi
		if [[ ! ${pv12_i_array[$c]} == null  ]];
		then	
			echo -e "	PV12 input current: "${pv12_i_array[$c]}" A"			
		fi
		if [[ ! ${pv13_i_array[$c]} == null  ]];
		then	
			echo -e "	PV13 input current: "${pv13_i_array[$c]}" A"			
		fi
		if [[ ! ${pv14_i_array[$c]} == null  ]];
		then	
			echo -e "	PV14 input current: "${pv14_i_array[$c]}" A"			
		fi
		if [[ ! ${pv15_i_array[$c]} == null  ]];
		then	
			echo -e "	PV15 input current: "${pv15_i_array[$c]}" A"			
		fi
		if [[ ! ${pv16_i_array[$c]} == null  ]];
		then	
			echo -e "	PV16 input current: "${pv16_i_array[$c]}" A"			
		fi
		if [[ ! ${pv17_i_array[$c]} == null  ]];
		then	
			echo -e "	PV17 input current: "${pv17_i_array[$c]}" A"			
		fi
		if [[ ! ${pv18_i_array[$c]} == null  ]];
		then	
			echo -e "	PV18 input current: "${pv18_i_array[$c]}" A"			
		fi
		if [[ ! ${pv19_i_array[$c]} == null  ]];
		then	
			echo -e "	PV19 input current: "${pv19_i_array[$c]}" A"			
		fi
		if [[ ! ${pv20_i_array[$c]} == null  ]];
		then	
			echo -e "	PV20 input current: "${pv20_i_array[$c]}" A"			
		fi
		if [[ ! ${pv21_i_array[$c]} == null  ]];
		then	
			echo -e "	PV21 input current: "${pv21_i_array[$c]}" A"			
		fi
		if [[ ! ${pv22_i_array[$c]} == null  ]];
		then	
			echo -e "	PV22 input current: "${pv22_i_array[$c]}" A"			
		fi
		if [[ ! ${pv23_i_array[$c]} == null  ]];
		then	
			echo -e "	PV23 input current: "${pv23_i_array[$c]}" A"			
		fi
		if [[ ! ${pv24_i_array[$c]} == null  ]];
		then	
			echo -e "	PV24 input current: "${pv24_i_array[$c]}" A"			
		fi
		if [[ ! ${total_cap_array[$c]} == null  ]];
		then	
			echo -e "	Cumulative energy: "${total_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${open_time_array[$c]} == null  ]];
		then	
			local startup_time=$(date -d @${open_time_array[$c]})	
			echo -e "	Inverter last startup time: "$startup_time					
		fi
		if [[ ! ${close_time_array[$c]} == null  ]];
		then	
			local shutdown_time=$(date -d @${close_time_array[$c]})
			echo -e "	Inverter last shutdown time: "$shutdown_time		
		fi
		if [[ ! ${mppt_total_cap_array[$c]} == null  ]];
		then	
			echo -e "	Total DC input energy: "${mppt_total_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_1_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 1 DC cumulative energy: "${mppt_1_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_2_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 2 DC cumulative energy: "${mppt_2_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_3_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 3 DC cumulative energy: "${mppt_3_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_4_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 4 DC cumulative energy: "${mppt_4_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_5_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 5 DC cumulative energy: "${mppt_5_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_6_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 6 DC cumulative energy: "${mppt_6_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_7_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 7 DC cumulative energy: "${mppt_7_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_8_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 8 DC cumulative energy: "${mppt_8_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_9_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 9 DC cumulative energy: "${mppt_9_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_10_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 10 DC cumulative energy: "${mppt_10_cap_array[$c]}" Kwh"			
		fi
		echo ""
		
		#special for checking if inverter is diconected 
		#else
		#	echo -e "	No any Real-time data when device is disconected!"
		
		#special loop finish for checking if inverter is diconected 
		#fi
		
		#end of for loop for presentation data every 5minutes
		done

	done

fi

# if we have central inverter
if [[ $success == "true"  ]] && [[  $2 == 14  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""

	
	for (( a=0; a<=((${#devIds_array[@]}-1)); a++ )) 
	do
	
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$a]}
		echo -e "\e[0m ID: "${devId_array[$a]}
		echo ""
		echo -e "	Every 5 minutes data from day: \e[1m"$(date +"%d %B %Y" -d @$(echo ${collectTime_array[0]::-3}))"\e[0m"
		echo ""
		
		#loop for every 5 minutes
		for (( c=0; c<=((${#collectTime_array[@]}-1)); c++ )) 
		do
		
		if [[ ! ${inverter_state_array[$c]} == null  ]];
		then	
			printf "	Inverter status: "
			#decimal number to hexdecimal
			local hex=$( printf "%x" ${inverter_state_array[$c]} );
			#echo $hex
			#function to check inverter status
			inverter_state $hex
			echo ""			
		fi
		if [[ ! ${day_cap_array[$c]} == null  ]];
		then	
			echo -e "	Daily energy: "${day_cap_array[$c]}" KWh"				
		fi
		if [[ ! ${total_cap_array[$c]} == null  ]];
		then	
			echo -e "	Cumulative energy: "${total_cap_array[$c]}" kWh"				
		fi
		if [[ ! ${temperature_array[$c]} == null  ]];
		then	
			echo -e "	Device internal temperature: "${temperature_array[$c]}" °C"				
		fi
		if [[ ! ${center_u_array[$c]} == null  ]];
		then	
			echo -e "	DC voltage: "${center_u_array[$c]}" V"				
		fi
		if [[ ! ${center_i_array[$c]} == null  ]];
		then	
			echo -e "	DC current: "${center_i_array[$c]}" A"				
		fi
		if [[ ! ${center_i_1_array[$c]} == null  ]];
		then	
			echo -e "	#1 current value: "${center_i_1_array[$c]}" A"				
		fi
		if [[ ! ${center_i_2_array[$c]} == null  ]];
		then	
			echo -e "	#2 current value: "${center_i_2_array[$c]}" A"				
		fi
		if [[ ! ${center_i_3_array[$c]} == null  ]];
		then	
			echo -e "	#3 current value: "${center_i_3_array[$c]}" A"				
		fi
		if [[ ! ${center_i_4_array[$c]} == null  ]];
		then	
			echo -e "	#4 current value: "${center_i_4_array[$c]}" A"				
		fi
		if [[ ! ${center_i_5_array[$c]} == null  ]];
		then	
			echo -e "	#5 current value: "${center_i_5_array[$c]}" A"				
		fi
		if [[ ! ${center_i_6_array[$c]} == null  ]];
		then	
			echo -e "	#6 current value: "${center_i_6_array[$c]}" A"				
		fi			
		if [[ ! ${center_i_7_array[$c]} == null  ]];
		then	
			echo -e "	#7 current value: "${center_i_7_array[$c]}" A"				
		fi
		if [[ ! ${center_i_8_array[$c]} == null  ]];
		then	
			echo -e "	#8 current value: "${center_i_8_array[$c]}" A"				
		fi
		if [[ ! ${center_i_9_array[$c]} == null  ]];
		then	
			echo -e "	#9 current value: "${center_i_9_array[$c]}" A"				
		fi
		if [[ ! ${center_i_10_array[$c]} == null  ]];
		then	
			echo -e "	#10 current value: "${center_i_10_array[$c]}" A"				
		fi
		if [[ ! ${mppt_power_array[$c]} == null  ]];
		then	
			echo -e "	MPPT (Maximum Power Point Tracking) total input power: "${mppt_power_array[$c]}" Kw"			
		fi
		if [[ ! ${a_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase A voltage: "${a_u_array[$c]}" V"				
		fi
		if [[ ! ${b_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase B voltage: "${b_u_array[$c]}" V"				
		fi
		if [[ ! ${c_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase C voltage: "${c_u_array[$c]}" V"				
		fi
		if [[ ! ${a_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase A current: "${a_i_array[$c]}" A"				
		fi
		if [[ ! ${b_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase B current: "${b_i_array[$c]}" A"				
		fi
		if [[ ! ${c_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase C current: "${c_i_array[$c]}" A"				
		fi
		if [[ ! ${power_factor_array[$c]} == null  ]];
		then	
			echo -e "	Power factor: "${power_factor_array[$c]}			
		fi
		if [[ ! ${elec_freq_array[$c]} == null  ]];
		then	
			echo -e "	Grid frequency: "${elec_freq_array[$c]}" Hz"			
		fi
		if [[ ! ${active_power_array[$c]} == null  ]];
		then	
			echo -e "	Active power: "${active_power_array[$c]}" Kw"			
		fi
		if [[ ! ${reactive_power_array[$c]} == null  ]];
		then	
			echo -e "	Output reactive power: "${reactive_power_array[$c]}" Kvar"			
		fi
		if [[ ! ${open_time_array[$c]} == null  ]];
		then	
			local startup_time=$(date -d @${open_time_array[$c]})	
			echo -e "	Inverter last startup time: "$startup_time
					
		fi
		if [[ ! ${close_time_array[$c]} == null  ]];
		then	
			local shutdown_time=$(date -d @${close_time_array[$c]})
			echo -e "	Inverter last shutdown time: "$shutdown_time		
		fi
		if [[ ! ${aop_array[$c]} == null  ]];
		then	
			echo -e "	Production reliability: "${aop_array[$c]}" %"			
		fi
		
		done
	done

fi

# if we have Smart Energy Center 
if [[ $success == "true"  ]] && [[  $2 == 38  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""

	
	for (( a=0; a<=((${#devIds_array[@]}-1)); a++ )) 
	do
	
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$a]}
		echo -e "\e[0m ID: "${devId_array[$a]}
		echo ""
		echo -e "	Every 5 minutes data from day: \e[1m"$(date +"%d %B %Y" -d @$(echo ${collectTime_array[0]::-3}))"\e[0m"
		echo ""
		
		#loop for every 5 minutes
		for (( c=0; c<=((${#collectTime_array[@]}-1)); c++ )) 
		do
		
		if [[ ! ${inverter_state_array[$c]} == null  ]];
		then	
			printf "	Inverter status: "
			#decimal number to hexdecimal
			local hex=$( printf "%x" ${inverter_state_array[$c]} );
			#echo $hex
			#function to check inverter status
			inverter_state $hex
			echo ""			
		fi
		if [[ ! ${ab_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid AB voltage: "${ab_u_array[$c]}" V"				
		fi		
		if [[ ! ${bc_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid BC voltage: "${bc_u_array[$c]}" V"				
		fi		
		if [[ ! ${ca_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid CA voltage: "${ca_u_array[$c]}" V"				
		fi		
		if [[ ! ${a_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase A voltage: "${a_u_array[$c]}" V"				
		fi		
		if [[ ! ${b_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase B voltage: "${b_u_array[$c]}" V"				
		fi		
		if [[ ! ${c_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase C voltage: "${c_u_array[$c]}" V"				
		fi		
		if [[ ! ${a_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase A current: "${a_i_array[$c]}" A"				
		fi		
		if [[ ! ${b_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase B current: "${b_i_array[$c]}" A"				
		fi		
		if [[ ! ${c_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase C current: "${c_i_array[$c]}" A"				
		fi		
		if [[ ! ${efficiency_array[$c]} == null  ]];
		then	
			echo -e "	Inverter conversion efficiency (manufacturer): "${efficiency_array[$c]}" %"				
		fi		
		if [[ ! ${temperature_array[$c]} == null  ]];
		then	
			echo -e "	Device internal temperature: "${temperature_array[$c]}" °C"				
		fi		
		if [[ ! ${power_factor_array[$c]} == null  ]];
		then	
			echo -e "	Power factor: "${power_factor_array[$c]}			
		fi		
		if [[ ! ${elec_freq_array[$c]} == null  ]];
		then	
			echo -e "	Grid frequency: "${elec_freq_array[$c]}" Hz"			
		fi		
		if [[ ! ${active_power_array[$c]} == null  ]];
		then	
			echo -e "	Active power: "${active_power_array[$c]}" Kw"			
		fi		
		if [[ ! ${reactive_power_array[$c]} == null  ]];
		then	
			echo -e "	Output reactive power: "${reactive_power_array[$c]}" Kvar"			
		fi		
		if [[ ! ${day_cap_array[$c]} == null  ]];
		then	
			echo -e "	Daily energy: "${day_cap_array[$c]}" Kwh"			
		fi		
		if [[ ! ${mppt_power_array[$c]} == null  ]];
		then	
			echo -e "	MPPT (Maximum Power Point Tracking) total input power: "${mppt_power_array[$c]}" Kw"			
		fi		
		if [[ ! ${pv1_u_array[$c]} == null  ]];
		then	
			echo -e "	PV1 input voltage: "${pv1_u_array[$c]}" V"			
		fi		
		if [[ ! ${pv2_u_array[$c]} == null  ]];
		then	
			echo -e "	PV2 input voltage: "${pv2_u_array[$c]}" V"			
		fi		
		if [[ ! ${pv3_u_array[$c]} == null  ]];
		then	
			echo -e "	PV3 input voltage: "${pv3_u_array[$c]}" V"			
		fi		
		if [[ ! ${pv4_u_array[$c]} == null  ]];
		then	
			echo -e "	PV4 input voltage: "${pv4_u_array[$c]}" V"	
		fi		
		if [[ ! ${pv5_u_array[$c]} == null  ]];
		then	
			echo -e "	PV5 input voltage: "${pv5_u_array[$c]}" V"			
		fi
		if [[ ! ${pv6_u_array[$c]} == null  ]];
		then	
			echo -e "	PV6 input voltage: "${pv6_u_array[$c]}" V"			
		fi
		if [[ ! ${pv7_u_array[$c]} == null  ]];
		then	
			echo -e "	PV7 input voltage: "${pv7_u_array[$c]}" V"			
		fi
		if [[ ! ${pv8_u_array[$c]} == null  ]];
		then	
			echo -e "	PV8 input voltage: "${pv8_u_array[$c]}" V"			
		fi
		if [[ ! ${pv1_i_array[$c]} == null  ]];
		then	
			echo -e "	PV1 input current: "${pv1_i_array[$c]}" A"			
		fi
		if [[ ! ${pv2_i_array[$c]} == null  ]];
		then	
			echo -e "	PV2 input current: "${pv2_i_array[$c]}" A"			
		fi
		if [[ ! ${pv3_i_array[$c]} == null  ]];
		then	
			echo -e "	PV3 input current: "${pv3_i_array[$c]}" A"			
		fi
		if [[ ! ${pv4_i_array[$c]} == null  ]];
		then	
			echo -e "	PV4 input current: "${pv4_i_array[$c]}" A"			
		fi
		if [[ ! ${pv5_i_array[$c]} == null  ]];
		then	
			echo -e "	PV5 input current: "${pv5_i_array[$c]}" A"			
		fi
		if [[ ! ${pv6_i_array[$c]} == null  ]];
		then	
			echo -e "	PV6 input current: "${pv6_i_array[$c]}" A"			
		fi
		if [[ ! ${pv7_i_array[$c]} == null  ]];
		then	
			echo -e "	PV7 input current: "${pv7_i_array[$c]}" A"			
		fi
		if [[ ! ${pv8_i_array[$c]} == null  ]];
		then	
			echo -e "	PV8 input current: "${pv8_i_array[$c]}" A"			
		fi
		if [[ ! ${total_cap_array[$c]} == null  ]];
		then	
			echo -e "	Cumulative energy: "${total_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${open_time_array[$c]} == null  ]];
		then	
			local startup_time=$(date -d @${open_time_array[$c]})	
			echo -e "	Inverter last startup time: "$startup_time					
		fi
		if [[ ! ${close_time_array[$c]} == null  ]];
		then	
			local shutdown_time=$(date -d @${close_time_array[$c]})
			echo -e "	Inverter last shutdown time: "$shutdown_time		
		fi
		if [[ ! ${mppt_total_cap_array[$c]} == null  ]];
		then	
			echo -e "	Total DC input energy: "${mppt_total_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_1_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 1 DC cumulative energy: "${mppt_1_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_2_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 2 DC cumulative energy: "${mppt_2_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_3_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 3 DC cumulative energy: "${mppt_3_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${mppt_4_cap_array[$c]} == null  ]];
		then	
			echo -e "	MPPT 4 DC cumulative energy: "${mppt_4_cap_array[$c]}" Kwh"			
		fi

		
		done
	done

fi

# if we have DC combiner box 
if [[ $success == "true"  ]] && [[  $2 == 15  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""

	
	for (( a=0; a<=((${#devIds_array[@]}-1)); a++ )) 
	do
	
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$a]}
		echo -e "\e[0m ID: "${devId_array[$a]}
		echo ""
		echo -e "	Every 5 minutes data from day: \e[1m"$(date +"%d %B %Y" -d @$(echo ${collectTime_array[0]::-3}))"\e[0m"
		echo ""
		
		#loop for every 5 minutes
		for (( c=0; c<=((${#collectTime_array[@]}-1)); c++ )) 
		do

		if [[ ! ${dc_i1_array[$c]} == null  ]];
		then	
			echo -e "	#1 current value: "${dc_i1_array[$c]}" A"				
		fi
		if [[ ! ${dc_i2_array[$c]} == null  ]];
		then	
			echo -e "	#2 current value: "${dc_i2_array[$c]}" A"				
		fi
		if [[ ! ${dc_i3_array[$c]} == null  ]];
		then	
			echo -e "	#3 current value: "${dc_i3_array[$c]}" A"				
		fi
		if [[ ! ${dc_i4_array[$c]} == null  ]];
		then	
			echo -e "	#4 current value: "${dc_i4_array[$c]}" A"				
		fi
		if [[ ! ${dc_i5_array[$c]} == null  ]];
		then	
			echo -e "	#5 current value: "${dc_i5_array[$c]}" A"				
		fi
		if [[ ! ${dc_i6_array[$c]} == null  ]];
		then	
			echo -e "	#6 current value: "${dc_i6_array[$c]}" A"				
		fi
		if [[ ! ${dc_i7_array[$c]} == null  ]];
		then	
			echo -e "	#7 current value: "${dc_i7_array[$c]}" A"				
		fi
		if [[ ! ${dc_i8_array[$c]} == null  ]];
		then	
			echo -e "	#8 current value: "${dc_i8_array[$c]}" A"				
		fi
		if [[ ! ${dc_i9_array[$c]} == null  ]];
		then	
			echo -e "	#9 current value: "${dc_i9_array[$c]}" A"				
		fi
		if [[ ! ${dc_i10_array[$c]} == null  ]];
		then	
			echo -e "	#10 current value: "${dc_i10_array[$c]}" A"				
		fi
		if [[ ! ${dc_i11_array[$c]} == null  ]];
		then	
			echo -e "	#11 current value: "${dc_i11_array[$c]}" A"				
		fi
		if [[ ! ${dc_i12_array[$c]} == null  ]];
		then	
			echo -e "	#12 current value: "${dc_i12_array[$c]}" A"				
		fi
		if [[ ! ${dc_i13_array[$c]} == null  ]];
		then	
			echo -e "	#13 current value: "${dc_i13_array[$c]}" A"				
		fi
		if [[ ! ${dc_i14_array[$c]} == null  ]];
		then	
			echo -e "	#14 current value: "${dc_i14_array[$c]}" A"				
		fi
		if [[ ! ${dc_i15_array[$c]} == null  ]];
		then	
			echo -e "	#15 current value: "${dc_i15_array[$c]}" A"				
		fi
		if [[ ! ${dc_i16_array[$c]} == null  ]];
		then	
			echo -e "	#16 current value: "${dc_i16_array[$c]}" A"				
		fi
		if [[ ! ${dc_i17_array[$c]} == null  ]];
		then	
			echo -e "	#17 current value: "${dc_i17_array[$c]}" A"				
		fi
		if [[ ! ${dc_i18_array[$c]} == null  ]];
		then	
			echo -e "	#18 current value: "${dc_i18_array[$c]}" A"				
		fi
		if [[ ! ${dc_i19_array[$c]} == null  ]];
		then	
			echo -e "	#19 current value: "${dc_i19_array[$c]}" A"				
		fi
		if [[ ! ${dc_i20_array[$c]} == null  ]];
		then	
			echo -e "	#20 current value: "${dc_i20_array[$c]}" A"				
		fi
		if [[ ! ${photc_i_array[$c]} == null  ]];
		then	
			echo -e "	PV current: "${photc_i_array[$c]}" A"				
		fi
		if [[ ! ${photc_u_array[$c]} == null  ]];
		then	
			echo -e "	PV voltage: "${photc_u_array[$c]}" V"				
		fi
		if [[ ! ${temperature_array[$c]} == null  ]];
		then	
			echo -e "	Device internal temperature: "${temperature_array[$c]}" °C"				
		fi
		if [[ ! ${thunder_count_array[$c]} == null  ]];
		then	
			echo -e "	Number of lightning strikes: "${thunder_count_array[$c]}" Times"
		fi
		done
	done

fi

# device is EMI
if [[ $success == "true"  ]] && [[ $2 == 10  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""

	
	for (( a=0; a<=((${#devIds_array[@]}-1)); a++ )) 
	do
	
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$a]}
		echo -e "\e[0m ID: "${devId_array[$a]}
		echo ""
		echo -e "	Every 5 minutes data from day: \e[1m"$(date +"%d %B %Y" -d @$(echo ${collectTime_array[0]::-3}))"\e[0m"
		echo ""
		
		#loop for every 5 minutes
		for (( c=0; c<=((${#collectTime_array[@]}-1)); c++ )) 
		do				
		if [[ ! ${temperature_array[$c]} == null  ]];
		then	
			echo -e "	Temperature: "${temperature_array[$c]}" °C"				
		fi			
		if [[ ! ${pv_temperature_array[$c]} == null  ]];
		then	
			echo -e "	PV temperature: "${pv_temperature_array[$c]}" °C"				
		fi	
		if [[ ! ${wind_speed_array[$c]} == null  ]];
		then	
			echo -e "	Wind speed: "${wind_speed_array[$c]}" m/s"				
		fi	
		if [[ ! ${wind_direction_array[$c]} == null  ]];
		then	
			echo -e "	Wind direction: "${wind_direction_array[$c]}" Degree"				
		fi	
		if [[ ! ${radiant_total_array[$c]} == null  ]];
		then	
			echo -e "	Total irradiation: "${radiant_total_array[$c]}" MJ/m 2"				
		fi	
		if [[ ! ${radiant_line_array[$c]} == null  ]];
		then	
			echo -e "	Irradiation intensity: "${radiant_line_array[$c]}" W/m 2"				
		fi	
		if [[ ! ${horiz_radiant_line_array[$c]} == null  ]];
		then	
			echo -e "	Horizontal irradiation intensity: "${horiz_radiant_line_array[$c]}" W/m 2"				
		fi	
		if [[ ! ${horiz_radiant_total_array[$c]} == null  ]];
		then	
			echo -e "	Horizontal irradiation: "${horiz_radiant_total_array[$c]}" MJ/m 2"				
		fi
		done
	done

fi


# device is Meter (Grid meter)
if [[ $success == "true"  ]] && [[ $2 == 17  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""

	
	for (( a=0; a<=((${#devIds_array[@]}-1)); a++ )) 
	do
	
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$a]}
		echo -e "\e[0m ID: "${devId_array[$a]}
		echo ""
		echo -e "	Every 5 minutes data from day: \e[1m"$(date +"%d %B %Y" -d @$(echo ${collectTime_array[0]::-3}))"\e[0m"
		echo ""
		
		#loop for every 5 minutes
		for (( c=0; c<=((${#collectTime_array[@]}-1)); c++ )) 
		do				

		if [[ ! ${ab_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid AB voltage: "${ab_u_array[$c]}" V"				
		fi
		if [[ ! ${bc_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid BC voltage: "${bc_u_array[$c]}" V"				
		fi
		if [[ ! ${ca_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid CA voltage: "${ca_u_array[$c]}" V"				
		fi
		if [[ ! ${a_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase A voltage (AC output): "${a_u_array[$c]}" V"				
		fi
		if [[ ! ${b_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase B voltage (AC output): "${b_u_array[$c]}" V"				
		fi
		if [[ ! ${c_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase C voltage (AC output): "${c_u_array[$c]}" V"				
		fi
		if [[ ! ${a_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase A current (IA): "${a_i_array[$c]}" A"				
		fi
		if [[ ! ${b_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase B current (IB): "${b_i_array[$c]}" A"				
		fi
		if [[ ! ${c_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase C current (IC): "${c_i_array[$c]}" A"				
		fi
		if [[ ! ${active_power_array[$c]} == null  ]];
		then	
			echo -e "	Active power: "${active_power_array[$c]}" Kw"		
		fi
		if [[ ! ${power_factor_array[$c]} == null  ]];
		then	
			echo -e "	Power factor: "${power_factor_array[$c]}			
		fi
		if [[ ! ${active_cap_array[$c]} == null  ]];
		then	
			echo -e "	Active power (Kilowatt hour of positive active power): "${active_cap_array[$c]}" kWh"			
		fi
		if [[ ! ${reactive_power_array[$c]} == null  ]];
		then	
			echo -e "	Output reactive power: "${reactive_power_array[$c]}" Kvar"			
		fi
		if [[ ! ${reverse_active_cap_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative active power: "${reverse_active_cap_array[$c]}" Kwh"			
		fi
		if [[ ! ${forward_reactive_cap_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of positive reactive power: "${forward_reactive_cap_array[$c]}" Kwh"			
		fi		
		if [[ ! ${reverse_reactive_cap_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative reactive power: "${reverse_reactive_cap_array[$c]}" Kwh"			
		fi			
		if [[ ! ${active_power_a_array[$c]} == null  ]];
		then	
			echo -e "	Active power Pa: "${active_power_a_array[$c]}" Kw"			
		fi		
		if [[ ! ${active_power_b_array[$c]} == null  ]];
		then	
			echo -e "	Active power Pb: "${active_power_b_array[$c]}" Kw"			
		fi		
		if [[ ! ${active_power_c_array[$c]} == null  ]];
		then	
			echo -e "	Active power Pb: "${active_power_c_array[$c]}" Kw"			
		fi		
		if [[ ! ${reactive_power_a_array[$c]} == null  ]];
		then	
			echo -e "	Reactive power Qa: "${reactive_power_a_array[$c]}" kVar"			
		fi	
		if [[ ! ${reactive_power_b_array[$c]} == null  ]];
		then	
			echo -e "	Reactive power Qb: "${reactive_power_ab_array[$c]}" kVar"			
		fi
		if [[ ! ${reactive_power_c_array[$c]} == null  ]];
		then	
			echo -e "	Reactive power Qc: "${reactive_power_c_array[$c]}" kVar"			
		fi
		if [[ ! ${total_apparent_power_array[$c]} == null  ]];
		then	
			echo -e "	Total apparent power: "${total_apparent_power_array[$c]}" kVA"			
		fi
		if [[ ! ${grid_frequency_array[$c]} == null  ]];
		then	
			echo -e "	Grid frequency: "${grid_frequency_array[$c]}" Hz"			
		fi
		if [[ ! ${reverse_active_peak_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative active power (peak): "${reverse_active_peak_array[$c]}" Kwh"			
		fi
		if [[ ! ${reverse_active_power_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative active power (off): "${reverse_active_power_array[$c]}" Kwh"			
		fi
		if [[ ! ${reverse_active_valley_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative active power (shoulder): "${reverse_active_valley_array[$c]}" Kwh"			
		fi
		if [[ ! ${reverse_active_top_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative active power (sharp): "${reverse_active_top_array[$c]}" Kwh"			
		fi
		if [[ ! ${positive_active_peak_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of positive active power (peak): "${positive_active_peak_array[$c]}" Kwh"			
		fi
		if [[ ! ${positive_active_power_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of positive active power (off): "${positive_active_power_array[$c]}" Kwh"			
		fi
		if [[ ! ${positive_active_valley_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of positive active power (shoulder): "${positive_active_valley_array[$c]}" Kwh"			
		fi
		if [[ ! ${positive_active_top_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of positive active power (sharp): "${positive_active_top_array[$c]}" Kwh"			
		fi	
		if [[ ! ${reverse_reactive_peak_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of positive reactive power (peak): "${reverse_reactive_peak_array[$c]}" Kwh"			
		fi
		if [[ ! ${reverse_reactive_power_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of positive reactive power (off): "${reverse_reactive_power_array[$c]}" Kwh"			
		fi
		if [[ ! ${reverse_reactive_valley_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of positive reactive power (shoulder): "${reverse_reactive_valley_array[$c]}" Kwh"			
		fi
		if [[ ! ${reverse_reactive_top_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative reactive power (sharp): "${reverse_reactive_top_array[$c]}" Kwh"			
		fi
		if [[ ! ${positive_reactive_peak_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative reactive power (peak): "${positive_reactive_peak_array[$c]}" Kwh"			
		fi
		if [[ ! ${positive_reactive_power_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative reactive power (off): "${positive_reactive_power_array[$c]}" Kwh"			
		fi
		if [[ ! ${positive_reactive_valley_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative reactive power (shoulder): "${positive_reactive_valley_array[$c]}" Kwh"			
		fi
		if [[ ! ${positive_reactive_top_array[$c]} == null  ]];
		then	
			echo -e "	Kilowatt hour of negative reactive power (sharp): "${positive_reactive_top_array[$c]}" Kwh"			
		fi

		done
	done

fi


# device is Power Sensor
if [[ $success == "true"  ]] && [[ $2 == 47  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""

	
	for (( a=0; a<=((${#devIds_array[@]}-1)); a++ )) 
	do
	
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$a]}
		echo -e "\e[0m ID: "${devId_array[$a]}
		echo ""
		echo -e "	Every 5 minutes data from day: \e[1m"$(date +"%d %B %Y" -d @$(echo ${collectTime_array[0]::-3}))"\e[0m"
		echo ""
		
		#loop for every 5 minutes
		for (( c=0; c<=((${#collectTime_array[@]}-1)); c++ )) 
		do
			
		if [[ ! ${meter_status_array[$c]} == null  ]];
		then	
			if [[ ${meter_status_array[$c]} == 0  ]];
			then
			meter_status="Offline"
			elif [[ ${meter_status_array[$c]} == 1  ]];
			then
			meter_status="Normal"
			else
			meter_status="Unknow"
			fi
			echo -e "	Meter status: "$meter_status
		fi
		if [[ ! ${meter_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid voltage: "${meter_u_array[$c]}" V"				
		fi
		if [[ ! ${meter_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid current: "${meter_i_array[$c]}" A"				
		fi
		if [[ ! ${active_power_array[$c]} == null  ]];
		then	
			echo -e "	Active power: "${active_power_array[$c]}" W"				
		fi
		if [[ ! ${reactive_power_array[$c]} == null  ]];
		then	
			echo -e "	Reactive power: "${reactive_power_array[$c]}" Var"				
		fi
		if [[ ! ${power_factor_array[$c]} == null  ]];
		then	
			echo -e "	Power factor: "${power_factor_array[$c]}				
		fi
		if [[ ! ${grid_frequency_array[$c]} == null  ]];
		then	
			echo -e "	Grid frequency: "${grid_frequency_array[$c]}" Hz"				
		fi
		if [[ ! ${active_cap_array[$c]} == null  ]];
		then	
			echo -e "	Active power (Kilowatt hour of positive active power): "${active_cap_array[$c]}" kWh"				
		fi
		if [[ ! ${reverse_active_cap_array[$c]} == null  ]];
		then	
			echo -e "	Rective power (Kilowatt hour of negative active power): "${reverse_active_cap_array[$c]}" kWh"				
		fi
		done
	done

fi


# device is Battery
if [[ $success == "true"  ]] && [[ $2 == 39  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""

	
	for (( a=0; a<=((${#devIds_array[@]}-1)); a++ )) 
	do
	
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$a]}
		echo -e "\e[0m ID: "${devId_array[$a]}
		echo ""
		echo -e "	Every 5 minutes data from day: \e[1m"$(date +"%d %B %Y" -d @$(echo ${collectTime_array[0]::-3}))"\e[0m"
		echo ""
		
		#loop for every 5 minutes
		for (( c=0; c<=((${#collectTime_array[@]}-1)); c++ )) 
		do				
		
		if [[ ! ${meter_status_array[$c]} == null  ]];
		then		
			if [[ ${meter_status_array[$c]} == 0  ]];
			then
			meter_status="Offline"
			elif [[ ${meter_status_array[$c]} == 1  ]];
			then
			meter_status="Normal"
			else
			meter_status="Unknow"
			fi
			echo -e "	Meter status: "$meter_status				
		fi
		if [[ ! ${meter_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid voltage: "${meter_u_array[$c]}" V"				
		fi
		if [[ ! ${meter_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid current: "${meter_i_array[$c]}" A"				
		fi
		if [[ ! ${active_power_array[$c]} == null  ]];
		then	
			echo -e "	Active power: "${active_power_array[$c]}" W"				
		fi
		if [[ ! ${reactive_power_array[$c]} == null  ]];
		then	
			echo -e "	Reactive power: "${reactive_power_array[$c]}" Var"				
		fi
		if [[ ! ${power_factor_array[$c]} == null  ]];
		then	
			echo -e "	Power factor: "${power_factor_array[$c]}				
		fi
		if [[ ! ${grid_frequency_array[$c]} == null  ]];
		then	
			echo -e "	Grid frequency: "${grid_frequency_array[$c]}" Hz"				
		fi
		if [[ ! ${active_cap_array[$c]} == null  ]];
		then	
			echo -e "	Active power (Kilowatt hour of positive active power): "${active_cap_array[$c]}" kWh"				
		fi
		if [[ ! ${reverse_active_cap_array[$c]} == null  ]];
		then	
			echo -e "	Rective power (Kilowatt hour of negative active power): "${reverse_active_cap_array[$c]}" kWh"				
		fi
		
		done
	done

fi

# device is Transformer
if [[ $success == "true"  ]] && [[ $2 == 8  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""

	
	for (( a=0; a<=((${#devIds_array[@]}-1)); a++ )) 
	do
	
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$a]}
		echo -e "\e[0m ID: "${devId_array[$a]}
		echo ""
		echo -e "	Every 5 minutes data from day: \e[1m"$(date +"%d %B %Y" -d @$(echo ${collectTime_array[0]::-3}))"\e[0m"
		echo ""
		
		#loop for every 5 minutes
		for (( c=0; c<=((${#collectTime_array[@]}-1)); c++ )) 
		do
					
		if [[ ! ${ab_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid AB line voltage: "${ab_u_array[$c]}" V"				
		fi
		if [[ ! ${bc_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid BC line voltage: "${bc_u_array[$c]}" V"				
		fi
		if [[ ! ${ca_u_array[$c]} == null  ]];
		then	
			echo -e "	Grid CA line voltage: "${ca_u_array[$c]}" V"				
		fi
		if [[ ! ${a_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase A voltage (AC output): "${a_u_array[$c]}" V"				
		fi
		if [[ ! ${b_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase B voltage (AC output): "${b_u_array[$c]}" V"				
		fi
		if [[ ! ${c_u_array[$c]} == null  ]];
		then	
			echo -e "	Phase C voltage (AC output): "${c_u_array[$c]}" V"				
		fi
		if [[ ! ${a_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase A current (IA): "${a_i_array[$c]}" A"				
		fi
		if [[ ! ${b_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase B current (IB): "${b_i_array[$c]}" A"				
		fi
		if [[ ! ${c_i_array[$c]} == null  ]];
		then	
			echo -e "	Grid phase C current (IC): "${c_i_array[$c]}" A"				
		fi		
		if [[ ! ${active_power_array[$c]} == null  ]];
		then	
			echo -e "	Active power: "${active_power_array[$c]}" Kw"			
		fi
		if [[ ! ${reactive_power_array[$c]} == null  ]];
		then	
			echo -e "	Reactive power: "${reactive_power_array[$c]}" Kvar"			
		fi
		if [[ ! ${power_factor_array[$c]} == null  ]];
		then	
			echo -e "	Power factor: "${power_factor_array[$c]}			
		fi
		if [[ ! ${elec_freq_array[$c]} == null  ]];
		then	
			echo -e "	Grid frequency: "${elec_freq_array[$c]}" Hz"			
		fi

		done
	done

fi


# in case of error
if [[ $success == "false"  ]];
	then
	#fuction which works with connection error	
	in_case_of_error_with_connection_to_API $getDevFiveMinutes
		
fi

echo ""


}

function getDevKpiDay {


# Request to API getKpiStationYear
local getDevKpiDay=$(printf '{"devIds": "'$1'", "devTypeId": "'$2'", "collectTime": '$3'}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getDevKpiDay  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')

#echo $getDevKpiDay | jq

local success=$(echo ''$getDevKpiDay''  | jq '.success' )
local buildCode=$(echo ''$getDevKpiDay''  | jq '.buildCode' )
local failCode=$(echo ''$getDevKpiDay''  | jq '.failCode' )
local message=$(echo ''$getDevKpiDay''  | jq '.message' )

#we have inverter
if [[ $2 == 1  ]];
then	

local devId=$(echo ''$getDevKpiDay''  | jq '.data[].devId' )
	local collectTime_every_day=$(echo ''$getDevKpiDay''  | jq '.data[].collectTime' )	
		local installed_capacity=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.installed_capacity' )		 
		local product_power=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.product_power' )		 
		local perpower_ratio=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.perpower_ratio' )
		local yield_deviation=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.yield_deviation' )
		local total_aop=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.total_aop' )
		local aoc_ratio=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.aoc_ratio' )			 

local data_getDevKpiDay=$(echo ''$getDevKpiDay''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevKpiDay''  | jq '.currentTime' )
	local collectTime=$(echo ''$data_getDevKpiDay''  | jq '.collectTime' )
	local devIds=$(echo ''$data_getDevKpiDay''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevKpiDay''  | jq '.devTypeId' )

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "collectTime_array=(${collectTime_every_day})"
		eval "installed_capacity_array=(${installed_capacity})"
		eval "product_power_array=(${product_power})"
		eval "perpower_ratio_array=(${perpower_ratio})"
		eval "yield_deviation_array=(${yield_deviation})"
		eval "total_aop_array=(${total_aop})"
		eval "aoc_ratio_array=(${aoc_ratio})"

#we have Battery
elif [[ $2 == 39  ]];
then
local devId=$(echo ''$getDevKpiDay''  | jq '.data[].devId' )
	local collectTime_every_day=$(echo ''$getDevKpiDay''  | jq '.data[].collectTime' )
		local charge_cap=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.charge_cap' )
		local discharge_cap=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.discharge_cap' )
		local charge_time=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.charge_time' )
		local discharge_time=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.discharge_time' )

local data_getDevKpiDay=$(echo ''$getDevKpiDay''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevKpiDay''  | jq '.currentTime' )
	local collectTime=$(echo ''$data_getDevKpiDay''  | jq '.collectTime' )
	local devIds=$(echo ''$data_getDevKpiDay''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevKpiDay''  | jq '.devTypeId' )
	
#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "collectTime_array=(${collectTime_every_day})"
		eval "charge_cap_array=(${charge_cap})"
		eval "discharge_cap_array=(${discharge_cap})"
		eval "charge_time_array=(${charge_time})"
		eval "discharge_time_array=(${discharge_time})"

#we have Central inverter
elif [[ $2 == 14  ]];
then
local devId=$(echo ''$getDevKpiDay''  | jq '.data[].devId' )
	local collectTime_every_day=$(echo ''$getDevKpiDay''  | jq '.data[].collectTime' )
		local installed_capacity=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.installed_capacity' )		 
		local product_power=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.product_power' )		 
		local perpower_ratio=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.perpower_ratio' )
		local yield_deviation=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.yield_deviation' )
		local total_aop=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.total_aop' )
		local aoc_ratio=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.aoc_ratio' )	

local data_getDevKpiDay=$(echo ''$getDevKpiDay''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevKpiDay''  | jq '.currentTime' )
	local collectTime=$(echo ''$data_getDevKpiDay''  | jq '.collectTime' )
	local devIds=$(echo ''$data_getDevKpiDay''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevKpiDay''  | jq '.devTypeId' )
	
#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "collectTime_array=(${collectTime_every_day})"
		eval "installed_capacity_array=(${installed_capacity})"
		eval "product_power_array=(${product_power})"
		eval "perpower_ratio_array=(${perpower_ratio})"
		eval "yield_deviation_array=(${yield_deviation})"
		eval "total_aop_array=(${total_aop})"
		eval "aoc_ratio_array=(${aoc_ratio})"

#we have Smart Energy Center
elif [[ $2 == 38  ]];
then
local devId=$(echo ''$getDevKpiDay''  | jq '.data[].devId' )
	local collectTime_every_day=$(echo ''$getDevKpiDay''  | jq '.data[].collectTime' )
		local installed_capacity=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.installed_capacity' )		 
		local product_power=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.product_power' )		 
		local perpower_ratio=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.perpower_ratio' )
		local yield_deviation=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.yield_deviation' )
		local total_aop=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.total_aop' )
		local aoc_ratio=$(echo ''$getDevKpiDay''  | jq '.data[].dataItemMap.aoc_ratio' )	

local data_getDevKpiDay=$(echo ''$getDevKpiDay''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevKpiDay''  | jq '.currentTime' )
	local collectTime=$(echo ''$data_getDevKpiDay''  | jq '.collectTime' )
	local devIds=$(echo ''$data_getDevKpiDay''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevKpiDay''  | jq '.devTypeId' )
	
#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"
local devIds="$(echo "$devIds" | tr -d '"')"
local devTypeId="$(echo "$devTypeId" | tr -d '"')"

		# Conversion of long variable string to array
		eval "devId_array=(${devId})"
		eval "collectTime_array=(${collectTime_every_day})"
		eval "installed_capacity_array=(${installed_capacity})"
		eval "product_power_array=(${product_power})"
		eval "perpower_ratio_array=(${perpower_ratio})"
		eval "yield_deviation_array=(${yield_deviation})"
		eval "total_aop_array=(${total_aop})"
		eval "aoc_ratio_array=(${aoc_ratio})"



fi
	


# Here comma is our delimiter value to array of stations codes given by user as a parameter in question
IFS="," read -a devIds_array <<< $devIds
IFS="," read -a devTypeId_array <<< $devTypeId


#echo "Request success or failure flag: " $success
if [[ $success == "true"  ]];
	then	
		echo ""
		echo -e "API \e[4mgetDevKpiDay\e[0m connection \e[42mOK\e[0m"
		getDevKpiDay_connection=true
elif [[ $success == "false" ]];
	then
		echo ""
		echo -e "API \e[4mgetDevKpiDay\e[0m connection \e[41mError\e[0m"
		getDevKpiDay_connection=false
else
	echo ""
	echo -e "\e[41mNetwork Error :(\e[0m" 
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


if [[ $success == "true"  ]];
then	
	echo "Build Code: "$buildCode
fi


local curent_time_actually=$(echo ${currentTime::-3})
local curent_time_of_request=$(echo ${collectTime::-3})
local difference_in_secounds=$(( $curent_time_actually-$curent_time_of_request ))

local curent_time_of_request=$(date -d @$curent_time_of_request)
echo "Time of your Request to API: "$curent_time_of_request

echo "Response time: "$difference_in_secounds" s"
#local curent_time_actually=$(date -d @$curent_time_actually)
#echo "Actuall time: "$curent_time_actually


# if we have inverter
if [[ $success == "true"  ]] && [[  $2 == 1  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""

	
	for (( a=0; a<=((${#devIds_array[@]}-1)); a++ )) 
	do
	
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$a]}
		echo -e "\e[0m ID: "${devId_array[$a]}
		echo ""
		echo -e "	Every Day data from month: \e[1m"$(date +"%B %Y %Z" -d @$(echo ${collectTime_array[0]::-3}))"\e[0m"
		echo ""
		
		#loop for every day
		for (( c=0; c<=((${#collectTime_array[@]}-1)); c++ )) 
		do
		

		#local collectTimeActually=$(echo ${collectTime_array[$c]::-3})
		echo -e "	\e[1m"$(date +"%d %B %Y" -d @$(echo ${collectTime_array[$c]::-3}))"\e[0m"
		
		
		#special loop  for checking if inverter is disconnected
		#if [[ ! $hex == "0"  ]];
		#then
		
				
		if [[ ! ${installed_capacity_array[$c]} == null  ]];
		then	
			echo -e "	Installed capacity: "${installed_capacity_array[$c]}" kWp"				
		fi
	 	if [[ ! ${product_power_array[$c]} == null  ]];
		then	
			echo -e "	Energy: "${product_power_array[$c]}" kWh"				
		fi	
		if [[ ! ${perpower_ratio_array[$c]} == null  ]];
		then	
			echo -e "	Equivalent utilization hours: "${perpower_ratio_array[$c]}" h"				
		fi
		if [[ ! ${yield_deviation_array[$c]} == null  ]];
		then	
			echo -e "	Production deviation: "${yield_deviation_array[$c]}" %"				
		fi
		if [[ ! ${total_aop_array[$c]} == null  ]];
		then	
			echo -e "	Production reliability: "${total_aop_array[$c]}" %"				
		fi
		if [[ ! ${aoc_ratio_array[$c]} == null  ]];
		then	
			echo -e "	Communication reliability: "${aoc_ratio_array[$c]}" %"				
		fi

		echo ""
		
		#special for checking if inverter is diconected 
		#else
		#	echo -e "	No any Real-time data when device is disconected!"
		
		#special loop finish for checking if inverter is diconected 
		#fi
		
		#end of for loop for presentation data every 5minutes
		done

	done

fi

# if we have Battery
if [[ $success == "true"  ]] && [[  $2 == 39  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""

	
	for (( a=0; a<=((${#devIds_array[@]}-1)); a++ )) 
	do
	
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$a]}
		echo -e "\e[0m ID: "${devId_array[$a]}
		echo ""
		echo -e "	Every Day data from month: \e[1m"$(date +"%B %Y %Z" -d @$(echo ${collectTime_array[0]::-3}))"\e[0m"
		echo ""
		
		#loop for every day
		for (( c=0; c<=((${#collectTime_array[@]}-1)); c++ )) 
		do
		

		#local collectTimeActually=$(echo ${collectTime_array[$c]::-3})
		echo -e "	\e[1m"$(date +"%d %B %Y" -d @$(echo ${collectTime_array[$c]::-3}))"\e[0m"
		
		
		#special loop  for checking if inverter is disconnected
		#if [[ ! $hex == "0"  ]];
		#then
		
		eval "charge_cap_array=(${charge_cap})"
		eval "discharge_cap_array=(${discharge_cap})"
		eval "charge_time_array=(${charge_time})"
		eval "discharge_time_array=(${discharge_time})"	
			
				
		if [[ ! ${charge_cap_array[$c]} == null  ]];
		then	
			echo -e "	Charging capacity: "${charge_cap_array[$c]}" kWh"				
		fi
	 	if [[ ! ${discharge_cap_array[$c]} == null  ]];
		then	
			echo -e "	Discharging capacity: "${discharge_cap_array[$c]}" kWh"				
		fi	
		if [[ ! ${charge_time_array[$c]} == null  ]];
		then	
			echo -e "	Charging duration: "${charge_time_array[$c]}" h"				
		fi
		if [[ ! ${discharge_time_array[$c]} == null  ]];
		then	
			echo -e "	Discharge duration: "${discharge_time_array[$c]}" h"				
		fi
		echo ""
		
		#special for checking if inverter is diconected 
		#else
		#	echo -e "	No any Real-time data when device is disconected!"
		
		#special loop finish for checking if inverter is diconected 
		#fi
		
		#end of for loop for presentation data every 5minutes
		done

	done

fi

#if we have Central inverter
if [[ $success == "true"  ]] && [[  $2 == 14  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""

	
	for (( a=0; a<=((${#devIds_array[@]}-1)); a++ )) 
	do
	
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$a]}
		echo -e "\e[0m ID: "${devId_array[$a]}
		echo ""
		echo -e "	Every Day data from month: \e[1m"$(date +"%B %Y %Z" -d @$(echo ${collectTime_array[0]::-3}))"\e[0m"
		echo ""
		
		#loop for every day
		for (( c=0; c<=((${#collectTime_array[@]}-1)); c++ )) 
		do
		

		#local collectTimeActually=$(echo ${collectTime_array[$c]::-3})
		echo -e "	\e[1m"$(date +"%d %B %Y" -d @$(echo ${collectTime_array[$c]::-3}))"\e[0m"
		
		
		#special loop  for checking if inverter is disconnected
		#if [[ ! $hex == "0"  ]];
		#then
		
				
		if [[ ! ${installed_capacity_array[$c]} == null  ]];
		then	
			echo -e "	Installed capacity: "${installed_capacity_array[$c]}" kWp"				
		fi
	 	if [[ ! ${product_power_array[$c]} == null  ]];
		then	
			echo -e "	Energy: "${product_power_array[$c]}" kWh"				
		fi	
		if [[ ! ${perpower_ratio_array[$c]} == null  ]];
		then	
			echo -e "	Equivalent utilization hours: "${perpower_ratio_array[$c]}" h"				
		fi
		if [[ ! ${yield_deviation_array[$c]} == null  ]];
		then	
			echo -e "	Production deviation: "${yield_deviation_array[$c]}" %"				
		fi
		if [[ ! ${total_aop_array[$c]} == null  ]];
		then	
			echo -e "	Production reliability: "${total_aop_array[$c]}" %"				
		fi
		if [[ ! ${aoc_ratio_array[$c]} == null  ]];
		then	
			echo -e "	Communication reliability: "${aoc_ratio_array[$c]}" %"				
		fi

		echo ""
		
		#special for checking if inverter is diconected 
		#else
		#	echo -e "	No any Real-time data when device is disconected!"
		
		#special loop finish for checking if inverter is diconected 
		#fi
		
		#end of for loop for presentation data every 5minutes
		done

	done

fi

#if we have Smart Energy Center
if [[ $success == "true"  ]] && [[  $2 == 38  ]];
	then
	
	echo ""
	echo "Numbers of Devices to check: "${#devIds_array[@]}
	echo ""

	
	for (( a=0; a<=((${#devIds_array[@]}-1)); a++ )) 
	do
	
		echo -e "\e[93m \c" 
		Device_type_ID ${devTypeId_array[$a]}
		echo -e "\e[0m ID: "${devId_array[$a]}
		echo ""
		echo -e "	Every Day data from month: \e[1m"$(date +"%B %Y %Z" -d @$(echo ${collectTime_array[0]::-3}))"\e[0m"
		echo ""
		
		#loop for every day
		for (( c=0; c<=((${#collectTime_array[@]}-1)); c++ )) 
		do
		

		#local collectTimeActually=$(echo ${collectTime_array[$c]::-3})
		echo -e "	\e[1m"$(date +"%d %B %Y" -d @$(echo ${collectTime_array[$c]::-3}))"\e[0m"
		
		
		#special loop  for checking if inverter is disconnected
		#if [[ ! $hex == "0"  ]];
		#then
		
				
		if [[ ! ${installed_capacity_array[$c]} == null  ]];
		then	
			echo -e "	Installed capacity: "${installed_capacity_array[$c]}" kWp"				
		fi
	 	if [[ ! ${product_power_array[$c]} == null  ]];
		then	
			echo -e "	Energy: "${product_power_array[$c]}" kWh"				
		fi	
		if [[ ! ${perpower_ratio_array[$c]} == null  ]];
		then	
			echo -e "	Equivalent utilization hours: "${perpower_ratio_array[$c]}" h"				
		fi
		if [[ ! ${yield_deviation_array[$c]} == null  ]];
		then	
			echo -e "	Production deviation: "${yield_deviation_array[$c]}" %"				
		fi
		if [[ ! ${total_aop_array[$c]} == null  ]];
		then	
			echo -e "	Production reliability: "${total_aop_array[$c]}" %"				
		fi
		if [[ ! ${aoc_ratio_array[$c]} == null  ]];
		then	
			echo -e "	Communication reliability: "${aoc_ratio_array[$c]}" %"				
		fi

		echo ""
		
		#special for checking if inverter is diconected 
		#else
		#	echo -e "	No any Real-time data when device is disconected!"
		
		#special loop finish for checking if inverter is diconected 
		#fi
		
		#end of for loop for presentation data every 5minutes
		done

	done

fi
# in case of error
if [[ $success == "false"  ]];
	then
	#fuction which works with connection error	
	in_case_of_error_with_connection_to_API $getDevKpiDay
		
fi

echo ""


}

function getDevKpiMonth {


# Request to API getKpiStationYear
local getDevKpiMonth=$(printf '{"devIds": "'$1'", "devTypeId": "'$2'", "collectTime": '$3'}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getDevKpiMonth  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')

echo $getDevKpiMonth | jq

local success=$(echo ''$getDevKpiMonth''  | jq '.success' )
local buildCode=$(echo ''$getDevKpiMonth''  | jq '.buildCode' )
local failCode=$(echo ''$getDevKpiMonth''  | jq '.failCode' )
local message=$(echo ''$getDevKpiMonth''  | jq '.message' )


local data_getDevKpiMonth=$(echo ''$getDevKpiMonth''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevKpiMonth''  | jq '.currentTime' )
	local collectTime=$(echo ''$data_getDevKpiMonth''  | jq '.collectTime' )
	local devIds=$(echo ''$data_getDevKpiMonth''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevKpiMonth''  | jq '.devTypeId' )
	

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"

# Here comma is our delimiter value to array of stations codes given by user as a parameter in question
IFS="," read -a devIds_array <<< $devIds



#echo "Request success or failure flag: " $success
if [[ $success == "true"  ]];
	then	
		echo ""
		echo -e "API \e[4mgetDevKpiMonth\e[0m connection \e[42mOK\e[0m"
		getDevKpiMonth_connection=true
elif [[ $success == "false" ]];
	then
		echo ""
		echo -e "API \e[4mgetDevKpiMonth\e[0m connection \e[41mError\e[0m"
		getDevKpiMonth_connection=false
else
	echo ""
	echo -e "\e[41mNetwork Error :(\e[0m" 
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


if [[ $success == "true"  ]];
then	
	echo "Build Code: "$buildCode
fi


local curent_time_actually=$(echo ${currentTime::-3})
local curent_time_of_request=$(echo ${collectTime::-3})
local difference_in_secounds=$(( $curent_time_actually-$curent_time_of_request ))

local curent_time_of_request=$(date -d @$curent_time_of_request)
echo "Time of your Request to API: "$curent_time_of_request

echo "Response time: "$difference_in_secounds" s"
#local curent_time_actually=$(date -d @$curent_time_actually)
#echo "Actuall time: "$curent_time_actually



# in case of error
if [[ $success == "false"  ]];
	then
	#fuction which works with connection error	
	in_case_of_error_with_connection_to_API $getDevKpiMonth
		
fi

echo ""


}

function getDevKpiYear {


# Request to API getKpiStationYear
local getDevKpiYear=$(printf '{"devIds": "-164425067615730", "devTypeId": "1", "collectTime": '$1'}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getDevKpiYear  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')

echo $getDevKpiYear| jq

local success=$(echo ''$getDevKpiYear''  | jq '.success' )
local buildCode=$(echo ''$getDevKpiYear''  | jq '.buildCode' )
local failCode=$(echo ''$getDevKpiYear''  | jq '.failCode' )
local message=$(echo ''$getDevKpiYear''  | jq '.message' )


local data_getDevKpiYear=$(echo ''$getDevKpiYear''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevKpiYear''  | jq '.currentTime' )
	local collectTime=$(echo ''$data_getDevKpiYear''  | jq '.collectTime' )
	local devIds=$(echo ''$data_getDevKpiYear''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevKpiYear''  | jq '.devTypeId' )
	

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"

# Here comma is our delimiter value to array of stations codes given by user as a parameter in question
IFS="," read -a devIds_array <<< $devIds



#echo "Request success or failure flag: " $success
if [[ $success == "true"  ]];
	then	
		echo ""
		echo -e "API \e[4mgetDevKpiYear\e[0m connection \e[42mOK\e[0m"
		getDevKpiYear_connection=true
elif [[ $success == "false" ]];
	then
		echo ""
		echo -e "API \e[4mgetDevKpiYear\e[0m connection \e[41mError\e[0m"
		getDevKpiYear_connection=false
else
	echo ""
	echo -e "\e[41mNetwork Error :(\e[0m" 
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


if [[ $success == "true"  ]];
then	
	echo "Build Code: "$buildCode
fi


local curent_time_actually=$(echo ${currentTime::-3})
local curent_time_of_request=$(echo ${collectTime::-3})
local difference_in_secounds=$(( $curent_time_actually-$curent_time_of_request ))

local curent_time_of_request=$(date -d @$curent_time_of_request)
echo "Time of your Request to API: "$curent_time_of_request

echo "Response time: "$difference_in_secounds" s"
#local curent_time_actually=$(date -d @$curent_time_actually)
#echo "Actuall time: "$curent_time_actually



# in case of error
if [[ $success == "false"  ]];
	then
	#fuction which works with connection error	
	in_case_of_error_with_connection_to_API $getDevKpiYear
		
fi

echo ""


}

function devUpgrade {


# Request to API getKpiStationYear
local devUpgrade=$(printf '{"devIds": "-164425067615730", "devTypeId": "1"}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/devUpgrade  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')

echo $devUpgrade | jq

local success=$(echo ''$devUpgrade''  | jq '.success' )
local buildCode=$(echo ''$devUpgrade''  | jq '.buildCode' )
local failCode=$(echo ''$devUpgrade''  | jq '.failCode' )
local message=$(echo ''$devUpgrade''  | jq '.message' )


local data_devUpgrade=$(echo ''$devUpgrade''  | jq '.params' )
	local currentTime=$(echo ''$data_devUpgrade''  | jq '.currentTime' )
	local devIds=$(echo ''$data_devUpgrade''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_devUpgrade''  | jq '.devTypeId' )
	

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"

# Here comma is our delimiter value to array of stations codes given by user as a parameter in question
IFS="," read -a devIds_array <<< $devIds



#echo "Request success or failure flag: " $success
if [[ $success == "true"  ]];
	then	
		echo ""
		echo -e "API \e[4mdevUpgrade\e[0m connection \e[42mOK\e[0m"
		devUpgrade_connection=true
elif [[ $success == "false" ]];
	then
		echo ""
		echo -e "API \e[4mdevUpgrade\e[0m connection \e[41mError\e[0m"
		devUpgrade_connection=false
else
	echo ""
	echo -e "\e[41mNetwork Error :(\e[0m" 
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


if [[ $success == "true"  ]];
then	
	echo "Build Code: "$buildCode
fi


local curent_time_actually=$(echo ${currentTime::-3})
local curent_time_of_request=$(date -d @$curent_time_actually)
echo "Time of your Request to API: "$curent_time_of_request


# in case of error
if [[ $success == "false"  ]];
	then
	#fuction which works with connection error	
	in_case_of_error_with_connection_to_API $devUpgrade
		
fi

echo ""


}


function getDevUpgradeInfo {


# Request to API getKpiStationYear
local getDevUpgradeInfo=$(printf '{"devIds": "-164425067615730", "devTypeId": "1"}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getDevUpgradeInfo  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')

echo $getDevUpgradeInfo | jq

local success=$(echo ''$getDevUpgradeInfo''  | jq '.success' )
#local buildCode=$(echo ''$getDevUpgradeInfo''  | jq '.buildCode' )
local failCode=$(echo ''$getDevUpgradeInfo''  | jq '.failCode' )
#local message=$(echo ''$getDevUpgradeInfo''  | jq '.message' )


local data_getDevUpgradeInfo=$(echo ''$getDevUpgradeInfo''  | jq '.params' )
	local currentTime=$(echo ''$data_getDevUpgradeInfo''  | jq '.currentTime' )
	local devIds=$(echo ''$data_getDevUpgradeInfo''  | jq '.devIds' )
	local devTypeId=$(echo ''$data_getDevUpgradeInfo''  | jq '.devTypeId' )
	

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"

# Here comma is our delimiter value to array of stations codes given by user as a parameter in question
IFS="," read -a devIds_array <<< $devIds



#echo "Request success or failure flag: " $success
if [[ $success == "true"  ]];
	then	
		echo ""
		echo -e "API \e[4mgetDevUpgradeInfo\e[0m connection \e[42mOK\e[0m"
		getDevUpgradeInfo_connection=true
elif [[ $success == "false" ]];
	then
		echo ""
		echo -e "API \e[4mgetDevUpgradeInfo\e[0m connection \e[41mError\e[0m"
		getDevUpgradeInfo_connection=false
else
	echo ""
	echo -e "\e[41mNetwork Error :(\e[0m" 
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


if [[ $success == "true"  ]];
then	
	echo "Build Code: "$buildCode
fi


local curent_time_actually=$(echo ${currentTime::-3})

local curent_time_of_request=$(date -d @$curent_time_actually)
echo "Time of your Request to API: "$curent_time_of_request



# in case of error
if [[ $success == "false"  ]];
	then
	#fuction which works with connection error	
	in_case_of_error_with_connection_to_API $getDevUpgradeInfo
		
fi

echo ""


}

function getAlarmList {


# Request to API getKpiStationYear
local getAlarmList=$(printf '{"stationCodes": "'$1'", "beginTime":1610292233000, "endTime":1612883122757, "language":"en_UK", "types":"1,2,3,4,5", "devTypes":"1,62", "levels":"1,2,3,4", "status":"1,2,3,4,5,6"}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getAlarmList  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')




echo $getAlarmList | jq

local success=$(echo ''$getAlarmList''  | jq '.success' )
local buildCode=$(echo ''$getAlarmList''  | jq '.buildCode' )
local failCode=$(echo ''$getAlarmList''  | jq '.failCode' )
local message=$(echo ''$getAlarmList''  | jq '.message' )
local parameters=$(echo ''$getAlarmList''  | jq '.parms' )
	

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"

# Here comma is our delimiter value to array of stations codes given by user as a parameter in question
IFS="," read -a devIds_array <<< $devIds



#echo "Request success or failure flag: " $success
if [[ $success == "true"  ]];
	then	
		echo ""
		echo -e "API \e[4mgetAlarmList\e[0m connection \e[42mOK\e[0m"
		getAlarmList_connection=true
elif [[ $success == "false" ]];
	then
		echo ""
		echo -e "API \e[4mgetAlarmList\e[0m connection \e[41mError\e[0m"
		getAlarmList_connection=false
else
	echo ""
	echo -e "\e[41mNetwork Error :(\e[0m" 
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


if [[ $success == "true"  ]];
then	
	echo "Build Code: "$buildCode
fi


local curent_time_actually=$(echo ${curent_time::-3})

local curent_time_of_request=$(date -d @$curent_time_actually)
echo "Time of your Request to API: "$curent_time_of_request



# in case of error
if [[ $success == "false"  ]];
	then
	#fuction which works with connection error	
	in_case_of_error_with_connection_to_API $getAlarmList
		
fi

echo ""


}



function snIsRegister {


# Request to API getKpiStationYear
local snIsRegister=$(printf '{"SN": "-164425067615730", "userName": "blazejos", "key": "1293849606739215"}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/snIsRegister XSRF-TOKEN:''$xsrf_token'' Content-Type:'application/json' Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')


echo $snIsRegister | jq


local success=$(echo ''$snIsRegister''  | jq '.success' )
local buildCode=$(echo ''$snIsRegister''  | jq '.buildCode' )
local failCode=$(echo ''$snIsRegister''  | jq '.failCode' )
local message=$(echo ''$snIsRegister''  | jq '.message' )
local parameters=$(echo ''$snIsRegister''  | jq '.parms' )
	

#removing " on begining and end
local buildCode="$(echo "$buildCode" | tr -d '"')"


#echo "Request success or failure flag: " $success
if [[ $success == "true"  ]];
	then	
		echo ""
		echo -e "API \e[4msnIsRegister\e[0m connection \e[42mOK\e[0m"
		snIsRegister_connection=true
elif [[ $success == "false" ]];
	then
		echo ""
		echo -e "API \e[4msnIsRegister\e[0m connection \e[41mError\e[0m"
		snIsRegister_connection=false
else
	echo ""
	echo -e "\e[41mNetwork Error :(\e[0m" 
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


if [[ $success == "true"  ]];
then	
	echo "Build Code: "$buildCode
fi


local curent_time_actually=$(echo ${curent_time::-3})

local curent_time_of_request=$(date -d @$curent_time_actually)
echo "Time of your Request to API: "$curent_time_of_request



# in case of error
if [[ $success == "false"  ]];
	then
	#fuction which works with connection error	
	in_case_of_error_with_connection_to_API $snIsRegister
		
fi

echo ""



}


: <<'END_COMMENT'


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
	curl -i -XPOST 'http://localhost:8086/write?db=panele_sloneczne&u=insert_user&p=476fdF$6&precision=s' --data-binary 'Power=hourly value='${power_inverted_array[$count_hours]}' '${hour_of_the_day_array[$count_hours]}''
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

END_COMMENT




# All the functions 
# Function to login to API
login_to_API

if [[ $login_status == true  ]];
then	
		# We start function to get list of plants
		getStationList
		#getStationRealKpi ${stations_Code_array[0]}
		
		if [[ $getStationList_connection == true  ]];
		then	
			# We start function to get list of devices inside one particular plant
			getDevList ${stations_Code_array[0]} $number_of_plants
			
			
			#echo ${device_Id_array[1]}
			#echo ${device_TypeId_array[1]}
			

			
			# Plant data
			getStationRealKpi ${stations_Code_array[0]}	
			getKpiStationHour ${stations_Code_array[0]} $curent_time
			getKpiStationDay ${stations_Code_array[0]} $curent_time
			getKpiStationMonth ${stations_Code_array[0]} $curent_time
			getKpiStationYear ${stations_Code_array[0]} $curent_time
			
			# Devices data precisious all voltages etc real-time
			getDevRealKpi  ${device_Id_array[1]} ${device_TypeId_array[1]}
			
			getDevFiveMinutes ${device_Id_array[1]} ${device_TypeId_array[1]} $curent_time
			getDevKpiDay ${device_Id_array[1]} ${device_TypeId_array[1]} $curent_time
			#getDevKpiMonth ${device_Id_array[1]} ${device_TypeId_array[1]} $curent_time
			#getDevKpiYear $curent_time
			#devUpgrade
			#getDevUpgradeInfo
			#getAlarmList ${stations_Code_array[0]}
			#snIsRegister
			
			#end of 2000 unix time ms format
			#getKpiStationYear ${stations_Code_array[0]} "978303599000"
			
			# End of 2020 unix time ms format
			#getKpiStationYear ${stations_Code_array[0]} "1609455599000"
			
			# End of 2020 unix time ms format
			#getKpiStationMonth ${stations_Code_array[0]} "1609455599000"
			
			#getKpiStationDay ${stations_Code_array[0]} "1609455599000"
			
			# time Sat Jan 30 2021 11:39:40 in unix time ms format for tests
			#1612006780447
			
				
		elif [[ $getStationList_connection == false ]];
		then
			exit
		else
			exit
		fi
		
elif [[ $login_status == false ]];
then	
		exit
else
	exit
fi


