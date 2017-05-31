trigger MasterFile_Attachment_Validation_BMS_EMEA on Master_File_BMS_EMEA__c (before insert, before update) {
    
    map<Id, boolean> valMap = AttachmentValidationLogic_BMS_EMEA.validationlogic(trigger.new);
    
    for(Master_File_BMS_EMEA__c mf: trigger.new){
        mf.Attachment_Validated_BMS_EMEA__c = valMap.get(mf.Id);
    }

}