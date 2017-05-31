/*
* Name: BMS_CN_Calculate_TL_Rank 
* Description: Calculate TL Level
* Author: Nate Zhang
* Created Date: 04/03/2013		Nate Zhang - Initial Version
* Update  Date: 09/06/2013		Nate Zhang - Combine both China and India algorithm and use the new TL Level
* Last Mofified By: Nate Zhang
* Last Modified Date: 09/06/2013
*/
trigger BMS_CN_Calculate_TL_Rank on TL_Rank_Criteria_BMS_CN__c (before insert, before update) 
{
    String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
    
    for(TL_Rank_Criteria_BMS_CN__c r : trigger.new) 
    {
        // Get territory
        String strTerr;
        Id userID;
        if(trigger.isInsert) 
        {
            strTerr = [SELECT Name FROM Territory WHERE Id IN (SELECT TerritoryId FROM UserTerritory WHERE UserId =: Userinfo.getUserId())].Name;
            userID = Userinfo.getUserId();
        } 
        else 
        {
            strTerr = [SELECT Name FROM Territory WHERE Id IN (SELECT TerritoryId FROM UserTerritory WHERE UserId =: r.CreatedById)].Name;
            userID = r.CreatedById;
        }
                
        String strRecTyp = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'TL_Rank_Criteria_BMS_CN__c' AND Id =: r.RecordTypeId].Name;
        
        if(strRecTyp <> 'Remove from Medical Plan') 
        {
            Id LockedRTId = [Select Id from RecordType where SObjectType = 'TL_Rank_Criteria_BMS_CN__c' and Name = 'TL Rank Criteria Lock MSM'].Id;
            Id LockedAllRTId = [Select Id from RecordType where SObjectType = 'TL_Rank_Criteria_BMS_CN__c' and Name = 'TL Rank Criteria Lock All'].Id;
      
            if(r.RecordTypeId == LockedAllRTId) 
            {
                for(TL_Rank_Criteria_BMS_CN__c old : trigger.old) 
                {
                    if(r.Id == old.Id) 
                    {
                        if(old.RecordTypeId != LockedAllRTId) 
                        {
                            break;
                        } 
                        else 
                        {
                            r.addError('The TL Ranking you\'re trying to edit is locked by system. You are not supposed to edit a historical TL Ranking record.');                      
                        }
                    }
                }           
            } 
            else if(r.RecordTypeId == LockedRTId) 
            {
                for(TL_Rank_Criteria_BMS_CN__c old : trigger.old) 
                {
                    if(r.Id == old.Id) 
                    {
                        if(old.RecordTypeId == null) 
                        {
                            break;
                        } 
                        else if (old.RecordTypeId == r.RecordTypeId) 
                        {
                            if(r.Status_BMS_CN__c == 'Apply for Medical Plan') 
                            {
                                r.addError('The TL Ranking you\'re trying to edit is locked by system. You cannot edit a TL Ranking record during applying TL to Medical Plan process.');  
                            } 
                            else 
                            {
                                break;   
                            }               
                        }
                    }
                }           
            }
            
            integer IntTL=0;
            integer IntSpeaker = 0;
            integer NatTL=0;
            integer NatSpeaker = 0;
            integer RegTL = 0;
            integer RegSpeaker = 0;
      
            // A. International 
            if(r.International1_Green1_BMS_CN__c) 
            {
                IntTL++;
                IntSpeaker++;
            }
            if(r.International2_Green2_BMS_CN__c) 
            {
                IntTL++;
                IntSpeaker++;
            }
            if(r.International3_BMS_CN__c) 
            {
                IntTL++;
            }
            if(r.International4_BMS_CN__c) 
            {
                IntTL++;
            }
            if(r.International5_BMS_CN__c) 
            {
                IntTL++;    
            }
            if(r.International6_BMS_CN__c)
                IntTL++;
            if(r.International7_Green3_BMS_CN__c) 
            {
                IntTL++;
                IntSpeaker++;
            }
            if(r.International8_Green4_BMS_CN__c) 
            {
                IntTL++;
                IntSpeaker++;
            }
      
            // B. National
            if(r.NationalQ1_BMS_CN__c) 
            {
                NatTL++;
            }
            if(r.NationalQ2_BMS_CN__c) 
            {
                NatTL++;
            }                     
            if(r.NationalQ3_Green1_BMS_CN__c) 
            {
                NatTL++;
                NatSpeaker++;
            }
            if(r.NationalQ4_Green2_BMS_CN__c) 
            {
                NatTL++;
                NatSpeaker++;
            }
            if(r.NationalQ5_BMS_CN__c) 
            {
                NatTL++;
            }                     
            if(r.NationalQ6_BMS_CN__c) 
            {
                NatTL++;
            }
            if(r.NationalQ7_Green3_BMS_CN__c) 
            {
                NatTL++;
                NatSpeaker++;
            }
      
            // C. Regional
            if(r.RegionalQ1_BMS_CN__c) 
            {
                RegTL++;
                RegSpeaker++;       
            }
            if(r.RegionalQ2_BMS_CN__c) 
            {
                RegTL++;
                RegSpeaker++;       
            }
            if(r.RegionalQ3_BMS_CN__c) 
            {
                RegTL++;
                RegSpeaker++;       
            }
            if(r.RegionalQ4_BMS_CN__c) 
            {
                RegTL++;
                RegSpeaker++;       
            }
            if(r.RegionalQ6_BMS_CN__c) 
            {
                RegTL++;
                RegSpeaker++;       
            }
            if(r.RegionalQ7_BMS_CN__c) 
            {
                RegTL++;
                RegSpeaker++;       
            }
            if(r.RegionalQ8_BMS_CN__c) 
            {
                RegTL++;
                RegSpeaker++;       
            }
      
            if (IntTL >=4 ) 
            {
                r.TL_Level_BMS_CN__c = 'International';
            } 
            else if (NatTL >= 4 || IntTL == 3) 
            {
                r.TL_Level_BMS_CN__c = 'National';
            }             
            else if (RegTL >=2 || NatTL == 3) 
            {
                r.TL_Level_BMS_CN__c = 'Regional';
            }
                
            List<Account> accounts = [Select Id, TL_Level_New_BMS_CN__c from Account where Id = :r.Account_BMS_CN__c];
            if(accounts.size()>0) 
            {
                accounts[0].TL_Level_New_BMS_CN__c = r.TL_Level_BMS_CN__c;            
            }
            
            if(r.TL_Level_BMS_CN__c == null  && RegTL <2 && r.Apply_TL_To_Medical_Plan_BMS_CN__c && r.Status_BMS_CN__c == null) 
            {
                // 1. send mail to MSMM
                //this part would be done at after insert
                
                // 2. change record type of MSM to lock              
                r.RecordTypeId  = LockedRTId;
                r.Status_BMS_CN__c = 'Apply for Medical Plan';
            } 
        
            if(r.TL_Level_BMS_CN__c == null && RegTL <2 && !r.Apply_TL_To_Medical_Plan_BMS_CN__c) 
            {
                r.addError('You must check \'Apply Low-Ranked TL to Medical Plan?\' checkbox to apply low ranked TL to Medical Plan and provide a justification.'); 
            }
        
            if(r.Status_BMS_CN__c == 'Approved' || r.Status_BMS_CN__c == 'Rejected' || r.TL_Level_BMS_CN__c != null) 
            {
                if(r.TL_Level_BMS_CN__c != null) 
                {
                    r.Status_BMS_CN__c = 'AutoApproved';
                }
                // 1. change record type           
                r.RecordTypeId  = LockedAllRTId;
                // 2. update the IsOnMedicalPlan to TSF            
                List<TSF_vod__c> tsfs = [Select On_Medical_Plan_BMS_CN__c from TSF_vod__c where Account_vod__c =:r.Account_BMS_CN__c AND Territory_vod__c =:strTerr];
                
                // Insert TSF
                if(tsfs.size() == 0 && r.Status_BMS_CN__c != 'Rejected') 
                {
                    TSF_vod__c newTSF = new TSF_vod__c();
                    newTSF.On_Medical_Plan_BMS_CN__c = true;
                    newTSF.Account_vod__c = r.Account_BMS_CN__c;
                    newTSF.Territory_vod__c = strTerr;
                    insert newTSF;
                }
                else
                {
                    for(TSF_vod__c tsf :tsfs) 
                    {
                        if(r.Status_BMS_CN__c != 'Rejected') 
                        { //'Approved' and 'AutoApproved'            
                            tsf.On_Medical_Plan_BMS_CN__c = true;
                        } 
                        else 
                        {
                            tsf.On_Medical_Plan_BMS_CN__c = false;
                        }                      
                    }
                    update tsfs;  
                }
                
                if(r.Status_BMS_CN__c == 'Rejected') 
                {
                    // Remove from Cylce Plan
                    List<Cycle_Plan_Target_vod__c> target = [SELECT 
                                                                Id 
                                                            FROM 
                                                                Cycle_Plan_Target_vod__c 
                                                            WHERE 
                                                                Cycle_Plan_vod__r.OwnerId =: userID AND 
                                                                Cycle_Plan_vod__r.Active_vod__c = true AND 
                                                                Cycle_Plan_Account_vod__c =: r.Account_BMS_CN__c];
                    delete target;
                } 
                else 
                {
                	if(r.Status_BMS_CN__c == 'Approved' && String.isBlank(r.TL_Level_BMS_CN__c))
                	{
                		r.TL_Level_BMS_CN__c = 'Medical Strategy';
                		if(accounts.size()>0) 
			            {
			                accounts[0].TL_Level_New_BMS_CN__c = r.TL_Level_BMS_CN__c;            
			            }
                	}
                	
                    // Insert into Cycle Plan
                    List<Cycle_Plan_Target_vod__c> target = [SELECT 
                                                                Id
                                                            FROM 
                                                                Cycle_Plan_Target_vod__c 
                                                            WHERE 
                                                                Cycle_Plan_vod__r.OwnerId =: userID AND 
                                                                Cycle_Plan_vod__r.Active_vod__c = true AND 
                                                                Cycle_Plan_Account_vod__c =: r.Account_BMS_CN__c];
                    if(target.size() == 0) 
                    {
                        Cycle_Plan_Target_vod__c newTraget = new Cycle_Plan_Target_vod__c();
                        newTraget.Cycle_Plan_vod__c = [SELECT Id FROM Cycle_Plan_vod__c WHERE OwnerId =: userID AND Active_vod__c = true].Id;
                        newTraget.Cycle_Plan_Account_vod__c = r.Account_BMS_CN__c;
                        insert newTraget;
                    }
                }          
            }            
            update accounts;
        }     
    }
}