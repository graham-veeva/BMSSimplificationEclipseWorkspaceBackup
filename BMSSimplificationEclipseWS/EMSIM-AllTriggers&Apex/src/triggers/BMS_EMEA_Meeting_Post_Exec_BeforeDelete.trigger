/* BMS ACN : March 2015 - Trigger to avoid deletion of Meetings in the Post Execustion Phase
   Created by Ashok - 13.03.2015
   
   Rationale: End Users have the ability to delete the meetings only in the Planning Phase. Even though, DELETE button is NOT enabled for the end users during the Post Execustion Phase, 
   they can still be able to delete the meetings using the "DEL" link on the Meetings View Page. So, to avoid such deletions -  
   the below trigger is created which will throw an error when an user tries to delete a meeting in the Meeting Post Execution Phase thereby preventing the same.
   
*/

trigger BMS_EMEA_Meeting_Post_Exec_BeforeDelete on Medical_Event_vod__c (before delete) 
{

   List<RecordType> recordType =
    [
        SELECT Id FROM RecordType
         WHERE DeveloperName = 'BMS_EMEA_2_Meeting_Post_Execution' AND SObjectType = 'Medical_Event_vod__c' AND IsActive = TRUE limit 1
    ];

    if(!recordType.isempty())
    {
     String RTid = recordType[0].Id;

     for (Medical_Event_vod__c event: Trigger.old) 
     {
         if (event.RecordTypeId == RTid) 
          {
            event.addError(Label.BMS_EMEA_FFM_Post_Exec_Deletion_Error);
          }
     }

     }
}