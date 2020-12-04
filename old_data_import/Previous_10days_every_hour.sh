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


# Login to FusionSolarAPI with user and Password
logowanie=$(curl -X POST -H "Content-Type: application/json" -d '{userName:"'$userName'",systemCode:"'$systemCode'"}' -i https://eu5.fusionsolar.huawei.com/thirdData/login )


#Operations on string for 
IFS='{'
array=( $logowanie )
#echo $logowanie
#echo "value = ${array[1]}"
question=${array[1]}


IFS=','
array=( $question )
#echo "value = ${array[5]}"
question=${array[5]}

#echo "${question::-1}"


#Operations on string for extract xsrl token necessary for next questions
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
header="XSRF-TOKEN"
xsrf_token=${array[1]}


IFS=':'
array=( $jsesionid )
#echo "value = ${array[1]}"
jsesionid=${array[1]}

IFS='='
array=( $jsesionid )
header_jsesion="JSESSIONID"
jsesionid=${array[1]}

echo ""
#echo $header
echo ""
#echo $xsrf_token
echo ""
#echo $jsesionid


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




