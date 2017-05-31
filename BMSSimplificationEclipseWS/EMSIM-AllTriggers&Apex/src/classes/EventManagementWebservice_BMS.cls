global class EventManagementWebservice_BMS{ 
   webService static Boolean allSpeakersApproved(String medicalEventId) {
        Boolean allApproved = true;
        List<Meeting_Speaker_BMS__c> meetingSpeakers = new List<Meeting_Speaker_BMS__c>();
        List<String> speakerIds = new List<String>();
        for (Meeting_Speaker_BMS__c ms : [SELECT ID FROM Meeting_Speaker_BMS__c
                                          WHERE Meeting__c = :medicalEventId]) {
            speakerIds.add(ms.Id);                        
        } 
        
        for (ProcessInstance pi : [SELECT Status 
                                   FROM ProcessInstance 
                                   WHERE TargetObjectId IN :speakerIds]) {
            if (pi.Status != 'Approved') {
                allApproved = false;
                break;
            }
        }                                     
        
        return allApproved;
   }
}