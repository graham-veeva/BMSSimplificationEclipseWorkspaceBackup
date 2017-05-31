trigger VPROF_Close_Out_Requirements on EM_Event_vod__c (before Update) {
    
    List<Id> eventIDs = new List<Id>();
    Set<Id> alreadyInCloseout = new Set<Id>();
    Set<Id> closedEvents = new Set<Id>();

    // find out what activities are already in closeout: we don't want the trigger to add errors to these
    for(EM_Event_vod__c event: Trigger.old){
        if(event.Status_vod__c == 'In Closeout'){
            alreadyInCloseout.add(event.Id);
        }else if(event.Status_vod__c == 'closed_vod'){
            closedEvents.add(event.Id);
        }
    }

    for(EM_Event_vod__c event: Trigger.new){
        if(event.Status_vod__c == 'In Closeout'){
            if(!alreadyInCloseout.contains(event.Id)){
                eventIDs.add(event.Id);
            }
        }
    }

    if(eventIDs.size() == 0){
        return;
    }

    // if the curent user is a sys admin, do not prevent changes
    Id myProfId = userinfo.getProfileId();
    Profile prof = [SELECT Id,PermissionsModifyAllData FROM Profile WHERE Id = :myProfId];
    if(prof.PermissionsModifyAllData == true){
        return;
    }

    List<Expense_Header_vod__c> expHeaderList = new List<Expense_Header_vod__c>([SELECT Id,Status_vod__c FROM Expense_Header_vod__c WHERE Event_vod__c IN :eventIDs]);

    for(EM_Event_vod__c event: Trigger.new){
        if(event.Status_vod__c == 'In Closeout'){
            if(!closedEvents.contains(event.Id)){
                for(Expense_Header_vod__c e: expHeaderList){
                    if(e.Status_vod__c == 'Draft' || e.Status_vod__c == 'PO Requested' || e.Status_vod__c == 'PO Pending'){
                        event.addError(System.label.Activity_Close_Out_Requirements_Error);
                    }
                }
            }
        }
    }
}