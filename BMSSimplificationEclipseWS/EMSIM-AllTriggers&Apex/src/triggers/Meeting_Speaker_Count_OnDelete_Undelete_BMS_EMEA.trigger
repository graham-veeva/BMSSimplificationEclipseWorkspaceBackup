/** BMS ACN - October 5th : Q3 GRM Release
    @ Created by Ashok Vardhan Reddy
    
    Rationale: System should provide end users the ability to delete meeting speakers in the planning and post execustion phase.
    Trigger to add/subtract the count on meeting speakers based on creation and deletion of meeting speakers respectively by the users.
    
*/

trigger Meeting_Speaker_Count_OnDelete_Undelete_BMS_EMEA on Meeting_Speaker_BMS__c (after delete, after undelete) 
{
  Map<Id,Medical_Event_vod__c> speakers = new Map<Id,Medical_Event_vod__c>();
  
  if(Trigger.new<>null)
  
    for(Meeting_Speaker_BMS__c ms:Trigger.new)
    
      if(ms.Meeting__c<>null)
      
        speakers.put(ms.Meeting__c,new Medical_Event_vod__c(id=ms.Meeting__c));
        
   if(Trigger.old<>null)
   
     for(Meeting_Speaker_BMS__c ms:Trigger.old)
     
       if(ms.Meeting__c<>null)      
        
        speakers.put(ms.Meeting__c,new Medical_Event_vod__c(id=ms.Meeting__c));
        
  update speakers.values();
}