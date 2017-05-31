/**
* Created Week of Feb 9th, 2016 (Kevin Neary, Murugesh Naidu)
* Checks to see if Materials that need attachment or Action items that need completion are done prior to moving 
* to applicable status
*/
trigger VPROF_Check_Required_Materials_BeforeUpdate on EM_Event_vod__c (before update) {

    // make sure that all of the event materials that are required have attachments before going into archive status
    //Also ensure all Action Items have been crossed off
    
//  Set<Id> eventIdsNeedingAttachment = new Set<Id>();
    Map<Id, EM_Event_Material_vod__c> reqdEventMaterialsMap = new Map<Id, EM_Event_Material_vod__c>(
                            [SELECT Id, Name, Applicable_Activity_Status_HCPTS__c, 
                                Event_vod__r.Status_vod__c, Event_vod__c, Mandatory_HCPTS__c,Requires_Attachment_HCPTS__c,
                                Mandated_Completion_Status_HCPTS__c, Actual_Completion_Status_HCPTS__c, Name_vod__c
                                FROM EM_Event_Material_vod__c 
                                WHERE Event_vod__c IN: Trigger.newMap.keySet() 
                                 AND (Requires_Attachment_HCPTS__c = true OR Mandatory_HCPTS__c = true)]);
   
    //System.debug('Event status from mterial=');
    Map<Id,List<EM_Event_Material_vod__c>> eventToMaterials = new Map<Id,List<EM_Event_Material_vod__c>>();
    String thisNodeUrl = URL.getSalesforceBaseUrl().toExternalForm() ;
    for(EM_Event_Material_vod__c em: reqdEventMaterialsMap.values()){
        String eventNewStatus = Trigger.newMap.get(em.Event_vod__c).Status_vod__c;
    //System.debug('Event current status from mterial=' + em.Event_vod__r.Status_vod__c);
    //System.debug('Event new status =' + Trigger.newMap.get(em.Event_vod__c).Status_vod__c);
        if(em.Applicable_Activity_Status_HCPTS__c == eventNewStatus){
            if((em.Mandatory_HCPTS__c!=null && em.Mandatory_HCPTS__c)

            && (em.Mandated_Completion_Status_HCPTS__c!=null)
            &&  ( em.Actual_Completion_Status_HCPTS__c == null || !em.Mandated_Completion_Status_HCPTS__c.contains(em.Actual_Completion_Status_HCPTS__c)
                 )
            )
            {
                Trigger.newMap.get(em.Event_vod__c).addError(Label.ActionItemNeedsCompletion + em.Name_vod__c + Label.ActionItemNeedsCompletion2 + ' ' + em.Mandated_Completion_Status_HCPTS__c, true);               
            }
  //          eventIdsNeedingAttachment.add(em.Event_vod__c);
            if((em.Requires_Attachment_HCPTS__c!=null && em.Requires_Attachment_HCPTS__c)){
                if(eventToMaterials.containsKey(em.Event_vod__c)){
                    eventToMaterials.get(em.Event_vod__c).add(em);
                }
                else{
                    eventToMaterials.put(em.Event_vod__c, new List<EM_Event_Material_vod__c> {em});
                }
            }
        }
    }
//  if(eventIdsNeedingAttachment == null || eventIdsNeedingAttachment.size() == 0){
//      return;
//  }
    
    
 /*   for(EM_Event_vod__c event: Trigger.new){
        if(event.Status_vod__c == 'Archived'){
            eventIdsNeedingAttachment.add(event.Id);
        }
    }


    List<EM_Event_Material_vod__c> eventMaterials = [SELECT Id,Event_vod__c FROM EM_Event_Material_vod__c WHERE Event_vod__c IN: eventIdsNeedingAttachment AND Requires_Attachment_HCPTS__c = true];
    for(EM_Event_Material_vod__c em: eventMaterials){
        if(eventToMaterials.containsKey(em.Event_vod__c)){
            eventToMaterials.get(em.Event_vod__c).add(em);
        }else{
            eventToMaterials.put(em.Event_vod__c,new List<EM_Event_Material_vod__c>{em});
        }
    }
*/
    Map<Id,List<Attachment>> materialToAttachments = new Map<Id,List<Attachment>>();
    List<Attachment> attachments = [SELECT Id,ParentId FROM Attachment WHERE parentId IN: reqdEventMaterialsMap.keySet()];
    for(Attachment a: attachments){
        if(materialToAttachments.containsKey(a.parentId)){
            materialToAttachments.get(a.parentId).add(a);
        }else{
            materialToAttachments.put(a.parentId,new List<Attachment>{a});
        }
    }

    for(EM_Event_vod__c event: Trigger.new){
        if(eventToMaterials.containsKey(event.Id)){
            List<EM_Event_Material_vod__c> thisEventsMaterials = eventToMaterials.get(event.Id);
            for(EM_Event_Material_vod__c em: thisEventsMaterials){
                if(materialToAttachments.containsKey(em.Id)){
                    List<Attachment> thisMaterialsAttachments = materialToAttachments.get(em.Id);
                    if(thisMaterialsAttachments == null || thisMaterialsAttachments.size() == 0){
                //      event.addError(Label.MaterialNeedsAttachmentError);
                        event.addError(Label.MaterialNeedsAttachmentError + ' ' + em.Name_vod__c , true);             
                    }
                }else{
                        event.addError(Label.MaterialNeedsAttachmentError + ' ' + em.Name_vod__c , true);             
                }
            }
        }
    }

}