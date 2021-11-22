# Huawei sun2000 API CLI 



[![GitHub license](https://img.shields.io/github/license/BlazejosP/huawei-sun2000-API-CLI)](https://github.com/BlazejosP/huawei-sun2000-API-CLI/blob/master/LICENSE)
 [![GitHub issues](https://img.shields.io/github/issues/BlazejosP/huawei-sun2000-API-CLI)](https://github.com/BlazejosP/huawei-sun2000-API-CLI/issues)
 ![Language](https://img.shields.io/badge/made%20with-bash-green)
![Lines of code](https://img.shields.io/tokei/lines/github/BlazejosP/huawei-sun2000-API-CLI)
![GitHub repo size](https://img.shields.io/github/repo-size/BlazejosP/huawei-sun2000-API-CLI)
![GitHub forks](https://img.shields.io/github/forks/BlazejosP/huawei-sun2000-API-CLI)
![GitHub Repo stars](https://img.shields.io/github/stars/BlazejosP/huawei-sun2000-API-CLI?style=social)

If you found this software usefully and do like to say thank you!
-
You can donate for charity and support small <B>Maks</B> in his fight against Cancer his parents try collect $36000 for cancer thratment in hospital in Barcelona, Spain because in Ukraine they can't help him anymore. In Spain they can but is necesarry to pay<a href="https://www.siepomaga.pl/en/maks-nazarenko#wplaty"><img alt="Twitter" src="https://img.shields.io/twitter/url?color=yellow&label=Small%20Maria%20versus%20SMA%20type%201&logo=github&logoColor=black&url=https%3A%2F%2Fwww.siepomaga.pl%2Fen%2Fmaria%23wplaty"></a>link and full desciption (unfortunetly only in Polish)

Maria is now fully funded if we talked about SMA gene therapy thanks to all you too! She collected $2.1 million for moust expensive drug medicine on the Word.
<a href="https://www.siepomaga.pl/en/maria#wplaty"><img alt="Twitter" src="https://img.shields.io/twitter/url?color=yellow&label=Small%20Maria%20versus%20SMA%20type%201&logo=github&logoColor=black&url=https%3A%2F%2Fwww.siepomaga.pl%2Fen%2Fmaria%23wplaty"></a>
.

Linux Command line tool for acess Huawei FusionSolarApp API
-
Huawei sun2000-(3KTL-100KTL)-M0/M1 all models comand line bash API for download data from their FusionSolarApp web service. To use this tool you may need kioskmode link as a minimum. But to fully use this tool you need an acount in their service and then request developer account. That all means that you need Huawei sun2000 https://solar.huawei.com/eu/products series PV inverter configured already with their cloud service or someone who give you acess to cloud service related with his Huawei device.

To use this script you must have as a minimum kioskmode link given to you by someone else who has Huawei account. But to fully use this software
you need account on Huawei FusionSolar https://eu5.fusionsolar.huawei.com and developer privilege.

Contact service team at eu_inverter_support@huawei.com to create an openAPI account for your plant. Inside email like this:

Email Template
-
```
Hi, I hereby request an openAPI user account to access the data from my inverter(s) through the new #FusionSolar API:

System name: <--here data--> 

Username: <--here data--> 

Plant Name: <--here data--> 

SN Inverter: <--here data-->
```

## Device Sun2000-(from 3KTL to 100KTL meaby also others)-M0/M1

 Confirmed working with the following devices

- [x] String inverter
  - [X] SUN2000-5KTL-M0
  - [X] SUN2000-30KTL-M3
- [x] Dongle
  - [x] SDongleA-05
- [X] Residential inverter
  - [X] SUN2000-4.6KTL-L1
- [x] Smart Logger
- [ ] EMI
- [x] Meter (Grid meter)
- [ ] Power Sensor
- [ ] Battery (only LG batteries are supported propably not true)
- [ ] Battery Huawei Luna2000 (we working on this)

Device itself must be equipped with Smart Dongle existing two types: 

Smart Dongle-4G (sends data through cellular network -> to internet -> and then stright to cloud service)

SmartDongle-WLAN-FE (sends data with use of user lan or wlan -> through user getway -> internet -> to cloud service)

Whatever dongle is in use there must be an connection to internet if not cloud service simple don't recieve new data. 

![Huawei-sun2000](pictures/3-10-FROUNT-Dongle.png)

Installation
-
This is tool for login and get data from Huawei FusionSolar https://eu5.fusionsolar.huawei.com
This tool use official FusionSolar API described here https://forum.huawei.com/enterprise/en/communicate-with-fusionsolar-through-an-openapi-account/thread/591478-100027 by manufacturer. Data from official API are instantous or every 5 mintes, hour, day, monthly, yearly.

You must have installed on your linux tools like curl, jq, httpie, grep, mosquitto_pub on debian and similar systems. They are necessary for working of this bash scripts. On Debian like system you can download them with:
```
sudo apt-get install curl

sudo apt-get install jq

sudo apt-get install grep

sudo apt-get install httpie

sudo apt-get install mosquitto-clients (if MQTT sending option will be used)

sudo apt-get install dialog (if TUI will be used)

```
On other linux distributions check used package system but that are standard linux command line tools so should be avaiable without problems if are not installed already. 

Configuration&Usage
-
<b>config.conf</b> - this file is needed by both fusionsolarapp.sh & fusionsolarapp_interface.sh and have inside stored your Usernames & Passwords and also links to kioskmodes which you have or have acess to them. You must edit this file first to made this software working. Now you can use this software even without huawei account if you can paste kioskmode given to you by someone else.

<b>fusionsolarapp.sh</b> - which is using official Huawei API called OpenAPI by Huawei. Now this script can pull and show on the screen data Real-time(actually), every 5min , daily, monthly, yearly for Plants (which may include many inverters+any other devices data together) and Individual Devices (like every one inverter, battery etc.) This script is now under development and for now can only grab all the data from your devices and show them on screen & if you choose option save to file. In not so long time will be able also send this data to InfluxDB(grafana), Domoticz, MQTT. This script need individual configuration inside if you need data tailored to your needs. How do this is described here https://github.com/BlazejosP/huawei-sun2000-API-CLI/issues/12

Then inside you can extract this data:
- [x] Plant data
  - [x] realtime plant performace
  - [x] actually and historical plant performace resolution every 5 minutes inside day
  - [x] actually and historical plant performace resolution 30 days
  - [x] actually and historical plant performace resolution 12 month
  - [x] actually and historical plant performace resolution all years
- [x] individual device data
  - [x] realtime device performace
  - [x] actually and historical data device performance resolution every 5 minutes inside day
  - [x] actually and historical data device performace resolution 30 days
  - [x] actually and historical data device performace resolution 12 month
  - [x] actually and historical data device performace resolution all years

![FusionSolarApp](pictures/fusionsolarappnew.png)

<b>fusionsolarapp_interface.sh</b> - this is the same program but with TUI graphical interface you must install additionally dialog. As for now you can login inside software will ask you about Login and Password if this data are not provided by config.conf. And check this properties inside checked below.

Then inside you can check:
- [x] Plant data
  - [x] realtime plant performace
  - [ ] actually and historical plant performace resolution every 5 minutes inside day
  - [ ] actually and historical plant performace resolution 30 days
  - [ ] actually and historical plant performace resolution 12 month
  - [ ] actually and historical plant performace resolution all years
- [x] individual device data
  - [x] realtime device performace
  - [x] actually and historical data device performance resolution every 5 minutes inside day
  - [x] actually and historical data device performace resolution 30 days
  - [x] actually and historical data device performace resolution 12 month
  - [ ] actually and historical data device performace resolution all years
 
Also list of devices which are inside plant together with their performance. Also is possible save data's to a file TXT CSV XML JOSN are suported. This program is now partialy working so not every functionality is already implemented as you can see above. You will be advised if you chose not working yet part. When will be finished will have the same usability as text version.

![TUI1](pictures/fusionsolarapp_interface1.png)



