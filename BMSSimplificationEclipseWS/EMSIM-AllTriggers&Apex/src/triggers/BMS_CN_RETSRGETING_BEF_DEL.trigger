/* 
* Name: BMS_CN_RETSRGETING_BEF_DEL 
* Description: process before delete record
* Author: Roy Zhang
* Created Date: 03/28/2013
* Last Modified Date: 03/28/2013
*/ 
trigger BMS_CN_RETSRGETING_BEF_DEL on Retargeting_BMS_CN__c (before delete) {
    for(Retargeting_BMS_CN__c reTargeting : trigger.old) {
        // Only Saved Re-Targeting can be deleted
        if(reTargeting.Status_BMS_CN__c <> 'Saved') {
            trigger.old[0].adderror('Cannot delete submitted request.');
        } else {
            if(reTargeting.OwnerId <> Userinfo.getUserId()) {
                trigger.old[0].adderror('Cannot delete this request.'); 
            }
            if(reTargeting.Active_BMS_CN__c == false) {
                trigger.old[0].adderror('Cannot delete this request.'); 
            }
            
            bms_cn_setting__c cnSetting = bms_cn_setting__c.getInstance(UserInfo.getProfileId());
            if(cnSetting.Enable_Retargeting_BMS_CN__c <> true) {
                trigger.old[0].adderror('Cannot delete this request.'); 
            }           
        }
    }
}