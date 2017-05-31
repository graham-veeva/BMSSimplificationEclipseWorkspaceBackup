/*
* @author - Ashok Vardhan Reddy
* @date - 2016.06.30 - MCCP Project for EU
* @description - Before Insert / Update to copy OwnerId to a custom lookup field. This enables formula fields to pull from the owner.
*/


trigger BMS_EMEA_MC_Cycle_Plan_OwnerCopy on MC_Cycle_Plan_vod__c (before insert, before update) {

    //define i to iterate through records
    Integer i = 0;

    //iterate through records
    for(MC_Cycle_Plan_vod__c x : trigger.new){
        
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
            x.Owner_Lookup_BMS_EMEA__c = x.OwnerId;
            
        }
        //increment i before going to the next element in for loop
        i++;
    }
}