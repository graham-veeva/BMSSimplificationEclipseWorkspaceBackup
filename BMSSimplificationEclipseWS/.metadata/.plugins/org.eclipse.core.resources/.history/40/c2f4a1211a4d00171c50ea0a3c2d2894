/*
* Murugesh Naidu, Veeva Professional Services
* July 10th, 2015
* Extension class for VF page VPROF_SubmitBudgetForApproval. Key tasks for this Controller are as follows:
1. Check if pre-defined fields for Approval are populated before submitting the record for approval - show error and which fields are missing if applicable
2. Manage Apex sharing with Approver, Reviewer, Certifier prior to sending the record for Approval
3. Code provides two fields on the EM_Budget_vod__c object whose default values define Required field criteria for Approval workflow. Note that these will prevent 
 the user from submitting the record for Approval. You should also make these required on the Approval flow itself to be solid end to end, else there could be an error on Approval Submission
*/
public class VPROF_SubmitBudgetForApprovalExt {
	EM_Budget_vod__c theBudget ;
	List<String> fieldsForApprovalList = new List<String>();
	Map<String, Schema.SObjectField> mapFldAPINameToDescribe = EM_Budget_vod__c.SObjectType.getDescribe().fields.getMap();		
		public VPROF_SubmitBudgetForApprovalExt(ApexPages.StandardController controller){
			Schema.SObjectField fieldForApproval1 = mapFldAPINameToDescribe.get('Fields_For_Approval_HCPTS__c');
			Schema.SObjectField fieldForApproval2 = mapFldAPINameToDescribe.get('Fields_For_Approval_1_HCPTS__c');
			System.debug('fieldForApproval1.getDescribe().getDefaultValueFormula()=' + fieldForApproval1.getDescribe().getDefaultValueFormula());
			if(fieldForApproval1.getDescribe().getDefaultValueFormula()!=null && fieldForApproval1.getDescribe().getDefaultValueFormula()!=''){
				String defaultValue1 = (String) fieldForApproval1.getDescribe().getDefaultValueFormula();
				defaultValue1 = defaultValue1.removeStart('\'').removeEnd('\'');
				fieldsForApprovalList.addAll(defaultValue1.split(','));
				System.debug('fieldsForApprovalList=' + fieldsForApprovalList);
				//make sure these are retrieved via SOQL
			//	theBudget = (EM_Budget_vod__c)Database.query('Select Id, ' + defaultValue1 + ' from EM_Budget_vod__c where Id = \'' + theBudget.Id + '\'');
			}
			if(fieldForApproval2.getDescribe().getDefaultValueFormula()!=null && fieldForApproval2.getDescribe().getDefaultValueFormula()!=''){
				String defaultValue2 = (String) fieldForApproval2.getDescribe().getDefaultValueFormula();
				defaultValue2 = defaultValue2.removeStart('\'').removeEnd('\'');
				fieldsForApprovalList.addAll(defaultValue2.split(','));
				System.debug('fieldsForApprovalList=' + fieldsForApprovalList);
				//make sure these are retrieved via SOQL
			//	theBudget = (EM_Budget_vod__c)Database.query('Select Id, ' + defaultValue1 + ' from EM_Budget_vod__c where Id = \'' + theBudget.Id + '\'');
			}
			List<String> fieldsToGet = new List<String>();
			if(fieldsForApprovalList.size() > 0){
				fieldsToGet.addAll(fieldsForApprovalList);
			}
			fieldsToGet.add('Id');
			fieldsToGet.add('Reviewing_User_HCPTS__c');
			fieldsToGet.add('Regulatory_Reviwer_HCPTS__c');
			fieldsToGet.add('Name');//External ID of ESP
			controller.addFields(fieldsToGet);
			theBudget = (EM_Budget_vod__c) controller.getRecord(); 
		}
		
 /**
 * @method submitForApproval
 * @description Submits eligible records to a configured Approval process on EM_Budget_vod__c; also handles Apex Managed sharing to share out the EM_Budget_vod__c record
 */		
		public Pagereference submitForApproval(){
			
			String missingCriteriaForApproval = '';
			String missingChildrenForApproval = '';
			System.debug('fieldsForApprovalList in method = ' + fieldsForApprovalList);
			Savepoint sp = Database.setSavepoint();
			List<String> relatedListsForApprovalList = new List<String>();
			try{
				for(String aFld: fieldsForApprovalList){
					if(aFld.endsWith('__r')){
						relatedListsForApprovalList.add(aFld);
						continue;
					}
					System.debug('aFld = ' + aFld);
					if(theBudget.get(aFld)==null || String.valueOf(theBudget.get(aFld))==''){
						missingCriteriaForApproval+='<b>' + mapFldAPINameToDescribe.get(aFld).getDescribe().getLabel() + '</b><br>';	
						System.debug('missingCriteriaForApproval=' + fieldsForApprovalList);
					}
				}
				if(relatedListsForApprovalList.size() > 0){
				//	List<Schema.ChildRelationship> childRelationShipObjects = Schema.SObjectType.EM_Budget_vod__c.getChildRelationships();
				//	System.debug('Child Relationships = ' + childRelationShipObjects );
					String childQuery = '';
					for(String aChildRelName: relatedListsForApprovalList){
						childQuery += '( Select Id from ' + aChildRelName + ' ), ';
					}
					childQuery = childQuery.removeEnd(', ');
					System.debug('Childquery = ' + Childquery);
					String theQuery = 'Select Id, ' + childQuery + ' from EM_Budget_vod__c where Id = \'' +  theBudget.Id + '\'';
					System.debug('theQuery = ' + theQuery);
					
					EM_Budget_vod__c aBud = Database.query(theQuery);
					for(String aChildRelName: relatedListsForApprovalList){
						if(aBud.getSObjects(aChildRelName)==null || aBud.getSObjects(aChildRelName).size() == 0){
							missingChildrenForApproval+='<b>' + aChildRelName + '</b><br>';	
						}
					}				
				}
				if(missingCriteriaForApproval!='' || missingChildrenForApproval!=''){
					ApexPages.Message myMsg = new ApexPages.Message(
														ApexPages.severity.ERROR, 
														'Missing Required fields and/or Related (child) lists for Approval. Please ensure the following are populated before Submitting for Approval::<br/>' 
															+ ((missingCriteriaForApproval != '') ? missingCriteriaForApproval : '')
															+ ((missingChildrenForApproval!='') ? 'Missing related lists (Atleast one must exist): <br>' + missingChildrenForApproval : '')
															+ 'Click the Back button to continue!');
					ApexPages.addmessage(myMsg);
					return null;				
				}
		        //Begin the Sharing Process
		        //Delete any shares that might already exist for this record	        
			  	EM_Budget_vod__Share reviewerShare;
			  	EM_Budget_vod__Share approverShare;
			  	EM_Budget_vod__Share certifierShare;
	      		List<EM_Budget_vod__Share> budgetSharesToInsert  = new List<EM_Budget_vod__Share>();
	 			approverShare = new EM_Budget_vod__Share(ParentId = theBudget.Id, 
	    									UserOrGroupId = theBudget.Approving_User_HCPTS__c,
	    									AccessLevel = 'Read',
	    									RowCause = Schema.EM_Budget_vod__Share.RowCause.Approver_HCPTS__c) ;         			
		        budgetSharesToInsert.add(approverShare);
	           	if(theBudget.Reviewing_User_HCPTS__c!=null){
	 				reviewerShare = new EM_Budget_vod__Share(ParentId = theBudget.Id, 
	    									UserOrGroupId = theBudget.Reviewing_User_HCPTS__c,
	    									AccessLevel = 'Read',
	    									RowCause = Schema.EM_Budget_vod__Share.RowCause.Reviewer_HCPTS__c) ;         			
		       		 budgetSharesToInsert.add(reviewerShare);
	           	}
	           	if(theBudget.Regulatory_Reviwer_HCPTS__c!=null){
	 				certifierShare = new EM_Budget_vod__Share(ParentId = theBudget.Id, 
	    									UserOrGroupId = theBudget.Regulatory_Reviwer_HCPTS__c,
	    									AccessLevel = 'Read',
	    									RowCause = Schema.EM_Budget_vod__Share.RowCause.Certifier_HCPTS__c) ;         			
		       		 budgetSharesToInsert.add(certifierShare);
	           	}
	 			if(budgetSharesToInsert.size() > 0){
	 				insert budgetSharesToInsert;
	 			}
				//Submit the request for Approval
		        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		        req1.setComments('Submitting request for Need Approval' );
		        req1.setObjectId(theBudget.id);
		        Approval.ProcessResult result = Approval.process(req1);
				return new PageReference('/' + theBudget.Id);
			}catch (Exception e){
				
				System.debug('Exception e' + e);
				if(e.getMessage().contains('ALREADY_IN_PROCESS')){
					ApexPages.addmessage(new ApexPages.Message( ApexPages.severity.ERROR, 
													'Record is already submitted for Approval! Click Return to go back!<br/>' + e.getMessage()));
					return null;						
				}
				Database.rollBack(sp);
				ApexPages.addmessage(new ApexPages.Message( ApexPages.severity.ERROR, 
													'Exception while processing. No data changes have been made...<br/>' + e.getMessage()));
				return null;									
				
			}
			
		}
		
}