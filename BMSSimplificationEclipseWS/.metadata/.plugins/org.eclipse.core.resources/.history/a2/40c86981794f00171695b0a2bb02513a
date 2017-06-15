trigger VPROF_Workflows on EM_Event_vod__c (before update, before insert) {

	/*
	** This trigger replaces the folling workflows in an effort to conserve SOQL limits:
	** Activity: Updated Logistics Support field
	** Update Activity ID
    ** mnaidu - 10/27/2016 - Adds additional logic to copy over Country_Reference_HCPTS from EM_Venue_vod if Event.venue_vod is specified
    ** mnaidu - 3/14 - Simplification Update - to stampt Activity ID properly for Simple Activities
	*/

	Set<Id> countryIds = new set<Id>();
	Set<Id> productIds = new Set<Id>();
    Set<Id> venueIds = new Set<Id>();
	List<EM_Event_vod__c> eventsToUpdate = new List<EM_Event_vod__c>();
	List<EM_Event_vod__c> eventsforIDStamp = new List<EM_Event_vod__c>();
	for(EM_Event_vod__c event: Trigger.new){
		eventsforIDStamp.add(event);
		if(event.Country_vod__c != null){
			// see if this value has been updated
			if(Trigger.isInsert){
				countryIds.add(event.Country_vod__c);
				eventsToUpdate.add(event);
			}else{
				countryIds.add(event.Country_vod__c);
				if(event.Country_vod__c != Trigger.oldMap.get(event.Id).Country_vod__c){
					eventsToUpdate.add(event);
				}
			}
		}
		if(event.Product_HCPTS__c != null){
			// see if this value has been updated
			if(Trigger.isInsert){
				productIds.add(event.Product_HCPTS__c);
				eventsToUpdate.add(event);
			}else{
				productIds.add(event.Product_HCPTS__c);
				if(event.Product_HCPTS__c != Trigger.oldMap.get(event.Id).Product_HCPTS__c){
					eventsToUpdate.add(event);
				}
			}
		}
        //Venue country update logic - mnaidu - 10/27/2016
		if(event.Venue_vod__c != null){
            	venueIds.add(event.Venue_vod__c);
                eventsToUpdate.add(event);
		}
        
	}

	if(eventsToUpdate.size() == 0 && eventsforIDStamp.size() == 0){
		return;
		}
    
	Map<Id,Country_vod__c> countries = new Map<Id,Country_vod__c>([SELECT Id,Alpha_2_Code_vod__c FROM Country_vod__c WHERE Id IN: countryIds]);
	Map<Id,Product_vod__c> products = new Map<Id,Product_vod__c>([SELECT Id,Name FROM Product_vod__c WHERE Id IN: productIds]);
    
    //Venue country update logic - mnaidu - 10/27/2016
	Map<Id,EM_Venue_vod__c> venues = new Map<Id,EM_Venue_vod__c>([SELECT Id,Name, Country_Reference_HCPTS__c FROM EM_Venue_vod__c WHERE Id IN: venueIds]);
    
    for(EM_Event_vod__c event: eventsToUpdate){
		// update logistic support field:
		if(event.Audio_Visual_Support_HCPTS__c == true && event.Venue_Support_HCPTS__c == true){
			event.Amex_Support_Needed_HCPTS__c = true;
		}else{
			event.Amex_Support_Needed_HCPTS__c = false;
		}

        //Venue country update logic - mnaidu - 10/27/2016
        if(event.Venue_vod__c!=null){
        	event.Country_HCPTS__c = venues.get(event.Venue_vod__c).Country_Reference_HCPTS__c;            
        }
	}
	for(EM_Event_vod__c event: eventsforIDStamp){
		// Update activity Id
		String startDateYear = '';
		if(event.Start_Date_Formula_HCPTS__c != null){
			startDateYear = String.valueOf(event.Start_Date_Formula_HCPTS__c.year());
		}
		String countryCode = '';
		if(countries.containsKey(event.Country_vod__c)){
			countryCode = countries.get(event.Country_vod__c).Alpha_2_Code_vod__c;
		}
		String productName = '';
		if(products.containsKey(event.Product_HCPTS__c)){
			productName = products.get(event.Product_HCPTS__c).Name;
		}
		if(event.Activity_Type_Formula_HCPTS__c!=null && event.Activity_Type_Formula_HCPTS__c.containsIgnoreCase('Simple')){
			event.Activity_ID_2_HCPTS__c = 'AN-' + startDateYear + '-' + countryCode + '-' +
				productName + '-' + event.Activity_Type_Simple_HCPTS__c + '-' + event.Activity_Id_HCPTS__c;
  			
		}
		else{
			event.Activity_ID_2_HCPTS__c = 'AN-' + startDateYear + '-' + countryCode + '-' +
				productName + '-' + event.Activity_Type_Formula_HCPTS__c + '-' + event.Activity_Id_HCPTS__c;
			
		}
		event.Activity_ID_2_HCPTS__c = event.Activity_ID_2_HCPTS__c.replaceAll('null', '');	
	}
}