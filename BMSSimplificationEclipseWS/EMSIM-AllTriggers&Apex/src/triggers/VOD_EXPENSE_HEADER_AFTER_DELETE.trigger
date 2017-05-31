trigger VOD_EXPENSE_HEADER_AFTER_DELETE on Expense_Header_vod__c (after delete) {
    List<String> header_ids = new List<String>();
    Set<Id> speakersToRollup = new Set<Id>();
    Set<Id> accountIds = new Set<Id>();
    Set<Id> eventSpeakerIds = new Set<Id>();
    Set<Id> eventBudgetsToRollup = new Set<Id>();
    Set<Id> eventIds = new Set<Id>();

    for (Expense_Header_vod__c header: Trigger.Old) {
        if (header.Incurred_Expense_Speaker_vod__c != null) {
            eventSpeakerIds.add(header.Incurred_Expense_Speaker_vod__c);
        } else if (header.Incurred_Expense_Account_vod__c != null){
        	accountIds.add(header.Incurred_Expense_Account_vod__c);
        }
    }

    List<Expense_Line_vod__c> lines = [SELECT Event_Budget_vod__c, Event_vod__c FROM Expense_Line_vod__c WHERE Expense_Header_vod__c IN :Trigger.OldMap.keyset()];

        for(Expense_Line_vod__c line: lines) {
            eventIds.add(line.Event_vod__c);
            eventBudgetsToRollup.add(line.Event_Budget_vod__c);
        }

    List<Expense_Attribution_vod__c> attributions = [SELECT Incurred_Expense_Speaker_vod__c, Incurred_Expense_Speaker_vod__r.Speaker_vod__c,
                                                     Incurred_Expense_Account_vod__c, Incurred_Expense_Attendee_vod__r.Account_vod__c
                                                     FROM Expense_Attribution_vod__c
                                                     WHERE Expense_Line_vod__r.Expense_Type_vod__r.Included_In_Speaker_Cap_vod__c = true
                                                     AND Expense_Line_vod__r.Expense_Header_vod__c IN :Trigger.OldMap.keyset()
                                                     AND (Incurred_Expense_Speaker_vod__c != null OR Incurred_Expense_Account_vod__c != null OR Incurred_Expense_Attendee_vod__r.Account_vod__c != null)];

    for(Expense_Attribution_vod__c attr: attributions) {
        if(attr.Incurred_Expense_Speaker_vod__c != null) {
            eventSpeakerIds.add(attr.Incurred_Expense_Speaker_vod__c);
        } else if(attr.Incurred_Expense_Account_vod__c != null) {
            accountIds.add(attr.Incurred_Expense_Account_vod__c);
        } else if (attr.Incurred_Expense_Attendee_vod__r.Account_vod__c != null) {
            accountIds.add(attr.Incurred_Expense_Attendee_vod__r.Account_vod__c);
        }
    }

    for(EM_Event_Speaker_vod__c eventSpeaker: [SELECT Speaker_vod__c FROM EM_Event_Speaker_vod__c WHERE Id IN :eventSpeakerIds AND Speaker_vod__c != null]) {
        speakersToRollup.add(eventSpeaker.Speaker_vod__c);
    }

    for(EM_Speaker_vod__c speaker: [SELECT Id FROM EM_Speaker_vod__c WHERE Account_vod__c IN :accountIds]) {
    	speakersToRollup.add(speaker.Id);
    }
	    
    List<Expense_Header_vod__Share> headerShares = [SELECT ParentId, UserOrGroupId, AccessLevel, RowCause FROM Expense_Header_vod__Share WHERE ParentId IN :Trigger.OldMap.keyset()];
    List<Database.DeleteResult> deleteResults = Database.delete(headerShares, false);
    for(Database.DeleteResult result: deleteResults){
        if(!result.isSuccess()){
            system.debug('delete error: ' + result.getErrors()[0]);
        }
    }
    
    if (!speakersToRollup.isEmpty()) {
        SpeakerYTDCalculator.calculate(speakersToRollup);
    }  

    if (!eventBudgetsToRollup.isEmpty()) {
        VOD_EXPENSE_LINE_TRIG.calculateEventBudgets(eventBudgetsToRollup);
    }

    if(!eventIds.isEmpty()) {
    	VOD_EXPENSE_LINE_TRIG.calculateRollUptoEvent(eventIds);
        List<EM_Event_vod__c> eventsToUpdate = new List<EM_Event_vod__c>();
        eventsToUpdate = VOD_EVENT_UTILS.rollupCountsToEvent(eventIds);
        update eventsToUpdate;
    }
}