trigger MeetingDocTemp_Attachment_Validation_BMS_EMEA on Meeting_Document_Template__c (after insert, after update) {

    set<string> country = new set<string>();
    set<string> activity = new set<string>();
    set<string> ffmstep = new set<string>();
    set<string> evtType = new set<string>();
    List<Master_File_BMS_EMEA__c> masterFileList = new List<Master_File_BMS_EMEA__c>();
    List<Medical_Event_vod__c> medEvtList = new List<Medical_Event_vod__c>();

    for(Meeting_Document_Template__c mdt:trigger.new){
            country.add(mdt.Country_Specific_BMS_EMEA__c);
            activity.add(mdt.Activity_Type_BMS_EMEA__c);
            ffmstep.add(mdt.FFM_Step_BMS_EMEA__c);
            evtType.add(mdt.Meeting_Type__c);
    }
    
    /*Master File*/
    List<Master_File_BMS_EMEA__c> mtFilelst = [select Id, Attachment_Validated_BMS_EMEA__c, Country_BMS_EMEA__c, Activity_Type_BMS_EMEA__c, FFM_Step_BMS_EMEA__c from Master_File_BMS_EMEA__c where Country_BMS_EMEA__c in:country and Activity_Type_BMS_EMEA__c in:activity and FFM_Step_BMS_EMEA__c in:ffmstep];

    for(Meeting_Document_Template__c mdt:trigger.new){    
        for(Master_File_BMS_EMEA__c mf:mtFilelst){
            
            if(mf.FFM_Step_BMS_EMEA__c == mdt.FFM_Step_BMS_EMEA__c && mf.Activity_Type_BMS_EMEA__c == mdt.Activity_Type_BMS_EMEA__c && mdt.Country_Specific_BMS_EMEA__c == mf.Country_BMS_EMEA__c){
                masterFileList.add(mf);
            }
            
        }    
    }
        
    map<Id, boolean> valMap = AttachmentValidationLogic_BMS_EMEA.validationlogic(masterFileList);
    
    mtFilelst = new List<Master_File_BMS_EMEA__c>();
    
    for(Master_File_BMS_EMEA__c mf:masterFileList){
        if(valMap.get(mf.Id) != mf.Attachment_Validated_BMS_EMEA__c){
            mf.Attachment_Validated_BMS_EMEA__c = valMap.get(mf.Id);
            mtFilelst.add(mf);
        }
    }
    update mtFilelst;
    
    /*Meeting*/
List<Medical_Event_vod__c> meetlst = [select Id,FFM_Activity_Type_BMS_EMEA__c, Attachment_Validated_BMS_EMEA__c,Country_MasterFile_BMS_EMEA__c,Activity_Type_BMS_EMEA__c,FFM_Step_BMS_EMEA__c ,Event_Type__c from Medical_Event_vod__c where Country_MasterFile_BMS_EMEA__c in:country and FFM_Step_BMS_EMEA__c in:ffmstep and Activity_Type_BMS_EMEA__c in:activity];
    for(Meeting_Document_Template__c mdt:trigger.new){    
        for(Medical_Event_vod__c mf:meetlst){            
            
          //  if(mf.Event_Type__c == mdt.Meeting_Type__c){
           if(mf.FFM_Step_BMS_EMEA__c == mdt.FFM_Step_BMS_EMEA__c && mf.Activity_Type_BMS_EMEA__c == mdt.Activity_Type_BMS_EMEA__c && mdt.Country_Specific_BMS_EMEA__c == mf.Country_MasterFile_BMS_EMEA__c ){  
                medEvtList.add(mf);
            }            
        }    
    }
        
    map<Id, boolean> meetvalMap = AttachmentValidationLogic_BMS_EMEA.meetvalidationlogic(medEvtList);
    
    meetlst = new List<Medical_Event_vod__c>();
    
    for(Medical_Event_vod__c mf:medEvtList){
        if(meetvalMap.get(mf.Id) != mf.Attachment_Validated_BMS_EMEA__c){
            mf.Attachment_Validated_BMS_EMEA__c = meetvalMap.get(mf.Id);
            meetlst.add(mf);
        }
    }
    update meetlst;
    
    
}