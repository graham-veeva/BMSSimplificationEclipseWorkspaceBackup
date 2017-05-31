trigger BMS_EMEA_CALL2_Before_INSUPD_DateTime_fix on Call2_vod__c (before insert, before update) {
    SET<Id> RTids = new SET<Id>();
    LIST<Call2_vod__c> submittedCalls = new LIST<Call2_vod__c>();
    
    for(Call2_vod__c C : Trigger.new){
        //ENTRY CRITERIA - submitted and recordtype is in custom setting
        if(C.Status_vod__c!='Submitted_vod'){
            system.debug('Not submitted, skipping: '+C.Id);
            continue;
        }
        //add to proceeding ones        
        submittedCalls.add(C);
    }
    
    //skip if empty
    if(submittedCalls.size()==0){
    	system.debug('None submitted, exiting');
    	return;
    }
    //get rectype devnames
	String value = BMS_EMEA_Settings__c.getInstance().Call_DateTime_RTs__c;
	if(value==null) system.debug('No custom setting found');
	else{
		system.debug('Settings found: ' + value.split(','));
	  
	    //get Ids of rectypes in CS
	    for(RecordType RT : [SELECT Id FROM RecordType WHERE DeveloperName in :value.split(',')]){
	    	RTids.add(RT.Id);
	    }
	}
	
    for(Call2_vod__c C : submittedCalls){
    	//ENTRY CRITERIA2 - Recordtype in Custom setting
    	if(RTids.contains(C.RecordTypeId)){
    		//safety measure - should never happen
    		if(C.Call_Datetime_vod__c==null)C.Call_Datetime_vod__c=Datetime.now();
    		
    		//process data
    		Date calldate = C.Call_Datetime_vod__c.date();
    		Time calltime;
    		system.debug('C.Call_Datetime_vod__c: '+C.Call_Datetime_vod__c+' calldate: ' + calldate + ' calltime: '+calltime);
    		
    		//transform datetime to 8 am or 1 pm
    		if(C.Call_Datetime_vod__c.hour()<12)calltime = Time.newInstance(08, 00, 00, 00);
    		else calltime = Time.newInstance(13, 00, 00, 00);
    		
    		C.Call_Datetime_vod__c = Datetime.newInstance(calldate, calltime);
    	}else system.debug('Incorrect recordtype for date modification: '+C.RecordTypeId);
    	//smile
    }//end of last cycle
}