trigger Meeting_Speaker_Delete_BMS on Meeting_Speaker_BMS__c (before delete) {
    List<Id> meetingIds = new List<Id>();
    List<Id> speakerIds = new List<id>();
    for (Meeting_Speaker_BMS__c ms : trigger.old) {
        meetingIds.add(ms.Meeting__c);
        speakerIds.add(ms.Id);
    }
    system.debug(LoggingLevel.Info,'meetingIds: ' + meetingIds);
    system.debug(LoggingLevel.Info,'speakerIds: ' + speakerIds);
    //get meeting info
    Map<Id,Medical_Event_vod__c> MeetingIdToMeeting = new Map<Id,Medical_Event_vod__c>([SELECT Id,Planned_Expense_Amount__c 
                                                                                        FROM Medical_Event_vod__c
                                                                                        WHERE Id IN :meetingIds]);
                                                                                        
    //get rate cards
    List<Rate_Card__c> rateCards = new List<Rate_Card__c>([SELECT Amount__c,Hourly_Rate__c,Hours__c,Is_Hourly__c,Medical_Event__c,Meeting_Speaker__c,Type__c 
                                                           FROM Rate_Card__c
                                                           WHERE Medical_Event__c IN :meetingIds AND
                                                                 Meeting_Speaker__c IN :speakerIds]);
                                                                 
    List<Medical_Event_vod__c> meetingsToUpdate = new List<Medical_Event_vod__c>();
    List<Rate_Card__c> rateCardsToDelete = new List<Rate_Card__c>();
    
    for (Meeting_Speaker_BMS__c ms : trigger.old) {
        Decimal total = 0;
        for (Rate_Card__c rc : rateCards) {
            if (rc.Medical_Event__c == ms.Meeting__c && rc.Meeting_Speaker__c == ms.Id) {
                total += rc.Amount__c;
                system.debug(LoggingLevel.Info,'adding total: ' + rc.Amount__c);
                rateCardsToDelete.add(rc);
                system.debug(LoggingLevel.Info,'rate card to delete: ' + rc);
            }
        }
        system.debug(LoggingLevel.Info,'complete total: ' + total);
        if (total > 0) {
            
            Medical_Event_vod__c meeting = MeetingIdToMeeting.get(ms.Meeting__c);
            system.debug(LoggingLevel.Info,'Meeing Old Planned Expenses: ' + meeting);
            meeting.Planned_Expense_Amount__c = meeting.Planned_Expense_Amount__c - total;
            system.debug(LoggingLevel.Info,'Meeting New Planned Expenses: ' + meeting);
            meetingsToUpdate.add(meeting);
        }
    }
    system.debug(LoggingLevel.Info,'Rate Cards to Delete: ' + rateCardsToDelete);
    system.debug(LoggingLevel.Info,'Meetings to Update: ' + meetingsToUpdate);
    delete rateCardsToDelete;
    update meetingsToUpdate;                                                                                        
}