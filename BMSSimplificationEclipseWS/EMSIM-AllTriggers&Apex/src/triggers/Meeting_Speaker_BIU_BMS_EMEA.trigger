trigger Meeting_Speaker_BIU_BMS_EMEA on Meeting_Speaker_BMS__c (before insert, before update) 
{
    
    list<Medical_Event_vod__c> otherMeetings = new list<Medical_Event_vod__c>();
    list<Medical_Event_vod__c> otherMeetings1 = new list<Medical_Event_vod__c>();
    list<Medical_Event_vod__c> otherMeetings2 = new list<Medical_Event_vod__c>();
    list<Meeting_Speaker_BMS__c> otherSpeakers = new list<Meeting_Speaker_BMS__c>();
    decimal otherMeetingSum = 0;
    decimal otherMeetingSum1 = 0;
    decimal otherSpeakerSum = 0;
    decimal actualRemaining = 0;
    decimal totalPlanned = 0;
    decimal currentHonorarium = 0;
    
    
    id masteFileID = [select Master_File_BMS_EMEA__c 
                      from   Medical_Event_vod__c 
                      where  id =: trigger.new[0].Meeting__c].Master_File_BMS_EMEA__c;
                      
    if ( masteFileID == null ) {
        // If there is no MasterFile - then do not run this trigger
        // Modified by: <raphael.krausz@veeva.com>
        // Modified date: 2014-12-15
        return;
    }

    decimal totalBudgetMF = [select Master_File_BMS_EMEA__r.Total_Budget_all_Events_BMS_EMEA__c 
                             from   Medical_Event_vod__c 
                             where  id  =: trigger.new[0].Meeting__c].Master_File_BMS_EMEA__r.Total_Budget_all_Events_BMS_EMEA__c;
                             
                             
    
    Medical_Event_vod__c meeting = [select  HCPs_registration_fees_Planned_BMS_EMEA__c,
                                            Sponsorship_of_Event_Planned_BMS_EMEA__c,
                                            Transportation_Planned_BMS_EMEA__c,
                                            Meals_Planned_BMS_EMEA__c,
                                            Hotel_Planned_BMS_EMEA__c,
                                            Other_Costs_Planned_BMS_EMEA__c,
                                            FFM_Step_BMS_EMEA__c
                                    from    Medical_Event_vod__c 
                                    where   id =: trigger.new[0].Meeting__c];
                                    
                                    
    decimal honorarium = 0;
    decimal hcpreg = meeting.HCPs_registration_fees_Planned_BMS_EMEA__c == null ? 0 : meeting.HCPs_registration_fees_Planned_BMS_EMEA__c;
    decimal sponsor = meeting.Sponsorship_of_Event_Planned_BMS_EMEA__c == null ? 0 : meeting.Sponsorship_of_Event_Planned_BMS_EMEA__c; 
    decimal transport = meeting.Transportation_Planned_BMS_EMEA__c == null ? 0 : meeting.Transportation_Planned_BMS_EMEA__c;
    decimal meals = meeting.Meals_Planned_BMS_EMEA__c == null ? 0 : meeting.Meals_Planned_BMS_EMEA__c;
    decimal hotel = meeting.Hotel_Planned_BMS_EMEA__c == null ? 0 : meeting.Hotel_Planned_BMS_EMEA__c; 
    decimal other = meeting.Other_Costs_Planned_BMS_EMEA__c == null ? 0 : meeting.Other_Costs_Planned_BMS_EMEA__c;
    string ffmstep = meeting.FFM_Step_BMS_EMEA__c;
                      
    
    
    
    //Handle error message translation
    private String Error;
    Map<String,String> labelMap = new Map<String,String>();
    ExternalString[] labels = [Select Value, Name, Category, (Select Value, language From Localization where language = :Userinfo.getLanguage()) From ExternalString  where Name = 'BMS_EMEA_Planned_Remaining_Error'];
   
    for(ExternalString label : labels)
    {
        ExternalStringLocalization[] localized = label.Localization;   
        if(localized.size() == 1)
            labelMap.put(label.Name, String.escapeSingleQuotes(localized[0].Value));
        else
            labelMap.put(label.Name, String.escapeSingleQuotes(label.value));
    } 
    
    Error = labelMap.get('BMS_EMEA_Planned_Remaining_Error') == NULL ? 'No Error Message Specified' : labelMap.get('BMS_EMEA_Planned_Remaining_Error');
    //End of error message handling
    
    
    
    
   /* otherMeetings = [select Total_Planned_BMS_EMEA__c
                     from   Medical_Event_vod__c 
                     where  Master_File_BMS_EMEA__c =: masteFileID
                     and    id <>: trigger.new[0].Meeting__c and ((Status_BMS_CORE__c != 'Cancelled') and (Status_BMS_CORE__c != 'Completed') and (Status_BMS_CORE__c != 'Closed'))];


   otherMeetings1 = [select Total_Actual_BMS_EMEA__c
                     from   Medical_Event_vod__c 
                     where  Master_File_BMS_EMEA__c =: masteFileID
                     and    id <>: trigger.new[0].Meeting__c and ((Status_BMS_CORE__c != 'Cancelled') and (Status_BMS_CORE__c != 'Approved') and (Status_BMS_CORE__c != 'Saved') and (Status_BMS_CORE__c != 'Submitted - Waiting Approval'))];
   */
    otherMeetings = [select Total_Planned_BMS_EMEA__c,Total_Actual_BMS_EMEA__c,Status_BMS_CORE__c
                     from   Medical_Event_vod__c 
                     where  Master_File_BMS_EMEA__c =: masteFileID
                     and    id <>: trigger.new[0].Meeting__c and Status_BMS_CORE__c != 'Cancelled'];
                     
    for(Medical_Event_vod__c om : otherMeetings){
         if(om.Status_BMS_CORE__c != 'Completed' && om.Status_BMS_CORE__c != 'Closed'){
             otherMeetings1.add(om);
             }
             else if(om.Status_BMS_CORE__c != 'Approved' && om.Status_BMS_CORE__c != 'Saved' && om.Status_BMS_CORE__c != 'Submitted - Waiting Approval'){
             otherMeetings2.add(om);
             }
         }  
                              
    for (Medical_Event_vod__c om : otherMeetings1) {
        otherMeetingSum = otherMeetingSum + om.Total_Planned_BMS_EMEA__c;
    }

    for (Medical_Event_vod__c om1 : otherMeetings2) {
        otherMeetingSum1 = otherMeetingSum1 + om1.Total_Actual_BMS_EMEA__c;
    }
    
    //Calculate honorarium
    otherSpeakers = [select Total_BMS_EMEA__c
                     from   Meeting_Speaker_BMS__c
                     where  Meeting__c =: trigger.new[0].Meeting__c
                     and    id <>: trigger.new[0].id ];
                     
    for(Meeting_Speaker_BMS__c ms : otherSpeakers)
    {
        otherSpeakerSum = otherSpeakerSum + ms.Total_BMS_EMEA__c;
    }
    
    //Has to be the same logic as Total_BMS_EMEA__c on Meeting_Speaker_BMS__c
    //currentHonorarium = trigger.new[0].Hourly_honorarium_rate_BMS_EMEA__c * trigger.new[0].Estimated_Duration_of_Service_hrs__c +
    //                  trigger.new[0].Hourly_honorarium_rate_BMS_EMEA__c * trigger.new[0].Estimated_Preparation_Time_hrs_BMS_EMEA__c + 
    //                  trigger.new[0].Hourly_travel_time_rate_BMS_EMEA__c * trigger.new[0].Compensated_Travel_Time_hrs_BMS_EMEA__c -
    //                  trigger.new[0].Amount_to_subtract_BMS_EMEA__c;
    //                  
    currentHonorarium = trigger.new[0].Total_BMS_EMEA__c;
    
    honorarium = currentHonorarium + otherSpeakerSum;
    
    
    //Calculate planned values of current Meeting on the fly
    totalPlanned = honorarium + hcpreg + sponsor + transport + meals + hotel + other;
    
    //Calculate actual remaining budget
    actualRemaining = totalBudgetMF - (otherMeetingSum + otherMeetingSum1) ;
    
    system.debug('ERIK current honorarium:' + currentHonorarium);
    system.debug('ERIK honorarium:' + honorarium);
    system.debug('ERIK other speaker sum:' + otherSpeakerSum);
    system.debug('ERIK other meeting sum: ' + otherMeetingSum);
    system.debug('ERIK total planned:' + totalPlanned);
    system.debug('ERIK actual remaining:' + actualRemaining);
    system.debug('ERIK total: ' + totalBudgetMF);
    
    //throw error if planned budget exceeds actual remaining budget of Master File
    if(ffmstep == 'Meeting Planning' && totalPlanned > actualRemaining)
    {
        trigger.new[0].addError(Error);  
        return;
    }
    
}