/*
* BMS_Action_Before_INSUPD
* Author: Mark T. Boyer, Veeva Systems - Professional Services
* Date: 2013-03-19
* Summary:
*  This trigger is used to update the owner of this Action record when a new user is assigned.
*
* Updated by: 
* Date: 
* Summary: 
*/

trigger BMS_Action_Before_INSUPD on Action_BMS__c (before insert, before update) {
    for (Action_BMS__c act : Trigger.new) {
		if(act.Assigned_To_BMS_CA__c != null && act.Assigned_To_BMS_CA__c != act.OwnerId) {
			act.OwnerId = act.Assigned_To_BMS_CA__c;
		}
    }
}