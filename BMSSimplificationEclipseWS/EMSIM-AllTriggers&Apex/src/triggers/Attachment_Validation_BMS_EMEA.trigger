trigger Attachment_Validation_BMS_EMEA on Attachment (after insert, after update, after delete) {

    set<Id> masterFId = new set<Id>();
    
    if(trigger.isDelete){
        for(Attachment att:trigger.old){
            masterFId.add(att.ParentId);
        }
    }
    else{    
        for(Attachment att:trigger.new){
            masterFId.add(att.ParentId);
        }
    }
    /*Master File Validation*/
    List<Master_File_BMS_EMEA__c> masterFileList = [select Id, Attachment_Validated_BMS_EMEA__c, Country_BMS_EMEA__c, Activity_Type_BMS_EMEA__c, FFM_Step_BMS_EMEA__c from Master_File_BMS_EMEA__c where Id in:masterFId];

    map<Id, boolean> valMap = AttachmentValidationLogic_BMS_EMEA.validationlogic(masterFileList);
    
    List<Master_File_BMS_EMEA__c> mtFilelst = new List<Master_File_BMS_EMEA__c>();
    
    for(Master_File_BMS_EMEA__c mf:masterFileList){
        if(valMap.get(mf.Id) != mf.Attachment_Validated_BMS_EMEA__c){
            mf.Attachment_Validated_BMS_EMEA__c = valMap.get(mf.Id);
            mtFilelst.add(mf);
        }
    }
    update mtFilelst;
    
    
    
    /*Meeting Validation*/
    List<Medical_Event_vod__c> meetingList = [select Id, FFM_Activity_Type_BMS_EMEA__c,Attachment_Validated_BMS_EMEA__c,Country_MasterFile_BMS_EMEA__c,Activity_Type_BMS_EMEA__c,FFM_Step_BMS_EMEA__c, Event_Type__c from Medical_Event_vod__c where Id in:masterFId];

	system.debug('---- PARENT MEETING DELETED ------'+meetingList);

    map<Id, boolean> meetvalMap = AttachmentValidationLogic_BMS_EMEA.meetvalidationlogic(meetingList);
    
    system.debug('---  meevalMAP -----'+meetvalMap);
    
    List<Medical_Event_vod__c> meetlst = new List<Medical_Event_vod__c>();
    
    for(Medical_Event_vod__c mf:meetingList){
        if(meetvalMap.get(mf.Id) != mf.Attachment_Validated_BMS_EMEA__c){
            mf.Attachment_Validated_BMS_EMEA__c = meetvalMap.get(mf.Id);
            meetlst.add(mf);
        }
    }
    update meetlst;
    
    

}