trigger VPROF_Clear_Inherited_Budget_On_Delete on EM_Event_Budget_vod__c (Before Delete) {
    List<EM_Event_vod__c> activitiesToUpdate = new List<EM_Event_vod__c>();
    Set<Id> activityIds = new Set<Id>();
    Map<Id,Id> eventToBudget = new Map<Id,Id>();
    Map<Id,EM_Event_Budget_vod__c> idToBudget = new Map<Id,EM_Event_Budget_vod__c>();
    for(EM_Event_Budget_vod__c budget :Trigger.old){
        activityIds.add(budget.Event_vod__c);
        idToBudget.put(budget.Id,budget);
    }
    List<EM_Event_vod__c> activities = [SELECT Id,Inherited_Budget_Need_HCPTS__c FROM EM_Event_vod__c WHERE Id IN: activityIds];
    
    for(EM_Event_Budget_vod__c budget :Trigger.old){
        eventToBudget.put(budget.Event_vod__c,budget.Id);
    }
    
    for(EM_Event_Budget_vod__c budget :Trigger.old){
        if(budget.Is_Need__c){
            // find activity
            for(EM_Event_vod__c act: activities){
                if(budget.Event_vod__c == act.Id && budget.Budget_vod__c == act.Inherited_Budget_Need_HCPTS__c){
                    act.Inherited_Budget_Need_HCPTS__c = null;
                    activitiesToUpdate.add(act);
                    break;
                }
            }
        }
    }

    List<Database.SaveResult> results = Database.update(activitiesToUpdate,false);
    System.debug(results);
    /*for(Database.SaveResult result : results){
        if(!result.isSuccess()){
            EM_Event_Budget_vod__c budget = new EM_Event_Budget_vod__c();
            System.debug(eventToBudget);
            System.debug('result: ' + result.getId());
            System.debug('result Id: ' + result.getId());
            Id budgetId = eventToBudget.get(result.getId());
            System.debug(budgetId);
            budget = idToBudget.get(budgetId);
            System.debug(result.getErrors()[0].getMessage());
            budget.addError(result.getErrors()[0].getMessage());
        }
    }*/

    for (Integer i = 0; i < activitiesToUpdate.size(); i++) {
        Database.SaveResult result = results[i];
        EM_Event_vod__c origRecord = activitiesToUpdate[i];
        if (!result.isSuccess()) {
            EM_Event_Budget_vod__c budget = new EM_Event_Budget_vod__c();
            Id budgetId = eventToBudget.get(origRecord.Id);
            budget = idToBudget.get(budgetId);
            budget.addError(result.getErrors()[0].getMessage());
        } 
    }
    
}