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
			#getDevList ${stations_Code_array[0]} $number_of_plants
			
						
			# Statistical data about whole Power Plant
			#date=1621981136530
			getStationRealKpi ${stations_Code_array[0]}	
			#getKpiStationHour ${stations_Code_array[0]} $date
			#getKpiStationDay ${stations_Code_array[0]} $date
			#getKpiStationMonth ${stations_Code_array[0]} $date
			#getKpiStationYear ${stations_Code_array[0]} $date
			
			
			# Statistical data about particular device/devices inside Power Plant
			
			# Devices data precisious all voltages etc real-time
			#getDevRealKpi  ${device_Id_array[0]} ${device_TypeId_array[0]}			
			#getDevFiveMinutes ${device_Id_array[1]} ${device_TypeId_array[1]} $curent_time
			#getDevKpiDay ${device_Id_array[1]} ${device_TypeId_array[1]} $curent_time
			#getDevKpiMonth ${device_Id_array[1]} ${device_TypeId_array[1]} $curent_time
			#getDevKpiYear ${device_Id_array[1]} ${device_TypeId_array[1]} $date
			
			
			#Error comunicates
			
			# we cover one month before chosen date that is as far as API allows
			Begining_time=$(expr $date - 2629743000)			
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




