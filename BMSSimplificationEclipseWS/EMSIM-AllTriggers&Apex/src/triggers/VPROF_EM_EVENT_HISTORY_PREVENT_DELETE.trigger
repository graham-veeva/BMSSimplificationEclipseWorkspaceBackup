trigger VPROF_EM_EVENT_HISTORY_PREVENT_DELETE on EM_Event_History_vod__c (before delete) {
    
    // Only system administrator should have the ability to delete Activity Histories
    
    String userProfileId = userinfo.getProfileId();
    String userProfileName = '';
    
    List<Profile> ProfileNameLst = [SELECT Name FROM Profile WHERE Id = :userProfileId];
    
    if(ProfileNameLst.size() != 1){
        // we did not find the profile
    }else{
        userProfileName = ProfileNameLst[0].Name;
    }
    
    for(EM_Event_History_vod__c eh: trigger.old){
        If(userProfileName != 'System Administrator'){
            eh.addError('Only System Administrators Can Delete Event History Records');
        }
    }
    
}