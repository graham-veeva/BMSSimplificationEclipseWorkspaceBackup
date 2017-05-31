/*
* @author - Jason Wigg, Veeva Systems, Inc.
* @date - 2013.02.25
* @description - Before Insert / Update to copy OwnerId to a custom lookup field. This enables formula fields to pull from the owner.
* SFDC has a feature on their roadmap which will eliminate the need for this workaround
*/


trigger BMS_MySetup_OwnerCopy on My_Setup_Products_vod__c (before insert, before update) {

	//define i to iterate through records
	Integer i = 0;

	//iterate through records
    for(My_Setup_Products_vod__c x : trigger.new){
		
		//stores the objectType of the owner of the record
        Schema.SObjectType objectType = x.OwnerId.getSObjectType();
		
        // check that owner is a user (not a queue)
        if( objectType != User.sObjectType){
        	//increment i before going to the next element in for loop
        	i++;
        	continue;
        }
        //is this an insert operation OR has the Owner changed
        if (trigger.isInsert || trigger.old[i].OwnerId != x.OwnerId){
            //add new value to record
           	x.Owner_Lookup_BMS_CORE__c = x.OwnerId;
           	
        }
        //increment i before going to the next element in for loop
        i++;
	}
}