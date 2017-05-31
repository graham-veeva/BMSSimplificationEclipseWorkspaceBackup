/* 
* BMS_CN_MI_UPD_REC_TYP_BEF_SUBMIT - Update record type once MI is submitted.
* Author: Roy Zhang
* Created Date: 03/02/2013
* Last Modified Date: 03/18/2013
*/ 
trigger BMS_CN_MI_UPD_REC_TYP_BEF_SUBMIT on Medical_Inquiry_vod__c (before insert, before update) {
    for(Integer i = 0; i <Trigger.new.size(); i++) {
        Medical_Inquiry_vod__c medInqNew = Trigger.new[i];
        
        // PI check
        String strProfile = [SELECT Id,Name FROM Profile WHERE Id=: UserInfo.getProfileId()].Name;
        String strRecType = [select Id,Name from RecordType where SObjectType = 'Medical_Inquiry_vod__c'  and Id =: medInqNew.RecordTypeId].Name;
        
        if(userInfo.getUserId() <> medInqNew.CreatedById && (strRecType == 'Medical Info Request' || strRecType == 'AE/Product Problem Report') && trigger.isUpdate == true) {
            Trigger.new[0].AddError('Cannot edit Medical Inquiry!');
        }
          
        if(medInqNew.Inquiry_Type_BMS_CN__c == 'Medical Info Request' || medInqNew.Inquiry_Type_BMS_CN__c == 'Adverse Event/Product Problem Report') {
            
            // Insert MI Attachment ojbect for Medical Info Request
            if(medInqNew.Attachments_ID_BMS_CN__c == null && medInqNew.Inquiry_Type_BMS_CN__c == 'Medical Info Request') {
                Med_Info_Attachments_BMS_CN__c medInqAttach = new Med_Info_Attachments_BMS_CN__c();
                insert medInqAttach;
                
                medInqNew.Attachments_ID_BMS_CN__c = medInqAttach.Id;

            } else if(medInqNew.Inquiry_Type_BMS_CN__c == 'Adverse Event/Product Problem Report'){
                medInqNew.Inquiry_Text__c = medInqNew.Narrative_BMS_CN__c;
            }   
        }
        
        // Update Medical Info Request Record Type to Locked
        if(medInqNew.Status_vod__c == 'Submitted_vod' && medInqNew.Inquiry_Type_BMS_CN__c == 'Medical Info Request') {
            Id newRecTypID = [select Id from RecordType where SObjectType = 'Medical_Inquiry_vod__c'  and Name = 'Medical Info Request(Lock)'].Id;
            medInqNew.RecordTypeId = newRecTypID;            
        }
        
        // Update AE/PQC Report Record Type to Locked
        if(medInqNew.Status_vod__c == 'Submitted_vod' && medInqNew.Inquiry_Type_BMS_CN__c == 'Adverse Event/Product Problem Report') {
            Id newRecTypID = [select Id from RecordType where SObjectType = 'Medical_Inquiry_vod__c' and Name = 'AE/Product Problem Report(Lock)'].Id;
            medInqNew.RecordTypeId = newRecTypID;            
        }
    }
}