trigger VPROF_NeedExpenseEstimate_PopulateFields on Need_Expense_Estimate_HCPTS__c (before insert, before update) {

	Set<Id> expTypeIds = new Set<Id>();
	for(Need_Expense_Estimate_HCPTS__c needExpEst :Trigger.new){
		if(needExpEst.Expense_Type_vod__c != null){
			expTypeIds.add(needExpEst.Expense_Type_vod__c);
		}
	}

	List<Expense_Type_vod__c> expTypes = [SELECT Id,Name,Expense_Code_vod__c FROM Expense_Type_vod__c WHERE ID IN :expTypeIds];

	for(Need_Expense_Estimate_HCPTS__c needExpEst :Trigger.new){
		for(Expense_Type_vod__c expType :expTypes){
			if(needExpEst.Expense_Type_vod__c == expType.Id){
				needExpEst.Expense_Type_Name_vod__c = expType.Name;
				needExpEst.Expense_Type_Code_vod__c = expType.Expense_Code_vod__c;
			}
		}
	}


}