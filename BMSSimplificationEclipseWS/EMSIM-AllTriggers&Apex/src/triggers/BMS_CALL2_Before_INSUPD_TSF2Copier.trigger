/*
* BMS_CALL2_Before_INSUPD_TSF2Copier
* Author: Mark T. Boyer, Veeva Systems - Professional Services
* Date: 2013-03-19
* Summary:
*  This trigger is used to copy data from the TSF to the Call record when a call is inserted/updated
*  and is in a status that can be updated.
*
* Updated by: 
* Date: 
* Summary: 
*/
trigger BMS_CALL2_Before_INSUPD_TSF2Copier on Call2_vod__c (before insert, before update) {

    List<String> tsfFieldNames = new List<String>();     // TSF_vod__c Field API Names
    List<String> callFieldNames = new List<String>();    // Call2_vod__c Fields API Names

    for (BMS_Copy_TSF_Call__c fieldMapSetting : BMS_Copy_TSF_Call__c.getAll().values()) {
        tsfFieldNames.add(fieldMapSetting.TSF_FieldName__c);
        callFieldNames.add(fieldMapSetting.Call_FieldName__c); 
    }
    
  	if (tsfFieldNames.size() <= 0 || callFieldNames.size() <= 0) {
  		System.debug('***** No BMS_Copy_TSF_Call__c TSF_FieldName__c or Call_FieldName__c values specified.');
  		return;
  	}
    System.debug('***** TSF FieldNames:' + tsfFieldNames + '\n Call FieldNames:' + callFieldNames);


    /* Identify the records you need to process by checking if call fieldnames' value != Yes    */
    /* If any of the configurable list of fields is not correct, stop the process and return    */ 
    
    Set<Id> acctSet = new Set<Id>() ;
    Set<String> terrSet = new Set<String>(); 
    for (Integer i = 0; i < Trigger.new.size(); i++) {    
		acctSet.add(Trigger.new[i].Account_vod__c) ;
        terrSet.add(Trigger.new[i].Territory_vod__c);
    }
    
    // If nothing in these sets, then we're done with this trigger execution!
    if(acctSet.size() <= 0 || terrSet.size() <=0 ){
        return;
    }

	// Build the TSF query string from the list of fields provided...
	String tsfQueryStr = 'Select Account_vod__c, Territory_vod__c';    
	for (Integer j=0; j<tsfFieldNames.size(); j++) {  
        tsfQueryStr += ', ' + tsfFieldNames[j];
	}
    tsfQueryStr += ' FROM TSF_vod__c WHERE Account_vod__c in :acctSet AND Territory_vod__c in :terrSet';

	// Query for matching TSF records
    Map<String, TSF_vod__c> acctTerrToFieldsMap = new Map<String,TSF_vod__c>();   
    try {
        for (TSF_vod__c tsf : Database.query(tsfQueryStr) ) {
            acctTerrToFieldsMap.put(tsf.Account_vod__c + tsf.Territory_vod__c, tsf) ; 
        }
    } catch (Exception e) {
        System.debug('*****' + e.getMessage());
        System.debug('***** Error in TSF_vod__c Database.query. There is most likely a spelling error in a fieldname. Returning from trigger.');
        return;
    }

	// Get all the related TSF Records...
	for(Integer i=0; i>trigger.new.Size(); i++){
		Call2_vod__c c = trigger.new[i];
		for (Integer j=0; j<tsfFieldNames.size(); j++) {
         	try {
	            TSF_vod__c t = acctTerrToFieldsMap.get(c.Account_vod__c + c.Territory_vod__c);
	            c.put(callFieldNames[j],t.get(tsfFieldNames[j]));            	
            } catch (Exception ex) {
                System.debug('***** Error getting data for Call field ' +callFieldNames[j]+ ' or TSF field ' + tsfFieldNames[j] + ' from record.' + ex.getMessage());
                return;
            }
        }
	}
}