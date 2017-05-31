trigger VPROF_Prevent_Duplicate_Expense_Types on Need_Expense_Estimate_HCPTS__c (before insert, before Update) {
	
	Set<Id> needIds = new Set<Id>();
	for(Need_Expense_Estimate_HCPTS__c needExpEst: Trigger.new){
		needIds.add(needExpEst.Need__c);
	}

	List<Need_Expense_Estimate_HCPTS__c> otherNeedExpEsts = [SELECT Id,Expense_Type_vod__c FROM Need_Expense_Estimate_HCPTS__c
		WHERE Need__c IN :needIds AND Id NOT IN :trigger.new];

	// make a map of need Ids to Expense Type Ids (where the expense type Ids are the expense types of the Expense Estimates on that need)
	Map<Id,Set<Id>> needToExpEstimates = new Map<Id,Set<Id>>();
	for(Id needId: needIds){
		for(Need_Expense_Estimate_HCPTS__c needExpEst :otherNeedExpEsts){
			if(needToExpEstimates.containsKey(needId)){
				needToExpEstimates.get(needId).add(needExpEst.Expense_Type_vod__c);
			}else{
				needToExpEstimates.put(needId,new Set<Id>{needExpEst.Expense_Type_vod__c});
			}
		}
	}

	for(Need_Expense_Estimate_HCPTS__c needExpEst: Trigger.new){
		Set<Id> otherExpEstOnThisNeed = needToExpEstimates.get(needExpEst.Need__c);
		if(otherExpEstOnThisNeed != null){
			if(otherExpEstOnThisNeed.contains(needExpEst.Expense_Type_vod__c)){
				needExpEst.addError(Label.Dublicate_Need_Expense_Estiamte_Error);
			}
		}
	}
}