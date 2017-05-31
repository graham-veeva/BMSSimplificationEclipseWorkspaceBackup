//Date: Nov 18, 2015.
//Murugesh Naidu, Sr. Tech Arch, Veeva Professional Services
//This trigger was created to stamp the EH record with Event Creator email and Event Svc Coordinator
//Email so that rejection/approval email alerts can use EH record
trigger VPROF_EventHistoryBeforeIns on EM_Event_History_vod__c (before insert) {
   
   List<Id> eventIds = new List<Id>();
   for(EM_Event_History_vod__c eh: Trigger.New){
      eh.Starting_Status_Simple_HCPTS__c = eh.Starting_Status_vod__c;      
      eh.Ending_Status_Simple_HCPTS__c = eh.Ending_Status_vod__c;
      eventIds.add(eh.Event_vod__c);
   }
   
   //grab the Events with more data thats needed
   Map<Id, EM_Event_vod__c> eventMap = new Map<Id, EM_Event_vod__c> ([Select Id, Name, Processor_Email_HCPTS__c, CreatedBy.Email 
                                           from EM_Event_vod__c
                                           where Id in: eventIds]);
    
    for(EM_Event_History_vod__c eh: Trigger.New){
         eh.Processor_Email_HCPTS__c = eventMap.get(eh.event_vod__c).Processor_Email_HCPTS__c;
         eh.Event_Creator_Email_HCPTS__c = eventMap.get(eh.event_vod__c).CreatedBy.Email;
    }                                     
   

}