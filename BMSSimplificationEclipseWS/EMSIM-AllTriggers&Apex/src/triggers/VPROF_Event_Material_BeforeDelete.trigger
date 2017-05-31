trigger VPROF_Event_Material_BeforeDelete on EM_Event_Material_vod__c (before delete) {
    for(EM_Event_Material_vod__c em: Trigger.old){
        if(em.Requires_Attachment_HCPTS__c || em.Mandatory_HCPTS__c){
            em.addError(label.EventMaterialDeleteError);
        }
    }
}