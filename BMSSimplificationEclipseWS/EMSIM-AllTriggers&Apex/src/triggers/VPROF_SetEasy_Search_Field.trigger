trigger VPROF_SetEasy_Search_Field on EM_Catalog_vod__c (before insert, before update) {
   Map<Id,Schema.RecordTypeInfo> rtMapById = EM_Catalog_vod__c.SObjectType.getDescribe().getRecordTypeInfosById();


    for(EM_Catalog_vod__c t: Trigger.New){
        t.Easy_Search_Field_HCPTS__c = t.Base_Language_Name_vod__c + ';' + rtMapById.get(t.RecordTypeId).getName();

        List<Schema.PicklistEntry> picklistValues = EM_Catalog_vod__c.Service_Type_HCPTS__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry pe: picklistValues) {
            //system.debug('PicklistEntry Value:' + pe.getValue() + ' Translated Label:' + pe.getLabel());
            if(pe.getValue() == t.Service_Type_HCPTS__c){
                t.Easy_Search_Field_HCPTS__c += ';' + pe.getLabel();
                break;
            }
        }

        List<Schema.PicklistEntry> picklistValues2 = EM_Catalog_vod__c.Service_Subtype__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry pe: picklistValues2) {
            //system.debug('PicklistEntry Value:' + pe.getValue() + ' Translated Label:' + pe.getLabel());
            if(pe.getValue() == t.Service_Subtype__c){
                t.Easy_Search_Field_HCPTS__c += ';' + pe.getLabel();
                break;
            }
        }


        List<Schema.PicklistEntry> picklistValues3 = EM_Catalog_vod__c.Category_HCPTS__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry pe: picklistValues3) {
            //system.debug('PicklistEntry Value:' + pe.getValue() + ' Translated Label:' + pe.getLabel());
            if(pe.getValue() == t.Category_HCPTS__c){
                t.Easy_Search_Field_HCPTS__c += ';' + pe.getLabel();
                break;
            }
        }

        if(t.Applicable_Activity_Status_HCPTS__c!=null &&
            (!t.Requires_Attachment_HCPTS__c && !t.Mandatory_HCPTS__c))  {
            t.Applicable_Activity_Status_HCPTS__c = null;
         
        } 
        t.External_Id_vod__c = t.Name_vod__c;
    }
}