public with sharing class PortalFeedController {
    @AuraEnabled
    public static User getUserData(String userid) {
        return [SELECT FirstName,ContactId FROM User WHERE Id = :userid LIMIT 1];
    }
    
    @AuraEnabled
    public static List<portal_feed_item__c> getFeedItems(String userid){
        List<portal_feed_item__c> pfil = [SELECT 
                                              Id,
                                              action_no__c,
                                              action_yes__c,
                                              category_1__c,
                                              date__c,
                                              icon_1__c,
                                              icon_2__c,
                                              icon_3__c,
                                              image__c,
                                              message_1__c,
                                              message_2__c,
                                              record_id_1__c,
                                              record_id_2__c,
                                              record_id_3__c,
                                              record_name_1__c,
                                              record_name_2__c,
                                              record_name_3__c,
                                              SLA_in_minutes__c,
	                                          SLA_active__c,
                                          	  SLA_achieved_since__c,
                                              source__c,
                                              sourceArticle__c,
                                              text__c,
                                              title__c,
                                              type__c,
                                           	  CreatedDate 
                                          FROM portal_feed_item__c 
                                          WHERE User__c = :userid
                                          ORDER BY date__c DESC
                                         ];
            
       
        return pfil;
    }


    
    @AuraEnabled
    public static Boolean pushEventMessage(general_message__e msg){
        try {
            EventBus.publish(msg);
            return true;
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return false;
        }
        
    }
    
    @AuraEnabled
    public static String updateStatusWithMessage(Id oid, String field, String value, String icon, String headline){
        try {
            String ObjectType = oid.getsobjecttype().getDescribe().getName();
            String strQuery = 'SELECT Id,Name,' + field + ' FROM ' + ObjectType + ' LIMIT 1' ;
            SObject record = oid.getsobjecttype().newSObject(oid);
            //record = Database.query(strQuery);
            record.put(field, value);
            Database.SaveResult dbs = Database.update(record,false);
            String returnString = '';
            if(dbs.isSuccess()){
                returnString = 'DB insert successful, sObject Type = ' +
                    (String)record.getSObjectType().getDescribe().getName() + '\n' 
                    + field + ' value = ' + record.get(field) + '\n' 
                    + 'is updateable = ' + record.getSObjectType().getDescribe().isUpdateable() + '\n'
                    + oid + ' < id vs id > ' + record.get('Id');
            } else {
                returnString = dbs.getErrors()[0].getMessage();
            }
            //create success message
            general_message__e msg = new general_message__e(
                    main_icon__c = icon,
                    headline__c = headline,
                    category_1__c = ObjectType,
                    category_2__c = 'New status:',
                    icon_1__c = icon,
                    message_1__c = 'status has been changed.',
                    message_2__c = '\"' + value + '\"',
                    record_id_1__c = oid,
                    record_name_1__c = (String)record.get('Name')
                );
            pushEventMessage(msg);
            return returnString;
        } catch (DmlException e) {
            String errorMessage = 'The following exception has occurred: ' + e.getMessage();
            System.debug(errorMessage);
            return errorMessage;
        }
    }
    
    @AuraEnabled
    public static String updateStatus(Id oid, String field, String value){
        try {
            String ObjectType = oid.getsobjecttype().getDescribe().getName();
            String strQuery = 'SELECT Id, Name, ' + field + ' FROM ' + ObjectType + ' LIMIT 1' ;
            SObject record = oid.getsobjecttype().newSObject(oid);
            //record = Database.query(strQuery);
            
             if(value=='true' || value=='false') {
                if(value=='true'){
                    record.put(field, true);
                } else {
                    record.put(field, false);
                }
            } else {
                if (value == 'ACTION:setDate'){
					record.put(field, dateTime.now());                      
                } else {
	                record.put(field, value);    
                }
                
            }
			
            
            Database.SaveResult dbs = Database.update(record,false);
            String returnString = '';
            if(dbs.isSuccess()){
                returnString = 'DB insert successful, sObject Type = ' +
                    (String)record.getSObjectType().getDescribe().getName() + '\n' 
                    + field + ' value = ' + record.get(field) + '\n' 
                    + 'is updateable = ' + record.getSObjectType().getDescribe().isUpdateable() + '\n'
                    + oid + ' < id vs id > ' + record.get('Id');
            } else {
                returnString = dbs.getErrors()[0].getMessage();
            }
            return returnString;
        } catch (DmlException e) {
            String errorMessage = 'The following exception has occurred: ' + e.getMessage();
            System.debug(errorMessage);
            return errorMessage;
        }
    }
    @AuraEnabled
    public static String updatePfi(Id pfid){
        String returnstring = 'success';
        Portal_feed_item__c pfi = [SELECT Id, SLA_achieved_since__c, SLA_active__c FROM Portal_feed_item__c WHERE Id = :pfid LIMIT 1];
        pfi.SLA_achieved_since__c = DateTime.now();
        pfi.SLA_active__c = false;
        try{update pfi;} catch (Exception e) {
            returnstring = 'error' + e.getMessage();
        }
        return returnstring;
    }
    @AuraEnabled
    public static String updateTestDriveLead(Id tid){
        //send message
            
        try {
            Test_Drive__c td = [SELECT Id,Lead_Source__c, Name FROM Test_Drive__c WHERE Id = :tid LIMIT 1];
            Lead l = [SELECT Id,Status,Name FROM Lead WHERE Id = :td.Lead_Source__c LIMIT 1];
            general_message__e msg = new general_message__e(
                    main_icon__c = 'standard:lead',
                    headline__c = 'Lead updated',
                    category_1__c = 'Lead',
                    category_2__c = 'New Status:',
                    icon_1__c = 'standard:lead',
                    message_1__c = 'has an updated status.',
                    message_2__c = '\"Working\"',
                    record_id_1__c = l.id,
                    record_name_1__c = l.Name
                );
            pushEventMessage(msg);
            
            naviController.startTestDrive(td);
            
            l.Status = 'Working';
            
            update l;
            
            return 'Lead Update successful';
        } catch (DmlException e) {
            String errorMessage = 'The following exception has occurred: ' + e.getMessage();
            System.debug(errorMessage);
            return errorMessage;
        }
    }

}