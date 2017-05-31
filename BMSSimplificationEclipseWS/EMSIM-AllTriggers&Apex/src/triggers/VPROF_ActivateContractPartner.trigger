//Murugesh Naidu, BMS Veeva Events Management Project
//March 1, 2016
//This locks  the unlocked COntract Partners if the corresponding Contract gets locked/Activated
trigger VPROF_ActivateContractPartner on Contract_vod__c (after insert, after update) {
    List<Contract_Partner_vod__c> cpsToActivate = [Select Id, Status_vod__c, Contract_vod__c,
                                                       Contract_vod__r.Status_vod__c
                                                     from Contract_Partner_vod__c 
                                                     where Contract_vod__c in: Trigger.newMap.keySet()
                                                     and Contract_vod__r.Status_vod__c = 'Activated_vod'
                                                     and Status_vod__c != 'Activated_vod'
                                                     ];
    if(cpsToActivate!=null && cpsToActivate.size() > 0){
        for(Contract_Partner_vod__c cp: cpsToActivate){
            cp.Status_vod__c = 'Activated_vod';
        }
        update cpsToActivate;
    }                                      
}