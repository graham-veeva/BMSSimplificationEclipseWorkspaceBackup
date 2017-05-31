trigger VPROF_Populate_Country_Field on Information_Collection_Form__c (before insert, before update) {

	/* 
	** if insert - if the country lookup is blank, populate it based on the country on the related speaker
	** if update - (updated from echosign) if the text country field is not blank, and has changed, update
	**  the country lookup field based on the text country field (this will be a 2 character counrty code)
	*/

	if(Trigger.isInsert){
		
		List<String> countryCodes = new List<String>();
		for(Information_Collection_Form__c icf: Trigger.new){
			if(icf.Country_vod__c == null && icf.Speaker_HCPTS__c != null && icf.Country_Formula_HCPTS__c != null){
				countryCodes.add(icf.Country_Formula_HCPTS__c);
			}
		}
		
		List<Country_vod__c> countries = [SELECT Id,Alpha_2_Code_vod__c FROM Country_vod__c 
											WHERE Alpha_2_Code_vod__c IN :countryCodes];

		for(Information_Collection_Form__c icf: Trigger.new){
			if(icf.Country_vod__c == null && icf.Speaker_HCPTS__c != null && icf.Country_Formula_HCPTS__c != null){
				for(Country_vod__c country: countries){
					if(icf.Country_Formula_HCPTS__c == country.Alpha_2_Code_vod__c){
						icf.Country_vod__c = country.Id;
					}
				}
			}
		}
	}


	if(Trigger.isUpdate){
		
		List<String> countryCodes = new List<String>();
		for(Information_Collection_Form__c icf: Trigger.new){
			if(icf.Contract_Country_HCPTS__c != null && icf.Contract_Country_HCPTS__c != ''){
				countryCodes.add(icf.Contract_Country_HCPTS__c);
			}
		}

		List<Country_vod__c> countries = [SELECT Id,Alpha_2_Code_vod__c FROM Country_vod__c 
											WHERE Alpha_2_Code_vod__c IN :countryCodes];

		for(Information_Collection_Form__c icf: Trigger.new){
			if(icf.Contract_Country_HCPTS__c != null && icf.Contract_Country_HCPTS__c != ''){
				for(Country_vod__c country: countries){
					if(icf.Contract_Country_HCPTS__c == country.Alpha_2_Code_vod__c){
						icf.Country_vod__c = country.Id;
					}
				}
			}
		}
	}
}