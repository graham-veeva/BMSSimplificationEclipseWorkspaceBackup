/**
 * Veeva Professional Services
 * Date: 05/07/2012
 * A trigger to copy select fields from TSF object to the matching Call object records.
 *
**/
trigger BMS_CALL2_BEFORE_INSUPD_TSFFieldCopier_TRIGGER on Call2_vod__c (before insert, before update) {
    /* Read custom settings to read select fields from TSF object and corresponding Call object fields */
    List<String> tsfFieldNames = new List<String>();     // TSF_vod__c Field API Names
    List<String> callFieldNames = new List<String>();    // Call2_vod__c Fields API Names
 
    for (BMS_TSF_To_Call_Field_Copier_Settings__c fieldMapSetting : BMS_TSF_To_Call_Field_Copier_Settings__c.getAll().values()) {
        tsfFieldNames.add(fieldMapSetting.TSF_Field_API_Name__c);
        callFieldNames.add(fieldMapSetting.Call_Field_API_Name__c);
    }     
    
  	if (tsfFieldNames.size() <= 0 || callFieldNames.size() <= 0) {
  		System.debug('***** No tsfFieldNames/callFieldNames');
  		return;
  	}  
    System.debug('***** TSF FieldNames:' + tsfFieldNames + '\n Call FieldNames:' + callFieldNames);
      
    /* Build a query dynamically using the TSF_vod__c field names from above, to get TSF_vod__c records */ 
    
    // build first half of the query  
    String tsfQueryListStr = 'Select Account_vod__c, Territory_vod__c';    
    // build second half of the query
    String tsfQueryCondStr = ' FROM TSF_vod__c WHERE Account_vod__c in :acctSet AND Territory_vod__c in :terrSet AND (' ; 
    
    for (Integer j=0; j<tsfFieldNames.size(); j++) {  
        tsfQueryListStr += ', ' + tsfFieldNames[j];
        
        if (tsfQueryCondStr.endsWith('(')) {
            tsfQueryCondStr += tsfFieldNames[j] + ' = true ';
        } else {
            tsfQueryCondStr += ' OR ' + tsfFieldNames[j] + ' = true ';
        }
    }
    // Query to get the TSF_vod__c records
    String tsfQueryStr = tsfQueryListStr + ' ' + tsfQueryCondStr + ')';
    System.debug('**** queryStr:' + tsfQueryStr);          
    
    /* Identify the records you need to process by checking if call fieldnames' value != Yes    */
    /* If any of the configurable list of fields is not correct, stop the process and return    */ 
    
    Set<Id> acctSet = new Set<Id>() ;
    Set<String> terrSet = new Set<String>(); 
      
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        Call2_vod__c newRec = Trigger.new[i] ;
        sObject myNewRec = newRec;      
        
        // For each record, loop through the configurable list of fields on call2_vod__c to check if any of them is != Yes
        Boolean processRecord = false;
        for (Integer j=0; j<callFieldNames.size(); j++) {
        
          // If the fieldname is wrong and is not available in the record, 
          // return from trigger.  
          try {    
              System.debug('**** callFieldName: ' +  callFieldNames[j]);
              if (myNewRec.get(callFieldNames[j]) != 'Yes') {
                  processRecord = true;
                  break;
              }
          } catch(Exception ex) {
              System.debug('***** Invalid field:' + callFieldNames[j] + '. Returning from trigger');
              return;        // return from the trigger
          }
        }
        if (processRecord) {
            acctSet.add(newRec.Account_vod__c) ;
            terrSet.add(newRec.Territory_vod__c);
        }
    }
    System.debug('***** acctSet size: ' + acctSet.size() +  ', Set:' + acctSet);
    System.debug('***** terrSet Size: ' + terrSet.size() + ', Set:' + terrSet);

    // continue only if we have candidate call records to be updated
    if(acctSet.size() <= 0 || terrSet.size() <=0 ){
        return;
    }
   
    /* query for matching TSF records that have the concerned flags checked */
    Map <String, String> acctTerrToFieldsMap = new Map<String,String> () ;   
    try {
        for (TSF_vod__c tsf : Database.query(tsfQueryStr) ) {
            for (Integer j=0; j<tsfFieldNames.size(); j++) {  
                try {
                    // check if you are able to get the value of the field from the record
                    // If you are unable to find the field in the record, return from trigger.
                    Boolean valChecked = (Boolean) tsf.get(tsfFieldNames[j]);
                    if (valChecked) { // Ignore if it is not true
                        System.debug('*****' + tsfFieldNames[j] + ',value:' + valChecked);
                        acctTerrToFieldsMap.put(tsf.Account_vod__c + tsf.Territory_vod__c + tsfFieldNames[j], 'Yes') ; 
                        System.debug('**** Add ' + tsfFieldNames[j] + '  to acctTerrToFieldsMap set to Yes');
                    }      
                } catch (Exception ex) {
                    System.debug('***** Error in finding the fied:' + tsfFieldNames[j] + ' from record.' + ex.getMessage());
                    return;
                }
            }
        }
    } catch (Exception e) {
        System.debug('*****' + e.getMessage());
        System.debug('***** Error in Database.query. Returning from trigger.');
        return;
    }
    System.debug('***** acctTerrToFieldsMap:' + acctTerrToFieldsMap);

    /* Set the call flags */
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        Call2_vod__c newRec = Trigger.new[i] ;

        for (Integer j=0; j<tsfFieldNames.size(); j++) {  
            String valChecked = acctTerrToFieldsMap.get(newRec.Account_vod__c + newRec.Territory_vod__c + tsfFieldNames[j]);
            System.debug('***** From map, ' + tsfFieldNames[j] + ':' + valChecked);
            if (valChecked != null) { // if it is available in Map, it is Yes.
                newRec.put(callFieldNames[j], valChecked);
                System.debug('***** Update in call, the value of ' + callFieldNames[j] + ' to ' + valChecked);
            }
        }

        if (newRec.Status_vod__c == 'Submitted_vod') {           
            newRec.Override_Lock_vod__c = true;
            System.debug('***** Set override_lock_vod__c = true');
        }
    }       
}