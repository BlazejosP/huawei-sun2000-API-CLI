# huawei-sun2000-API-CLI
huawei sun2000-(3KTL-10KTL)-M0 all models comand line bash API for download data from their FusionSolarApp. To use this tool you need an acount in their service and then request developer account. That all mean that you need Huawei sun2000 series PV inverter configured already with their cloud service or someone who give you acess to cloud service related with his Huawei device.


Tool for login and get data from Huawei FusionSolar https://eu5.fusionsolar.huawei.com
This tool use oficial FusionSolar API described here https://forum.huawei.com/enterprise/en/communicate-with-fusionsolar-through-an-openapi-account/thread/591478-100027 by manufacturer 

You must have installed on your linux tools like curl, jq, httpie

sudo apt-get install curl

sudo apt-get install jq

sudo apt-get install httpie

To use this script you need account on Huawei FusionSolar https://eu5.fusionsolar.huawei.com and developer privilege.
Contact service team at eu_inverter_support@huawei.com to create an openAPI account for your plant.

in email like this:

Hi, I hereby request an openAPI user account to access the data from my inverter(s) through the new #FusionSolar API:

System name: <--here data-->
Username: <--here data-->
Plant Name: <--here data-->
SN Inverter: <--here data-->
