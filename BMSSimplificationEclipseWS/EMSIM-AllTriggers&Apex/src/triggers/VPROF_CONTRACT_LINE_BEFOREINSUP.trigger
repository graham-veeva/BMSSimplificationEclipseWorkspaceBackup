/**
** Created July 7, 2015
** Murugesh Naidu, Veeva Professional Services
** Does the following:
1. Sets the Service_vod__c lookup field to Fee_Reimburseable_Topic_HCPTS__c lookup field. This is so
that we can put custom BMS lookup filters on Fee_Reimburseable_Topic_HCPTS__c and still be able to leverage 
Veeva OOB Product benefits
**/
trigger VPROF_CONTRACT_LINE_BEFOREINSUP on Contract_Line_vod__c (before insert, before update) {
	
    Set<ID> contractIds = new Set<ID>();
    Set<ID> topicIds = new Set<ID>();
    Set<String> deductionCategories = new Set<String> {'Deduction'};
    
    for(Contract_Line_vod__c cl: Trigger.new){
    	contractIds.add(cl.Contract_vod__c);
        topicIds.add(cl.Fee_Reimburseable_Topic_HCPTS__c);
    }    
    Map<Id, Contract_vod__c> mapContracts = new Map<Id, Contract_vod__c> ( [SELECT Id, Name, Start_Date_vod__c, End_Date_vod__c
                                                                            FROM Contract_vod__c
                            												 where Id in:contractIds ]);
	Map<Id, EM_Catalog_vod__c> mapTopics = new Map<Id, EM_Catalog_vod__c> ( [SELECT Id, Name, Category_HCPTS__c
                                                                            FROM EM_Catalog_vod__c
                            												 where Id in:topicIds ]);
    
    for(Contract_Line_vod__c cl: Trigger.new){
        if(cl.Fee_Reimburseable_Topic_HCPTS__c!=null){
            cl.Service_vod__c = cl.Fee_Reimburseable_Topic_HCPTS__c;
            cl.Start_Date_vod__c = mapContracts.get(cl.Contract_vod__c).Start_Date_vod__c;
            cl.End_Date_vod__c = mapContracts.get(cl.Contract_vod__c).End_Date_vod__c;
            cl.Service_Category_HCPTS__c = mapTopics.get(cl.Fee_Reimburseable_Topic_HCPTS__c).Category_HCPTS__c;
            if(deductionCategories.contains(cl.Service_Category_HCPTS__c)
                && cl.EM_Rate_vod__c > 0){
                cl.EM_Rate_vod__c = -cl.EM_Rate_vod__c ;
            }
        }
    }
}