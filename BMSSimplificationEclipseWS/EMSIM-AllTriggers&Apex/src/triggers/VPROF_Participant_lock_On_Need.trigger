trigger VPROF_Participant_lock_On_Need on Participants_HCPTS__c (Before update, Before delete) {
    
    Set<Id> needIds = new Set<Id>();
    if(Trigger.isupdate){
        for(Participants_HCPTS__c p: Trigger.new){
            if(p.Budget_HCPTS__c != null){
                needIds.add(p.Budget_HCPTS__c);
            }        
        }
        
        Map<Id,EM_Budget_vod__c> needMap = new Map<id,EM_Budget_vod__c>([SELECT Id,Approval_Status_HCPTS__c FROM EM_Budget_vod__c WHERE Id IN :needIds]);
        
        // get the custom setting for Need Participant
        LockActivityChildren__c ls = LockActivityChildren__c.getInstance('Default Participant On Need');
        
        if(ls==null){return;}
        
        for(Participants_HCPTS__c p: Trigger.new){
            if(p.Budget_HCPTS__c != null && needMap.containsKey(p.Budget_HCPTS__c)){
                EM_Budget_vod__c myNeed = needMap.get(p.Budget_HCPTS__c);
                if(myNeed.Approval_Status_HCPTS__c != null){
                    if(ls.Parent_Statuses__c.contains(myNeed.Approval_Status_HCPTS__c)){
                        if(ls.EditLock__c){p.AddError(System.Label.Locked_Record_Error_Message);}
                    }
                }
            }
        }
    }
    
    if(Trigger.isDelete){
        for(Participants_HCPTS__c p: Trigger.old){
            if(p.Budget_HCPTS__c != null){
                needIds.add(p.Budget_HCPTS__c);
            }
        }
        
        Map<Id,EM_Budget_vod__c> needMap = new Map<id,EM_Budget_vod__c>([SELECT Id,Approval_Status_HCPTS__c FROM EM_Budget_vod__c WHERE Id IN :needIds]);
        
        // get the custom setting for Need Participant
        LockActivityChildren__c ls = LockActivityChildren__c.getInstance('Default Participant On Need');
        
        if(ls==null){return;}
        
        for(Participants_HCPTS__c p: Trigger.old){
            if(p.Budget_HCPTS__c != null && needMap.containsKey(p.Budget_HCPTS__c)){
                EM_Budget_vod__c myNeed = needMap.get(p.Budget_HCPTS__c);
                if(myNeed.Approval_Status_HCPTS__c != null){
                    if(ls.Parent_Statuses__c.contains(myNeed.Approval_Status_HCPTS__c)){
                        if(ls.DeleteLock__c){p.AddError(System.Label.Locked_Record_Error_Message);}
                    }
                }
            }
        }
    }
}