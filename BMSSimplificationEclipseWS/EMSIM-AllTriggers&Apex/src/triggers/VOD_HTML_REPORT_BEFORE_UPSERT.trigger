trigger VOD_HTML_REPORT_BEFORE_UPSERT on HTML_Report_vod__c (before insert, before update) {
    
    Set<String> profileIdsToQuery = new Set<String>();
    Set<String> profileNamesToQuery = new Set<String>();
    Map<String, String> profileIdsToNameMap = new Map<String, String>();
    Map<String, String> profileNamesToIdMap = new Map<String, String>();
    
    // Add either the Profile Id or Profile Name to the respective Set
    for(HTML_Report_vod__c report : Trigger.new) {
        if(report.Profile_vod__c != null) {
            profileIdsToQuery.add(report.Profile_vod__c);
        } else if(report.Profile_Name_vod__c != null) {
            profileNamesToQuery.add(report.Profile_Name_vod__c);
        }
    }
    
    // Querry for all Profiles by Id. Add them to the respective map
    if(!profileIdsToQuery.isEmpty()) {
        for(Profile profile : [SELECT Id, Name FROM Profile WHERE Id IN: profileIdsToQuery]) {
            profileIdsToNameMap.put(profile.Id, profile.Name);
        }    
    }
    
    // Query for all the Profiles by Name. Add them to the respective Map
    if(!profileNamesToQuery.isEmpty()) {
        for(Profile profile : [SELECT Id, Name FROM Profile WHERE Name IN: profileNamesToQuery]) {
            profileNamesToIdMap.put(profile.Name, profile.Id);
        }
    }
    
    // get the error message that need to be used
    
    List<Message_vod__c> messages = [Select Text_vod__c From Message_vod__c WHERE Name='CANNOT_RESOLVE_PROFILE_ERROR' AND Category_vod__c='Alerts' AND Active_vod__c=true AND Language_vod__c=:userInfo.getLanguage()];
    String errorText;
    if(messages.size() != 0){
        errorText = messages[0].Text_vod__c;
    } else { // default to english hardcoded
        errorText = 'Could not determine the Salesforce Profile associated with this record';    
    }

    
    for(HTML_Report_vod__c report : Trigger.new) {
        // If a Profile Id and Name are not supplied then continue.
        if(report.Profile_vod__c == null && report.Profile_Name_vod__c == null) {
            continue;
        }
        
        // Fetch the Profile Name from the map
        String profileName = profileIdsToNameMap.get(report.Profile_vod__c);
        if(profileName != null) {
            // Valid name. Set it here.
            report.Profile_Name_vod__c = profileName;    
        } else {
            // Could not find the Profile Name from the Id. User might have provided the Name instead.
            // Fetch the Profile Id from the map
            String profileId = profileNamesToIdMap.get(report.Profile_Name_vod__c);
            if(profileId == null) {
                // Could not find a valid Profile Id OR Name. Add an error. 
                report.Id.addError(errorText , false);
            } else {
                // Found the Profile Id
                report.Profile_vod__c = profileId;    
            }
        }
    }
}