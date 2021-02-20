#!/bin/bash

# Configuration section
#----------------------

#API login and password
userName="<--here data-->"
systemCode="<--here data-->"

# InfluxDB configuration
influxdb_server="<--here data-->" #for example "localhost" or "192.168.1.4"
influxdb_port="<--here data-->" # influxdb input port for example "8086"
influxdb_database="<--here data-->" #database name for example "solar_panels_data" 
influxdb_db_insert_user="<--here data-->" # user fith privilge to insert for example "my_root_user" 
influxdb_db_insert_password="<--here data-->" #for example "secret_password" 
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



#curent_time=$(echo ''$getStationList''  | jq '.params' )
#curent_time=$(echo ''$curent_time''  | jq '.currentTime' )


if [ -f Previous_1month_every_day.config ]
then
    	echo "Config File is existing"
	echo "Date inside file is used as a starting point for our import"
	# we add config file with date where we finished last time
	. Previous_1month_every_day.config
	curent_time=$curent_month
	curent_starting_time_actually=$(echo ${curent_time::-3})
	# Operation on UNIX time we come back in time 1 month 2592000 secounds
        previous_month_current_starting_time=$(($curent_starting_time_actually - 2592000))
	previous_month_data=$(date +"%B %m-%Y" -d @$previous_month_current_starting_time)
	echo $previous_month_current_starting_time
	data=$(date +"%B %m-%Y" -d @$curent_starting_time_actually)
	echo $data
	sleep 5s
else
    	echo "Config File is not existing"
	echo "File is created and importing historical data starts from today Date"
	curent_time=$(echo ''$getStationList''  | jq '.params' )
	curent_time=$(echo ''$curent_time''  | jq '.currentTime' )
	curent_time=$(echo $curent_time)
	curent_starting_time_actually=$(echo ${curent_time::-3})
	# Operation on UNIX time we come back in time 1 month 2592000 secounds
        previous_month_current_starting_time=$(($curent_starting_time_actually - 2592000))
	previous_month_data=$(date +"%B %m-%Y" -d @$previous_month_current_starting_time)
        echo $previous_month_current_starting_time
	data=$(date +"%B %m-%Y" -d @$curent_starting_time_actually)
        echo $data
	sleep 5s
fi

#3 August 2020
#curent_time=1596438811000

#13 July 2020
#curent_time=1594651214000
#2 July 2020
#curent_time=1593704642000
#22 June 2220
#curent_time=1592784000000
#12 June 2020
#curent_time=1591920000000

#20 May 2020
#curent_time=1589932800000



curent_time_actually=$(echo ${curent_time::-3})
#curent_time_actually_divide=expr $(($curent_time / 1000))
curent_time_actually_divide=$((curent_time / 1000))

#data=$(date +"%B %m-%Y" -d @$curent_time_actually)
echo "Just starting importing month: "$data
chosen_date=$data
sleep 5s



data=$(echo ''$getStationList''  | jq '.data[]' )

station_Code=$(echo ''$data''  | jq '.stationCode' )



#echo $curent_time "as seen by API"
#echo $curent_time_actually "unix secounds"

#echo $curent_time_actually_divide "divided by 1000"





# Operation on UNIX time we come back in time 1 month 2592000 secounds
#yesterday_time_short=$(($curent_time_actually_divide - 2592000))

# we write to config file date when we can start next time
		truncate=$(truncate -s0 Previous_1month_every_day.config)
		echo "#!/bin/bash" >> Previous_1month_every_day.config
		echo "#this is config file for Previous_1month_every_day.sh there is last month from which data were imported in unix epoch + three 0 for compability with API format. If you d'like start from your own month importing add on the end of unix date 000 next time when you start program he starts capturing from this date. Day and hour is not important meayby whathever if is just inside this month" >> Previous_1month_every_day.config
		echo "#month from which we start next time inserting historical data is "$previous_month_data >> Previous_1month_every_day.config
		echo "curent_month="$previous_month_current_starting_time"000" >> Previous_1month_every_day.config
		printf '%s\n' $previous_month_curent_starting_time
		sleep 5s


yesterday_time_short=$(($curent_time_actually_divide))

# Day before in unix format
#echo $yesterday_time_short


yesterday_time_long=$(($yesterday_time_short * 1000))
#echo $yesterday_time_long


# Request to API getKpiStationDay
getKpiStationDay=$(printf '{"stationCodes": '$station_Code', "collectTime": '$yesterday_time_long'}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getKpiStationDay  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')


# echo $getKpiStationDay | jq

day=( $(echo ''$getKpiStationDay''  | jq '.data[].collectTime' ) )
power_iverted_whole_day=( $(echo ''$getKpiStationDay''  | jq '.data[].dataItemMap.inverter_power' ) )
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
#echo "Number of positions in array ""${#day_array[@]}"
#echo '\n'
#printf '%s\n' "${power_iverted_whole_day[@]}"
#printf '%s\n' "${power_iverted_whole_day_array[@]}"
#echo '\n'
#printf '%s\n' "${power_profit_whole_day[@]}"
#printf '%s\n' "${perpower_ratio_whole_day[@]}"
#echo '\n'
#printf '%s\n' "${reduction_total_co2_whole_day[@]}"
#echo '\n'
#printf '%s\n' "${reduction_total_coal_whole_day[@]}"
#echo '\n'








# Add in loop series of data to influxDB for each day of the actual month
count_days=0
for s in "${day_array[@]}"; do 

	data=$(date +"%d-%m-%Y" -d @${day_array[$count_days]})
	echo "day: "$data" "${power_iverted_whole_day_array[$count_days]}"Kw/h"
	sleep 2s

	#daily power production in actual month
	curl -i -XPOST 'http://'$influxdb_server':'$influxdb_port'/write?db='$influxdb_database'&u='$influxdb_db_insert_user'&p='$influxdb_db_insert_password'&precision=s' --data-binary 'Power=daily value='${power_iverted_whole_day_array[$count_days]}' '${day_array[$count_days]}''

	#daily DC/AC conversion losses in inverter during production in actual month
	curl -i -XPOST 'http://'$influxdb_server':'$influxdb_port'/write?db='$influxdb_database'&u='$influxdb_db_insert_user'&p='$influxdb_db_insert_password'&precision=s' --data-binary 'Power=perpower_ratio value='${perpower_ratio_whole_day_array[$count_days]}' '${day_array[$count_days]}''
	
	#daily Co2 reduction in actual month
	curl -i -XPOST 'http://'$influxdb_server':'$influxdb_port'/write?db='$influxdb_database'&u='$influxdb_db_insert_user'&p='$influxdb_db_insert_password'&precision=s' --data-binary 'Power=daily_co2 value='${reduction_total_co2_whole_day_array[$count_days]}' '${day_array[$count_days]}''

	#daily coal reduction in actual month
	curl -i -XPOST 'http://'$influxdb_server':'$influxdb_port'/write?db='$influxdb_database'&u='$influxdb_db_insert_user'&p='$influxdb_db_insert_password'&precision=s' --data-binary 'Power=daily_coal value='${reduction_total_coal_whole_day_array[$count_days]}' '${day_array[$count_days]}''

	(( count_days++ ))
done


