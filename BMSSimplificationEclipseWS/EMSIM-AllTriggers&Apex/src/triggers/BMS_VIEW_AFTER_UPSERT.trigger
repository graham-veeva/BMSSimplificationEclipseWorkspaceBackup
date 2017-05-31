trigger BMS_VIEW_AFTER_UPSERT on View_vod__c (after insert, after update) {
    /* Stamp the SFDC Id as the external id if one does not exist */
    List<View_vod__c> viewList = new List<View_vod__c>();
    
    for (View_vod__c v : trigger.new) {
        if (v.External_ID_vod__c == null) {
            viewList.add(new View_vod__c(Id = v.Id,External_ID_vod__c = v.Id));            
        }
    }
    
    if (viewList.size() > 0) update viewList;
}