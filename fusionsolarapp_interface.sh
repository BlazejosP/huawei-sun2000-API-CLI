#!/bin/bash

# possible arguments different gui systems
# dialog
# whiptail
# gdialog
# yad
# Load configuration values variables
#source config.conf
source config.conf
source functions.sh



if [ -z "$userName" ] && [ -z "$systemCode" ];	
	then	
		login_text="username and password not exists in config.conf"
	fi
				
if [ ! -z "$userName" ] && [ ! -z "$systemCode" ];	
	then	
		login_text="username and password exists in config.conf\n\n Username:$userName\n Password:$systemCode"
		
	fi


#DIALOG=${DIALOG:=whiptail}
DIALOG=${DIALOG:=dialog}
#DIALOG=${DIALOG:=gdialog}

	$DIALOG --title " Login to API" --clear \
	--backtitle "Huawei FusionSolarApp API" \
        --msgbox "$login_text" 10 50
	--shadow
	clear #clears the terminal screen

# Function to login to API
login_to_API $DIALOG




	$DIALOG --title " Login to API" --clear \
	--backtitle "$info_for_dialog_backtitle" \
        --msgbox  "$info_for_dialog_screen" 10 50
        --shadow
	clear #clears the terminal screen


