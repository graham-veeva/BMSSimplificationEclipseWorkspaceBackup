/*
* Name: BMS_CN_Calculate_TL_Rank 
* Description: process after update
* Author: Simon Lu
* Created Date: 04/03/2013
* Last Modified Date: 06/21/2013 - Nate: Add new notification mail sent to requestor to indicate Apprvoal/Rejection
*/
trigger BMS_CN_IN_TL_RNK_MAIL_AFTER_INS on TL_Rank_Criteria_BMS_CN__c (after insert, after update) 
{
    Messaging.SingleEmailMessage emailOut = new Messaging.SingleEmailMessage();
    Messaging.SingleEmailMessage emailResultNotification = new Messaging.SingleEmailMessage();
    
    EmailTemplate et = [SELECT id FROM EmailTemplate WHERE Name = 'BMS China India TL Ranking Email Template'];
    EmailTemplate et_res = [SELECT id FROM EmailTemplate WHERE Name = 'BMS China TL Ranking Approve Reject Email Template'];
    
    for(TL_Rank_Criteria_BMS_CN__c r: trigger.new) 
    {        
    	integer RegTL = 0;
    	// C. Regional
        if(r.RegionalQ1_BMS_CN__c) 
        {
            RegTL++;   
        }
        if(r.RegionalQ2_BMS_CN__c) 
        {
            RegTL++;     
        }
        if(r.RegionalQ3_BMS_CN__c) 
        {
            RegTL++;    
        }
        if(r.RegionalQ4_BMS_CN__c) 
        {
            RegTL++;     
        }
        if(r.RegionalQ6_BMS_CN__c) 
        {
            RegTL++;    
        }
        if(r.RegionalQ7_BMS_CN__c) 
        {
            RegTL++;     
        }
        if(r.RegionalQ8_BMS_CN__c) 
        {
            RegTL++;     
        }  
        if(trigger.isInsert && r.TL_Level_BMS_CN__c == null && RegTL <2 && r.Apply_TL_To_Medical_Plan_BMS_CN__c && r.Status_BMS_CN__c == 'Apply for Medical Plan')
        {    
            emailOut.setTemplateId(et.ID);
            emailOut.setWhatId(r.ID);
            Id getManagerID = [select id,ManagerId from user where id=: Userinfo.getUserId()][0].Managerid;
            if(getManagerID !=null)
            {
	            user reps_manager = [select id,lastName,firstName,managerid,email from user where id=:getManagerID];
	            if(reps_manager.Email != null)
	            {
		            Contact tempContact = new Contact(email = reps_manager.email, firstName = reps_manager.firstName, lastName = reps_manager.lastName);
		            insert tempContact;
		            emailOut.setTargetObjectId(tempContact.id);
		            emailOut.setUseSignature(false);
		            emailOut.setSaveAsActivity(false);
		            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailOut});
		            delete tempContact;
	            }
            }
        }
        else if(trigger.isUpdate && (r.Status_BMS_CN__c == 'Rejected' || r.Status_BMS_CN__c == 'Approved'))
        {        	
        	emailResultNotification.setTemplateId(et_res.Id);
        	emailResultNotification.setWhatId(r.Id);
        	user requestor = [select id,lastName,firstName,email from user where id=:r.CreatedById];
        	if(requestor != null && requestor.Email != null)
        	{   
        		Contact tempContact = new Contact(email = requestor.Email, firstName = requestor.firstName, lastName = requestor.lastName);
		        insert tempContact;       		
	            emailResultNotification.setTargetObjectId(tempContact.Id);
	            emailResultNotification.setUseSignature(false);
	            emailResultNotification.setSaveAsActivity(false);
	            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailResultNotification});
	            delete tempContact;
	            
        	}
        }
    }
    

}