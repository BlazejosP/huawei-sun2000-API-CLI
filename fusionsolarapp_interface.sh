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
#DIALOG=${DIALOG:=xdialog}
#DIALOG=${DIALOG:=gtkdialog}
#DIALOG=${DIALOG:=gdialog}
#DIALOG=${DIALOG:=yad}
#DIALOG=${DIALOG:=mate-dialog}

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
			
# Here you can write collections of your logins and passwords to your single or if you have multiple accounts on Huawei server. Your own and given to you by someone's else if share with you his/her account access. They must be named like this [login0] [password0] [login1] [password1] etc... until [login99] [password99] is last. Password and login with <--here login--> and <--here password--> are ignored and skiped.
#Here is an example:
# here write your login and password
#declare -A huawei_account_login=(
#[login0]=\"ExampleUser\"
#[password0]=\"Example@Password\"
#[login1]=\"<--here login-->\"
#[password1]=\"<--here password-->\"
#[login2]=\"<--here login-->\"
#[password2]=\"<--here password-->\"
#[login3]=\"<--here login-->\"
#[password3]=\"<--here password-->\"
#[login4]=\"ExampleUser2\"
#[password4]=\"Example@Password2\"
#etc ...
#)

# here write your login and password
declare -A huawei_account_login=(
[login0]=\"$username_temp\"
[password0]=\"$password_temp\"
[login1]=\"<--here login-->\"
[password1]=\"<--here password-->\"
)


# Here paste URL's from Kiosk modes configuration \"Kiosk View Settings\" in FussionSolarApp which is from your plant and also is possible to include other person kioskmode's URL's if they gave you a link. Remember to made this link working is necessary to activate this in Huawei FussionSolarApp web interface! This is array so you can insert here data in the form kiosk_mode_url_array=( [kioskmode0]=\"<--here URL0-->\" [kioskmode1]=\"<--here URL1-->\" [kioskmode2]=\"<--here URL2-->\" etc... until [kioskmode99])  only remeber to give names kioskmode[number] for each link. This with <--here URL--> in link area are ignored and skiped.
#Should looks like this for example:
#declare -A kiosk_mode_url_array=( 
#[kioskmode0]=\"https://eu5.fusionsolar.huawei.com/rest/pvms/web/kiosk/v1/station-kiosk-file?kk=XXXXXXXXXX\" 
#[kioskmode1]=\"https://eu5.fusionsolar.huawei.com/rest/pvms/web/kiosk/v1/station-kiosk-file?kk=bbbbbbbbbb\"
#[kioskmode2]=\"<--here URL-->\"
#[kioskmode3]=\"<--here URL-->\" 
#[kioskmode4]=\"<--here URL-->\" 
#[kioskmode5]=\"https://eu5.fusionsolar.huawei.com/rest/pvms/web/kiosk/v1/station-kiosk-file?kk=cccccccccc\"
#etc...
#)    

declare -A kiosk_mode_url_array=( 
[kioskmode0]=\"<--here URL-->\" 
[kioskmode1]=\"<--here URL-->\" 
) "> config.conf


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
    		
    		$DIALOG --ok-label "List of Login's" --extra-button --extra-label "Exit" --default-button "extra" --title "List of Power Stations" \
 		--backtitle "Logout from API" \
		--msgbox  "$info_for_dialog_screen" 10 50
    		
    		exitstatus=$?
			if [ $exitstatus = 0 ];
        	 	then
        	 		#we chosen List of Login's button
        	 		# go back to menu of accounts and URL's
    				main_function			
        	 	elif [ $exitstatus = 3 ];
        	 	then
        	 		#We chosen extra Exit button
        	 		#clear #clears the terminal screen
				exit 
        	 	else
        	 		#clear #clears the terminal screen
				exit 
        	 	fi
        	  
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
    		
    		$DIALOG --ok-label "List of Login's" --extra-button --extra-label "Exit" --default-button "extra" --title "List of Power Stations" \
 		--backtitle "Logout from API" \
		--msgbox  "$info_for_dialog_screen" 10 50
    		
    		exitstatus=$?
			if [ $exitstatus = 0 ];
        	 	then
        	 		#we chosen List of Login's button
        	 		# go back to menu of accounts and URL's
    				main_function			
        	 	elif [ $exitstatus = 3 ];
        	 	then
        	 		#We chosen extra Exit button
        	 		#clear #clears the terminal screen
				exit 
        	 	else
        	 		#clear #clears the terminal screen
				exit 
        	 	fi		
		
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
    		
    		$DIALOG --ok-label "List of Login's" --extra-button --extra-label "Exit" --default-button "extra" --title "List of Power Stations" \
 		--backtitle "Logout from API" \
		--msgbox  "$info_for_dialog_screen" 10 50
    		
    		exitstatus=$?
			if [ $exitstatus = 0 ];
        	 	then
        	 		#we chosen List of Login's button
        	 		# go back to menu of accounts and URL's
    				main_function			
        	 	elif [ $exitstatus = 3 ];
        	 	then
        	 		#We chosen extra Exit button
        	 		#clear #clears the terminal screen
				exit 
        	 	else
        	 		#clear #clears the terminal screen
				exit 
        	 	fi		
		
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
    		
    		$DIALOG --ok-label "List of Login's" --extra-button --extra-label "Exit" --default-button "extra" --title "Plant Device's list" \
 		--backtitle "Logout from API" \
		--msgbox  "$info_for_dialog_screen" 10 50
    		
    		exitstatus=$?
			if [ $exitstatus = 0 ];
        	 	then
        	 		#we chosen List of Login's button
        	 		# go back to menu of accounts and URL's
    				main_function			
        	 	elif [ $exitstatus = 3 ];
        	 	then
        	 		#We chosen extra Exit button
        	 		#clear #clears the terminal screen
				exit 
        	 	else
        	 		#clear #clears the terminal screen
				exit 
        	 	fi		
		
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

if [ "$3" == "String_Inverter" ] || [ "$3" == "Residential_inverter" ] || [ "$3" == "Battery" ];
then
	Our_menu_getDeviceKPI=$($DIALOG  --ok-label "Browse" --extra-button --extra-label "Back" --cancel-label "Logout" 		 --title "Device $1: $2" \
	 --backtitle "Device $1: $2" \
	 --menu "Which data want to see?" 15 60 10 \
	 1 "REAL-TIME data" \
	 2 "Every HOUR of particular day" \
	 3 "Every DAY of particular month" \
	 4 "Every MONTH of particular year" \
	 5 "Every YEAR of particular century" \
	 --output-fd 1)

	exitstatus=$?
        #echo $exitstatus
        if [ $exitstatus = 0 ];
        then 
		
	case "$Our_menu_getDeviceKPI" in
	
			# Options for device from API
			 1)	# Real-time data from Device				
				getDeviceKPI_entry				
        			;;
			 2)	# Every five minutes data from Device	for particular day			
				getDevFiveMinutes_entry				
        			;;
        		 3)	# Every day data from Device for particular month			
				getDevKpiDay_entry				
        			;;
        		 4)	# Every month data from Device for particular year			
				getDevKpiMonth_entry				
        			;;
        		 5)	# Yearly data from Device for particular year			
				getDevKpiYear_entry				
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
    		
    		$DIALOG --ok-label "List of Login's" --extra-button --extra-label "Exit" --default-button "extra" --title "Plant Device's list" \
 		--backtitle "Logout from API" \
		--msgbox  "$info_for_dialog_screen" 10 50
    		
    		exitstatus=$?
			if [ $exitstatus = 0 ];
        	 	then
        	 		#we chosen List of Login's button
        	 		# go back to menu of accounts and URL's
    				main_function			
        	 	elif [ $exitstatus = 3 ];
        	 	then
        	 		#We chosen extra Exit button
        	 		#clear #clears the terminal screen
				exit 
        	 	else
        	 		#clear #clears the terminal screen
				exit 
        	 	fi
		
	elif [ $exitstatus = 3 ]; 
    	then	
	         #go back to menu of devices
		Devices_list	
	else
    		
    		#clear #clears the terminal screen
    		exit
	fi 


elif [ "$3" == "EMI" ] || [ "$3" == "Grid_meter" ] || [ "$3" == "Power_Sensor" ];
then
	Our_menu_getDeviceKPI=$($DIALOG  --ok-label "Browse" --extra-button --extra-label "Back" --cancel-label "Logout" 		 --title "Device $1: $2" \
	 --backtitle "Device $1: $2" \
	 --menu "Which data want to see?" 15 60 10 \
	 1 "REAL-TIME data" \
	 2 "Every HOUR of particular day" \
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
        		 2)	# Every five minutes data from Device	for particular day			
				getDevFiveMinutes_entry				
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
    		
    		$DIALOG --ok-label "List of Login's" --extra-button --extra-label "Exit" --default-button "extra" --title "Plant Device's list" \
 		--backtitle "Logout from API" \
		--msgbox  "$info_for_dialog_screen" 10 50
    		
    		exitstatus=$?
			if [ $exitstatus = 0 ];
        	 	then
        	 		#we chosen List of Login's button
        	 		# go back to menu of accounts and URL's
    				main_function			
        	 	elif [ $exitstatus = 3 ];
        	 	then
        	 		#We chosen extra Exit button
        	 		#clear #clears the terminal screen
				exit 
        	 	else
        	 		#clear #clears the terminal screen
				exit 
        	 	fi
		
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

getDevFiveMinutes_entry() {

# we shows dialog with Calendar 
choose_date_for_getDevFiveMinutes_entry

# we send inside this function our device ID, type number and Date for day which we d'like to check 
getDevFiveMinutes ${device_Id_array[$count]} ${device_TypeId_array[$count]} $date_choosen_within_dialog # data device number and device type question about every five minutes in specific day data from particular device

#call to next function
getDevFiveMinutes_results


}

choose_date_for_getDevFiveMinutes_entry(){

choose_date_for_getDevFiveMinutes=$($DIALOG --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" --ok-label "Browse" --cancel-label "Back"\
 		--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 		--date-format %s \
		--calendar "Choose day which you do like to check?" 0 0 \
		--output-fd 1)
		
		exitstatus=$?
        	#echo $exitstatus
        	
        	if [ $exitstatus = 0 ];
       	then 
        		# we convert today hours, minutes to secounds because we need actual day+minutes+secounds to compare if user choose future date or not.
        		local actually_hour_secound_format=$(expr $(date +%H) \* 3600)
        		local actually_minutes_secound_format=$(expr $(date +%M) \* 60)
        		local actually_second_secound_format=$(date +%S) 
        		local actually_time_today_hours_minutes_secounds_secound_format=$(expr $actually_hour_secound_format + $actually_minutes_secound_format + $actually_second_secound_format)
        	
        		#here w substract our hours,minutes,secounds to have choosen date in midnight at 00:00:00
        		local choose_date_for_getDevFiveMinutes_with_actually_time_secounds_format=$(expr $choose_date_for_getDevFiveMinutes - $actually_time_today_hours_minutes_secounds_secound_format)
			
			# we add to unix time milisecound to made this compatibile with API which accept unix times in milisecounds format that is why we add "000" to time string
        		local date_choosen_in_dialog=$choose_date_for_getDevFiveMinutes_with_actually_time_secounds_format"000" 
       	
       		if (( date_choosen_in_dialog > $curent_time  ));
       		then
       			$DIALOG --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
 			 	--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
				--msgbox  "Day $(date +"%d %B %Y" -d @$(echo ${choose_date_for_getDevFiveMinutes})) is invalid! You can not choose date from future not alowed on Huawei server." 10 50
				
				#go back to Calendar
				#getDevFiveMinutes_entry
				#go back to menu of devices
				Devices_list_menu 
				
			# we check dat choosen date is from before 01/01/2010 in that case Hauwei devices from Sun2000 were certain not build yet 	
			elif (( date_choosen_in_dialog < 1262304000000  ));
       		then	
				$DIALOG --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
 			 	--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
				--msgbox  "Day $(date +"%d %B %Y" -d @$(echo ${choose_date_for_getDevFiveMinutes})) is invalid! Huawei  ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]} was not even build at that time." 10 50

				#go back to menu of devices
				Devices_list_menu 
				
			else
				# we add to unix time milisecound to made this compatibile with API which accept unix times in milisecounds format that is why we add "000" to time string
				date_choosen_within_dialog=$choose_date_for_getDevFiveMinutes"000"
				
				#we return to getDevFiveMinutes_entry and proceed with getDevFiveMinutes function 
				return	
        		fi
        		
        	elif [ $exitstatus = 1 ]; 
    		then
    			#go back to menu of devices
			Devices_list_menu 
			
    		else
    			#go back to menu of devices
			#Devices_list_menu
			
			#echo $exitstatus
			exit
			
    		fi
		
}

getDevFiveMinutes_results() {

# if day is empty and are no data
if [ ${#results_for_dialog_screen_time[@]} == 0 ];
then

       $DIALOG --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
 	--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
	--msgbox  "There is no data on Huawei server from $(date +"%d %B %Y" -d @$(echo ${date_choosen_within_dialog::-3}))\n\n ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]} was not commisioned at that time / switch off or device were without connection to Internet at that time." 10 50
				
	#go back to Calendar
	getDevFiveMinutes_entry

else

			#creation of dynamic menu of times 5 minutes slots list
       		for (( c=1; c<=${#results_for_dialog_screen_time[@]}; c++ ))
			do 
			
				times_number_array_for_dialog[$(( $c-1 ))]=$c	
				every_5min_times_list_array_for_dialog[$(( $c-1 ))]=$(echo "${results_for_dialog_screen_time[$(( $c-1 ))]}" )
				#final answer with times as a string for dialog
				every_5min_times_number_and_list_array_for_dialog[$(( $c-1 ))]=$(echo ${times_number_array_for_dialog[$(( $c-1 ))]} ${every_5min_times_list_array_for_dialog[$(( $c-1 ))]})
				
				#now answers in form of data for every 5 minutes for dialog
				every_5min_all_the_data_list_array_for_dialog[$(( $c-1 ))]=${results_for_dialog_screen_time[$(( $c-1 ))]}
				
			done
			
			
# copy of 5minutes slot string for dialog windows usage				
local device_type_and_number=${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}			


	
	getDevFiveMinutes_results=$($DIALOG  --ok-label "Browse" --extra-button --extra-label "Back" --cancel-label "Logout" --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
	 --backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
	 --menu "Every 5 minutes from $(date +"%d %B %Y" -d @$(echo ${collectTime_array[0]::-3}))" 16 45 10 \
	${every_5min_times_number_and_list_array_for_dialog[@]} \
	 --output-fd 1)
		
		#${results_for_dialog_screen_5min[*]}
		exitstatus=$?
        	#echo $exitstatus
        	
        	if [ $exitstatus = 0 ];
       	then 
       		# There is 288 5 minutes intervals so inside 24 hours no more is possible for one day
       		case $((   (getDevFiveMinutes_results >= 0 && getDevFiveMinutes_results <= 288)      * 1 +   (getDevFiveMinutes_results > 288)   * 2)) in
	
			
			 	
			(1)	#Preparation of answer long string with all the data for particular 5 minutes slot

				# if we have String inverter
				if [[ $question_is_sucessful == "true"  ]] && [[  $device_type == 1  ]];
				then			
				 	answer_for_dialog_getDevFiveMinutes_results_every_interval=${every_5min_all_the_data_list_array_for_dialog[$(( $getDevFiveMinutes_results-1 ))]}"\n\n"${status_of_inverter_every_5min[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_AB_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_BC_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_CA_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Phase_A_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Phase_B_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Phase_C_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_phase_A_current[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_phase_B_current[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_phase_C_current[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Inverter_conversion_efficiency[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_temperature[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_power_factor[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_elec_freq[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_active_power[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reactive_power[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_day_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_power[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv1[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv2[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv3[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv4[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv5[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv6[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv7[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv8[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv9[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv10[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv11[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv12[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv13[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv14[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv15[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv16[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv17[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv18[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv19[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv20[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv21[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv22[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv23[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv24[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv1_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv2_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv3_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv4_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv5_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv6_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv7_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv8_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv9_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv10_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv11_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv12_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv13_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv14_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv15_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv16_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv17_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv18_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv19_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv20_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv21_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv22_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv23_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv24_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_total_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_open_time[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_close_time[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_total_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_1_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_2_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_3_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_4_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_5_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_6_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_7_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_8_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_9_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_10_cap[$(( $getDevFiveMinutes_results-1 ))]}
				 
				# if we have Residential inverter
				elif [[ $question_is_sucessful == "true"  ]] && [[  $device_type == 38  ]];
				then	
					answer_for_dialog_getDevFiveMinutes_results_every_interval=${every_5min_all_the_data_list_array_for_dialog[$(( $getDevFiveMinutes_results-1 ))]}"\n\n"${status_of_inverter_every_5min[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_AB_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_BC_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_CA_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Phase_A_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Phase_B_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Phase_C_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_phase_A_current[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_phase_B_current[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_phase_C_current[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Inverter_conversion_efficiency[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_temperature[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_power_factor[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_elec_freq[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_active_power[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reactive_power[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_day_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_power[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv1[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv2[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv3[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv4[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv5[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv6[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv7[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv8[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv1_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv2_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv3_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv4_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv5_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv6_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv7_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv8_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_total_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_open_time[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_close_time[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_1_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_2_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_3_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_4_cap[$(( $getDevFiveMinutes_results-1 ))]}
				
				# device is EMI
				elif [[ $question_is_sucessful == "true"  ]] && [[ $device_type == 10  ]];
				then
					answer_for_dialog_getDevFiveMinutes_results_every_interval=${every_5min_all_the_data_list_array_for_dialog[$(( $getDevFiveMinutes_results-1 ))]}"\n\n"${results_for_dialog_screen_time[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_temperature[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_temperature_PV[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_wind_speed[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_wind_direction[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_radiant_total[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_radiant_line[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_horiz_radiant_line[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_horiz_radiant_total[$(( $getDevFiveMinutes_results-1 ))]}
				
				# device is Grid meter
				elif [[ $question_is_sucessful == "true"  ]] && [[ $device_type == 17  ]];
				then
					answer_for_dialog_getDevFiveMinutes_results_every_interval=${every_5min_all_the_data_list_array_for_dialog[$(( $getDevFiveMinutes_results-1 ))]}"\n\n"${results_for_dialog_screen_time[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_AB_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_BC_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_CA_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Phase_A_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Phase_B_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Phase_C_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_phase_A_current[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_phase_B_current[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_phase_C_current[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_active_power[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_power_factor[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_active_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reactive_power[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reverse_active_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_forward_reactive_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reverse_reactive_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_active_power_a[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_active_power_b[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_active_power_c[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reactive_power_a[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reactive_power_b[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reactive_power_c[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_total_apparent_power[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_grid_frequency[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reverse_active_peak_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reverse_active_power_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reverse_active_valley_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reverse_active_top_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_positive_active_peak_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_positive_active_power_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_positive_active_valley_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_positive_active_top_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reverse_reactive_peak_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reverse_reactive_shoulder_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reverse_reactive_valley_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reverse_reactive_top_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_forward_reactive_peak_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_forward_reactive_shoulder_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_forward_reactive_valley_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_forward_reactive_top_array[$(( $getDevFiveMinutes_results-1 ))]}
					
				# device is Power Sensor
				elif [[ $question_is_sucessful == "true"  ]] && [[ $device_type == 48  ]];
				then
					answer_for_dialog_getDevFiveMinutes_results_every_interval=${every_5min_all_the_data_list_array_for_dialog[$(( $getDevFiveMinutes_results-1 ))]}"\n\n"${results_for_dialog_screen_time[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_meter_status[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_meter_u_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_meter_i_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_active_power_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_reactive_power_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_power_factor_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_grid_frequency_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_active_cap_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_reverse_active_cap_array[$(( $getDevFiveMinutes_results-1 ))]}
					
				# device is Battery
				elif [[ $question_is_sucessful == "true"  ]] && [[ $device_type == 39  ]];
				then
					answer_for_dialog_getDevFiveMinutes_results_every_interval=${every_5min_all_the_data_list_array_for_dialog[$(( $getDevFiveMinutes_results-1 ))]}"\n\n"${results_for_dialog_screen_battery_status[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_max_charge_power_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_max_charge_power_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_max_discharge_power_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_ch_discharge_power_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_busbar_u_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_battery_soc_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_battery_soh_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_ch_discharge_model[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_charge_cap_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_discharge_cap_array[$(( $getDevFiveMinutes_results-1 ))]}
					
				else
					answer_for_dialog_getDevFiveMinutes_results_every_interval="unknow device type that may be some error"
				fi
				
			
				#dialog window which presents particular 5 minutes slot
				getDevFiveMinutes_results_every_interval=$($DIALOG --yes-label "OK" --no-label "Save to file" --default-button "yes" --title "Device $device_type_and_number" \
				--backtitle "Device $device_type_and_number" \
				--scrolltext \
				--yesno "$info_for_dialog_screen\n${results_for_dialog_screen[0]}\n$answer_for_dialog_getDevFiveMinutes_results_every_interval" 20 50 \
				--output-fd 1)
				
				exitstatus=$?
				 
				if [ $exitstatus = 0 ];
        			then
        				#go back to menu of devices
					getDevFiveMinutes_results
					
					elif [ $exitstatus = 1 ]; 
					then
						#go back to menu of devices

						#getDevFiveMinutes_results
						save_to_file_for_getDevFiveMinutes
					
				else
					#echo  $exitstatus
					#clear #clears the terminal screen
					exit
				fi					
        			
        			#					
        			;; 
        			
        		(2)	$DIALOG --title "Device $device_type_and_number}"  \
 			 	--backtitle "Device $device_type_and_number"  \
				--msgbox  "24 hours have only 288 5 minutes intervals this is beyond range and may be an error" 10 50
				getDevFiveMinutes_results
				;;	
        	 	      					
 			(*) 	$DIALOG --title "Device $device_type_and_number"  \
 			 	--backtitle "Device $device_type_and_number}"  \
				--msgbox  "Nothing Chosen" 10 50
				getDevFiveMinutes_results
				
				
			esac


       	elif [ $exitstatus = 3 ];
       	then 
       		#empty array because we d'like to have clear one when we again ask about 5 min slots
			results_for_dialog_screen_time=()
			
       		#go back to devices list in power plant		
			Devices_list
    			
    		elif [ $exitstatus = 1 ]; 
    		then
			#logout from account
    			logout_from_API
    		
    			$DIALOG --ok-label "List of Login's" --extra-button --extra-label "Exit" --default-button "extra" --title "Every 5 minutes from $(date +"%d %B %Y" -d @$(echo ${collectTime_array[0]::-3}))" \
 			--backtitle "Logout from API" \
			--msgbox  "$info_for_dialog_screen" 10 50
    		
    			exitstatus=$?
				if [ $exitstatus = 0 ];
        	 		then
        	 			#we chosen List of Login's button
        	 			# go back to menu of accounts and URL's
    					main_function			
        	 		elif [ $exitstatus = 3 ];
        	 		then
        	 			#We chosen extra Exit button
        	 			#clear #clears the terminal screen
					exit 
        	 		else
        	 			#clear #clears the terminal screen
					exit 
        	 		fi
		else
    		
    			#clear #clears the terminal screen
    			exit
		fi

fi

}

save_to_file_for_getDevFiveMinutes() {

	 Our_menu_save_to_file=$($DIALOG  --ok-label "Save" --extra-button --extra-label "Back" --cancel-label "Logout" 		 --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
	 --backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
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
			 1)	# Every 5 minutes  data for Device save
			 
				# times and every value for every 5 minutes list for txt
				
				# if we have String inverter
				if [[ $question_is_sucessful == "true"  ]] && [[  $device_type == 1  ]];
				then	
					answer_for_txt=${every_5min_all_the_data_list_array_for_dialog[$(( $getDevFiveMinutes_results-1 ))]}"\r\n\n"${status_of_inverter_every_5min[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_AB_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_BC_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_CA_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Phase_A_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Phase_B_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Phase_C_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_phase_A_current[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_phase_B_current[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_phase_C_current[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Inverter_conversion_efficiency[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_temperature[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_power_factor[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_elec_freq[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_active_power[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reactive_power[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_day_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_power[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv1[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv2[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv3[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv4[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv5[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv6[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv7[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv8[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv9[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv10[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv11[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv12[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv13[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv14[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv15[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv16[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv17[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv18[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv19[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv20[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv21[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv22[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv23[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv24[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv1_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv2_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv3_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv4_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv5_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv6_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv7_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv8_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv9_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv10_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv11_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv12_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv13_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv14_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv15_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv16_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv17_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv18_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv19_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv20_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv21_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv22_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv23_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv24_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_total_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_open_time[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_close_time[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_total_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_1_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_2_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_3_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_4_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_5_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_6_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_7_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_8_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_9_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_10_cap[$(( $getDevFiveMinutes_results-1 ))]}
				
				# if we have Residential inverter
				elif [[ $question_is_sucessful == "true"  ]] && [[  $device_type == 38  ]];
				then	
					answer_for_txt=${every_5min_all_the_data_list_array_for_dialog[$(( $getDevFiveMinutes_results-1 ))]}"\r\n\n"${status_of_inverter_every_5min[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_AB_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_BC_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_CA_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Phase_A_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Phase_B_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Phase_C_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_phase_A_current[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_phase_B_current[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_phase_C_current[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Inverter_conversion_efficiency[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_temperature[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_power_factor[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_elec_freq[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_active_power[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reactive_power[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_day_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_power[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv1[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv2[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv3[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv4[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv5[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv6[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv7[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv8[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv1_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv2_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv3_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv4_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv5_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv6_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv7_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_pv8_i[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_total_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_open_time[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_close_time[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_1_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_2_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_3_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_mppt_4_cap[$(( $getDevFiveMinutes_results-1 ))]}
				 
				# device is EMI
				elif [[ $question_is_sucessful == "true"  ]] && [[ $device_type == 10  ]];
				then
					 answer_for_txt=${every_5min_all_the_data_list_array_for_dialog[$(( $getDevFiveMinutes_results-1 ))]}"\r\n\n"${results_for_dialog_screen_temperature[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_temperature_PV[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_wind_speed[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_wind_direction[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_radiant_total[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_radiant_line[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_horiz_radiant_line[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_horiz_radiant_total[$(( $getDevFiveMinutes_results-1 ))]} 
					 
				# device is Grid meter
				elif [[ $question_is_sucessful == "true"  ]] && [[ $device_type == 17  ]];
				then
					answer_for_txt=${every_5min_all_the_data_list_array_for_dialog[$(( $getDevFiveMinutes_results-1 ))]}"\r\n\n"${results_for_dialog_screen_Grid_AB_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_BC_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_CA_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Phase_A_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Phase_B_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Phase_C_voltage[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_phase_A_current[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_phase_B_current[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_Grid_phase_C_current[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_active_power[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_power_factor[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_active_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reactive_power[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reverse_active_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_forward_reactive_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reverse_reactive_cap[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_active_power_a[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_active_power_b[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_active_power_c[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reactive_power_a[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reactive_power_b[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reactive_power_c[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_total_apparent_power[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_grid_frequency[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reverse_active_peak_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reverse_active_power_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reverse_active_valley_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reverse_active_top_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_positive_active_peak_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_positive_active_power_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_positive_active_valley_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_positive_active_top_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reverse_reactive_peak_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reverse_reactive_shoulder_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reverse_reactive_valley_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_reverse_reactive_top_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_forward_reactive_peak_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_forward_reactive_shoulder_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_forward_reactive_valley_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_forward_reactive_top_array[$(( $getDevFiveMinutes_results-1 ))]}
					
				# device is Power Sensor
				elif [[ $question_is_sucessful == "true"  ]] && [[ $device_type == 48  ]];
				then
					answer_for_txt=${every_5min_all_the_data_list_array_for_dialog[$(( $getDevFiveMinutes_results-1 ))]}"\r\n\n"${results_for_dialog_screen_meter_status[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_meter_u_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_meter_i_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_active_power_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_reactive_power_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_power_factor_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_grid_frequency_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_active_cap_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_reverse_active_cap_array[$(( $getDevFiveMinutes_results-1 ))]}
					
				# device is Battery
				elif [[ $question_is_sucessful == "true"  ]] && [[ $device_type == 39  ]];
				then
					answer_for_txt=${every_5min_all_the_data_list_array_for_dialog[$(( $getDevFiveMinutes_results-1 ))]}"\r\n\n"${results_for_dialog_screen_battery_status[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_max_charge_power_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_max_charge_power_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_max_discharge_power_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_ch_discharge_power_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_busbar_u_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_battery_soc_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_battery_soh_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_ch_discharge_model[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_charge_cap_array[$(( $getDevFiveMinutes_results-1 ))]}${results_for_dialog_screen_discharge_cap_array[$(( $getDevFiveMinutes_results-1 ))]}
									 
				else
				 answer_for_txt="unknow device type that may be some error"
				fi
							 
			 	#Save as TXT
			 	echo -e "${results_for_dialog_screen[0]}$answer_for_txt" > every_5_minutes_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}".txt
			 	

				
				#save to file finaly data from one 5 minutes slot
				#echo -e "$answer_for_txt" >> every_5_minutes_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}".txt
			 	
			 	$DIALOG  \
    				--title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
 				--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nevery_5_minutes_data_device_${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" 15 50
			 	
			 	getDevFiveMinutes_results
        			;; 
			 
			 2)	# Every 5 minutes data for Device save
			 
			 	# times and every value for every 5 minutes list for csv
			 					
				# if we have String inverter
				if [[ $question_is_sucessful == "true"  ]] && [[  $device_type == 1  ]];
				then	
					answer_for_csv=${csv_times[$(( $getDevFiveMinutes_results-1 ))]}${csv_status_of_inverter[$(( $getDevFiveMinutes_results-1 ))]}${csv_ab_u[$(( $getDevFiveMinutes_results-1 ))]}${csv_bc_u[$(( $getDevFiveMinutes_results-1 ))]}${csv_ca_u[$(( $getDevFiveMinutes_results-1 ))]}${csv_a_u[$(( $getDevFiveMinutes_results-1 ))]}${csv_b_u[$(( $getDevFiveMinutes_results-1 ))]}${csv_c_u[$(( $getDevFiveMinutes_results-1 ))]}${csv_a_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_b_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_c_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_efficiency[$(( $getDevFiveMinutes_results-1 ))]}${csv_temperature[$(( $getDevFiveMinutes_results-1 ))]}${csv_power_factor[$(( $getDevFiveMinutes_results-1 ))]}${csv_elec_freq[$(( $getDevFiveMinutes_results-1 ))]}${csv_active_power[$(( $getDevFiveMinutes_results-1 ))]}${csv_reactive_power[$(( $getDevFiveMinutes_results-1 ))]}${csv_day_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_mppt_power[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv1[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv2[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv3[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv4[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv5[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv6[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv7[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv8[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv9[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv10[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv11[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv12[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv13[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv14[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv15[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv16[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv17[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv18[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv19[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv20[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv21[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv22[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv23[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv24[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv1_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv2_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv3_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv4_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv5_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv6_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv7_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv8_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv9_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv10_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv11_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv12_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv13_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv14_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv15_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv16_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv17_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv18_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv19_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv20_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv21_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv22_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv23_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv24_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_total_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_open_time[$(( $getDevFiveMinutes_results-1 ))]}${csv_close_time[$(( $getDevFiveMinutes_results-1 ))]}${csv_mppt_total_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_mppt_1_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_mppt_2_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_mppt_3_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_mppt_4_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_mppt_5_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_mppt_6_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_mppt_7_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_mppt_8_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_mppt_9_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_mppt_10_cap[$(( $getDevFiveMinutes_results-1 ))]}
			 
			 	# if we have Residential inverter
				elif [[ $question_is_sucessful == "true"  ]] && [[  $device_type == 38  ]];
				then	
					answer_for_csv=${csv_times[$(( $getDevFiveMinutes_results-1 ))]}${csv_status_of_inverter[$(( $getDevFiveMinutes_results-1 ))]}${csv_ab_u[$(( $getDevFiveMinutes_results-1 ))]}${csv_bc_u[$(( $getDevFiveMinutes_results-1 ))]}${csv_ca_u[$(( $getDevFiveMinutes_results-1 ))]}${csv_a_u[$(( $getDevFiveMinutes_results-1 ))]}${csv_b_u[$(( $getDevFiveMinutes_results-1 ))]}${csv_c_u[$(( $getDevFiveMinutes_results-1 ))]}${csv_a_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_b_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_c_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_efficiency[$(( $getDevFiveMinutes_results-1 ))]}${csv_temperature[$(( $getDevFiveMinutes_results-1 ))]}${csv_power_factor[$(( $getDevFiveMinutes_results-1 ))]}${csv_elec_freq[$(( $getDevFiveMinutes_results-1 ))]}${csv_active_power[$(( $getDevFiveMinutes_results-1 ))]}${csv_reactive_power[$(( $getDevFiveMinutes_results-1 ))]}${csv_day_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_mppt_power[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv1[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv2[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv3[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv4[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv5[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv6[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv7[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv8[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv1_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv2_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv3_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv4_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv5_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv6_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv7_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_pv8_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_total_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_open_time[$(( $getDevFiveMinutes_results-1 ))]}${csv_close_time[$(( $getDevFiveMinutes_results-1 ))]}${csv_mppt_1_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_mppt_2_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_mppt_3_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_mppt_4_cap[$(( $getDevFiveMinutes_results-1 ))]}
				
				# device is EMI
				elif [[ $question_is_sucessful == "true"  ]] && [[ $device_type == 10  ]];
				then
					answer_for_csv=${csv_times[$(( $getDevFiveMinutes_results-1 ))]}${csv_temperature[$(( $getDevFiveMinutes_results-1 ))]}${csv_temperature_PV[$(( $getDevFiveMinutes_results-1 ))]}${csv_wind_speed[$(( $getDevFiveMinutes_results-1 ))]}${csv_wind_direction[$(( $getDevFiveMinutes_results-1 ))]}${csv_radiant_total[$(( $getDevFiveMinutes_results-1 ))]}${csv_radiant_line[$(( $getDevFiveMinutes_results-1 ))]}${csv_horiz_radiant_line[$(( $getDevFiveMinutes_results-1 ))]}${csv_horiz_radiant_total[$(( $getDevFiveMinutes_results-1 ))]}

				# device is Grid meter
				elif [[ $question_is_sucessful == "true"  ]] && [[ $device_type == 17  ]];
				then
					answer_for_csv=${csv_times[$(( $getDevFiveMinutes_results-1 ))]}${csv_ab_u[$(( $getDevFiveMinutes_results-1 ))]}${csv_bc_u[$(( $getDevFiveMinutes_results-1 ))]}${csv_ca_u[$(( $getDevFiveMinutes_results-1 ))]}${csv_a_u[$(( $getDevFiveMinutes_results-1 ))]}${csv_b_u[$(( $getDevFiveMinutes_results-1 ))]}${csv_c_u[$(( $getDevFiveMinutes_results-1 ))]}${csv_a_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_b_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_c_i[$(( $getDevFiveMinutes_results-1 ))]}${csv_active_power[$(( $getDevFiveMinutes_results-1 ))]}${csv_power_factor[$(( $getDevFiveMinutes_results-1 ))]}${csv_active_power[$(( $getDevFiveMinutes_results-1 ))]}${csv_reactive_power[$(( $getDevFiveMinutes_results-1 ))]}${csv_reverse_active_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_forward_reactive_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_reverse_reactive_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_reverse_reactive_cap[$(( $getDevFiveMinutes_results-1 ))]}${csv_active_power_a[$(( $getDevFiveMinutes_results-1 ))]}${csv_active_power_b[$(( $getDevFiveMinutes_results-1 ))]}${csv_active_power_c[$(( $getDevFiveMinutes_results-1 ))]}${csv_total_apparent_power[$(( $getDevFiveMinutes_results-1 ))]}${csv_grid_frequency[$(( $getDevFiveMinutes_results-1 ))]}${csv_reverse_active_peak_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_reverse_active_power_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_reverse_active_valley_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_reverse_active_top_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_positive_active_peak_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_positive_active_power_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_positive_active_valley_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_positive_active_top_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_reverse_reactive_peak_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_reverse_reactive_shoulder_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_reverse_reactive_valley_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_reverse_reactive_top_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_forward_reactive_peak_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_forward_reactive_shoulder_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_forward_reactive_valley_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_forward_reactive_top_array[$(( $getDevFiveMinutes_results-1 ))]}
				
				# device is Power Sensor
				elif [[ $question_is_sucessful == "true"  ]] && [[ $device_type == 48  ]];
				then
					answer_for_csv=${csv_times[$(( $getDevFiveMinutes_results-1 ))]}${csv_meter_status[$(( $getDevFiveMinutes_results-1 ))]}${csv_meter_u_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_meter_i_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_active_power_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_reactive_power_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_power_factor_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_grid_frequency_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_active_cap_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_reverse_active_cap_array[$(( $getDevFiveMinutes_results-1 ))]}
					
				# device is Battery
				elif [[ $question_is_sucessful == "true"  ]] && [[ $device_type == 39  ]];
				then
					answer_for_csv=${csv_times[$(( $getDevFiveMinutes_results-1 ))]}${csv_battery_status[$(( $getDevFiveMinutes_results-1 ))]}${csv_max_charge_power_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_max_discharge_power_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_ch_discharge_power_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_busbar_u_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_battery_soc_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_battery_soh_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_ch_discharge_model[$(( $getDevFiveMinutes_results-1 ))]}${csv_charge_cap_array[$(( $getDevFiveMinutes_results-1 ))]}${csv_discharge_cap_array[$(( $getDevFiveMinutes_results-1 ))]}
									 
				else
				 answer_for_csv="unknow device type that may be some error"
				fi	
				
				#Save as CSV
       			echo -e "Description;Value;Units${csv[0]}$answer_for_csv" > every_5_minutes_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}".csv
				#echo -e "${csv[0]}" >> every_5_minutes_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}".csv
				

				
				#save to file finaly data from one 5 minutes slot
				#echo -e "$answer_for_csv" >> every_5_minutes_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}".csv
				
				$DIALOG  \
    				--title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 				--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nevery_5_minutes_data_device_${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}.csv" 15 50
				
				getDevFiveMinutes_results			
        			;; 
				
			 3)	# Every 5 minutes data for Device save
			 
			 	# times and every value for every 5 minutes list for xml
			 	
				# if we have String inverter
				if [[ $question_is_sucessful == "true"  ]] && [[  $device_type == 1  ]];
				then	
					answer_for_xml=${xml_times[$(( $getDevFiveMinutes_results-1 ))]}${xml_status_of_inverter[$(( $getDevFiveMinutes_results-1 ))]}${xml_ab_u[$(( $getDevFiveMinutes_results-1 ))]}${xml_bc_u[$(( $getDevFiveMinutes_results-1 ))]}${xml_ca_u[$(( $getDevFiveMinutes_results-1 ))]}${xml_a_u[$(( $getDevFiveMinutes_results-1 ))]}${xml_b_u[$(( $getDevFiveMinutes_results-1 ))]}${xml_c_u[$(( $getDevFiveMinutes_results-1 ))]}${xml_a_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_b_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_c_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_efficiency[$(( $getDevFiveMinutes_results-1 ))]}${xml_temperature[$(( $getDevFiveMinutes_results-1 ))]}${xml_power_factor[$(( $getDevFiveMinutes_results-1 ))]}${xml_elec_freq[$(( $getDevFiveMinutes_results-1 ))]}${xml_active_power[$(( $getDevFiveMinutes_results-1 ))]}${xml_reactive_power[$(( $getDevFiveMinutes_results-1 ))]}${xml_day_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_mppt_power[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv1[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv2[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv3[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv4[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv5[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv6[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv7[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv8[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv9[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv10[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv11[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv12[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv13[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv14[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv15[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv16[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv17[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv18[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv19[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv20[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv21[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv22[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv23[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv24[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv1_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv2_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv3_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv4_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv5_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv6_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv7_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv8_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv9_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv10_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv11_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv12_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv13_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv14_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv15_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv16_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv17_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv18_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv19_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv20_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv21_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv22_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv23_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv24_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_total_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_open_time[$(( $getDevFiveMinutes_results-1 ))]}${xml_close_time[$(( $getDevFiveMinutes_results-1 ))]}${xml_mppt_total_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_mppt_1_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_mppt_2_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_mppt_3_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_mppt_4_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_mppt_5_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_mppt_6_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_mppt_7_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_mppt_8_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_mppt_9_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_mppt_10_cap[$(( $getDevFiveMinutes_results-1 ))]}
			 
			 	# if we have Residential inverter
				elif [[ $question_is_sucessful == "true"  ]] && [[  $device_type == 38  ]];
				then	
					answer_for_xml=${xml_times[$(( $getDevFiveMinutes_results-1 ))]}${xml_status_of_inverter[$(( $getDevFiveMinutes_results-1 ))]}${xml_ab_u[$(( $getDevFiveMinutes_results-1 ))]}${xml_bc_u[$(( $getDevFiveMinutes_results-1 ))]}${xml_ca_u[$(( $getDevFiveMinutes_results-1 ))]}${xml_a_u[$(( $getDevFiveMinutes_results-1 ))]}${xml_b_u[$(( $getDevFiveMinutes_results-1 ))]}${xml_c_u[$(( $getDevFiveMinutes_results-1 ))]}${xml_a_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_b_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_c_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_efficiency[$(( $getDevFiveMinutes_results-1 ))]}${xml_temperature[$(( $getDevFiveMinutes_results-1 ))]}${xml_power_factor[$(( $getDevFiveMinutes_results-1 ))]}${xml_elec_freq[$(( $getDevFiveMinutes_results-1 ))]}${xml_active_power[$(( $getDevFiveMinutes_results-1 ))]}${xml_reactive_power[$(( $getDevFiveMinutes_results-1 ))]}${xml_day_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_mppt_power[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv1[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv2[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv3[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv4[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv5[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv6[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv7[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv8[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv1_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv2_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv3_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv4_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv5_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv6_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv7_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_pv8_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_total_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_open_time[$(( $getDevFiveMinutes_results-1 ))]}${xml_close_time[$(( $getDevFiveMinutes_results-1 ))]}${xml_mppt_1_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_mppt_2_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_mppt_3_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_mppt_4_cap[$(( $getDevFiveMinutes_results-1 ))]}
				
				# device is EMI
				elif [[ $question_is_sucessful == "true"  ]] && [[ $device_type == 10  ]];
				then
					answer_for_xml=${xml_times[$(( $getDevFiveMinutes_results-1 ))]}${xml_temperature[$(( $getDevFiveMinutes_results-1 ))]}${xml_temperature_PV[$(( $getDevFiveMinutes_results-1 ))]}${xml_wind_speed[$(( $getDevFiveMinutes_results-1 ))]}${xml_wind_direction[$(( $getDevFiveMinutes_results-1 ))]}${xml_radiant_total[$(( $getDevFiveMinutes_results-1 ))]}${xml_radiant_line[$(( $getDevFiveMinutes_results-1 ))]}${xml_horiz_radiant_line[$(( $getDevFiveMinutes_results-1 ))]}${xml_horiz_radiant_total[$(( $getDevFiveMinutes_results-1 ))]}

				# device is Grid meter
				elif [[ $question_is_sucessful == "true"  ]] && [[ $device_type == 17  ]];
				then
					answer_for_xml=${xml_times[$(( $getDevFiveMinutes_results-1 ))]}${xml_ab_u[$(( $getDevFiveMinutes_results-1 ))]}${xml_bc_u[$(( $getDevFiveMinutes_results-1 ))]}${xml_ca_u[$(( $getDevFiveMinutes_results-1 ))]}${xml_a_u[$(( $getDevFiveMinutes_results-1 ))]}${xml_b_u[$(( $getDevFiveMinutes_results-1 ))]}${xml_c_u[$(( $getDevFiveMinutes_results-1 ))]}${xml_a_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_b_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_c_i[$(( $getDevFiveMinutes_results-1 ))]}${xml_active_power[$(( $getDevFiveMinutes_results-1 ))]}${xml_power_factor[$(( $getDevFiveMinutes_results-1 ))]}${xml_active_power[$(( $getDevFiveMinutes_results-1 ))]}${xml_reactive_power[$(( $getDevFiveMinutes_results-1 ))]}${xml_reverse_active_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_forward_reactive_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_reverse_reactive_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_reverse_reactive_cap[$(( $getDevFiveMinutes_results-1 ))]}${xml_active_power_a[$(( $getDevFiveMinutes_results-1 ))]}${xml_active_power_b[$(( $getDevFiveMinutes_results-1 ))]}${xml_active_power_c[$(( $getDevFiveMinutes_results-1 ))]}${xml_total_apparent_power[$(( $getDevFiveMinutes_results-1 ))]}${xml_grid_frequency[$(( $getDevFiveMinutes_results-1 ))]}${xml_reverse_active_peak_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_reverse_active_power_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_reverse_active_valley_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_reverse_active_top_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_positive_active_peak_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_positive_active_power_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_positive_active_valley_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_positive_active_top_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_reverse_reactive_peak_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_reverse_reactive_shoulder_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_reverse_reactive_valley_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_reverse_reactive_top_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_forward_reactive_peak_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_forward_reactive_shoulder_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_forward_reactive_valley_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_forward_reactive_top_array[$(( $getDevFiveMinutes_results-1 ))]}
				
				# device is Power Sensor
				elif [[ $question_is_sucessful == "true"  ]] && [[ $device_type == 48  ]];
				then
					answer_for_xml=${xml_times[$(( $getDevFiveMinutes_results-1 ))]}${xml_meter_status[$(( $getDevFiveMinutes_results-1 ))]}${xml_meter_u_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_meter_i_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_active_power_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_reactive_power_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_power_factor_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_grid_frequency_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_active_cap_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_reverse_active_cap_array[$(( $getDevFiveMinutes_results-1 ))]}
					
				# device is Battery
				elif [[ $question_is_sucessful == "true"  ]] && [[ $device_type == 39  ]];
				then
					answer_for_xml=${xml_times[$(( $getDevFiveMinutes_results-1 ))]}${xml_battery_status[$(( $getDevFiveMinutes_results-1 ))]}${xml_max_charge_power_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_max_discharge_power_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_ch_discharge_power_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_busbar_u_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_battery_soc_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_battery_soh_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_ch_discharge_model[$(( $getDevFiveMinutes_results-1 ))]}${xml_charge_cap_array[$(( $getDevFiveMinutes_results-1 ))]}${xml_discharge_cap_array[$(( $getDevFiveMinutes_results-1 ))]}
									 
				else
				 answer_for_xml="unknow device type that may be some error"
				fi	
			
				#Save as XML
			 	echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r<device>\r${xml[0]}$answer_for_xml</device>" > every_5_minutes_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}".xml
			 	
				
				$DIALOG  \
    				--title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 				--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nevery_5_minutes_data_device_${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}.xml" 15 50
				
				getDevFiveMinutes_results			
        			;; 
        			
        		4)	# Every 5 minutes data for Device save
        		
        			# times and every value for every 5 minutes list for josn
				# if we have String inverter
				if [[ $question_is_sucessful == "true"  ]] && [[  $device_type == 1  ]];
				then	
					answer_for_josn=${josn_times[$(( $getDevFiveMinutes_results-1 ))]}${josn_status_of_inverter[$(( $getDevFiveMinutes_results-1 ))]}${josn_ab_u[$(( $getDevFiveMinutes_results-1 ))]}${josn_bc_u[$(( $getDevFiveMinutes_results-1 ))]}${josn_ca_u[$(( $getDevFiveMinutes_results-1 ))]}${josn_a_u[$(( $getDevFiveMinutes_results-1 ))]}${josn_b_u[$(( $getDevFiveMinutes_results-1 ))]}${josn_c_u[$(( $getDevFiveMinutes_results-1 ))]}${josn_a_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_b_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_c_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_efficiency[$(( $getDevFiveMinutes_results-1 ))]}${josn_temperature[$(( $getDevFiveMinutes_results-1 ))]}${josn_power_factor[$(( $getDevFiveMinutes_results-1 ))]}${josn_elec_freq[$(( $getDevFiveMinutes_results-1 ))]}${josn_active_power[$(( $getDevFiveMinutes_results-1 ))]}${josn_reactive_power[$(( $getDevFiveMinutes_results-1 ))]}${josn_day_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_mppt_power[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv1[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv2[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv3[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv4[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv5[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv6[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv7[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv8[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv9[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv10[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv11[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv12[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv13[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv14[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv15[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv16[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv17[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv18[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv19[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv20[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv21[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv22[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv23[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv24[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv1_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv2_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv3_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv4_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv5_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv6_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv7_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv8_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv9_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv10_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv11_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv12_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv13_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv14_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv15_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv16_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv17_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv18_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv19_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv20_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv21_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv22_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv23_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv24_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_total_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_open_time[$(( $getDevFiveMinutes_results-1 ))]}${josn_close_time[$(( $getDevFiveMinutes_results-1 ))]}${josn_mppt_total_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_mppt_1_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_mppt_2_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_mppt_3_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_mppt_4_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_mppt_5_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_mppt_6_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_mppt_7_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_mppt_8_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_mppt_9_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_mppt_10_cap[$(( $getDevFiveMinutes_results-1 ))]}
			 
			 	# if we have Residential inverter
				elif [[ $question_is_sucessful == "true"  ]] && [[  $device_type == 38  ]];
				then	
					answer_for_josn=${josn_times[$(( $getDevFiveMinutes_results-1 ))]}${josn_status_of_inverter[$(( $getDevFiveMinutes_results-1 ))]}${josn_ab_u[$(( $getDevFiveMinutes_results-1 ))]}${josn_bc_u[$(( $getDevFiveMinutes_results-1 ))]}${josn_ca_u[$(( $getDevFiveMinutes_results-1 ))]}${josn_a_u[$(( $getDevFiveMinutes_results-1 ))]}${josn_b_u[$(( $getDevFiveMinutes_results-1 ))]}${josn_c_u[$(( $getDevFiveMinutes_results-1 ))]}${josn_a_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_b_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_c_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_efficiency[$(( $getDevFiveMinutes_results-1 ))]}${josn_temperature[$(( $getDevFiveMinutes_results-1 ))]}${josn_power_factor[$(( $getDevFiveMinutes_results-1 ))]}${josn_elec_freq[$(( $getDevFiveMinutes_results-1 ))]}${josn_active_power[$(( $getDevFiveMinutes_results-1 ))]}${josn_reactive_power[$(( $getDevFiveMinutes_results-1 ))]}${josn_day_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_mppt_power[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv1[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv2[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv3[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv4[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv5[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv6[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv7[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv8[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv1_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv2_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv3_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv4_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv5_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv6_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv7_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_pv8_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_total_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_open_time[$(( $getDevFiveMinutes_results-1 ))]}${josn_close_time[$(( $getDevFiveMinutes_results-1 ))]}${josn_mppt_1_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_mppt_2_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_mppt_3_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_mppt_4_cap[$(( $getDevFiveMinutes_results-1 ))]}
				
				# device is EMI
				elif [[ $question_is_sucessful == "true"  ]] && [[ $device_type == 10  ]];
				then
					answer_for_josn=${josn_times[$(( $getDevFiveMinutes_results-1 ))]}${josn_temperature[$(( $getDevFiveMinutes_results-1 ))]}${josn_temperature_PV[$(( $getDevFiveMinutes_results-1 ))]}${josn_wind_speed[$(( $getDevFiveMinutes_results-1 ))]}${josn_wind_direction[$(( $getDevFiveMinutes_results-1 ))]}${josn_radiant_total[$(( $getDevFiveMinutes_results-1 ))]}${josn_radiant_line[$(( $getDevFiveMinutes_results-1 ))]}${josn_horiz_radiant_line[$(( $getDevFiveMinutes_results-1 ))]}${josn_horiz_radiant_total[$(( $getDevFiveMinutes_results-1 ))]}

				# device is Grid meter
				elif [[ $question_is_sucessful == "true"  ]] && [[ $device_type == 17  ]];
				then
					answer_for_josn=${josn_times[$(( $getDevFiveMinutes_results-1 ))]}${josn_ab_u[$(( $getDevFiveMinutes_results-1 ))]}${josn_bc_u[$(( $getDevFiveMinutes_results-1 ))]}${josn_ca_u[$(( $getDevFiveMinutes_results-1 ))]}${josn_a_u[$(( $getDevFiveMinutes_results-1 ))]}${josn_b_u[$(( $getDevFiveMinutes_results-1 ))]}${josn_c_u[$(( $getDevFiveMinutes_results-1 ))]}${josn_a_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_b_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_c_i[$(( $getDevFiveMinutes_results-1 ))]}${josn_active_power[$(( $getDevFiveMinutes_results-1 ))]}${josn_power_factor[$(( $getDevFiveMinutes_results-1 ))]}${josn_active_power[$(( $getDevFiveMinutes_results-1 ))]}${josn_reactive_power[$(( $getDevFiveMinutes_results-1 ))]}${josn_reverse_active_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_forward_reactive_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_reverse_reactive_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_reverse_reactive_cap[$(( $getDevFiveMinutes_results-1 ))]}${josn_active_power_a[$(( $getDevFiveMinutes_results-1 ))]}${josn_active_power_b[$(( $getDevFiveMinutes_results-1 ))]}${josn_active_power_c[$(( $getDevFiveMinutes_results-1 ))]}${josn_total_apparent_power[$(( $getDevFiveMinutes_results-1 ))]}${josn_grid_frequency[$(( $getDevFiveMinutes_results-1 ))]}${josn_reverse_active_peak_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_reverse_active_power_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_reverse_active_valley_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_reverse_active_top_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_positive_active_peak_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_positive_active_power_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_positive_active_valley_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_positive_active_top_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_reverse_reactive_peak_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_reverse_reactive_shoulder_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_reverse_reactive_valley_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_reverse_reactive_top_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_forward_reactive_peak_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_forward_reactive_shoulder_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_forward_reactive_valley_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_forward_reactive_top_array[$(( $getDevFiveMinutes_results-1 ))]}
				
				# device is Power Sensor
				elif [[ $question_is_sucessful == "true"  ]] && [[ $device_type == 48  ]];
				then
					answer_for_josn=${josn_times[$(( $getDevFiveMinutes_results-1 ))]}${josn_meter_status[$(( $getDevFiveMinutes_results-1 ))]}${josn_meter_u_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_meter_i_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_active_power_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_reactive_power_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_power_factor_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_grid_frequency_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_active_cap_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_reverse_active_cap_array[$(( $getDevFiveMinutes_results-1 ))]}
					
				# device is Battery
				elif [[ $question_is_sucessful == "true"  ]] && [[ $device_type == 39  ]];
				then
					answer_for_josn=${josn_times[$(( $getDevFiveMinutes_results-1 ))]}${josn_battery_status[$(( $getDevFiveMinutes_results-1 ))]}${josn_max_charge_power_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_max_discharge_power_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_ch_discharge_power_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_busbar_u_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_battery_soc_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_battery_soh_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_ch_discharge_model[$(( $getDevFiveMinutes_results-1 ))]}${josn_charge_cap_array[$(( $getDevFiveMinutes_results-1 ))]}${josn_discharge_cap_array[$(( $getDevFiveMinutes_results-1 ))]}
									 
				else
				 answer_for_josn="unknow device type that may be some error"
				fi	
				
				#Save as JOSN
			 	echo -e "{\r	\"device\": {\r${josn[0]}$answer_for_josn	}\r}" > every_5_minutes_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}".josn
				
				$DIALOG  \
    				--title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}}" \
 				--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}}" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nRealtime_data_plant_${stations_Code_array[$count]}.josn" 15 50
				
				getDevFiveMinutes_results			
        			;; 
        				      					
 			 *) 	$DIALOG --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 			 	--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
				--msgbox  "Nothing chosen" 10 50
				
				save_to_file_for_getDevFiveMinutes
				
		esac	
		
    	elif [ $exitstatus = 1 ]; 
    	then	
		#logout from account
    		logout_from_API
    		
    		$DIALOG --ok-label "List of Login's" --extra-button --extra-label "Exit" --default-button "extra" --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 		--backtitle "Logout from API" \
		--msgbox  "$info_for_dialog_screen" 10 50
    		
    			exitstatus=$?
				if [ $exitstatus = 0 ];
        	 		then
        	 			#we chosen List of Login's button
        	 			# go back to menu of accounts and URL's
    					main_function			
        	 		elif [ $exitstatus = 3 ];
        	 		then
        	 			#We chosen extra Exit button
        	 			#clear #clears the terminal screen
					exit 
        	 		else
        	 			#clear #clears the terminal screen
					exit 
        	 		fi
		
	elif [ $exitstatus = 3 ]; 
    	then	
	        #go back to menu of every 5minutes slots
		getDevFiveMinutes_results	
	else
    		
    		#clear #clears the terminal screen
    		exit
	fi

}

getDevKpiDay_entry() {

# we shows dialog with Calendar 
choose_date_for_getDevKpiDay_entry

# testing dates which comes back from function choose_date_for_getDevKpiDay_entry
#local date_choosen_within_dialog2=$(echo ${date_choosen_within_dialog::-3})
#echo $date_choosen_within_dialog2
#echo $(date +"%d %B %Y" -d @$(echo ${date_choosen_within_dialog2}))
#echo $(date +"%H %M %S  -  %d %B %Y" -d @$(echo ${date_choosen_within_dialog2}))

# we send inside this function our device ID, type number and Date for month which we d'like to check 
getDevKpiDay ${device_Id_array[$count]} ${device_TypeId_array[$count]} $date_choosen_within_dialog # data device number and device type question about every day in specific month data from particular device

#call to next function to shows results in TUI interface
getDevKpiDay_results


}

choose_date_for_getDevKpiDay_entry(){

choose_date_for_getDevKpiDay=$($DIALOG --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" --ok-label "Browse" --cancel-label "Back"\
 		--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 		--date-format %s \
		--calendar "Choose month which you do like to check?" 0 0 \
		--output-fd 1)
		
		exitstatus=$?
        	#echo $exitstatus
        	
        	if [ $exitstatus = 0 ];
       	then 
        		
        		# here we multiply choosen days by day in secounds in one day 86400s and take out one day thanks for that whatever day we choose inide month we always have 01 of the month day.
        		local actually_day_secound_format=$(expr $(date +"%d" -d@$( echo ${choose_date_for_getDevKpiDay})) \* 86400 - 86400)  
        		local actually_time_today_hours_minutes_secounds_secound_format=$actually_day_secound_format
        		
        		#here w substract our hours,minutes,secounds to have choosen date in midnight at 00:00:00
        		local choose_date_for_getDevKpiDay_with_actually_time_secounds_format=$(expr $choose_date_for_getDevKpiDay - $actually_time_today_hours_minutes_secounds_secound_format)
			
			# we add to unix time milisecound to made this compatibile with API which accept unix times in milisecounds format that is why we add "000" to time string
        		local date_choosen_in_dialog=$choose_date_for_getDevKpiDay_with_actually_time_secounds_format"000" 
       	
       		if (( date_choosen_in_dialog > $curent_time  ));
       		then
       			$DIALOG --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
 			 	--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
				--msgbox  "Month $(date +"%B %Y" -d @$(echo ${choose_date_for_getDevKpiDay})) is invalid! You can not choose date from future not alowed on Huawei server." 10 50
				
				#go back to Calendar
				#getDevFiveMinutes_entry
				#go back to menu of devices
				Devices_list_menu 
				
			# we check dat choosen date is from before 01/01/2010 in that case Hauwei devices from Sun2000 were certain not build yet 	
			elif (( date_choosen_in_dialog < 1262304000000  ));
       		then	
				$DIALOG --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
 			 	--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
				--msgbox  "Month $(date +"%B %Y" -d @$(echo ${choose_date_for_getDevKpiDay})) is invalid! Huawei  ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]} was not even build at that time." 10 50

				#go back to menu of devices
				Devices_list_menu 
				
			else
				# we add to unix time milisecound to made this compatibile with API which accept unix times in milisecounds format that is why we add "000" to time string
				date_choosen_within_dialog=$choose_date_for_getDevKpiDay_with_actually_time_secounds_format"000"
				# testing what we sending outside function
				#echo $date_choosen_within_dialog
				
				#we return to getDevKpiDay_entry and proceed with getDevKpiDay function 
				return	
        		fi
        		
        	elif [ $exitstatus = 1 ]; 
    		then
    			#go back to menu of devices
			Devices_list_menu 
			
    		else
    			#go back to menu of devices
			#Devices_list_menu
			
			#echo $exitstatus
			exit
			
    		fi
		
}

getDevKpiDay_results() {

# if month is empty and are no data
if [[ "$month_is_valid_filed_with_data" == false ]];
then

       $DIALOG --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
 	--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
	--msgbox  "There is no data on Huawei server from $(date +"%B %Y" -d @$(echo ${date_choosen_within_dialog::-3}))\n\n ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]} was not commisioned at that time / switch off or device were without connection to Internet at that time." 10 50
				
	#go back to Calendar
	getDevKpiDay_entry

else

    		$DIALOG --extra-button --extra-label "Save to file" \
    		--title "Device: ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 		--backtitle "Device: ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 		--output-fd 1 \
		--msgbox  "$info_for_dialog_screen ${summary_for_dialog_screen[$count]}\n${results_for_dialog_screen[$count]}" 15 50
		
		exitstatus=$?
        	#echo $exitstatus
        	
        	if [ $exitstatus = 0 ];
       	then 
       		# get back to manu of Devices list
       		Devices_list
       		
       	elif [ $exitstatus = 3 ];
       	then 
       		#save to different files csv/txt/xml/josn		
			getDevKpiDay_save_to_file
        	else
    		
    			#clear #clears the terminal screen
    			exit
    			  		
		fi

fi
		
}

getDevKpiDay_save_to_file() {

	Our_menu_save_to_file=$($DIALOG  --ok-label "Save" --extra-button --extra-label "Back" --cancel-label "Logout" --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
	 --backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
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
			 1)	# getDevKpiDay data for device save
			 	#Save as TXT
			 	echo -e "${results_for_dialog_screen[$count]}" > Every_day_inside_"$(date +"%B_%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${stations_Code_array[$count]}".txt
			 	
			 	$DIALOG  \
	 			--title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
				--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nEvery_day_inside_"$(date +"%B_%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_${stations_Code_array[$count]}.txt" 15 50
			 	
			 	getDevKpiDay_results			
        			;; 
			 
			 2)	# getDevKpiDay data for device save
				#Save as CSV
       			echo -e "Description;Value;Units" > Every_day_inside_"$(date +"%B_%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${stations_Code_array[$count]}".csv
				echo -e "${csv[$count]}" >> Every_day_inside_"$(date +"%B_%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${stations_Code_array[$count]}".csv
				
				$DIALOG  \
	 			--title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
				--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nEvery_day_inside_"$(date +"%B_%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_${stations_Code_array[$count]}.csv" 15 50
				
				getDevKpiDay_results			
        			;; 
				
			 3)	# getDevKpiDay data for Plant save
				#Save as XML
			 	echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r<Device>\r" > Every_day_inside_"$(date +"%B_%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${stations_Code_array[$count]}".xml
				echo -e "${xml[$count]}" >> Every_day_inside_"$(date +"%B_%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${stations_Code_array[$count]}".xml
				echo -e "</Device>" >> Every_day_inside_"$(date +"%B_%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${stations_Code_array[$count]}".xml
				
				$DIALOG  \
	 			--title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
				--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nEvery_day_inside_"$(date +"%B_%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_${stations_Code_array[$count]}.xml" 15 50
				
				getDevKpiDay_results			
        			;; 
        			
        		4)	# getDevKpiDaydata for Plant save
				#Save as XML
			 	echo -e "{\r	\"Device\": {\r" > Every_day_inside_"$(date +"%B_%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${stations_Code_array[$count]}".josn
				echo -e "${josn[$count]}" >> Every_day_inside_"$(date +"%B_%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${stations_Code_array[$count]}".josn
				echo -e "	}\r}" >> Every_day_inside_"$(date +"%B_%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${stations_Code_array[$count]}".josn
				
				$DIALOG  \
	 			--title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
	 			--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nEvery_day_inside_"$(date +"%B_%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_${stations_Code_array[$count]}.josn" 15 50
				
				getDevKpiDay_results			
        			;; 
        				      					
 			 *) 	$DIALOG  --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
	 			--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
				--msgbox  "Nothing chosen" 10 50
				
				getDevKpiDay_save_to_file
				
		esac	
		
    	elif [ $exitstatus = 1 ]; 
    	then		
		#logout from account
    		logout_from_API
    		
    		$DIALOG --ok-label "List of Login's" --extra-button --extra-label "Exit" --default-button "extra" --title "List of Power Stations" \
 		--backtitle "Logout from API" \
		--msgbox  "$info_for_dialog_screen" 10 50
    		
    		exitstatus=$?
			if [ $exitstatus = 0 ];
        	 	then
        	 		#we chosen List of Login's button
        	 		# go back to menu of accounts and URL's
    				main_function			
        	 	elif [ $exitstatus = 3 ];
        	 	then
        	 		#We chosen extra Exit button
        	 		#clear #clears the terminal screen
				exit 
        	 	else
        	 		#clear #clears the terminal screen
				exit 
        	 	fi		
		
	elif [ $exitstatus = 3 ]; 
    	then	
	        #go back to menu of Devices
		Devices_list	
	else
    		
    		#clear #clears the terminal screen
    		exit
	fi

}

getDevKpiMonth_entry() {

# we shows dialog with Calendar 
choose_date_for_getDevKpiMonth_entry

# testing dates which comes back from function choose_date_for_getDevKpiDay_entry
#local date_choosen_within_dialog2=$(echo ${date_choosen_within_dialog::-3})
#echo $date_choosen_within_dialog2
#echo $(date +"%d %B %Y" -d @$(echo ${date_choosen_within_dialog2}))
#echo $(date +"%H %M %S  -  %d %B %Y" -d @$(echo ${date_choosen_within_dialog2}))

# we send inside this function our device ID, type number and Date for year which we d'like to check 
getDevKpiMonth ${device_Id_array[$count]} ${device_TypeId_array[$count]} $date_choosen_within_dialog 
# data device number and device type question about every day in specific month data from particular device

#call to next function to shows results in TUI interface
getDevKpiMonth_results

}

choose_date_for_getDevKpiMonth_entry(){

choose_date_for_getDevKpiMonth=$($DIALOG --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" --ok-label "Browse" --cancel-label "Back"\
 		--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 		--date-format %s \
		--calendar "Choose year which you do like to check?" 0 0 \
		--output-fd 1)
		
		exitstatus=$?
        	#echo $exitstatus
        	
        	if [ $exitstatus = 0 ];
       	then 
        		
        		# here we multiply choosen days by day in secounds in one day 86400s and take out one day thanks for that whatever day we choose inide month we always have 01 of the month day.
        		local actually_day_secound_format=$(expr $(date +"%j" -d@$( echo ${choose_date_for_getDevKpiMonth})) \* 86400 - 86400)  
        		local actually_time_today_hours_minutes_secounds_secound_format=$actually_day_secound_format
        		
        		#here w substract our hours,minutes,secounds to have choosen date in midnight at 00:00:00
        		local choose_date_for_getDevKpiMonth_with_actually_time_secounds_format=$(expr $choose_date_for_getDevKpiMonth - $actually_time_today_hours_minutes_secounds_secound_format)
			
			# we add to unix time milisecound to made this compatibile with API which accept unix times in milisecounds format that is why we add "000" to time string
        		local date_choosen_in_dialog=$choose_date_for_getDevKpiMonth_with_actually_time_secounds_format"000" 
       	
       		if (( date_choosen_in_dialog > $curent_time  ));
       		then
       			$DIALOG --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
 			 	--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
				--msgbox  "Year $(date +"%Y" -d @$(echo ${choose_date_for_getDevKpiMonth})) is invalid! You can not choose date from future not alowed on Huawei server." 10 50
				
				#go back to Calendar
				#getDevFiveMinutes_entry
				#go back to menu of devices
				Devices_list_menu 
				
			# we check dat choosen date is from before 01/01/2010 in that case Hauwei devices from Sun2000 were certain not build yet 	
			elif (( date_choosen_in_dialog < 1262304000000  ));
       		then	
				$DIALOG --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
 			 	--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
				--msgbox  "Year $(date +"%Y" -d @$(echo ${choose_date_for_getDevKpiMonth})) is invalid! Huawei  ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]} was not even build at that time." 10 50

				#go back to menu of devices
				Devices_list_menu 
				
			else
				# we add to unix time milisecound to made this compatibile with API which accept unix times in milisecounds format that is why we add "000" to time string
			date_choosen_within_dialog=$choose_date_for_getDevKpiMonth_with_actually_time_secounds_format"000"
				# testing what we sending outside function
				#echo $date_choosen_within_dialog
				
				#we return to getDevKpiDay_entry and proceed with getDevKpiDay function 
				return	
        		fi
        		
        	elif [ $exitstatus = 1 ]; 
    		then
    			#go back to menu of devices
			Devices_list_menu 
			
    		else
    			#go back to menu of devices
			#Devices_list_menu
			
			#echo $exitstatus
			exit
			
    		fi
		
}


getDevKpiMonth_results() {

# if month is empty and are no data
if [[ "$year_is_valid_filed_with_data" == false ]];
then

       $DIALOG --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
 	--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
	--msgbox  "There is no data on Huawei server from $(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))\n\n ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]} was not commisioned at that time / switch off or device were without connection to Internet at that time." 10 50
				
	#go back to Calendar
	getDevKpiMonth_entry

else

    		$DIALOG --extra-button --extra-label "Save to file" \
    		--title "Device: ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 		--backtitle "Device: ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 		--output-fd 1 \
		--msgbox  "$info_for_dialog_screen ${summary_for_dialog_screen[$count]}\n${results_for_dialog_screen[$count]}" 15 50
		
		exitstatus=$?
        	#echo $exitstatus
        	
        	if [ $exitstatus = 0 ];
       	then 
       		# get back to manu of Devices list
       		Devices_list
       		
       	elif [ $exitstatus = 3 ];
       	then 
       		#save to different files csv/txt/xml/josn		
			getDevKpiMonth_save_to_file
			#exit
        	else
    		
    			#clear #clears the terminal screen
    			exit
    			  		
		fi

fi
		
}

getDevKpiMonth_save_to_file() {

	Our_menu_save_to_file=$($DIALOG  --ok-label "Save" --extra-button --extra-label "Back" --cancel-label "Logout" --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
	 --backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
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
			 1)	# getDevKpiMonth data for device save
			 	#Save as TXT
			 	echo -e "${results_for_dialog_screen[$count]}" > Every_month_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"_from_plant_"${stations_Code_array[$count]}".txt
			 	
			 	$DIALOG  \
	 			--title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
				--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nEvery_month_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}_from_plant_${stations_Code_array[$count]}.txt" 15 50
			 	
			 	getDevKpiMonth_results			
        			;; 
			 
			 2)	# getDevKpiMonth data for device save
				#Save as CSV
       			echo -e "Description;Value;Units" > Every_month_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"_from_plant_"${stations_Code_array[$count]}".csv
				echo -e "${csv[$count]}" >> Every_month_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"_from_plant_"${stations_Code_array[$count]}".csv
				
				$DIALOG  \
	 			--title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
				--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nEvery_month_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}_from_plant_${stations_Code_array[$count]}.csv" 15 50
				
				getDevKpiMonth_results			
        			;; 
				
			 3)	# getDevKpiMonth data for device save
				#Save as XML
			 	echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r<Device>\r" > Every_month_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"_from_plant_"${stations_Code_array[$count]}".xml
				echo -e "${xml[$count]}" >> Every_month_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"_from_plant_"${stations_Code_array[$count]}".xml
				echo -e "</Device>" >> Every_month_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"_from_plant_"${stations_Code_array[$count]}".xml
				
				$DIALOG  \
	 			--title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
				--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nEvery_month_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}_from_plant_${stations_Code_array[$count]}.xml" 15 50
				
				getDevKpiMonth_results			
        			;; 
        			
        		4)	# getDevKpiMonth data for device save
				#Save as XML
			 	echo -e "{\r	\"Device\": {\r" > Every_month_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"_from_plant_"${stations_Code_array[$count]}".josn
				echo -e "${josn[$count]}" >> Every_month_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"_from_plant_"${stations_Code_array[$count]}".josn
				echo -e "	}\r}" >> Every_month_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"_from_plant_"${stations_Code_array[$count]}".josn
				
				$DIALOG  \
	 			--title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
	 			--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nEvery_month_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}_from_plant_${stations_Code_array[$count]}}.josn" 15 50
				
				getDevKpiMonth_results			
        			;; 
        				      					
 			 *) 	$DIALOG  --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
	 			--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
				--msgbox  "Nothing chosen" 10 50
				
				getDevKpiMonth_save_to_file
				
		esac	
		
    	elif [ $exitstatus = 1 ]; 
    	then		
		#logout from account
    		logout_from_API
    		
    		$DIALOG --ok-label "List of Login's" --extra-button --extra-label "Exit" --default-button "extra" --title "List of Power Stations" \
 		--backtitle "Logout from API" \
		--msgbox  "$info_for_dialog_screen" 10 50
    		
    		exitstatus=$?
			if [ $exitstatus = 0 ];
        	 	then
        	 		#we chosen List of Login's button
        	 		# go back to menu of accounts and URL's
    				main_function			
        	 	elif [ $exitstatus = 3 ];
        	 	then
        	 		#We chosen extra Exit button
        	 		#clear #clears the terminal screen
				exit 
        	 	else
        	 		#clear #clears the terminal screen
				exit 
        	 	fi		
		
	elif [ $exitstatus = 3 ]; 
    	then	
	        #go back to menu of Devices
		Devices_list	
	else
    		
    		#clear #clears the terminal screen
    		exit
	fi

}

getDevKpiYear_entry() {

# we shows dialog with Calendar 
choose_date_for_getDevKpiYear_entry

# testing dates which comes back from function choose_date_for_getDevKpiDay_entry
#local date_choosen_within_dialog2=$(echo ${date_choosen_within_dialog::-3})
#echo $date_choosen_within_dialog2
#echo $(date +"%d %B %Y" -d @$(echo ${date_choosen_within_dialog2}))
#echo $(date +"%H %M %S  -  %d %B %Y" -d @$(echo ${date_choosen_within_dialog2}))

# we send inside this function our device ID, type number and Date for year which we d'like to check 
getDevKpiYear ${device_Id_array[$count]} ${device_TypeId_array[$count]} $date_choosen_within_dialog #$curent_time 
#year2021=${results_for_dialog_screen[0]}

#getDevKpiYear ${device_Id_array[$count]} ${device_TypeId_array[$count]} $(expr $curent_time - 31622399000)
#year2020=${results_for_dialog_screen[0]}
# data device number and device type question about every day in specific month data from particular device

#call to next function to shows results in TUI interface
getDevKpiYear_results
#echo $(date +"%Y" -d @${curent_time::-3})
#exit

}

choose_date_for_getDevKpiYear_entry(){

choose_date_for_getDevKpiYear=$($DIALOG --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" --ok-label "Browse" --cancel-label "Back"\
 		--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 		--date-format %s \
		--calendar "Choose year which you do like to check?" 0 0 \
		--output-fd 1)
		
		exitstatus=$?
        	#echo $exitstatus
        	
        	if [ $exitstatus = 0 ];
       	then 
        		
        		# here we multiply choosen days by day in secounds in one day 86400s and take out one day thanks for that whatever day we choose inide month we always have 01 of the month day.
        		local actually_day_secound_format=$(expr $(date +"%j" -d@$( echo ${choose_date_for_getDevKpiYear})) \* 86400 - 86400)  
        		local actually_time_today_hours_minutes_secounds_secound_format=$actually_day_secound_format
        		
        		#here w substract our hours,minutes,secounds to have choosen date in midnight at 00:00:00
        		local choose_date_for_getDevKpiYear_with_actually_time_secounds_format=$(expr $choose_date_for_getDevKpiYear - $actually_time_today_hours_minutes_secounds_secound_format)
			
			# we add to unix time milisecound to made this compatibile with API which accept unix times in milisecounds format that is why we add "000" to time string
        		local date_choosen_in_dialog=$choose_date_for_getDevKpiYear_with_actually_time_secounds_format"000" 
       	
       		if (( date_choosen_in_dialog > $curent_time  ));
       		then
       			$DIALOG --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
 			 	--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
				--msgbox  "Year $(date +"%Y" -d @$(echo ${choose_date_for_getDevKpiYear})) is invalid! You can not choose date from future not alowed on Huawei server." 10 50
				
				#go back to Calendar
				#getDevFiveMinutes_entry
				#go back to menu of devices
				Devices_list_menu 
				
			# we check date choosen. Date is from before 01/01/2010 in that case Hauwei devices from Sun2000 were certain not even build yet 	
			elif (( date_choosen_in_dialog < 1262304000000  ));
       		then	
				$DIALOG --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
 			 	--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
				--msgbox  "Year $(date +"%Y" -d @$(echo ${choose_date_for_getDevKpiYear})) is invalid! Huawei  ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]} was not even build at that time." 10 50

				#go back to menu of devices
				Devices_list_menu 
				
			else
				# we add to unix time milisecound to made this compatibile with API which accept unix times in milisecounds format that is why we add "000" to time string
			date_choosen_within_dialog=$choose_date_for_getDevKpiYear_with_actually_time_secounds_format"000"
				# testing what we sending outside function
				#echo $date_choosen_within_dialog
				
				#we return to getDevKpiDay_entry and proceed with getDevKpiDay function 
				return	
        		fi
        		
        	elif [ $exitstatus = 1 ]; 
    		then
    			#go back to menu of devices
			Devices_list_menu 
			
    		else
    			#go back to menu of devices
			#Devices_list_menu
			
			#echo $exitstatus
			exit
			
    		fi
		
}

getDevKpiYear_results() {

# if month is empty and are no data
if [[ "$epoch_is_valid_filed_with_data" == false ]];
then

       $DIALOG --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
 	--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"  \
	--msgbox  "There is no data on Huawei server from $(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))\n\n ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]} was not commisioned at that time / switch off or device were without connection to Internet at that time." 10 50
				
	#go back to Calendar
	getDevKpiYear_entry

else

    		$DIALOG --extra-button --extra-label "Save to file" \
    		--title "Device: ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 		--backtitle "Device: ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 		--output-fd 1 \
		--msgbox  "$info_for_dialog_screen ${summary_for_dialog_screen[$count]}\n${results_for_dialog_screen[$count]}" 15 50
		
		exitstatus=$?
        	#echo $exitstatus
        	
        	if [ $exitstatus = 0 ];
       	then 
       		# get back to manu of Devices list
       		Devices_list
       		
       	elif [ $exitstatus = 3 ];
       	then 
       		#save to different files csv/txt/xml/josn		
			getDevKpiYear_save_to_file
			#exit
        	else
    		
    			#clear #clears the terminal screen
    			exit
    			  		
		fi

fi
		
}

getDevKpiYear_save_to_file() {

	Our_menu_save_to_file=$($DIALOG  --ok-label "Save" --extra-button --extra-label "Back" --cancel-label "Logout" --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
	 --backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
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
			 1)	# getDevKpiYear data for device save
			 	#Save as TXT	
			 	echo -e "${results_for_dialog_screen[$count]}" > Years_starting_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"_from_plant_"${stations_Code_array[$count]}".txt
			 	
			 	$DIALOG  \
	 			--title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
				--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nYears_starting_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}_from_plant_${stations_Code_array[$count]}.txt" 15 50
			 	
			 	getDevKpiYear_results			
        			;; 
			 
			 2)	# getDevKpiYear data for device save
				#Save as CSV
       			echo -e "Description;Value;Units" > Years_starting_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"_from_plant_"${stations_Code_array[$count]}".csv
				echo -e "${csv[$count]}" >> Years_starting_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"_from_plant_"${stations_Code_array[$count]}".csv
				
				$DIALOG  \
	 			--title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
				--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nYears_starting_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}_from_plant_${stations_Code_array[$count]}.csv" 15 50
				
				getDevKpiYear_results			
        			;; 
				
			 3)	# getDevKpiYear data for device save
				#Save as XML
			 	echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r<Device>\r" > Years_starting_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"_from_plant_"${stations_Code_array[$count]}".xml
				echo -e "${xml[$count]}" >> Years_starting_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"_from_plant_"${stations_Code_array[$count]}".xml
				echo -e "</Device>" >> Years_starting_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"_from_plant_"${stations_Code_array[$count]}".xml
				
				$DIALOG  \
	 			--title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
				--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nYears_starting_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}_from_plant_${stations_Code_array[$count]}.xml" 15 50
				
				getDevKpiYear_results			
        			;; 
        			
        		4)	# getDevKpiYear data for device save
				#Save as josn
			 	echo -e "{\r	\"Device\": {\r" > Years_starting_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"_from_plant_"${stations_Code_array[$count]}".josn
				echo -e "${josn[$count]}" >> Years_starting_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"_from_plant_"${stations_Code_array[$count]}".josn
				echo -e "	}\r}" >> Years_starting_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_"${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}"_from_plant_"${stations_Code_array[$count]}".josn
				
				$DIALOG  \
	 			--title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
	 			--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nYears_starting_from_"$(date +"%Y" -d @$(echo ${date_choosen_within_dialog::-3}))"_data_device_${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}_from_plant_${stations_Code_array[$count]}.josn" 15 50
				
				getDevKpiYear_results			
        			;; 
        				      					
 			 *) 	$DIALOG  --title "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
	 			--backtitle "Device ${devices_list_array_for_dialog[$(( $Our_menu_devices_list-1 ))]}" \
				--msgbox  "Nothing chosen" 10 50
				
				getDevKpiYear_save_to_file
				
		esac	
		
    	elif [ $exitstatus = 1 ]; 
    	then		
		#logout from account
    		logout_from_API
    		
    		$DIALOG --ok-label "List of Login's" --extra-button --extra-label "Exit" --default-button "extra" --title "List of Power Stations" \
 		--backtitle "Logout from API" \
		--msgbox  "$info_for_dialog_screen" 10 50
    		
    		exitstatus=$?
			if [ $exitstatus = 0 ];
        	 	then
        	 		#we chosen List of Login's button
        	 		# go back to menu of accounts and URL's
    				main_function			
        	 	elif [ $exitstatus = 3 ];
        	 	then
        	 		#We chosen extra Exit button
        	 		#clear #clears the terminal screen
				exit 
        	 	else
        	 		#clear #clears the terminal screen
				exit 
        	 	fi		
		
	elif [ $exitstatus = 3 ]; 
    	then	
	        #go back to menu of Devices
		Devices_list	
	else
    		
    		#clear #clears the terminal screen
    		exit
	fi

}



kioskmode_entry() {

#here we call to function kioskmode from functions.sh
kioskmode "$1"

#call to next function which is responsible for presentation of results in dialog window 
kioskmode_results $number_digital_kioskmode

}

kioskmode_results() {

if [[ $Kiosk_mode_connection == true ]];
then
    		$DIALOG --extra-button --extra-label "Save to file" \
    		--title "Plant kioskmode: $1" \
 		--backtitle "Plant kioskmode: $1" \
 		--output-fd 1 \
		--msgbox  "$info_for_dialog_screen ${summary_for_dialog_screen[$count]}\n${results_for_dialog_screen[$count]}" 15 50
		
elif [[ $Kiosk_mode_connection == false ]];
then

    		$DIALOG  \
    		--title "Plant kioskmode: $1" \
 		--backtitle "Plant kioskmode: $1" \
 		--output-fd 1 \
		--msgbox  "$info_for_dialog_screen ${summary_for_dialog_screen[$count]}\n${results_for_dialog_screen[$count]}" 15 50
		
else

   		$DIALOG  \
    		--title "Plant kioskmode: $1" \
 		--backtitle "Plant kioskmode: $1" \
 		--output-fd 1 \
		--msgbox  "Some Error there is no information that question to kioskmode is sucessful or not" 15 50

fi
		
		exitstatus=$?
        	#echo $exitstatus
        	
        	if [ $exitstatus = 0 ];
       	then 
       		#go back to main menu of accounts and URL's
       		accounts_and_kioskmode_urls_list_menu
       		
       	elif [ $exitstatus = 3 ];
       	then 
       
			#save results to txt,csv,xml,josn
			save_to_file_for_kioskmode

        	else
    		
    			#clear #clears the terminal screen
    			exit
    		
		fi
}

save_to_file_for_kioskmode() {

	Our_menu_save_to_file=$($DIALOG  --ok-label "Save" --cancel-label "Exit" --extra-button --extra-label "Back" \
 	 --title "Plant kioskmode: $number_digital_kioskmode" \
	 --backtitle "Plant kioskmode: $number_digital_kioskmode" \
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
			 1)	# kioskmode data for Plant save
			 	#Save as TXT
			 	echo -e "${results_for_dialog_screen[$count]}" > Kioskmode_data_plant_"$number_digital_kioskmode".txt
			 	
			 	$DIALOG  \
    				--title "Plant kioskmode: $number_digital_kioskmode" \
 				--backtitle "Plant kioskmode: $number_digital_kioskmode" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nKioskmode_data_plant_$number_digital_kioskmode.txt" 15 50
			 	
			 	save_to_file_for_kioskmode		
        			;; 
			 
			 2)	# kioskmode data for Plant save
				#Save as CSV
       			echo -e "Description;Value;Units" > Kioskmode_data_plant_"$number_digital_kioskmode".csv
				echo -e "${csv[$count]}" >> Kioskmode_data_plant_"$number_digital_kioskmode".csv
				
				$DIALOG  \
    				--title "Plant kioskmode: $number_digital_kioskmode" \
 				--backtitle "Plant kioskmode: $number_digital_kioskmode" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nKioskmode_data_plant_$number_digital_kioskmode.csv" 15 50
				
				save_to_file_for_kioskmode			
        			;; 
				
			 3)	# kioskmode data for Plant save
				#Save as XML
			 	echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r<plant>\r" > Kioskmode_data_plant_"$number_digital_kioskmode".xml
				echo -e "${xml[$count]}" >> Kioskmode_data_plant_"$number_digital_kioskmode".xml
				echo -e "</plant>" >> Kioskmode_data_plant_"$number_digital_kioskmode".xml
				
				$DIALOG  \
    				--title "Plant kioskmode: $number_digital_kioskmode}" \
 				--backtitle "Plant kioskmode: $number_digital_kioskmode" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nKioskmode_data_plant_$number_digital_kioskmode.xml" 15 50
				
				save_to_file_for_kioskmode		
        			;; 
        			
        		4)	# kioskmode data for Plant save
				#Save as JOSN
			 	echo -e "{\r	\"plant\": {\r" > Kioskmode_data_plant_"$number_digital_kioskmode".josn
				echo -e "${josn[$count]}" >> Kioskmode_data_plant_"$number_digital_kioskmode".josn
				echo -e "	}\r}" >> Kioskmode_data_plant_"$number_digital_kioskmode".josn
				
				$DIALOG  \
    				--title "Plant kioskmode: $number_digital_kioskmode" \
 				--backtitle "Plant kioskmode: $number_digital_kioskmode" \
 				--output-fd 1 \
				--msgbox  "Data saved in file \nKioskmode_data_plant_$number_digital_kioskmode.josn" 15 50
				
				save_to_file_for_kioskmode			
        			;; 
        				      					
 			 *) 	$DIALOG --title "Plant kioskmode: $number_digital_kioskmode" \
 			 	--backtitle "Plant kioskmode: $number_digital_kioskmode" \
				--msgbox  "Nothing chosen" 10 50
				
				save_to_file_for_kioskmode
				
		esac	
		
	elif [ $exitstatus = 3 ]; 
    	then	
	        #go back to kioskmode results
		kioskmode_results $number_digital_kioskmode	
		
	elif [ $exitstatus = 1 ]; 
    	then	

		
		$DIALOG --ok-label "List of Login's" --extra-button --extra-label "Exit" --default-button "extra" --title "Kioskmode save to file" \
 		--backtitle "Kioskmode save to file" \
		--msgbox  "Would you like to exit or go back to list of logins and passwords?" 10 50
    		
    		exitstatus=$?
			if [ $exitstatus = 0 ];
        	 	then
        	 		#we chosen List of Login's button
        	 		# go back to menu of accounts and URL's
    				main_function			
        	 	elif [ $exitstatus = 3 ];
        	 	then
        	 		#We chosen extra Exit button
        	 		#clear #clears the terminal screen
				exit 
        	 	else
        	 		#clear #clears the terminal screen
				exit 
        	 	fi
        	  
		
	else
    		
    		#clear #clears the terminal screen
    		exit
	fi

}


accounts_and_kioskmode_urls_list_menu() {

# checking how many logins&passwords existing in config.conf and number of URL's for kioskmode

#number of postions login+pasword in array
#echo $((${#huawei_account_login[@]}/2))




for (( number_of_logins=0; number_of_logins<=((${#huawei_account_login[@]}/2-1)); number_of_logins++ )); do

	if [ ! "${huawei_account_login[login$number_of_logins]}" == "<--here login-->" ] && [ ! "${huawei_account_login[password$number_of_logins]}" == "<--here password-->" ];
	then

		#checking if username&password imported from config.conf contains space character and correcting this removing spaces in memory
		if [[ ${huawei_account_login[login$number_of_logins]} == *" "* ]] || [[ ${huawei_account_login[password$number_of_logins]} == *" "* ]];
		then
			#correcting username
			huawei_account_login[login$number_of_logins]="$(echo "${huawei_account_login[login$number_of_logins]}" | tr -d '[:space:]')"
			#correcting password
			huawei_account_login[password$number_of_logins]="$(echo "${huawei_account_login[password$number_of_logins]}" | tr -d '[:space:]')"	
		fi
	
		#If there  inside login&password is no space character
		local number_of_particular_valid_logins[$number_of_logins]=$number_of_logins
		local accounts_for_dialog[$number_of_logins]=${huawei_account_login[login$number_of_logins]}
		#echo "Login:"${huawei_account_login[login$number_of_logins]}
		#echo "Password:"${huawei_account_login[password$number_of_logins]}
		#echo ""
		
	else
		#local number_of_particular_valid_logins[$number_of_logins]=null
		local number_of_particular_valid_logins[$number_of_logins]=$( expr $number_of_logins + 200 )
		local accounts_for_dialog[$number_of_logins]=null
	fi	
	
	if [ ! "${number_of_particular_valid_logins[$number_of_logins]}" == null ] && [ ! "${accounts_for_dialog[$number_of_logins]}" == null ] ;
	then
	#dialog for logins counts all aviable correct logins for menu
	local login_positions_ready_for_dialog[$number_of_logins]=$(echo "${number_of_particular_valid_logins[$number_of_logins]}" "${accounts_for_dialog[$number_of_logins]}"); 
	
	elif [ "${accounts_for_dialog[$number_of_logins]}" == null ];
	then
	local login_positions_ready_for_dialog[$number_of_logins]=$(echo "${number_of_particular_valid_logins[$number_of_logins]}" "Login&Password_unactive"); 
	
	fi	
done



for (( number_of_links_from_kioskmode=0; number_of_links_from_kioskmode<=((${#kiosk_mode_url_array[@]}-1)); number_of_links_from_kioskmode++ )); do

	if [ ! "${kiosk_mode_url_array[kioskmode$number_of_links_from_kioskmode]}" == "<--here URL-->" ];
	then
		#checking if URL's imported from config.conf contains space character and correcting this removing spaces in memory
		if [[ ${kiosk_mode_url_array[kioskmode$number_of_links_from_kioskmode]} == *" "* ]];
		then
			#correcting URL's
			kiosk_mode_url_array[kioskmode$number_of_links_from_kioskmode]="$(echo "${kiosk_mode_url_array[kioskmode$number_of_links_from_kioskmode]}" | tr -d '[:space:]')"		
		fi
	
		local number_of_particular_valid_kioskmodes_urls[$number_of_links_from_kioskmode]=$( expr $number_of_links_from_kioskmode + 100 )
		local kioskmode_urls_for_dialog[$number_of_links_from_kioskmode]=${kiosk_mode_url_array[kioskmode$number_of_links_from_kioskmode]}
		#echo "kioskmode URL:"${kiosk_mode_url_array[kioskmode$number_of_links_from_kioskmode]}
		#echo ""
		
		# extract kioskmode token from url in config.
		if [[ ${kioskmode_urls_for_dialog[$number_of_links_from_kioskmode]} == *"kk="* ]]; 
		then
			local kiosk_mode_token=`echo "${kioskmode_urls_for_dialog[$number_of_links_from_kioskmode]}" | grep -o 'kk=.*'` 
			local kiosk_mode_token_array[$number_of_links_from_kioskmode]=`echo "$kiosk_mode_token" | grep -Po '^.{3}\K.*'`
		else
			#if kioskmode url is invalid without token kk=
			local kiosk_mode_token_array[$number_of_links_from_kioskmode]=`echo "${kioskmode_urls_for_dialog[$number_of_links_from_kioskmode]}"`
		
		fi
	else 
		local number_of_particular_valid_kioskmodes_urls[$number_of_links_from_kioskmode]=$( expr $number_of_links_from_kioskmode + 300 )
		local kiosk_mode_token_array[$number_of_links_from_kioskmode]=null
	fi
	
	if [ ! "${number_of_particular_valid_kioskmodes_urls[$number_of_links_from_kioskmode]}" == null ] && [ ! "${kiosk_mode_token_array[$number_of_links_from_kioskmode]}" == null ] ;
	then
	#dialog for kioskmodes counts all aviable correct url's for menu
	local kioskmode_positions_ready_for_dialog[$number_of_links_from_kioskmode]=$(echo "${number_of_particular_valid_kioskmodes_urls[$number_of_links_from_kioskmode]}" "${kiosk_mode_token_array[$number_of_links_from_kioskmode]}"); 
	
	elif [ "${kiosk_mode_token_array[$number_of_links_from_kioskmode]}" == null ] ;
	then	
	local kioskmode_positions_ready_for_dialog[$number_of_links_from_kioskmode]=$(echo "${number_of_particular_valid_kioskmodes_urls[$number_of_links_from_kioskmode]}" "kioskmode_link_unactive"); 
	
	fi
done

	#echo ${variable[@]}
	
	
	Our_accounts_and_kioskmode_urls_list=$($DIALOG --ok-label "Browse" --cancel-label "Exit" --title "List of accounts and kioskmode's" \
	 --backtitle "List of accounts and kioskmode's URL's" \
	 --menu "List of accounts and kioskmode's URL's:" 10 50 10 \
	 ${login_positions_ready_for_dialog[@]} \
	 ${kioskmode_positions_ready_for_dialog[@]} \
	 --output-fd 1)
        #3>&1 1>&2 2>&3)
        
        exitstatus=$?
        #echo $exitstatus
        if [ $exitstatus = 0 ];
        then 
		case "$Our_accounts_and_kioskmode_urls_list" in
		# Propably there is no account with so many power plants like 999
		[0-99]) 
				exitstatus=$?
				
				if [ $exitstatus = 0 ];
        			then
        			
        			
        				if [ ! -z "${huawei_account_login[login$Our_accounts_and_kioskmode_urls_list]}" ] || [ ! -z "${huawei_account_login[password$Our_accounts_and_kioskmode_urls_list]}" ];	
					then	
	
						if [ "${huawei_account_login[login$Our_accounts_and_kioskmode_urls_list]}" == "<--here login-->" ] || [ "${huawei_account_login[password$Our_accounts_and_kioskmode_urls_list]}" == "<--here password-->" ];
						then
							$DIALOG --title "Login to API" --clear \
							--backtitle "Huawei FusionSolarApp API" \
      							--msgbox "$login_text" 10 50
							#--shadow
							#clear #clears the terminal screen
		
							# input of username and password
							User_name_and_password_filing
		
		
							# Function to login to API with arguments chosen from menu username and password
							login_to_API "login$Our_accounts_and_kioskmode_urls_list" "password$Our_accounts_and_kioskmode_urls_list"
		
		
		
						else
							# uncoment this dialog window if you do like to see your login and passwod displayed in window after sucessfully login
							#login_text="username and password exists in config.conf\n\n Username:${huawei_account_login[login$Our_accounts_and_kioskmode_urls_list]}\n Password:${huawei_account_login[password$Our_accounts_and_kioskmode_urls_list]}"
		
							#$DIALOG --title "Login to API" --clear \
							#--backtitle "Huawei FusionSolarApp API" \
      							#--msgbox "$login_text" 10 50
      							
							#--shadow
							#clear #clears the terminal screen	
		
							# Function to login to API with arguments chosen from menu username and password
							login_to_API "login$Our_accounts_and_kioskmode_urls_list" "password$Our_accounts_and_kioskmode_urls_list"
		
						fi
					else
	
						login_text="config.conf has no username and password data variables [login] and [password] are deleted/commented"
						$DIALOG --title "Login to API" --clear \
						--backtitle "Huawei FusionSolarApp API" \
      						--msgbox "$login_text" 10 50
						#--shadow
						#clear #clears the terminal screen	
       				fi	
				fi
				;;	
		
		[1][0-9][0-9])	
		
				exitstatus=$?
				 
				if [ $exitstatus = 0 ];
        			then
        				#we connect to partcular kioskmode URL's with specific link we -100 because this was added erlier to diffrientate between logins/passwords and URL's 
        				kioskmode_entry "kioskmode$( expr $Our_accounts_and_kioskmode_urls_list - 100)"
        				
				elif [ $exitstatus = 3 ]; 
				then
					#echo $exitstatus
					exit
					
				elif [ $exitstatus = 1 ]; 
				then
					#echo $exitstatus
					exit
				else
					#echo $exitstatus
					exit
				fi				
        			;; 
        	
        	[2][0-9][0-9])	      	 
        			$DIALOG --title "Disabled login" \
 				--backtitle "Disabled login " \
				--msgbox  "This login is filed with generic data? Can not take you anywhere until you edit config.conf and insert inside this postion valid login and password to Fusionsolarapp account" 10 50
    		
    				exitstatus=$?
    				
				if [ $exitstatus = 0 ];
        	 		then
        	 			#we chosen List of Login's button
        	 			# go back to menu of accounts and URL's
    					main_function	
				elif [ $exitstatus = 1 ]; 
				then
					#echo $exitstatus
					exit
				else
					#echo $exitstatus
					exit
				fi
				;;	
		[3][0-9][0-9])	      	 
        			$DIALOG --title "Disabled link" \
 				--backtitle "Disabled link " \
				--msgbox  "This link is filed with generic data? Can not take you anywhere until you edit config.conf and insert inside this postion valid kioskmode link" 10 50
    		
    				exitstatus=$?
    				
				if [ $exitstatus = 0 ];
        	 		then
        	 			#we chosen List of Login's button
        	 			# go back to menu of accounts and URL's
    					main_function	
				elif [ $exitstatus = 1 ]; 
				then
					#echo $exitstatus
					exit
				else
					#echo $exitstatus
					exit
				fi
				;;				
	
       	*) 
       	 		$DIALOG --title "unknow error" \
 				--backtitle "unknow error" \
				--msgbox  "This login or link is filed with generic data? Can not take you anywhere until you edit config.conf" 10 50
    		
    				exitstatus=$?
    				
				if [ $exitstatus = 0 ];
        	 		then
        	 			#we chosen List of Login's button
        	 			# go back to menu of accounts and URL's
    					main_function	
				elif [ $exitstatus = 1 ]; 
				then
					#echo $exitstatus
					exit
				else
					#echo $exitstatus
					exit
				fi	
					
       	#closing of case "$Our_accounts_and_kioskmode_urls_list" in
       	esac	
       	
	
	elif [ $exitstatus = 3 ]; 
	then
		#echo $exitstatus
		exit
					
	elif [ $exitstatus = 1 ]; 
	then
		#echo $exitstatus
		exit		
	else
		exit
	fi




}



# base function of this program starts first
main_function() {

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


# list of accounts and URL's
accounts_and_kioskmode_urls_list_menu



if [[ $login_status == true  ]];
then	

# We start function to get list of plants
getStationList $DIALOG
	
# Now we take list of our plants related with username password
Plant_list


	
elif [[ $login_status == false ]];
then	

	$DIALOG --title "Login to API" --clear \
	--backtitle "$info_for_dialog_backtitle" \
      	--msgbox "$info_for_dialog_screen" 10 50
	#--shadow
	#clear #clears the terminal screen	
		

	main_function
else
	exit
fi

}



# code of program itself First function which is lanuched
main_function

