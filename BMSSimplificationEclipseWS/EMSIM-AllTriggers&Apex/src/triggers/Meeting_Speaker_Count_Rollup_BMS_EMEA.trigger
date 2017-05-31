/** BMS ACN - October 5th : Q3 GRM Release
    @ Created by Ashok Vardhan Reddy
    
    Rationale: System should provide end users the ability to delete meeting speakers in the planning and post execustion phase.
    Trigger to add/subtract the count on meeting speakers based on creation and deletion of meeting speakers respectively by the users.
    
*/

trigger Meeting_Speaker_Count_Rollup_BMS_EMEA on Medical_Event_vod__c (before insert, before update) 
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

  for(Medical_Event_vod__c event:Trigger.new)
    event.Number_of_Speakers_BMS_EMEA__c = 0;
    
  for(Meeting_Speaker_BMS__c msc:[select id,Meeting__c from Meeting_Speaker_BMS__c where Meeting__c in :Trigger.new])
    Trigger.newMap.get(msc.Meeting__c).Number_of_Speakers_BMS_EMEA__c++;
    
}