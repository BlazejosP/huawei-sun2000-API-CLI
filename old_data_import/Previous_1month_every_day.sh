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


