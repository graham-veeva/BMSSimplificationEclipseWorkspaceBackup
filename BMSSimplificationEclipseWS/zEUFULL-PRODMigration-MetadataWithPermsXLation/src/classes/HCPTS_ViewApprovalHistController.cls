public with sharing class HCPTS_ViewApprovalHistController {

	public EM_Budget_vod__c theBudget {get;set;}
	public HCPTS_ViewApprovalHistController(ApexPages.StandardController controller){
		
		theBudget = [ Select m.Name, m.Id, m.Approval_Status_HCPTS__c, m.Status_vod__c, 
		             (Select Id, SystemModstamp, ProcessInstanceId, ProcessInstance.Status, OriginalActor.Name, Actor.Name, Comments, CreatedBy.Name, CreatedDate, StepStatus
							 From ProcessSteps order by CreatedDate desc) 
			           From EM_Budget_vod__c m
			           where m.id =: ((EM_Budget_vod__c) controller.getRecord()).Id];		
		
		
	}
}