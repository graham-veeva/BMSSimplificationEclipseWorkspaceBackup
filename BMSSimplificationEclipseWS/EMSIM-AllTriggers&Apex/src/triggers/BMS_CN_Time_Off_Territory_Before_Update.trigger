trigger BMS_CN_Time_Off_Territory_Before_Update on Time_Off_Territory_vod__c (Before update) {
    //Get the user's profile
    Id id1 = UserInfo.getProfileId();
    String profileName = [Select Name from Profile where Id =: id1].Name;
    //get record typeid of BMS_CHINA_Statutory_Holiday
    String strid = [select Id from RecordType where Name ='BMS-CHINA-Statutory  Holiday' and SobjectType = 'Time_Off_Territory_vod__c'].Id;
    
    for (Integer i=0; i<Trigger.new.size(); i++) {
        if (profileName !='System Administrator' && strid  == Trigger.new[i].RECORDTYPEID)
        {
            Trigger.new[i].Date_vod__c = Trigger.old[i].Date_vod__c;
        }


    }

}