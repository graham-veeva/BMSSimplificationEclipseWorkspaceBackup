trigger BMS_EMEA_PlannedCostsLessRemainingBudget on Medical_Event_vod__c  (before insert, before update) {

    //code block to check if this transaction belongs to legacy Medical Events or new Events Management module
  //Added by Murugesh Naidu (murugesh.naidu@veeva.com) Nov 12, 2015
  //Assumes that groups will either use EM_Event_vod or Medical_Event_vod as the primary starting point and not both
  if(Trigger.isDelete){
        if(Trigger.old[0].EM_Event_vod__c!=null){
            return;
        }
    }
    else{
        if(Trigger.new[0].EM_Event_vod__c!=null){
            return;
        }    
    }

    // If there is no MasterFile - then do not run this trigger
    // Modified by: <raphael.krausz@veeva.com>
    // Modified date: 2014-12-15
    if (Trigger.new[0].Master_File_BMS_EMEA__c == null) {
        return;
    }


    //replacement of validation rule BMS_EMEA_PlannedCostsLessRemainingBudget

    decimal remainingBudget = [select Remaining_Budget_BMS_EMEA__c from Master_File_BMS_EMEA__c where id = : trigger.new[0].Master_File_BMS_EMEA__c].Remaining_Budget_BMS_EMEA__c; // not part of the calculation anymore, actualRemaining is used
    decimal totalBudgetMF = [select Total_Budget_all_Events_BMS_EMEA__c from Master_File_BMS_EMEA__c where id = : trigger.new[0].Master_File_BMS_EMEA__c].Total_Budget_all_Events_BMS_EMEA__c;
    decimal totalPlanned = 0;
    decimal actualRemaining = 0;

    decimal honorarium = trigger.new[0].Honorarium_Planned_BMS_EMEA__c == null ? 0 : trigger.new[0].Honorarium_Planned_BMS_EMEA__c;
    decimal hcpreg = trigger.new[0].HCPs_registration_fees_Planned_BMS_EMEA__c == null ? 0 : trigger.new[0].HCPs_registration_fees_Planned_BMS_EMEA__c;
    decimal sponsor = trigger.new[0].Sponsorship_of_Event_Planned_BMS_EMEA__c == null ? 0 : trigger.new[0].Sponsorship_of_Event_Planned_BMS_EMEA__c;
    decimal transport = trigger.new[0].Transportation_Planned_BMS_EMEA__c == null ? 0 : trigger.new[0].Transportation_Planned_BMS_EMEA__c;
    decimal meals = trigger.new[0].Meals_Planned_BMS_EMEA__c == null ? 0 : trigger.new[0].Meals_Planned_BMS_EMEA__c;
    decimal hotel = trigger.new[0].Hotel_Planned_BMS_EMEA__c == null ? 0 : trigger.new[0].Hotel_Planned_BMS_EMEA__c;
    decimal other = trigger.new[0].Other_Costs_Planned_BMS_EMEA__c == null ? 0 : trigger.new[0].Other_Costs_Planned_BMS_EMEA__c;

    private String Error;

   list<Medical_Event_vod__c> otherMeetings = new list<Medical_Event_vod__c>();
   list<Medical_Event_vod__c> otherMeetings1 = new list<Medical_Event_vod__c>();
   list<Medical_Event_vod__c> otherMeetings2 = new list<Medical_Event_vod__c>();
   decimal otherMeetingSum = 0;
   decimal otherMeetingSum1 = 0;


    //Handle error message translation
    Map<String, String> labelMap = new Map<String, String>();
    ExternalString[] labels = [Select Value, Name, Category, (Select Value, language From Localization where language = :Userinfo.getLanguage()) From ExternalString  where Name = 'BMS_EMEA_Planned_Remaining_Error'];

    for (ExternalString label : labels) {
        ExternalStringLocalization[] localized = label.Localization;
        if (localized.size() == 1)
            labelMap.put(label.Name, String.escapeSingleQuotes(localized[0].Value));
        else
            labelMap.put(label.Name, String.escapeSingleQuotes(label.value));
    }

    Error = labelMap.get('BMS_EMEA_Planned_Remaining_Error') == NULL ? 'No Error Message Specified' : labelMap.get('BMS_EMEA_Planned_Remaining_Error');
    //End of error message handling


       //Capture other related meeting planned totals to calculate real remaining budget
  /* otherMeetings = [select Total_Planned_BMS_EMEA__c
                     from   Medical_Event_vod__c
                     where  Master_File_BMS_EMEA__c = : trigger.new[0].Master_File_BMS_EMEA__c
                             and    id <>: trigger.new[0].id and ((Status_BMS_CORE__c != 'Cancelled') and (Status_BMS_CORE__c != 'Completed') and (Status_BMS_CORE__c != 'Closed'))];


   otherMeetings1 = [select Total_Actual_BMS_EMEA__c
                     from   Medical_Event_vod__c
                     where  Master_File_BMS_EMEA__c = : trigger.new[0].Master_File_BMS_EMEA__c
                             and    id <>: trigger.new[0].id and ((Status_BMS_CORE__c != 'Cancelled') and (Status_BMS_CORE__c != 'Approved') and (Status_BMS_CORE__c != 'Saved') and (Status_BMS_CORE__c != 'Submitted - Waiting Approval'))];
     */  
     
    otherMeetings = [select Total_Planned_BMS_EMEA__c,Total_Actual_BMS_EMEA__c,Status_BMS_CORE__c
                     from   Medical_Event_vod__c
                     where  Master_File_BMS_EMEA__c = : trigger.new[0].Master_File_BMS_EMEA__c and id <>: trigger.new[0].id and Status_BMS_CORE__c != 'Cancelled'];
                     
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
        
    //Calculate planned values of current Meeting on the fly
    totalPlanned = honorarium + hcpreg + sponsor + transport + meals + hotel + other;

    //Calculate the actual remaining budget of Master File
    actualRemaining = totalBudgetMF - (otherMeetingSum + otherMeetingSum1) ;

    //system.debug('ERIK other meetings sum: ' + otherMeetingSum);
    //system.debug('ERIK total planned: ' + totalPlanned);
    //system.debug('ERIK remaining: ' + remainingBudget);
    //system.debug('ERIK actual remaining: ' + actualRemaining);

    //throw error if planned budget exceeds actual remaining budget of Master File
    if (trigger.new[0].FFM_Step_BMS_EMEA__c == 'Meeting Planning' && totalPlanned > actualRemaining) {
        trigger.new[0].addError(Error);
        return;
    }
}