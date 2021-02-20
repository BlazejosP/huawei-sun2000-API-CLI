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

if [ -f Previous_10_days_every_hour.config ]
then
    	echo "Config File is existing"
	echo "Date inside file is used as a starting point for our import"
	# we add config file with date where we finished last time
	. Previous_10_days_every_hour.config
	curent_starting_time_actually=$(echo ${curent_time::-3})
	data=$(date +"%d %B %Y" -d @$curent_starting_time_actually)
	echo $data
	sleep 5s
else
    	echo "Config File is not existing"
	echo "File is created and importing historical data starts from today Date"
	curent_time=$(echo ''$getStationList''  | jq '.params' )
	curent_time=$(echo ''$curent_time''  | jq '.currentTime' )
	curent_time=$(echo $curent_time)
	curent_starting_time_actually=$(echo ${curent_time::-3})
	data=$(date +"%d %B %Y" -d @$curent_starting_time_actually)
        echo $data
	sleep 5s
fi

echo $curent_time

#30/11/2020
#curent_time=1606694400000
#20/11/2020
#curent_time=1605895200000
#10/11/2020
#curent_time=1605020400000
#31/10/2020
#curent_time=1604160000000
#21/10/2020
#curent_time=1603292400000
#11/10/2020
#curent_time=1602432000000
#1/10/2020
#curent_time=1601568000000
#21/09/2020
#curent_time=1600707600000
#11/09/2020
#curent_time=1599843600000



#28 July 2020
#curent_time=1595947214000
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



#curent_time_actually=$(echo ${curent_time::-3})
#curent_time_actually_divide=expr $(($curent_time / 1000))
curent_time_actually_divide=$((curent_time / 1000))


data=$(echo ''$getStationList''  | jq '.data[]' )

station_Code=$(echo ''$data''  | jq '.stationCode' )



#echo $curent_time "as seen by API"
#echo $curent_time_actually "unix secounds"

#echo $curent_time_actually_divide


counter_of_previous_days_since_starting=1
while [ $counter_of_previous_days_since_starting -le 10 ]
do

# Operation on UNIX time we come back in time 1 day 86400 secounds
yesterday_time_short=$(($curent_time_actually_divide - 86400))

# Day before in unix format
#echo $yesterday_time_short


yesterday_time_long=$(($yesterday_time_short * 1000))
#echo $yesterday_time_long

# Request to API getKpiStationHour
getKpiStationHour=$(printf '{"stationCodes": '$station_Code', "collectTime": '$yesterday_time_long'}'| http  --follow --timeout 3600 POST https://eu5.fusionsolar.huawei.com/thirdData/getKpiStationHour  XSRF-TOKEN:''$xsrf_token''  Content-Type:'application/json'  Cookie:'web-auth=true; XSRF-TOKEN='$xsrf_token'; JSESSIONID='$jsesionid'')

#Time prepared back to short version
curent_time_actually_divide=$(($yesterday_time_long / 1000))

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
#printf '%s\n' "${power_profit[@]}"

#time in unix secound format is not necessary to cut -3 character
# echo "Date of that day which is now inserted as seen by system:"${hour_of_the_day_array[$Number_of_hours]}
#shorter time for read in unix
#day_which_now_inserting_to_database=${hour_of_the_day_array[$Number_of_hours]}
#echo $day_which_now_inserting_to_database
#data=$(date +"%d %B %Y" -d @$day_which_now_inserting_to_database)
#echo "Historical data from "$data" now will be inserted to database"
#echo ""
#sleep 2s

#truncate=$(truncate -s0 wyjscie.txt)
#echo "curent_time="${hour_of_the_day_array[$Number_of_hours]}"000"  >> wyjscie.txt
#printf '%s\n' "${hour_of_the_day_array[$Number_of_hours]}"



# Add in loop series of data to influxDB for each hour of the actual day
count_hours=0
for s in "${hour_of_the_day_array[@]}"; do 
	
        #Display hour timestamp
        #echo ${hour_of_the_day_array[$count_hours]}
        data=$(date +"%H:%M" -d @${hour_of_the_day_array[$count_hours]})
        echo "Hour of the day: "$data" "${power_iverted_array[$count_hours]}"Kw/h"

	curl -i -XPOST 'http://'$influxdb_server':'$influxdb_port'/write?db='$influxdb_database'&u='$influxdb_db_insert_user'&p='$influxdb_db_insert_password'&precision=s' --data-binary 'Power=hourly value='${power_iverted_array[$count_hours]}' '${hour_of_the_day_array[$count_hours]}''
	(( count_hours++ ))

done


Number_of_hours=$(echo ${#hour_of_the_day_array[@]})
Number_of_hours=$(( $Number_of_hours-1 ))

	#Display hour timestamp
	data=$(date +"%H:%M" -d @${hour_of_the_day_array[$Number_of_hours]})
        echo "Hour of the day: "$data" "${power_iverted_array[$Number_of_hours]}"Kw/h"
	#Hourly power production today last hour
	curl -i -XPOST 'http://'$influxdb_server':'$influxdb_port'/write?db='$influxdb_database'&u='$influxdb_db_insert_user'&p='$influxdb_db_insert_password'&precision=s' --data-binary 'Power=hourly value='${power_iverted_array[$Number_of_hours]}' '${hour_of_the_day_array[$Number_of_hours]}''

day_which_now_inserting_to_database=${hour_of_the_day_array[$Number_of_hours]}
#echo $day_which_now_inserting_to_database
data=$(date +"%d %B %Y" -d @$day_which_now_inserting_to_database)
echo "Historical data from "$data" now will be inserted to database"
echo "Number of sunny hours in that particular day:"$Number_of_hours
echo ${power_iverted_array[$Number_of_hours]}
echo ""
sleep 2s



		# Add in loop series of data to influxDB for each hour of the actual day
		count_hours=0
		for s in "${hour_of_the_day_array[@]}"; do 
			
			#Display hour timestamp
                        #echo ${hour_of_the_day_array[$count_hours]}
                        data=$(date +"%H:%M" -d @${hour_of_the_day_array[$count_hours]})
                        echo "Hour of the day: "$data" "${power_iverted_array[$count_hours]}"Kw/h"

			#Hourly power production today
			curl -i -XPOST 'http://'$influxdb_server':'$influxdb_port'/write?db='$influxdb_database'&u='$influxdb_db_insert_user'&p='$influxdb_db_insert_password'&precision=s' --data-binary 'Power=hourly value='${power_iverted_array[$count_hours]}' '${hour_of_the_day_array[$count_hours]}''
			
		(( count_hours++ ))
		done


	# Counter of previous days
	((counter_of_previous_days_since_starting++))

	if [[ $counter_of_previous_days_since_starting -eq 10 ]]
	then
		echo "Just reach 10th day plese wait."

		data=$(date +"%d %B %Y" -d @$day_which_now_inserting_to_database)
		truncate=$(truncate -s0 Previous_10_days_every_hour.config)
		echo "#!/bin/bash" >> Previous_10_days_every_hour.config
		echo "#this is config file for Previous_10_days_every_hour.sh there is last day from which data were imported in unix epoch + three 0 for compability with API format. If you d'like start from your own day importing add on the end of unix date 000 next time when you start program he starts capturing from this date" >> Previous_10_days_every_hour.config
		echo "#day from which we start next time inserting historical data is "$data >> Previous_10_days_every_hour.config
		echo "curent_time="$day_which_now_inserting_to_database"000" >> Previous_10_days_every_hour.config
		printf '%s\n' $day_which_now_inserting_to_database
		sleep 5s

	else
		echo "Just preparing next day to insert please wait"
		
	fi


done




