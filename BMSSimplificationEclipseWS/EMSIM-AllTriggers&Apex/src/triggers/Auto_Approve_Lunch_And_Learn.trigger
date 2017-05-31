trigger Auto_Approve_Lunch_And_Learn on Medical_Event_vod__c (after update) {

//code block to check if this transaction belongs to legacy Medical Events or new Events Management module
  //Added by Murugesh Naidu (murugesh.naidu@veeva.com) Nov 12, 2015
  //Assumes that groups will either use EM_Event_vod or Medical_Event_vod as the primary starting point and not both
  if(Trigger.isDelete){
        if(Trigger.old[0].EM_Event_vod__c!=null){
            return;
        }
    }
    else{
        if(Trigger.new[0].EM_Event_vod__c!=null){
            return;
        }    
    }

    //String executionRecordTypeId = [SELECT Id,Name,SobjectType FROM RecordType WHERE sobjecttype = 'Medical_Event_vod__c' AND Name = 'Execution' LIMIT 1].ID;
    Map<Id,Medical_Event_vod__C> eventsToUpdate = new Map<Id,Medical_Event_vod__c>();
    //add record type here?
    for (Medical_Event_vod__c me: Trigger.new) {
       if (me.Auto_Approve_LnL__c == true && me.Event_Type__c == 'Lunch and Learn') {
           //me.RecordTypeID = executionRecordTypeId;
           eventsToUpdate.put(me.Id,me);
       }
    }
    system.debug('JK - eventsToUpdate: ' + eventsToUpdate);
    if (eventsToUpdate.isEmpty()) {
        return;
    }

    Map<String,ProcessInstance> processInstances = new Map<String,ProcessInstance>();
    for (ProcessInstance pi : [SELECT Status, Id 
                               FROM ProcessInstance 
                               WHERE TargetObjectId IN :eventsToUpdate.keySet()]) {
        system.debug('JK - Process Instance: ' + pi);
        if (pi.Status == 'Started') {
            processInstances.put(pi.Id,pi);                 
        }
    }
    system.debug('JK - Process Instances: ' + processInstances);
    if (processInstances.isEmpty()) {
        return;
    }
    
    Map<String, String> workItemIdToProcessInstanceId = new Map<String,String>();
    for(ProcessInstanceWorkitem wi : [SELECT ID, ActorId,OriginalActorId,ProcessInstanceId 
                                        FROM ProcessInstanceWorkitem 
                                        WHERE ProcessInstanceId IN :processInstances.keyset()]) {
        workItemIdToProcessInstanceId.put(wi.Id,wi.ProcessInstanceId);                                        
    }
    system.debug('JK - WorkItems: ' + workItemIdToProcessInstanceId);

    for (String wi : workItemIdToProcessInstanceId.keyset()) {
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();    
        req2.setComments('Auto approving Lunch and Learn request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req2.setWorkitemId(wi);
        Approval.ProcessResult result2 =  Approval.process(req2);  
    }
}