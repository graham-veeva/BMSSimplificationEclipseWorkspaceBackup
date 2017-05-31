trigger VPROF_HCTPS_Need_Inheritance on EM_Event_Budget_vod__c (before insert, after insert) {
    System.debug('VPROF_HCTPS_Need_Inheritance');
    // Only apply this logic for single records, not bulk. The record must also have an activity and a need
    if(Trigger.new.size() > 1 || Trigger.new[0].Budget_vod__c == null || Trigger.new[0].Event_vod__c == null){return;}
    EM_Event_Budget_vod__c activityBudget = Trigger.new[0];

    // see if we have a list custom setting for this event record type
    Map<String, BMSNeedToEventInheritance__c> inheritanceSettings = BMSNeedToEventInheritance__c.getAll();

    String activityQry = CustomVeevaUtilities.getDynamicSOQLForAllEligibleFieldsWithoutFrom(EM_Event_vod__c.sObjectType);
    activityQry += ',recordType.developerName FROM EM_Event_vod__c WHERE Id = \'' + activityBudget.Event_vod__c + '\'';
    EM_Event_vod__c activity = Database.query(activityQry);

    if(!(inheritanceSettings.containsKey(activity.recordType.developerName))){
        SYstem.debug('No custom setting for this activity record type');
        return;
    }
    BMSNeedToEventInheritance__c inheritanceSetting = inheritanceSettings.get(activity.recordType.developerName);

    // see if this need record type should be included
    String needQry = CustomVeevaUtilities.getDynamicSOQLForAllEligibleFieldsWithoutFrom(EM_Budget_vod__c.sObjectType);
    needQry += ',recordType.developerName FROM EM_Budget_vod__c WHERE Id = \'' + activityBudget.Budget_vod__c + '\'';
    EM_Budget_vod__c need = Database.query(needQry);

    if(!(inheritanceSetting.Applicable_Need_Record_Types__c.contains(need.recordType.DeveloperName))){
        System.debug('Need record type not included');
        return;
    }



    // check to see if this activity already has an associated need, if it does we do not do inheritance
    if(activity.Inherited_Budget_Need_HCPTS__c != null){
        if(Trigger.isAfter && activity.Inherited_Budget_Need_HCPTS__c != need.Id){
            System.debug('Activity already has a need');
            return;
        }
        if(Trigger.isBefore){
            System.debug('Activity already has a need');
            return;
        }
    }

    // before insert - copy the header information
    if(Trigger.isInsert && Trigger.isBefore){
        // set these fields for later
        activityBudget.Failure_Inheriting_Expense_Estimates__c = false;
        activityBudget.Waiting_for_Expense_Estimate_Inheritance__c = true;
        System.debug('calling inherit header info');
        VPROF_Need_Inheritance.inheritHeaderInfo(activityBudget,activity,inheritanceSetting,need);
    }

    // after insert - copy the participants and the Expense Estimates
    if(Trigger.isInsert && Trigger.isAfter){
        
        if(inheritanceSetting.Inherit_Expense_Esimates__c){
            VPROF_Need_Inheritance.scheduleExpenseEstimateInheritance(activityBudget.Id,activity.Id,need.Id);
        }

        if(inheritanceSetting.Inherit_Participants__c){
            VPROF_Need_Inheritance.inheritParticipants(activityBudget.Id,activity.Id,need.Id);
        }
    }
}