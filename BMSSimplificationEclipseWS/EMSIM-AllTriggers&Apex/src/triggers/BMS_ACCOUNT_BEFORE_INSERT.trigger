/*
* Author: Jason Wigg, Veeva Systems, Inc.
* Date: 2013.05.16
* Summary: Fill in Country for User-created Accounts.
* 1. Determine if user has modify all data priviledge
* 2. If not, iterate records
* 3. Fill in the Account Source Country Field with the User's country field.
* 
*/

trigger BMS_ACCOUNT_BEFORE_INSERT on Account (before insert) {

	//JW get profile permission information
	String ProfileId = UserInfo.getProfileId();
    Profile pr = [Select Id, PermissionsModifyAllData From Profile where Id = :ProfileId];   
    
    //JW If Modify All Data is True, then finished
	if (pr != null && pr.PermissionsModifyAllData){
		 return;
	}
	//JW If a regular user, input country code from user record
	else
	{
	
	//JW Get user source country
	String UserId = UserInfo.getUserId();
	User u = [Select Id, User_Source_Country_BMS_CORE__c From User where Id = :UserId];
	
		//JW iterate through records
		for (integer i=0;i<Trigger.new.size();i++) { 
			//JW put in the Country code value from the user
			Trigger.new[i].Account_Source_Country_BMS_CORE__c = u.User_Source_Country_BMS_CORE__c;
		}		
	}
}