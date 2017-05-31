/**
* Created: June 28th, 2015 By Murugesh Naidu, Sr. Technical Architect, Veeva Proofessional Services
* This trigger was created to:
1. Set the Company code reference onto the EM_Budget_vod object when a WBS or Cost Center Number is selected by the User
2. Set the Processor as Owner if Delegate Sharing Rights is checked
3. If Need Owner is blank, set it to the current OwnerId
*/
trigger VPROF_EMBudgetBeforeInsertUpdate on EM_Budget_vod__c (before insert, before update) {
	
	List<ID> ccIds = new List<ID> ();
	List<ID> wbsIds = new List<ID> ();
	
	for(EM_Budget_vod__c b: Trigger.New){
//1. Set the Company code reference onto the EM_Budget_vod object when a WBS or Cost Center Number is selected by the User
		if(b.Cost_Center_Code_HCPTS__c!=null){
			ccIds.add(b.Cost_Center_Code_HCPTS__c);
		}
		if(b.WBS_Number_HCPTS__c!=null){
			wbsIds.add(b.WBS_Number_HCPTS__c);
		}
//2. Set the Processor as Owner if Delegate Sharing Rights is checked
		if(b.Delegate_Sharing_Rights_to_Processor__c){ 
			b.Delegate_Sharing_Rights_to_Processor__c = false;
			Boolean isAdminUser = [Select Id, PermissionsModifyAllData FROM Profile where Id =: UserInfo.getProfileId()].PermissionsModifyAllData;
			if(
			  (isAdminUser || UserInfo.getUserId() == b.OwnerId )
				&& b.Processor_HCPTS__c!=null
				){ ////only owners can delegate their Ownership rights to someone else
				b.OwnerId = b.Processor_HCPTS__c;
			}
		}
		if(b.Need_Owner_HCPTS__c == null){//if Need Owner is blank, set it to the current CreatedById
			b.Need_Owner_HCPTS__c = b.CreatedById;
		}
	}
	
	Map<ID, Cost_Center_Details_HCPTS__c> ccMap = new Map<ID, Cost_Center_Details_HCPTS__c>(
														[Select Id, Company_Code_HCPTS__c from
														Cost_Center_Details_HCPTS__c where Id in:ccIds] );
	Map<ID, WBS_Details_HCPTS__c> wbsMap = new Map<ID, WBS_Details_HCPTS__c>(
														[Select Id, Company_Code_HCPTS__c from
														WBS_Details_HCPTS__c where Id in:wbsIds] );
	
	
	for(EM_Budget_vod__c b: Trigger.New){
		System.debug('Current EM Budget b = ' + b);
		if(b.Cost_Center_Code_HCPTS__c!=null && ccMap.get(b.Cost_Center_Code_HCPTS__c).Company_Code_HCPTS__c!=null){
			b.Company_Code_HCPTS__c = ccMap.get(b.Cost_Center_Code_HCPTS__c).Company_Code_HCPTS__c;
		}
		if(b.WBS_Number_HCPTS__c!=null && wbsMap.get(b.WBS_Number_HCPTS__c).Company_Code_HCPTS__c!=null){
			b.Company_Code_HCPTS__c = wbsMap.get(b.WBS_Number_HCPTS__c).Company_Code_HCPTS__c;
		}
	}
	/////
}