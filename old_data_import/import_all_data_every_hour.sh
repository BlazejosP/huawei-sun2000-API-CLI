#!/bin/bash

# This program import historical data energy production for every hour from FusionSolarAPP to your database influxDB with use of oficial Huawei API. Because API only allow to import 10 days history per one login this program call to API many times as is possible to import your whole timeframe.
# That is why he ask first for benchmark short check from actually day to 10 days back and mesure connection to Huawei  server and how long time take inserton to your influxDB. With this time data he can estimate whole import duration. For example in my case that was 40 minutes for 6 month of previous data.
# This script call to other Previous_10days_every_hour.sh which is reponsible for calling to API and simply download previous  10 days data then insert this data in corect order into database. Menu from this script just call to this file as many times as is necessary to import your whole timeframe.
# API and influxDB configurations are inside Previous_10days_every_hour.sh modifiy your to your needs and then execute this program import_all_data_every_hour.sh to start your importing

exit_bacuse_no_correct_date_input="is not valid program is ending now"  
exit_bacuse_no_finishing_date_input="There where no end date wich states when we finish import so program is ending now"

echo "Input a date from which we start import historical data for hourly production every day in format like this YYYY-MM-DD for example: 2020-05-01 or (ENTER) to start from today"
read date_of_start

if [[ $date_of_start =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && date -d "$date_of_start" >/dev/null
      then 
      		echo ""
      		echo "Date $date_of_start is valid and matches the format (YYYY-MM-DD)"
      		echo ""
      		
      elif [ -z "$date_of_start" ]
      then
      		echo ""
      		echo "Date $(date +'%Y-%m-%d') is valid and matches the format (YYYY-MM-DD)"
      		echo ""
      
      else
      		echo ""
      		echo "Date "$date_of_start" "$exit_bacuse_no_correct_date_input  
		exit 0
fi

echo $(date +%s --date $date_of_start)

echo "Input a date when we finish importing historical data typically day when your installation were comisioning and start working also in format like this YYYY-MM-DD for example: 2020-05-01"
read date_of_end

if [[ $date_of_end =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && date -d "$date_of_end" >/dev/null
      then 
      		echo ""
      		echo "Date $date_of_end is valid and matches the format (YYYY-MM-DD)"
      		echo ""
      elif [ -z "$date_of_end" ]
      then
      		echo ""
      		echo $exit_bacuse_no_finishing_date_input
      else	
      		echo ""
      		echo "Date "$date_of_end" "$exit_bacuse_no_correct_date_input   
		exit 0
fi





if [ -z "$date_of_start" ]
	then
		if [ -z "$date_of_end" ]
		then
			echo $exit_bacuse_no_finishing_data_input
			exit 0
		else
			days_from_our_date=$((($(date +%s)-$(date +%s --date $date_of_end))/(3600*24)))
			how_many_repetitions_is_necessary=$((($days_from_our_date/10)+1))
			echo "That means between both dates is $days_from_our_date days difference. Because HUAWEI API allows only grab data for 10 days in one conection this program must be automatically repeated $how_many_repetitions_is_necessary times"
			echo ""
			#date of start to file actually date
			date_of_start_unix_epoch=$(date +%s)

			data=$(date +"%d %B %Y" -d @$date_of_start_unix_epoch)
                	truncate=$(truncate -s0 Previous_10_days_every_hour.config)
                	echo "#!/bin/bash" >> Previous_10_days_every_hour.config
                	echo "#this is config file for Previous_10_days_every_hour.sh there is last day from which data were imported in unix epoch + three 0 for compability with API format. If you d'like start from your own day importing add on the end of unix date 000 next time when you start program he starts capturing from this date" >> Previous_10_days_every_hour.config
                	echo "#day from which we start next time inserting historical data is "$data >> Previous_10_days_every_hour.config
                	echo "curent_time="$date_of_start_unix_epoch"000" >> Previous_10_days_every_hour.config


		fi
	else
		if [ -z "$date_of_end" ]
		then
			echo $exit_bacuse_no_finishing_data_input
			exit 0
		else
			days_from_our_date=$((($(date +%s --date $date_of_start)-$(date +%s --date $date_of_end))/(3600*24)))
			how_many_repetitions_is_necessary=$((($days_from_our_date/10)+1))
			echo "That means between both dates is $days_from_our_date days difference. Because HUAWEI API allows only grab data for 10 days in one conection this program must be automatically repeated $how_many_repetitions_is_necessary times"
			echo ""
			#date of start to file from input
			date_of_start_unix_epoch=$(date +%s --date $date_of_start)
			
			data=$(date +"%d %B %Y" -d @$date_of_start_unix_epoch)
                        truncate=$(truncate -s0 Previous_10_days_every_hour.config)
                        echo "#!/bin/bash" >> Previous_10_days_every_hour.config
                        echo "#this is config file for Previous_10_days_every_hour.sh there is last day from which data were imported in unix epoch + three 0 for compability with API format. If you d'like start from your own day importing add on the end of unix date 000 next time when you start program he starts capturing from this date" >> Previous_10_days_every_hour.config
                        echo "#day from which we start next time inserting historical data is "$data >> Previous_10_days_every_hour.config
                        echo "curent_time="$date_of_start_unix_epoch"000" >> Previous_10_days_every_hour.config 
		fi
fi



echo "Would you like to benchmark first your conection to Huawei API FusionSolarAPP and your InfluxDB server? After that will be possible to calculate/estimte how much time you need to import all historical data to database? Choose y or n"
read benchmark

if [ -z "$benchmark" ]
	then
		echo ""
		echo "You do not choosed anything? Choose [y] or n"
		read benchmark
	
	elif [ $benchmark == "y" ]
	then
		echo ""
		#echo "You chosed Testing your configuration."
		#testing time of execution in secounds
		#start of time capture
		START_TIME=$SECONDS
		
		#here goes the code to insert data to database
		. Previous_10days_every_hour.sh
		
		#end of time capture
		echo "One API call to grab and insert data from 10 days take"
		secs=ELAPSED_TIME=$(($SECONDS - $START_TIME))

		printf '%dh:%dm:%ds\n' $(($secs/3600)) $(($secs%3600/60)) $(($secs%60))
		echo  "Importing all data from your timeframe will take around"
		sec_timeframe=$secs*$how_many_repetitions_is_necessary
		printf '%dh:%dm:%ds\n' $(($sec_timeframe/3600)) $(($sec_timeframe%3600/60)) $(($sec_timeframe%60))
		
		echo "Would you like to start imporing data?"
		read importing
		if [ -z "$importing" ]
		        then
				echo ""
                		echo "You do not choosed anything? Choose [y] or [n]"
                		read importing

		elif [ $importing == "y" ]
        		then
				#here goes the code to insert data to database so many times as calculated
				for (( c=1; c<=$how_many_repetitions_is_necessary; c++ ))
					do
					. Previous_10days_every_hour.sh
				done
		elif [ $importing == "n" ]
        		then
                		echo ""
                		echo "You choosed mot to go with importing. Exiting"
        	else
                	echo ""
                	echo "You choosd $benchmark which is not valid value. Exiting"

		fi

	elif [ $benchmark == "n" ]
		then
		               echo "Would you like to start imporing data?"
                		read importing
                if [ -z "$importing" ]
                        then
                                echo ""
                                echo "You do not choosed anything? Choose [y] or [n]"
                                read importing

                elif [ $importing == "y" ]
                        then
                                #here goes the code to insert data to database so many times as calculated
                                for (( c=1; c<=$how_many_repetitions_is_necessary; c++ ))
                                        do
                                        . Previous_10days_every_hour.sh
                                done
                elif [ $importing == "n" ]
                        then
                                echo ""
                                echo "You choosed mot to go with importing. Exiting"
                else
                        echo ""
                        echo "You choosd $benchmark which is not valid value. Exiting"

                fi

	else
		echo ""
		echo "You choosd $benchmark which is not valid value. Exiting"
fi




