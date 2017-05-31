trigger VPROF_Business_Approval_Requirements on EM_Event_vod__c (after update) {
    
    List<Id> eventIds = new List<Id>();
    
    for(EM_Event_vod__c event: Trigger.new){
        if(event.Status_vod__c == 'In Business Approval'){
            eventIds.add(event.Id);
        }
    }

    if(eventIds.size() == 0){
        return;
    }
    
    Map<Id,EM_Event_vod__c> eventMap = new Map<Id,EM_Event_vod__c>([SELECT Id,Recordtype.developerName FROM EM_Event_vod__c WHERE Id IN :eventIds]);

    List<EM_Event_Speaker_vod__c> activitySpeakerList = new List<EM_Event_Speaker_vod__c>([SELECT Id,Event_vod__c FROM EM_Event_Speaker_vod__c WHERE Event_vod__c IN :eventIds]);
    List<EM_Event_Budget_vod__c> activityBudgetList = new List<EM_Event_Budget_vod__c>([SELECT Id,Event_vod__c FROM EM_Event_Budget_vod__c WHERE Event_vod__c IN :eventIds]);
    List<EM_Expense_Estimate_vod__c> expEstList = new List<EM_Expense_Estimate_vod__c>([SELECT Id,Event_vod__c FROM EM_Expense_Estimate_vod__c WHERE Event_vod__c IN :eventIds]);
    List<EM_Attendee_vod__c> audList = new List<EM_Attendee_vod__c>([SELECT Id,Event_vod__c FROM EM_Attendee_vod__c WHERE Event_vod__c IN :eventIds]);
    
    for(EM_Event_vod__c event: Trigger.new){
        
        if(event.Status_vod__c == 'In Business Approval'){
            
            boolean hasActivitySpeaker = false;
            boolean hasActivityBudget = false;
            boolean hasExpEst = false;
            boolean hasAud = false;

            for(EM_Event_Speaker_vod__c p: activitySpeakerList){
                if(p.Event_vod__c == event.Id){hasActivitySpeaker = true;}
            }
            for(EM_Event_Budget_vod__c p: activityBudgetList){
                if(p.Event_vod__c == event.Id){hasActivityBudget = true;}
            }
            for(EM_Expense_Estimate_vod__c p: expEstList){
                if(p.Event_vod__c == event.Id){hasExpEst = true;}
            }
            for(EM_Attendee_vod__c p: audList){
                if(p.Event_vod__c == event.Id){
                    hasAud = true;
                }
                
                
            }
            EM_Event_vod__c eventWithRecType = eventMap.get(event.Id);
            if(eventWithRecType.recordtype.developerName != 'Preceptorship' && eventWithRecType.recordtype.developerName != 'HCP_Sponsorship'){
                hasAud = true;
            }
            if(eventWithRecType.recordtype.developerName == 'HCP_Sponsorship' || eventWithRecType.recordtype.developerName == 'Standard_Rep_Presentation'){
                hasActivitySpeaker = true;
            }

            if(!hasActivitySpeaker || !hasActivityBudget || !hasExpEst || !hasAud){
                event.addError(System.Label.Business_Approval_Requirements_Error);
            }
        }
    }
}