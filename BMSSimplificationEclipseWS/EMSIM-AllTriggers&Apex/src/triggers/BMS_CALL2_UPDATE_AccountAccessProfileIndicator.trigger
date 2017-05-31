trigger BMS_CALL2_UPDATE_AccountAccessProfileIndicator on Call2_vod__c (after insert, after update) {
   
    List <Account> AccountList = new List<Account>();
    for (Integer i = 0 ;  i < Trigger.new.size(); i++)         
         { 
             If ((Trigger.new[i].Access_Discussed__c == true) && ((Trigger.new[i].Account_vod__c != null) || (Trigger.new[i].Account_vod__c != '')))
             {
                 Account AccLst = new Account(Id=Trigger.new[i].Account_vod__c);                                                         
                                       
                 AccLst.BMS_Last_Access_Interaction_date__c = Trigger.new[i].Call_Datetime_vod__c;
                 AccLst.BMS_Last_Access_Interaction_User__c = Trigger.new[i].OwnerID;
                 AccountList.add(AccLst); 
             }
         }
             if(AccountList.size()>0)
             update AccountList;
    }