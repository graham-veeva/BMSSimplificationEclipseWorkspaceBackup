trigger Check_Required_Documents on Medical_Event_vod__c (before update) {
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
    Map<String,Medical_Event_vod__c> closingEvents = new Map<String, Medical_Event_vod__c>();
    String closeOutRecordTypeID = [SELECT Id, Name,SobjectType FROM RecordType WHERE SobjectType = 'Medical_Event_vod__c' AND Name = '4. Close Out' LIMIT 1].Id;
    
    for (Medical_Event_vod__c me : trigger.new) {
        if (me.RecordTypeId == closeOutRecordTypeID && me.Has_All_Documents_BMS__c == false) {
            me.addError('Meeting must have all required documents before closing out.');
        }
    }

}