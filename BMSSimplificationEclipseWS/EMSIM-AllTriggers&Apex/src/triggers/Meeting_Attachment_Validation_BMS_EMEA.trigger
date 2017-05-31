trigger Meeting_Attachment_Validation_BMS_EMEA on Medical_Event_vod__c (before insert, before update) {

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

    // Modified by: <raphael.krausz@veeva.com>
    // Modified date: 2014-12-15
    // We only want those meetings which are FFM - replaced Trigger.new with newMeetingsList in below code.
    List<Medical_Event_vod__c> newMeetingsList = new List<Medical_Event_vod__c>();
    for (Medical_Event_vod__c meeting : Trigger.new) {
        if (meeting.FFM_Step_BMS_EMEA__c != null) {
            newMeetingsList.add(meeting);
        }
    }

    Map<Id, Boolean> valMap = AttachmentValidationLogic_BMS_EMEA.meetvalidationlogic(newMeetingsList);
    
    for (Medical_Event_vod__c mf : newMeetingsList) {
        mf.Attachment_Validated_BMS_EMEA__c = valMap.get(mf.Id);
    }

}