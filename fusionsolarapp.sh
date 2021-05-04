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




# All the functions 
# Function to login to API
login_to_API

if [[ $login_status == true  ]];
then	
		# We start function to get list of plants
		getStationList
		
		if [[ $getStationList_connection == true  ]];
		then	
			# We start function to get list of devices inside one particular plant
			#getDevList ${stations_Code_array[0]} $number_of_plants
			
						
			# Statistical data about whole Power Plant
			
			#getStationRealKpi ${stations_Code_array[0]}	
			#getKpiStationHour ${stations_Code_array[0]} $curent_time
			#getKpiStationDay ${stations_Code_array[0]} $curent_time
			#getKpiStationMonth ${stations_Code_array[0]} $curent_time
			#getKpiStationYear ${stations_Code_array[0]} $curent_time
			
			
			# Statistical data about particular device/devices inside Power Plant
			
			# Devices data precisious all voltages etc real-time
			#getDevRealKpi  ${device_Id_array[1]} ${device_TypeId_array[1]}			
			#getDevFiveMinutes ${device_Id_array[1]} ${device_TypeId_array[1]} $curent_time
			#getDevKpiDay ${device_Id_array[1]} ${device_TypeId_array[1]} $curent_time
			#getDevKpiMonth ${device_Id_array[1]} ${device_TypeId_array[1]} $curent_time
			#getDevKpiYear ${device_Id_array[1]} ${device_TypeId_array[1]} $curent_time
			
			
			#Error comunicates
			
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
			#Device type. Multiple device types are separated by commas (,), for example, 1,38. 1: Smart String Inverter; 2: SmartLogger; 8: transformer; 10: EMI; 13: protocol converter; 14: Central Inverter; 15: DC combiner box; 16: general device; 17: grid meter; 37: Pinnet data logger; 38: Smart Energy Center; 39: battery; 40: Smart Backup Box; 45: MBUS; 47: Power Sensor; 52: SAJ data logger; 53: high voltage bay of the main transformer; 54: main transformer; 55: low voltage bay of the main transformer; 56: bus bay; 57: line bay; 58: plant transformer bay; 59: SVC/SVG bay; 60: bus tie/section bay; 61: plant power supply device; 62: Dongle; 63: distributed SmartLogger; 70: safety box; 71: collector			
			device_type="1,2,8,10,13,14,15,16,17,37,38,39,40,45,47,52,53,54,55,56,57,58,59,60,61,62,63,70,71"
			
			
			# getAlarmList ${stations_Code_array[0]} $Begining_time $curent_time $language $status $alarm_severity $alarm_type $device_type
			
			
			#Upgrade
			
			# Upgrade of firmware inside inverter or smart Energy Center 
			#devUpgrade ${device_Id_array[1]} ${device_TypeId_array[1]}
			
			# info about upgrades and which were aplied when and what is their status
			#getDevUpgradeInfo ${device_Id_array[1]} ${device_TypeId_array[1]}
			
			# this function is used to enter the email address or phone number 
			# and the device SN to check whethever the SN has been registered 
			# by the user unfortunetly can't made this working as for March 2021
			# meaby still not implemented by Huwei or done something wrong
			#
			#snIsRegister ${device_esnCode_array[1]} $userName
			

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



