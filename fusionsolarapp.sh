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

# Load configuration values variables
source config.conf
source functions.sh

#   Define root name of a temporary output file
#    All data stored in files ${out}XXXXX will be deleted once script finishes
out=`mktemp tempXXXXXX` || exit 1
trap "rm -f $out*" 0 1 2 3 5
export out

#  Take as argument a desired date for $curent_date variable 
#  If provided needs to be provided as 8-digit number yyyymmdd
#      !! Format is not checked !!
if test x${1} = x; then
   mydate=0
else
   mydate=$1
fi

# Define name of global variable for master log file
#   Used to record output of functions
export logfile=$(date +%Y_%m_%d).log

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
		
		
		if [[ $getStationList_connection == true  ]];
		then	
			# We start function to get list of devices inside one particular plant this fuction is necessary to work if you d'like use functions getDevReal*
			getDevList ${stations_Code_array[0]} $number_of_plants
			
			# Define current date variable based on command-line input or default 2021-05-25
			if test "$mydate" != "0"; then
                          #echo Extracting hourly data for date=$mydate
                          curent_time=$(date -d$mydate +%s)000
                          #echo corresponding to $curent_time s since 1970 01 01
                        else
                          curent_time=1621981136530
                          mydate=$(date -d@${curent_time} +%Y%m%d)
                        fi

			#     Statistical data about first Power Plant
			#getStationRealKpi ${stations_Code_array[0]}
			#getKpiStationHour ${stations_Code_array[0]} $curent_time
			#getKpiStationDay ${stations_Code_array[0]} $curent_time
			#getKpiStationMonth ${stations_Code_array[0]} $curent_time
			#getKpiStationYear ${stations_Code_array[0]} $curent_time
			
			#     Statistical data about a second Power Plant (if more than on registered in API account)
			#getStationRealKpi ${stations_Code_array[1]}
			#getKpiStationHour ${stations_Code_array[1]} $curent_time
			#getKpiStationDay ${stations_Code_array[1]} $curent_time
			#getKpiStationMonth ${stations_Code_array[1]} $curent_time
			#getKpiStationYear ${stations_Code_array[1]} $curent_time

			#  Creation of a formatted output file of hourly production for a given date:
			getKpiStationHour ${stations_Code_array[0]} $curent_time
			less ${out}.json | jq '.data[].dataItemMap.inverterPower' > ${out}.power
                        less ${out}.json | jq '.data[].collectTime' > ${out}.time
                        while read d; do
                            d3=$(echo ${d::-3})
                            date -d@${d3} +%Y-%m-%dT%H:%M:%S >> ${out}.dates
                        done < ${out}.time
                        paste -d'|' ${out}.dates ${out}.power > device1_${mydate}.production

			# Statistical data about particular device/devices inside Power Plant
			
			# Devices data precisious all voltages etc real-time
			getDevRealKpi  ${device_Id_array[0]} ${device_TypeId_array[0]}			
			#getDevFiveMinutes ${device_Id_array[0]} ${device_TypeId_array[0]} $curent_time
			#getDevKpiDay ${device_Id_array[0]} ${device_TypeId_array[0]} $curent_time
			#getDevKpiMonth ${device_Id_array[0]} ${device_TypeId_array[0]} $curent_time
			#Months in previous year
			#getDevKpiMonth ${device_Id_array[0]} ${device_TypeId_array[0]} $(expr $curent_time - 31622399000) # minus one year
			#getDevKpiYear ${device_Id_array[0]} ${device_TypeId_array[0]} $(expr $curent_time - 31622399000) # minus one year
			#getDevKpiYear ${device_Id_array[0]} ${device_TypeId_array[0]} $curent_time #actually year
			
			
			#Error comunicates
			#---------
			
			# we cover one month before chosen date that is as far as API allows
			Begining_time=$(expr $curent_time - 2629743000)			
			#Languages. The value must be zh_CN, en_UK, ja_JP, it_IT, nl_NL, pt_BR, de_DE, fr_FR, es_ES, or po_PO.
			language="en_UK"
			#status Alarm status. Multiple alarm statuses are separated by commas (,), for example, 1,2. 1: not handled (active); 2: acknowledged (by a user); 3: being handled (transferred to a defect ticket); 4: handled (defect handling has ended); 5: cleared (by a user); 6: cleared (automatically by the device)
			status="1,2,3,4,5,6"
			# Alarm severity. Multiple alarm severities are separated by commas (,), for example, 1,2. 1: critical; 2: major; 3: minor; 4: warning
			alarm_severity="1,2,3,4"
			#Alarm type. Multiple alarm types are separated by commas (,), for example, 1,2. types 1: transposition signal; 2: exception alarm; 3: protection event; 4: notification status; 5: alarm information
			alarm_type="1,2,3,4,5"
			#Device type. Multiple device types are separated by commas (,), for example, 1,38. 1: String Inverter; 2: Smart Logger; 8: transformer; 10: EMI; 13: protocol converter; 16: general device; 17: grid meter; 22: PID; 37: Pinnet data logger; 38: Residential inverter; 39: Battery; 40: Backup Box; 45: PLC; 47: Power Sensor; 62: Dongle; 63: distributed SmartLogger; 70: safety box;			
			device_type="1,2,8,10,13,16,17,22,37,38,39,40,45,47,62,63,70"
			
			
			#getAlarmList ${stations_Code_array[0]} $Begining_time $date $language $status $alarm_severity $alarm_type $device_type
			
			#---------
			
			#logout from API with unregistration of Xsrf token
			logout_from_API
			

			# Different dates for tests
			
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




