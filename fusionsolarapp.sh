#!/bin/bash

# Tool for login and get data from Huawei FusionSolar https://eu5.fusionsolar.huawei.com
# This tool use oficial FusionSolar API described here https://forum.huawei.com/enterprise/en/communicate-with-fusionsolar-through-an-openapi-account/thread/591478-100027 by manufacturer 
# You must have installed on your linux tools like jq, httpie
# sudo apt-get install jq
# sudo apt-get install httpie
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

Device_type_ID () {
# List of possible smart devices in Power Plant by Huawei. Based on documentation SmartPVMS.V300R006C10_API_Northbound.Interface.Reference.1.pdf pages 28-30 
if [ $1 == "1"  ];
then
	echo "	Smart String Inverter"
elif [ $1 == "2"  ];
then	
	echo "	SmartLogger"
elif [ $1 == "3"  ];
then	
	echo "	String"
elif [ $1 == "3"  ];
then	
	echo "	String"
elif [ $1 == "6"  ];
then	
	echo "	Bay"
elif [ $1 == "7"  ];
then	
	echo "	Busbar"
elif [ $1 == "8"  ];
then	
	echo "	Transformer"
elif [ $1 == "9"  ];
then	
	echo "	Transformer meter"
elif [ $1 == "10"  ];
then	
	echo "	EMI"
elif [ $1 == "11"  ];
then	
	echo "	AC combiner box"
elif [ $1 == "13"  ];
then	
	echo "	DPU"
elif [ $1 == "14"  ];
then	
	echo "	Central Inverter"
elif [ $1 == "15"  ];
then	
	echo "	DC combiner box"
elif [ $1 == "16"  ];
then	
	echo "	General device"
elif [ $1 == "17"  ];
then	
	echo "	Grid meter"
elif [ $1 == "18"  ];
then	
	echo "	Step-up station"
elif [ $1 == "19"  ];
then	
	echo "	Factory-used energy generation area meter"
elif [ $1 == "20"  ];
then	
	echo "	Solar power forecasting system"
elif [ $1 == "21"  ];
then	
	echo "	Factory-used energy non-generation area meter"
elif [ $1 == "22"  ];
then	
	echo "	PID"
elif [ $1 == "23"  ];
then	
	echo "	Virtual device of plant monitoring system"
elif [ $1 == "24"  ];
then	
	echo "	Power quality device"
elif [ $1 == "25"  ];
then	
	echo "	Step-up transformer"
elif [ $1 == "26"  ];
then	
	echo "	Photovoltaic grid-connection cabinet"
elif [ $1 == "27"  ];
then	
	echo "	Photovoltaic grid-connection panel"
elif [ $1 == "37"  ];
then	
	echo "	Pinnet SmartLogger"
elif [ $1 == "38"  ];
then	
	echo "	Smart Energy Center"
elif [ $1 == "39"  ];
then	
	echo "	Battery"
elif [ $1 == "40"  ];
then	
	echo "	Smart Backup Box"
elif [ $1 == "45"  ];
then	
	echo "	MBUS"
elif [ $1 == "46"  ];
then	
	echo "	Optimizer"
elif [ $1 == "47"  ];
then	
	echo "	Power Sensor"
elif [ $1 == "52"  ];
then	
	echo "	SAJ data logger"
elif [ $1 == "53"  ];
then	
	echo "	High voltage bay of the main transformer"
elif [ $1 == "54"  ];
then	
	echo "	Main transformer"
elif [ $1 == "55"  ];
then	
	echo "	Low voltage bay of the main transformer"
elif [ $1 == "56"  ];
then	
	echo "	Bus bay"
elif [ $1 == "57"  ];
then	
	echo "	Line bay"
elif [ $1 == "58"  ];
then	
	echo "	Plant transformer bay"
elif [ $1 == "59"  ];
then	
	echo "	SVC/SVG bay"
elif [ $1 == "60"  ];
then	
	echo "	Bus tie/section bay"
elif [ $1 == "61"  ];
then	
	echo "	Plant power supply device"
elif [ $1 == "62"  ];
then	
	echo "	Dongle"
elif [ $1 == "63"  ];
then	
	echo "	Distributed SmartLogger"
elif [ $1 == "70"  ];
then	
	echo "	Safety box"
else
	echo "	Unknown Device"
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
	echo "	Plant Name: "${stations_Name_array[$count]}
	echo "	Address of the plant: "${stations_Addres_array[$count]}
	echo "	Installed capacity: "${stations_capacity_array[$count]}" kWp"
	echo "	Plant contact: "${stations_Linkman_array[$count]}
	echo "	Contact phone number :"${stations_owner_phone_array[$count]}
	
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

# Function to login to API
login_to_API

if [[ $login_status == true  ]];
then	
		# We start function to get list of plants
		getStationList
		
		if [[ $getStationList_connection == true  ]];
		then	
			# We start function to get list of devices inside one particular plant
			getDevList ${stations_Code_array[0]} $number_of_plants
			getStationRealKpi ${stations_Code_array[0]}	
			getKpiStationHour ${stations_Code_array[0]} $curent_time
			getKpiStationDay ${stations_Code_array[0]} $curent_time
			getKpiStationMonth ${stations_Code_array[0]} $curent_time
			getKpiStationYear ${stations_Code_array[0]} $curent_time
			
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


