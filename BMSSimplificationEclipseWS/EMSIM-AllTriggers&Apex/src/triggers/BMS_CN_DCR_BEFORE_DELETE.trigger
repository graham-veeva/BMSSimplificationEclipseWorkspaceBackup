/*
* Name: BMS_CN_DCR_BEFORE_DELETE 
* Description: process before delete record
* Author: Roy Zhang
* Created Date: 03/19/2013
* Last Modified Date: 03/19/2013
*/
trigger BMS_CN_DCR_BEFORE_DELETE on Data_Change_Request_BMS_CN__c (before delete) {
	for(integer i = 0; i < trigger.old.Size(); i++){
		Data_Change_Request_BMS_CN__c dcrOld = trigger.old[i];
		
		// Cannot delete submitted request
		if(dcrOld.Status_BMS_CN__c <> 'Saved') {
			trigger.old[0].adderror('Cannot delete submitted request.');
		} else {
			if(dcrOld.OwnerId <> Userinfo.getUserId()) {
				trigger.old[0].adderror('Cannot delete this request.');	
			}			
		}
	}
}