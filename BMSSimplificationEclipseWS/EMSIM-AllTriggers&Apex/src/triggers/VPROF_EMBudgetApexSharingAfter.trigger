/*
* Murugesh Naidu, Veeva Professional Services
* July 10th, 2015
* Trigger shares the Budget record with the Processor and/or Need Owner once the Project Owner defines/specifies the Processor in the Processor_HCPTS__c field or the Processor defines
* the Need Owner in the Need Owner field
* SHaring with Approver, Reviewer, Certifier as applicable will be at the time of Submit for Approval (See VF page VPROF_SubmitBudgetForApproval)
*/
trigger VPROF_EMBudgetApexSharingAfter on EM_Budget_vod__c (after insert, after update) {
      EM_Budget_vod__Share processorShare;
      EM_Budget_vod__Share needOwnerShare;
      List<EM_Budget_vod__Share> budgetShares  = new List<EM_Budget_vod__Share>();
      List<ID> budgetIds = new List<ID>();
      List<String> rowCausesToRemove = new List<String>();
      for(EM_Budget_vod__c aBudget : Trigger.new){
          // Instantiate the sharing objects for Processor
          if((Trigger.IsInsert && aBudget.Processor_HCPTS__c!=null) 
          		|| (Trigger.isUpdate && aBudget.Processor_HCPTS__c!=null && Trigger.oldMap.get(aBudget.Id).Processor_HCPTS__c!=aBudget.Processor_HCPTS__c) ){
	          processorShare = new EM_Budget_vod__Share(ParentId = aBudget.Id, 
	            											UserOrGroupId = aBudget.Processor_HCPTS__c, 
	            											AccessLevel = 'Edit',
	            											RowCause = Schema.EM_Budget_vod__Share.RowCause.Processor_HCPTS__c);
	          budgetIds.add(aBudget.Id) ;
	          budgetShares.add(processorShare);
	          rowCausesToRemove.add(Schema.EM_Budget_vod__Share.RowCause.Processor_HCPTS__c);
          }
          // Instantiate the sharing objects for Need Owner
          if((Trigger.IsInsert && aBudget.Need_Owner_HCPTS__c!=null) 
          		|| (Trigger.isUpdate && aBudget.Need_Owner_HCPTS__c!=null && Trigger.oldMap.get(aBudget.Id).Need_Owner_HCPTS__c!=aBudget.Need_Owner_HCPTS__c) ){
	          needOwnerShare = new EM_Budget_vod__Share(ParentId = aBudget.Id, 
	            											UserOrGroupId = aBudget.Need_Owner_HCPTS__c, 
	            											AccessLevel = 'Edit',
	            											RowCause = Schema.EM_Budget_vod__Share.RowCause.Need_Owner_HCPTS__c);
	          budgetIds.add(aBudget.Id) ;
	          budgetShares.add(needOwnerShare);
	          rowCausesToRemove.add(Schema.EM_Budget_vod__Share.RowCause.Need_Owner_HCPTS__c);
          }
      }
      //Remove any existing Processor Shares on these records
      List<EM_Budget_vod__Share> sharesToDelete = [Select Id from EM_Budget_vod__Share where ParentId in:budgetIds 
      												AND  RowCause IN: rowCausesToRemove
      												];
      
      if(sharesToDelete!=null && sharesToDelete.size() > 0){
      	delete sharesToDelete;
      }
      if(budgetShares.size() > 0){
      	 Database.SaveResult[] lsr = Database.insert(budgetShares,false);
	     Integer i=0;
	      // Process the save results
	      for(Database.SaveResult sr : lsr){
	          if(!sr.isSuccess()){
	              // Get the first save result error
	              Database.Error err = sr.getErrors()[0];
	              // Check if the error is related to a trivial access level
	              // Access levels equal or more permissive than the object's default
	              // access level are not allowed.
	              // These sharing records are not required and thus an insert exception is
	              // acceptable.
	
	              if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION 
	                                             &&  err.getMessage().contains('AccessLevel'))){
	
	                  // Throw an error when the error is not related to trivial access level.
	                  trigger.newMap.get(budgetShares[i].ParentId).
	                    addError(
	                     'Unable to grant sharing access due to following exception: '
	                     + err.getMessage());
	              }
	          }
	          i++;
	      }  
      }

}