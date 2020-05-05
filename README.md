# Automotive Demo Pack

### Original package:
- https://git.soma.salesforce.com/dfleminks/volkswagen-demo-pack


## Setup Dashboard

1. upload datasets 

```
// Change mdapi:deploy to source:deploy with api version override to prevent async 
sfdx force:mdapi:deploy -d mdapi/autoDashboard -u <targetusername>
```


```
sfdx shane:analytics:dataset:upload -n demo_data_df_raw -f data/analytics/demo_data_df_raw.csv
sfdx shane:analytics:dataflow:start -n DF_Data_Prep
sfdx shane:analytics:dataset:upload -n demo_data_df_preped -f data/analytics/demo_data_df_preped.csv
sfdx shane:analytics:dataset:upload -n demo_data_df_service -f data/analytics/demo_data_df_service.csv
sfdx shane:analytics:dataset:upload -n demo_data_df_trails -f data/analytics/demo_data_df_trails.csv

```

2. Push metadata



## Setting up project with Basic Data
1. push source
```
sfdx force:source:push -u <targetusername>
```
2. assign permset to user
```
sfdx force:user:permset:assign -n autoforce_demo_pack -u <targetusername>
```
3. Run the following command:
```
sfdx force:apex:execute -f data/scripts/setDemosetting.txt -u <targetusername>
```
4. Run the following command to import data:
```
sfdx force:data:tree:import -p data/sfdx-out/John-Plan.json -u <targetusername>
```
5. Run the following command to create the Dealer Portal User:
```
sfdx force:apex:execute -f data/scripts/setRoleCall.txt -u <targetusername>
```

1. Publish Dealer Community
2. Reset Daniel Password
3. Set External haring settings to public for: Account, Contact, Asset


In case you run into an error, you can delete all data that has been accidentally created by calling
WARNING, this will delete most data in the ORG
```
sfdx force:apex:execute -f  data/scripts/deleteAllDataCall.txt -u <targetOrg>
```



## Setup Dashboard (Continue)

