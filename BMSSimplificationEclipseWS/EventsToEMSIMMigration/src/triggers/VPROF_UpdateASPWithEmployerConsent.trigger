/**
* @author - Murugesh Naidu, Veeva Professional Services
* @createdDate - June 21, 2016
* @description - Updates all ASPs where the Activity has not already happened in the system with the updated Employer Consent Status. If more than 10 records need to be updated, it makes a future call

*/
trigger VPROF_UpdateASPWithEmployerConsent on EM_Speaker_vod__c (after insert, after update) {
    
    Set<String> NOT_YET_EXECUTED_EVENT_STATUSES = new Set<String> {'In Draft', 
                                                            'In Planning',
                                                            'In Service Coordinator Review',
                                                        //  'In Execution',
                                                            'In Business Approval'
                                                           // ,'Pre-Event',
                                                           // 'Approved_vod'
                                                            };
    public static final Integer MAX_SYNC_UPDATE_SIZE = 10;
    List<EM_Event_Speaker_vod__c> aspsToUpdate = [Select Id, Name, Employer_Consent_Required_HCPTS__c, Speaker_vod__c
                                                    , Event_vod__r.Status_vod__c
                                                    from EM_Event_Speaker_vod__c
                                                    where Speaker_vod__c in :Trigger.newMap.keyset()
                                                    and Event_vod__r.Status_vod__c in: NOT_YET_EXECUTED_EVENT_STATUSES];
    
    List<ID> espsToUpdateAsync = new List<ID>();
    List<EM_Event_Speaker_vod__c> espsToUpdate = new List<EM_Event_Speaker_vod__c>();
    Map<ID, EM_Speaker_vod__c> changedSpeakerMap = new Map<ID, EM_Speaker_vod__c> ();
    if(aspsToUpdate.size() > MAX_SYNC_UPDATE_SIZE){
        //update asynchronously
        for(EM_Event_Speaker_vod__c esp: aspsToUpdate){
                    if((Trigger.IsInsert || (Trigger.isUpdate && Trigger.newMap.get(esp.Speaker_vod__c).Employer_Consent_Required_HCPTS__c
                            != Trigger.oldMap.get(esp.Speaker_vod__c).Employer_Consent_Required_HCPTS__c))
                       && Trigger.newMap.get(esp.Speaker_vod__c).Employer_Consent_Required_HCPTS__c!=null){
                            espsToUpdateAsync.add(esp.Id);                      
                       }
        }
        CustomVeevaUtilities.updateEventSpeakerEmployerConsentsAsync(espsToUpdateAsync);
    }
    else if (aspsToUpdate.size() > 0){
           for(EM_Event_Speaker_vod__c esp: aspsToUpdate){
                if((Trigger.IsInsert || (Trigger.isUpdate && Trigger.newMap.get(esp.Speaker_vod__c).Employer_Consent_Required_HCPTS__c
                            != Trigger.oldMap.get(esp.Speaker_vod__c).Employer_Consent_Required_HCPTS__c))
                   && Trigger.newMap.get(esp.Speaker_vod__c).Employer_Consent_Required_HCPTS__c!=null){
                        espsToUpdate.add(esp);
                        changedSpeakerMap.put(esp.Speaker_vod__c, Trigger.newMap.get(esp.Speaker_vod__c));
                   }    
           }   
        CustomVeevaUtilities.updateEventSpeakerEmployerConsents(espsToUpdate, changedSpeakerMap);
    }
}