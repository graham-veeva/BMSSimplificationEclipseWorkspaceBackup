/*
* Name: BMS_CN_TL_RNK_BEFORE_INS
* Description: process before insert
*              this trigger is also used for India users
* Author: Roy Zhang
* Created Date: 03/22/2013
* Last Modified Date: 03/22/2013
*/
trigger BMS_CN_TL_RNK_BEFORE_INS on TL_Rank_Criteria_BMS_CN__c (before insert) {
    for(TL_Rank_Criteria_BMS_CN__c TLRnk : trigger.new) {
        
        String strRecTyp = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'TL_Rank_Criteria_BMS_CN__c' AND Id =: TLRnk.RecordTypeId].Name;
        
        // Check doctor on Medical Plan or not
        if(trigger.isInsert && strRecTyp == 'Remove from Medical Plan') {
            
            // Get territory
            String strTerritory = [SELECT Name FROM Territory WHERE Id IN (SELECT TerritoryId FROM UserTerritory WHERE UserId =: userinfo.getUserId())].Name;
            
            List<TSF_vod__c> tsfList = [SELECT 
                                            Id, 
                                            On_Medical_Plan_BMS_CN__c
                                        FROM 
                                            TSF_vod__c 
                                        WHERE 
                                            Account_vod__c =: TLRnk.Account_BMS_CN__c AND
                                            Territory_vod__c =: strTerritory];
            
            Boolean flg = false;
            for(TSF_vod__c tsf : tsfList) {
                if(tsf.On_Medical_Plan_BMS_CN__c == true) {
                    flg = true;
                }
            }
                        
            if(flg == false) {
                trigger.new[0].addError('The HCP isn\'t on Medical Plan');
            }                               
        }
    }
}