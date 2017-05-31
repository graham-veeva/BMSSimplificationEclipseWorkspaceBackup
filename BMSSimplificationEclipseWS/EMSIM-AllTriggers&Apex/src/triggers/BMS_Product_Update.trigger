trigger BMS_Product_Update on Multichannel_Consent_vod__c (before insert,before update) {




  for (Integer i = 0; i <Trigger.new.size(); i++)
  {
       
       Trigger.new[i].Product_vod__c = null;
       
  }
  
  
}