trigger VPROF_GermanDataPrivacyMasking on EM_Event_vod__c (before insert, before update) {
    
    Time AM_TIME = Time.newInstance(8,0,0,0);
    Time PM_TIME = Time.newInstance(13,0,0,0);
    Integer FIXED_DURATION = 4; //hours
    Integer AM_CUTOFF = 12; //hours
    static final String GERMANY = 'DE';
    Map<Id, Country_vod__c> countryMap = new Map<Id, Country_vod__c> (
                                        [Select Id, Country_Name_vod__c from Country_vod__c]);
    if(countryMap == null || countryMap.size() == 0){
        return;
    }
    for(EM_Event_vod__c event: Trigger.new){
        
        if( countryMap.get(event.Country_vod__c).Country_Name_vod__c == GERMANY){
            if(event.Start_time_vod__c.hour() >= AM_CUTOFF ){//PM
                event.Start_time_vod__c = Datetime.newInstance(event.Start_time_vod__c.date(),
                                                               PM_TIME);               
            }
            else{//AM
                event.Start_time_vod__c = Datetime.newInstance(event.Start_time_vod__c.date(),
                                                               AM_TIME);
            }
            
            event.End_Time_vod__c = event.Start_time_vod__c.addHours(FIXED_DURATION);
        }
        
    }

    
}