trigger BMS_EMEA_Meeting_Approve_Reject_Once_Delete on Medical_Event_vod__c (before delete) 
{
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

   List<RecordType> recordType =
    [
        SELECT Id FROM RecordType
         WHERE DeveloperName = 'BMS_EMEA_1_Meeting_Plan' AND SObjectType = 'Medical_Event_vod__c' AND IsActive = TRUE limit 1
    ];

    if(!recordType.isempty())
    {
     String RTid = recordType[0].Id;

     for (Medical_Event_vod__c event: Trigger.old) 
     {
         if (event.RecordTypeId == RTid && event.Approved_Rejected_Once_BMS_EMEA__c == TRUE) 
          {
            event.addError(Label.BMS_EMEA_FFM_Planning_Deletion_Error);
          }
     }

     }
}