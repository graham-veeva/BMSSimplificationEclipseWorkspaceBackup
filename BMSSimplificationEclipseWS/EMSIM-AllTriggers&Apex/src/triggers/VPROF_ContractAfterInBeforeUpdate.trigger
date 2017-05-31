/**
** Created July 6th 2015 - Murugesh Naidu, Veeva Professional Services
** Does the following:
1. If Contract_vod__c.Service_HCPTS__c is populated, inserts a corresponding Contract_Description_HCPTS__c as a related list record
for this Contract
**/
trigger VPROF_ContractAfterInBeforeUpdate on Contract_vod__c (after insert, before update) {
    
    List<ID> topicIDList = new List<ID>();
    Map<ID, ID> mapTopicToContractId = new Map<ID, ID>();
    List<ID> contractIdsToUpdate = new List<ID>();
    for(Contract_vod__c c: Trigger.New){
            if(c.Service_HCPTS__c!=null){
                mapTopicToContractId.put(c.Service_HCPTS__c, c.Id);
                if(Trigger.isUpdate && Trigger.isBefore){
                    c.Service_HCPTS__c = null;//blank our Service_HCPTS__c field
                }
                else{
                    contractIdsToUpdate.add(c.Id);
                }
            }
        }   
        system.debug('mapTopicToContractId = ' + mapTopicToContractId);
        if(mapTopicToContractId.size() > 0){
        //  Map<ID,Schema.RecordTypeInfo> rtMapByIdContracts = Schema.SObjectType.Contract_vod__c.getRecordTypeInfosById();
        //  system.debug('mapTopicToContractId = ' + mapTopicToContractId);
        //  Map<String,Schema.RecordTypeInfo> rtMapByNameContractLines = Schema.SObjectType.Contract_Line_vod__c.getRecordTypeInfosByName();
        //  system.debug('mapTopicToContractId = ' + mapTopicToContractId);
            List<EM_Catalog_vod__c> topics = [Select Id, Name from EM_Catalog_vod__c where Id in: mapTopicToContractId.keySet()];
            List<Contract_Description_HCPTS__c> contractDescriptions = new List<Contract_Description_HCPTS__c>();
            system.debug('Descriptions (topics) = ' + topics);
            for(EM_Catalog_vod__c cat: topics){
                Contract_vod__c parentContract = Trigger.newMap.get(mapTopicToContractId.get(cat.Id));
                System.debug('parentContract = ' + parentContract);
            //  String contractRecTypeName = rtMapByIdContracts.get(parentContract.RecordTypeId).getName();
            //  ID contractLineRecTyoeId = rtMapByNameContractLines.get(contractRecTypeName).getRecordTypeId();
        //      System.debug('contractLineRecTyoeId = ' + contractLineRecTyoeId);
                contractDescriptions.add(new Contract_Description_HCPTS__c(Contract_HCPTS__c = parentContract.Id, 
                                                                Service_HCPTS__c = cat.Id,
                                                                External_Id_HCPTS__c = parentContract.Id + ';' + cat.Id
                                                                ) );
            }
    //      system.debug('contractLines before insert = ' + contractLines);
            upsert contractDescriptions External_Id_HCPTS__c;
    //      system.debug('contractLines after insert = ' + contractLines);
            
        }
        if(contractIdsToUpdate.size() > 0){
            List<Contract_vod__c> contractList = [Select Id, Name, Service_HCPTS__c from Contract_vod__c where Id in: contractIdsToUpdate];
            for(Contract_vod__c c: contractList){
                c.Service_HCPTS__c = null;
            }
            update contractList;
        }
}