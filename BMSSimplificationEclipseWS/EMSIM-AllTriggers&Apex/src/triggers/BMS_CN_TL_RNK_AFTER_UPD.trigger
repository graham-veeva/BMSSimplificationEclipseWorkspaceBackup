/*
* Name: BMS_CN_TL_RNK_AFTER_UPD 
* Description: process after update
*                  1) Remove from Medical Plan
*                  2) Remove from Cycle Plan
*                  3) Clear TL Level on account profile
*              this trigger is also used for India users
* Author: Roy Zhang
* Created Date: 03/22/2013
* Last Modifed By: Roy Zhang
* Last Modified Date: 04/09/2013
*/
trigger BMS_CN_TL_RNK_AFTER_UPD on TL_Rank_Criteria_BMS_CN__c (after update) {
    for(TL_Rank_Criteria_BMS_CN__c TLRnk : trigger.new) {
        String strRecTyp = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'TL_Rank_Criteria_BMS_CN__c' AND Id =: TLRnk.RecordTypeId].Name;
        
        if(TLRnk.Status_BMS_CN__c == 'Approved' && strRecTyp == 'Remove from Medical Plan') {
            // Get territory
            String strTerritory = [SELECT Name FROM Territory WHERE Id IN (SELECT TerritoryId FROM UserTerritory WHERE userid =: TLRnk.CreatedById)].Name;
    
            List<TSF_vod__c> tsfList = [SELECT 
                                            Id, 
                                            On_Medical_Plan_BMS_CN__c
                                        FROM 
                                            TSF_vod__c 
                                        WHERE 
                                            Account_vod__c =: TLRnk.Account_BMS_CN__c AND
                                            Territory_vod__c =: strTerritory];
            // Remove Medical Plan Flag on TSF                              
            for(TSF_vod__c tsf : tsfList) {
                if(tsf.On_Medical_Plan_BMS_CN__c == true) {
                    tsf.On_Medical_Plan_BMS_CN__c = false;
                }
            }
            update tsfList;
            
            Account acct = [SELECT Id FROM Account WHERE Id =: TLRnk.Account_BMS_CN__c];
            acct.TL_Level_New_BMS_CN__c = null;
            update acct;
            
            // Remove from Cycle Plan
            List<Cycle_Plan_Target_vod__c> target = [SELECT 
                                                        Id 
                                                    FROM 
                                                        Cycle_Plan_Target_vod__c 
                                                    WHERE 
                                                        Cycle_Plan_vod__r.OwnerId =: TLRnk.CreatedById AND 
                                                        Cycle_Plan_vod__r.Active_vod__c = true AND 
                                                        Cycle_Plan_Account_vod__c =: TLRnk.Account_BMS_CN__c];
            delete target;            
        }   
    }
}