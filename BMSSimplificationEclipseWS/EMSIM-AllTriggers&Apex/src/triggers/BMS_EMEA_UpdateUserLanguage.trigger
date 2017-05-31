trigger BMS_EMEA_UpdateUserLanguage on Data_Change_Request_vod__c (before update) {

List<User> userLanguage = new List<User>();

for(Data_Change_Request_vod__c dcr: Trigger.new){

userLanguage = [select LanguageLocaleKey from User where id =: dcr.OwnerId ];
dcr.User_Language_BMS_EMEA__c = userLanguage[0].LanguageLocaleKey;
}
}