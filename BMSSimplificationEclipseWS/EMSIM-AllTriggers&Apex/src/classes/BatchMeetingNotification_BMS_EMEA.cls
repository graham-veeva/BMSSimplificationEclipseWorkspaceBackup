global  class BatchMeetingNotification_BMS_EMEA implements Database.Batchable<SObject>{

    public String query;
    Date currentDate = date.today();

    global Database.QueryLocator start(Database.BatchableContext BC){

        //Query the needed meetings
        query = ('Select Id,Name,Start_Date_vod__c,Status_BMS_CORE__c,FFM_Step_BMS_EMEA__c,Email_Notification_flag_BMS_EMEA__c,Country_MasterFile_BMS_EMEA__c From Medical_Event_vod__c WHERE Status_BMS_CORE__c=\'Approved\' AND FFM_Step_BMS_EMEA__c=\'Meeting Post-Execution\' ');
        query += ' AND (Email_Notification_flag_BMS_EMEA__c = false OR Email_Notification_2_flag_BMS_EMEA__c = false)'; //added by Viktor to make this scalable
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        
        List<Medical_Event_vod__c> meetingList = (List<Medical_Event_vod__c>) scope;
        
        //Inititate custom settings
        List<BMS_EMEA_BatchMeeting__c> notificationSettings = new list<BMS_EMEA_BatchMeeting__c>();
        
        notificationSettings = [select id,Name,Notification_delay__c from BMS_EMEA_BatchMeeting__c];
        
        Map<String, BMS_EMEA_BatchMeeting__c> mcs = BMS_EMEA_BatchMeeting__c.getAll();
        
        system.debug('--- NOtification Settings ---'+mcs);
        
        //Process each meeting
        for(Medical_Event_vod__c medicalEvent : meetingList){
            
            //REtrive country setting
            BMS_EMEA_BatchMeeting__c setting = mcs.get(medicalEvent.Country_MasterFile_BMS_EMEA__c);
             
            if(setting != null){
                //Check notification delay
                system.debug('--- Country -----'+setting.Name);
                system.debug('--- Notification delay -----'+setting.Notification_delay__c);
                
                integer delay = integer.valueOf(setting.Notification_delay__c);
                integer delay2 = integer.valueOf(setting.Notification_2_delay__c);
                
                System.debug('--- current date + delay '+currentDate.addDays(delay));
                system.debug('--- Meeting Start Date ---'+medicalEvent.Start_Date_vod__c);
                
                if(currentDate.addDays(delay)  >= medicalEvent.Start_Date_vod__c){
                    
                    //Set notification flag
                    medicalEvent.Email_Notification_flag_BMS_EMEA__c = true;
                }
                
                if(currentDate.addDays(delay2)  >= medicalEvent.Start_Date_vod__c)
                    medicalEvent.Email_Notification_2_flag_BMS_EMEA__c = true;
            }else{
                //Use the default value
                setting = mcs.get('Default');
                
                system.debug('--- Default delay -----'+setting.Notification_delay__c);
                
                integer delay = integer.valueOf(setting.Notification_delay__c);
                integer delay2 = integer.valueOf(setting.Notification_2_delay__c); 
                
                if(delay != null){
                    if(currentDate.addDays(delay)  >= medicalEvent.Start_Date_vod__c){
                     
                        //Set notification flag
                        medicalEvent.Email_Notification_flag_BMS_EMEA__c = true;
                    }
                }
                if(delay2 != null){   
                    if(currentDate.addDays(delay2)  >= medicalEvent.Start_Date_vod__c)
                        medicalEvent.Email_Notification_2_flag_BMS_EMEA__c = true;
                
                }
            }           
        }
        
        //Update meeting list
        update meetingList;
        
    }

    global void finish(Database.BatchableContext BC){
        
    }
    
}