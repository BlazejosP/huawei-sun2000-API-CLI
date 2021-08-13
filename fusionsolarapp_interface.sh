#!/bin/bash

# possible arguments different gui systems
# dialog
# whiptail
# gdialog
# yad
# Load configuration values variables
#source config.conf

#DIALOG=${DIALOG:=whiptail}
DIALOG=${DIALOG:=dialog}
#DIALOG=${DIALOG:=gdialog}
#DIALOG=${DIALOG:=yad}

User_name_and_password_filing() {

	# If you cannot understand this, read Bash_Shell_Scripting#if_statements again.
	exec 3>&1;
	username_temp=$($DIALOG --title "Huawei SolarApp Username" --inputbox "Username" 0 0 2>&1 1>&3);
	
	exitcode=$?;
	exec 3>&-;
	#echo $username_temp $exitcode;
	
	case "$exitcode" in
		0) 
			exec 3>&1;
			password_temp=$($DIALOG --title "Huawei SolarApp Password" --passwordbox "Password" 0 0 2>&1 1>&3);
	
			exitcode=$?;
			exec 3>&-;
			#echo $password_temp $exitcode;
			
			case "$exitcode" in
				0) 
				echo -e "#!/bin/bash
			
# Configuration section for fusionsolarapp.sh
			
#----------------------
userName="\"$username_temp\"" #your login name to openAPI user account
systemCode="\"$password_temp\"" #Password of the third-party system openAPI user account
#----------------------" > config.conf
				;;
				1) exit;;
				255) exit;;
			esac
			
		;;
		1) exit;;
		255) exit;;
	esac
	

#	password_temp=$($DIALOG --passwordbox test 0 0 2>&1 1>&3);
	
	exitcode=$?;
	exec 3>&-;
#	echo $password_temp $exitcode;
	
	
}






#All functions of this file

Plant_list() {

getStationList $DIALOG #$number_of_plants

#call to next function
Plant_list_menu
}


Plant_list_menu() {

	#creation of dynamic menu of plant's list
       
       for (( c=1; c<=${#stations_Name_array[@]}; c++ ))
	do  		
	Plants_list_array_for_dialog=( $c "${stations_Code_array[$(( $c-1 ))]}")
	done	
	
	
	Our_menu_plant_list=$($DIALOG  --ok-label "Browse" --cancel-label "Logout" --title "List of Power Stations" \
	 --backtitle "Power plant's related with this account" \
	 --menu "Account Plant's list:" 10 50 10 \
	 "${Plants_list_array_for_dialog[@]}" \
	 --output-fd 1)
        #3>&1 1>&2 2>&3)
        
        exitstatus=$?
        #echo $exitstatus
        if [ $exitstatus = 0 ];
        then 
		
	case "$Our_menu_plant_list" in
			# Propably there is no account with so many power plants like 999
			[1-999])	$DIALOG --extra-button --extra-label "Plant data" --ok-label "Back" --cancel-label "Devices list" --default-button "extra" --title "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
				--backtitle "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
				--scrolltext \
				--yesno "$info_for_dialog_screen\n${results_for_dialog_screen[ $(( $Our_menu_plant_list-1 )) ]}" 20 50
				
				 exitstatus=$?
				 
				if [ $exitstatus = 0 ];
        			then
        				#go back to menu of plants
					Plant_list_menu
				elif [ $exitstatus = 3 ]; 
				then
					# Menu with API functions for plant
					getStationKPI_menu
				elif [ $exitstatus = 1 ]; 
				then
					# Menu with devices in plant
					Devices_list
				else
					#echo  $exitstatus
					#clear #clears the terminal screen
					exit
				fi
				
				#					
        			;; 	      					
 			*) 	$DIALOG --title "List of Power Stations" \
 			 	--backtitle "Power plant's related with this account" \
				--msgbox  "Nothing Chosen" 10 50
				Plant_list_menu
		esac	
		
    	elif [ $exitstatus = 1 ]; 
    	then
    		logout_from_API
    		
    		$DIALOG --title "List of Power Stations" \
 		--backtitle "Logout from API" \
		--msgbox  "$info_for_dialog_screen" 10 50
    		
    		#clear #clears the terminal screen
		exit
	else
    		
    		#clear #clears the terminal screen
    		exit
	fi
}


getStationKPI_menu() {

	Our_menu_getStationKPI=$($DIALOG  --ok-label "Browse" --extra-button --extra-label "Back" --cancel-label "Logout" 		 --title "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
	 --backtitle "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
	 --menu "Which data want to see?" 15 60 10 \
	 1 "REAL-TIME data" \
	 2 "Every HOUR of particular day (not implemented)" \
	 3 "Every DAY of particular month (not implemented)" \
	 4 "Every MONTH of particular year (not implemented)" \
	 5 "Every YEAR of particular century (not implemented)" \
	 --output-fd 1)

	exitstatus=$?
        #echo $exitstatus
        if [ $exitstatus = 0 ];
        then 
		
	case "$Our_menu_getStationKPI" in
	
			# Options for plant from API
			 1)	# Real-time data for Plant
				getStationRealKpi_entry				
        			;; 	      					
 			 *) 	$DIALOG --title "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
 			 	--backtitle "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
				--msgbox  "Not implemented now" 10 50
				
				getStationKPI_menu
				
		esac	
		
    	elif [ $exitstatus = 1 ]; 
    	then
    		#logout from account
    		logout_from_API
    		
    		$DIALOG --title "List of Power Stations" \
 		--backtitle "Logout from API" \
		--msgbox  "$info_for_dialog_screen" 10 50
    		
    		#clear #clears the terminal screen
		exit
		
	elif [ $exitstatus = 3 ]; 
    	then	
	        #go back to menu of plants
		Plant_list	
	else
    		
    		#clear #clears the terminal screen
    		exit
	fi



}

getStationRealKpi_entry() {

getStationRealKpi ${stations_Code_array[$count]} #our plant code

#call to next function
getStationRealKpi_results

}

getStationRealKpi_results() {

    		$DIALOG --extra-button --extra-label "Save to file" \
    		--title "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
 		--backtitle "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
 		--output-fd 1 \
		--msgbox  "$info_for_dialog_screen ${summary_for_dialog_screen[$count]}\n${results_for_dialog_screen[$count]}" 15 50
		
		exitstatus=$?
        	#echo $exitstatus
        	
        	if [ $exitstatus = 0 ];
       	then 
       		# get back to manu of Plant options
       		getStationKPI_menu
       		
       	elif [ $exitstatus = 3 ];
       	then 
       		
       		#Save as CSV
       		#echo -e "Description;Value;Units" > Realtime_data_plant_"${stations_Code_array[$count]}"_time_of_question_"$curent_time_actually".csv
			#echo -e "${csv[$count]}" >> Realtime_data_plant_"${stations_Code_array[$count]}"_time_of_question_"$curent_time_actually".csv
			
			save_to_file
       		# get back to manu of Plant options
       		#getStationKPI_menu
        	else
    		
    			#clear #clears the terminal screen
    			exit
    		
		fi
}

save_to_file() {

	Our_menu_save_to_file=$($DIALOG  --ok-label "Save" --extra-button --extra-label "Back" --cancel-label "Logout" 		 --title "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
	 --backtitle "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
	 --menu "Choose format?" 15 60 10 \
	 1 "TXT" \
	 2 "CSV" \
	 3 "XML" \
	 4 "JOSN" \
	 --output-fd 1)

	exitstatus=$?
        #echo $exitstatus
        if [ $exitstatus = 0 ];
        then 
		
	case "$Our_menu_save_to_file" in
	
			# Options for save files from API
			 1)	# Real-time data for Plant save
			 	#Save as TXT
			 	echo -e "${results_for_dialog_screen[$count]}" > Realtime_data_plant_"${stations_Code_array[$count]}".txt
			 	
			 	$DIALOG  \
    				--title "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
 				--backtitle "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nRealtime_data_plant_${stations_Code_array[$count]}.txt" 15 50
			 	
			 	getStationRealKpi_results			
        			;; 
			 
			 2)	# Real-time data for Plant save
				#Save as CSV
       			echo -e "Description;Value;Units" > Realtime_data_plant_"${stations_Code_array[$count]}".csv
				echo -e "${csv[$count]}" >> Realtime_data_plant_"${stations_Code_array[$count]}".csv
				
				$DIALOG  \
    				--title "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
 				--backtitle "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nRealtime_data_plant_${stations_Code_array[$count]}.csv" 15 50
				
				getStationRealKpi_results			
        			;; 
				
			 3)	# Real-time data for Plant save
				#Save as XML
			 	echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r<plant>\r" > Realtime_data_plant_"${stations_Code_array[$count]}".xml
				echo -e "${xml[$count]}" >> Realtime_data_plant_"${stations_Code_array[$count]}".xml
				echo -e "</plant>" >> Realtime_data_plant_"${stations_Code_array[$count]}".xml
				
				$DIALOG  \
    				--title "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
 				--backtitle "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nRealtime_data_plant_${stations_Code_array[$count]}.xml" 15 50
				
				getStationRealKpi_results			
        			;; 
        			
        		4)	# Real-time data for Plant save
				#Save as XML
			 	echo -e "{\r	\"plant\": {\r" > Realtime_data_plant_"${stations_Code_array[$count]}".josn
				echo -e "${josn[$count]}" >> Realtime_data_plant_"${stations_Code_array[$count]}".josn
				echo -e "	}\r}" >> Realtime_data_plant_"${stations_Code_array[$count]}".josn
				
				$DIALOG  \
    				--title "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
 				--backtitle "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nRealtime_data_plant_${stations_Code_array[$count]}.josn" 15 50
				
				getStationRealKpi_results			
        			;; 
        				      					
 			 *) 	$DIALOG --title "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
 			 	--backtitle "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
				--msgbox  "Nothing chosen" 10 50
				
				save_to_file
				
		esac	
		
    	elif [ $exitstatus = 1 ]; 
    	then
    		#logout from account
    		logout_from_API
    		
    		$DIALOG --title "List of Power Stations" \
 		--backtitle "Logout from API" \
		--msgbox  "$info_for_dialog_screen" 10 50
    		
    		#clear #clears the terminal screen
		exit
		
	elif [ $exitstatus = 3 ]; 
    	then	
	        #go back to menu of plants
		getStationRealKpi_results	
	else
    		
    		#clear #clears the terminal screen
    		exit
	fi

}

Devices_list() {

getDevList ${stations_Code_array[0]} #$number_of_plants

#call to next function
Devices_list_menu
}

Devices_list_menu() {
# $DIALOG --title "Plant Device's list" \
# 		--backtitle "Plant: ${device_stationCode_array[$count]}" \
#		--msgbox  "${info_for_dialog_screen[$count]}\n${summary_for_dialog_screen[$count]}\n${results_for_dialog_screen[0]}\n${results_for_dialog_screen[1]}" 10 50



	#creation of dynamic menu of devices list
       for (( c=1; c<=${#device_Id_array[@]}; c++ ))
	do 
	devices_number_array_for_dialog[$(( $c-1 ))]=$c	
	devices_list_array_for_dialog[$(( $c-1 ))]=$(echo "$( Device_type_ID ${device_TypeId_array[$(( $c-1 ))]} "no_whitespace" )[${device_Id_array[$(( $c-1 ))]}]" )
	
	devices_number_and_list_array_for_dialog[$(( $c-1 ))]=$(echo ${devices_number_array_for_dialog[$(( $c-1 ))]} ${devices_list_array_for_dialog[$(( $c-1 ))]})
	
	
	
	done	
	
	
	Our_menu_devices_list=$($DIALOG  --ok-label "Browse" --extra-button --extra-label "Back" --cancel-label "Logout" --title "Plant Device's list" \
	 --backtitle "Devices from plant: ${device_stationCode_array[$count]}" \
	 --menu "Plant ${device_stationCode_array[$count]} device's list choose one to see an internal data" 15 50 10 \
	${devices_number_and_list_array_for_dialog[@]} \
	--output-fd 1)
        #3>&1 1>&2 2>&3)
        
        #${devices_number_array_for_dialog[0]} "${devices_list_array_for_dialog[0]}" \
	#${devices_number_array_for_dialog[1]} "${devices_list_array_for_dialog[1]}" \
	
        exitstatus=$?
        #echo $exitstatus
        if [ $exitstatus = 0 ];
        then 
		
	case "$Our_menu_devices_list" in
	
			# Propably there is no account with so many devices like 1000
			 [1-999])	$DIALOG --yes-label "Back" --no-label "Options" --default-button "no" --title "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
				--backtitle "Devices from plant: ${device_stationCode_array[$count]}" \
				--scrolltext \
				--yesno "$info_for_dialog_screen\n${results_for_dialog_screen[$(( $Our_menu_devices_list-1 ))]}" 20 50
				
				exitstatus=$?
				 
				if [ $exitstatus = 0 ];
        			then
        				#go back to menu of devices
					Devices_list_menu
				elif [ $exitstatus = 1 ]; 
				then
					# Menu with devices in plant
					#Devices_list_menu
					#$DIALOG --title "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
 			 		#--backtitle "Devices from plant: ${device_stationCode_array[$count]}" \
					#--msgbox  "Not implemended" 10 50
					if [ $(echo "$( Device_type_ID ${device_TypeId_array[$(( $Our_menu_devices_list-1 ))]} "no_whitespace")" ) == "String_Inverter" ]
					then
					  
						getDeviceKPI_menu ${devices_number_array_for_dialog[$(( $Our_menu_devices_list-1 ))]} ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]} "String_Inverter"
					elif [ $(echo "$( Device_type_ID ${device_TypeId_array[$(( $Our_menu_devices_list-1 ))]} "no_whitespace")" ) = "EMI" ]
					then
					  
						getDeviceKPI_menu ${devices_number_array_for_dialog[$(( $Our_menu_devices_list-1 ))]} ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}
					elif [ $(echo "$( Device_type_ID ${device_TypeId_array[$(( $Our_menu_devices_list-1 ))]} "no_whitespace")" ) = "Grid_meter" ]
					then
					  
						getDeviceKPI_menu ${devices_number_array_for_dialog[$(( $Our_menu_devices_list-1 ))]} ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}
					elif [ $(echo "$( Device_type_ID ${device_TypeId_array[$(( $Our_menu_devices_list-1 ))]} "no_whitespace")" ) = "Residential_inverter" ]
					then
					  
						getDeviceKPI_menu ${devices_number_array_for_dialog[$(( $Our_menu_devices_list-1 ))]} ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}
					elif [ $(echo "$( Device_type_ID ${device_TypeId_array[$(( $Our_menu_devices_list-1 ))]} "no_whitespace")" ) = "Battery" ]
					then
					  
						getDeviceKPI_menu ${devices_number_array_for_dialog[$(( $Our_menu_devices_list-1 ))]} ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}
					elif [ $(echo "$( Device_type_ID ${device_TypeId_array[$(( $Our_menu_devices_list-1 ))]} "no_whitespace")" ) = "Power_Sensor" ]
					then
					  
						getDeviceKPI_menu ${devices_number_array_for_dialog[$(( $Our_menu_devices_list-1 ))]} $(echo "$( Device_type_ID ${device_TypeId_array[$(( $Our_menu_devices_list-1 ))]} "no_whitespace")" )
					else
						$DIALOG --title "Device ${devices_number_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}: ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 			 			--backtitle "Device ${devices_number_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}: ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
						--msgbox  "This device $(echo "$( Device_type_ID ${device_TypeId_array[$(( $Our_menu_devices_list-1 ))]} "no_whitespace")" ) has no any aditionally data" 10 50
						Devices_list_menu
					fi
					
				else
					#echo  $exitstatus
					#clear #clears the terminal screen
					exit
				fi
				
				#					
        			;; 	      					
 			*) 	$DIALOG --title "Plant ${number_plant[$count]}: ${stations_Code_array[$count]}" \
 			 	--backtitle "Devices from plant: ${device_stationCode_array[$count]}" \
				--msgbox  "Nothing Chosen" 10 50
				Devices_list_menu
				
				
		esac	
		
    	elif [ $exitstatus = 1 ]; 
    	then
    		#logout from account
    		logout_from_API
    		
    		$DIALOG --title "List of Power Stations" \
 		--backtitle "Logout from API" \
		--msgbox  "$info_for_dialog_screen" 10 50
    		
    		#clear #clears the terminal screen
		exit
		
	elif [ $exitstatus = 3 ]; 
    	then	
	        #go back to menu of plants
		Plant_list	
	else
    		
    		#clear #clears the terminal screen
    		exit
	fi
}


getDeviceKPI_menu() {

if [ $3 == "String_Inverter" ] || [ $3 = "Residential_inverter" ] || [ $3 = "Battery" ];
then
	Our_menu_getDeviceKPI=$($DIALOG  --ok-label "Browse" --extra-button --extra-label "Back" --cancel-label "Logout" 		 --title "Device $1: $2" \
	 --backtitle "Device $1: $2" \
	 --menu "Which data want to see?" 15 60 10 \
	 1 "REAL-TIME data" \
	 2 "Every HOUR of particular day (not implemented)" \
	 3 "Every DAY of particular month (not implemented)" \
	 4 "Every MONTH of particular year (not implemented)" \
	 5 "Every YEAR of particular century (not implemented)" \
	 --output-fd 1)

	exitstatus=$?
        #echo $exitstatus
        if [ $exitstatus = 0 ];
        then 
		
	case "$Our_menu_getDeviceKPI" in
	
			# Options for device from API
			 1)	# Real-time data for Device				
				getDeviceKPI_entry				
        			;;
        			 	      					
 			 *) 	$DIALOG --title "Device $1: $2" \
 			 	--backtitle "Device $1: $2" \
				--msgbox  "Not implemented now" 10 50
				
				Devices_list
		esac	
		
    	elif [ $exitstatus = 1 ]; 
    	then
    		#logout from account
    		logout_from_API
    		
    		$DIALOG --title "List of Power Stations" \
 		--backtitle "Logout from API" \
		--msgbox  "$info_for_dialog_screen" 10 50
    		
    		#clear #clears the terminal screen
		exit
		
	elif [ $exitstatus = 3 ]; 
    	then	
	         #go back to menu of devices
		Devices_list	
	else
    		
    		#clear #clears the terminal screen
    		exit
	fi 


elif [ $3 == "EMI" ] || [ $3 = "Grid_meter" ] || [ $3 = "Power_Sensor" ];
then
	Our_menu_getDeviceKPI=$($DIALOG  --ok-label "Browse" --extra-button --extra-label "Back" --cancel-label "Logout" 		 --title "Device $1: $2" \
	 --backtitle "Device $1: $2" \
	 --menu "Which data want to see?" 15 60 10 \
	 1 "REAL-TIME data" \
	 2 "Every HOUR of particular day (not implemented)" \
	 --output-fd 1)

	exitstatus=$?
        #echo $exitstatus
        if [ $exitstatus = 0 ];
        then 
		
	case "$Our_menu_getDeviceKPI" in
	
			# Options for device from API
			 1)	# Real-time data for device				
				getDeviceKPI_entry				
        			;; 	
        			      					
 			 *) 	$DIALOG --title "Device $1: $2" \
 			 	--backtitle "Device $1: $2" \
				--msgbox  "Not implemented now" 10 50
				
				Devices_list
				
		esac	
		
    	elif [ $exitstatus = 1 ]; 
    	then
    		#logout from account
    		logout_from_API
    		
    		$DIALOG --title "List of Power Stations" \
 		--backtitle "Logout from API" \
		--msgbox  "$info_for_dialog_screen" 10 50
    		
    		#clear #clears the terminal screen
		exit
		
	elif [ $exitstatus = 3 ]; 
    	then	
	        #go back to menu of devices
		Devices_list	
	else
    		
    		#clear #clears the terminal screen
    		exit
	fi 
fi

}

getDeviceKPI_entry() {

getDevRealKpi ${device_Id_array[$count]} ${device_TypeId_array[$count]} # data device number and deice type question about real-time data from particular device

#call to next function
getDeviceKPI_results

}

getDeviceKPI_results() {


    		$DIALOG --extra-button --extra-label "Save to file" \
    		--title "Device: ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 		--backtitle "Device: ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 		--output-fd 1 \
		--msgbox  "$info_for_dialog_screen ${summary_for_dialog_screen[$count]}\n${results_for_dialog_screen[$count]}" 15 50
		
		exitstatus=$?
        	#echo $exitstatus
        	
        	if [ $exitstatus = 0 ];
       	then 
       		# get back to manu of Plant options
       		Devices_list
       		
       	elif [ $exitstatus = 3 ];
       	then 
       		#save to different files csv/txt/xml/josn		
			save_to_file
        	else
    		
    			#clear #clears the terminal screen
    			exit
    		
		fi

}



# code of program itself


source functions.sh


# checking if file config.conf with login password existing
FILE="config.conf"
 
if [ -f "$FILE" ];
then
   #echo "File $FILE exist."
   source config.conf
else
   #echo "File $FILE does not exist" >&2
   User_name_and_password_filing
   source config.conf
fi

				
if [ ! -z "$userName" ] || [ ! -z "$systemCode" ];	
	then	
		if [ "$userName" == "<--here data-->" ] || [ "$systemCode" == "<--here data-->" ];
		then
		
		login_text="config.conf is existing but has default not valid data inside"
		
		$DIALOG --title "Login to API" --clear \
		--backtitle "Huawei FusionSolarApp API" \
      		--msgbox "$login_text" 10 50
		#--shadow
		#clear #clears the terminal screen
		
		# input of username and password
		User_name_and_password_filing
		
		
		# Function to login to API
		login_to_API $DIALOG
		
		
		
		else
		
		login_text="username and password exists in config.conf\n\n Username:$userName\n Password:$systemCode"
		
		$DIALOG --title "Login to API" --clear \
		--backtitle "Huawei FusionSolarApp API" \
      		--msgbox "$login_text" 10 50
		#--shadow
		#clear #clears the terminal screen	
		
		# Function to login to API
		login_to_API $DIALOG	
			

		

		
		
		fi
else
	
		login_text="config.conf has no username and password data variables \$userName and \$systemCode are deleted/commented"
			$DIALOG --title "Login to API" --clear \
			--backtitle "Huawei FusionSolarApp API" \
      			--msgbox "$login_text" 10 50
			#--shadow
			#clear #clears the terminal screen	
		
fi





if [[ $login_status == true  ]];
then	

# We start function to get list of plants
getStationList $DIALOG

	#$DIALOG --title "Login parameters" --clear \
	#--backtitle "$info_for_dialog_backtitle" \
        #--msgbox  "$info_for_dialog_screen" 10 50
        #--shadow
	#clear #clears the terminal screen


	

Plant_list_menu



        
        #$DIALOG --title "List of Power Stations" \
	#--backtitle "Power plant's related with this account" \
	#--msgbox  "$info_for_dialog_screen" 10 50
        #--shadow
	#clear #clears the terminal screen

# Function to logout from API
#logout_from_API $DIALOG

#	$DIALOG --title "Logout from API" --clear \
#	--backtitle "$info_for_dialog_backtitle" \
#        --msgbox  "$info_for_dialog_screen" 10 50
#        --shadow
#	clear #clears the terminal screen
	
elif [[ $login_status == false ]];
then	

		$DIALOG --title "Login to API" --clear \
		--backtitle "$info_for_dialog_backtitle" \
      		--msgbox "$info_for_dialog_screen" 10 50
		#--shadow
		#clear #clears the terminal screen	
		


		exit
else
	exit
fi




