trigger MeetingRecordTypeDelete_BMS_EMEA on Medical_Event_vod__c (before insert, before update) {

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


    public List<Attachment> OldAttachments;
    public Set<Id> allMedicalEventIds = new Set<Id>();
    public Medical_Event_vod__c beforeUpdateME;
    public Id medicalEvent1RecordTypeId = [select Id, DeveloperName from RecordType where SobjectType = 'Medical_Event_vod__c' and DeveloperName = 'BMS_EMEA_1_Meeting_Plan'].Id;
    public Id medicalEvent2RecordTypeId = [select Id, DeveloperName from RecordType where SobjectType = 'Medical_Event_vod__c' and DeveloperName = 'BMS_EMEA_2_Meeting_Post_Execution'].Id;
    public Map<Id, String> mapToUpdate = new Map<Id, String>();

    if (trigger.IsUpdate) {

        //for (Medical_Event_vod__c ME : Trigger.new) {
        for (Medical_Event_vod__c ME : newMeetingsList) {

            ME.MeetingRecordTypeDelete_BMS_EMEA__c = (ME.MeetingRecordTypeDelete_BMS_EMEA__c == null) ? 'test' : ME.MeetingRecordTypeDelete_BMS_EMEA__c;

            beforeUpdateME = System.Trigger.oldMap.get(ME.Id);

            //Remove REcordtype reference and use FFM_BMS_Step instead
            //if(beforeUpdateME.RecordTypeId == medicalEvent1RecordTypeId && ME.RecordTypeId == medicalEvent2RecordTypeId){
            if (beforeUpdateME.FFM_Step_BMS_EMEA__c == 'Meeting Planning' && ME.FFM_Step_BMS_EMEA__c == 'Meeting Post-Execution') {

                allMedicalEventIds.add(ME.Id);
            }
        }


        OldAttachments = [SELECT Id FROM Attachment where ParentId in: allMedicalEventIds];

        for (Medical_Event_vod__c loopME : [select id, MeetingRecordTypeDelete_BMS_EMEA__c, (select id from Attachments) from Medical_Event_vod__c where
                                            Id in: allMedicalEventIds]) {
            loopME.MeetingRecordTypeDelete_BMS_EMEA__c = (loopME.MeetingRecordTypeDelete_BMS_EMEA__c == null) ? '' : loopME.MeetingRecordTypeDelete_BMS_EMEA__c;

            for (Attachment att : loopME.Attachments) {
                loopME.MeetingRecordTypeDelete_BMS_EMEA__c += (!loopME.MeetingRecordTypeDelete_BMS_EMEA__c.contains(att.Id)) ? ' ,' + att.Id : '';
            }
            mapToUpdate.put(loopME.Id, loopME.MeetingRecordTypeDelete_BMS_EMEA__c);
        }

        for (Medical_Event_vod__c ME2 : newMeetingsList) {

            beforeUpdateME = System.Trigger.oldMap.get(ME2.Id);

            //Remove REcordtype reference and use FFM_BMS_Step instead
            //if(beforeUpdateME.RecordTypeId == medicalEvent1RecordTypeId && ME2.RecordTypeId == medicalEvent2RecordTypeId){
            if (beforeUpdateME.FFM_Step_BMS_EMEA__c == 'Meeting Planning' && ME2.FFM_Step_BMS_EMEA__c == 'Meeting Post-Execution') {
                ME2.MeetingRecordTypeDelete_BMS_EMEA__c =  (mapToUpdate.get(ME2.Id) != null) ? mapToUpdate.get(ME2.Id) : '';
            }
        }

    } else {

        for (Medical_Event_vod__c ME : newMeetingsList) {
            ME.MeetingRecordTypeDelete_BMS_EMEA__c = (ME.MeetingRecordTypeDelete_BMS_EMEA__c == null) ? 'test' : ME.MeetingRecordTypeDelete_BMS_EMEA__c;
        }
    }
}