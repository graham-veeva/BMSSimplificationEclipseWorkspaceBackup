trigger BMS_CN_CALL2_DISCUSSION_AFTER_TRIGGER on Call2_Discussion_vod__c (after insert, after update) 
{
    //Author:           Nate Zhang
    //Create Date:      2013.01.16
    //Last Update Date: 2013.01.16
    //---------------------------------BMS_CN__c
    List<Call2_Discussion_vod__c> cds = Trigger.new;
    List<ID> AccountIds = new List<ID>();
    List<ID> ProductIds = new List<ID>();
    
    for(Call2_Discussion_vod__c cd: cds)
    {
        //System.Debug('Nate: cd.Call2_vod__r.Status_vod__c :' + cd.Call2_vod__r.Status_vod__c );
        String status = [Select Status_vod__c from Call2_vod__c where Id =: cd.Call2_vod__c].Status_vod__c;
        System.Debug('Nate: Status:' + status);
        if(status == 'Saved_vod')
        {
            AccountIds.add(cd.Account_vod__c);
            ProductIds.add(cd.Product_vod__c);
        }       
    }
    
    List<Product_Metrics_vod__c> pms = [select Agree_BMS_CN__c, Account_vod__c, Products_vod__c, Knowledge_BMS_CN__c from Product_Metrics_vod__c 
                                        where Account_vod__c in :AccountIds AND
                                        Products_vod__c in :ProductIds];
                                        
    System.Debug('[Nate]: pms' + pms);
    System.Debug('[Nate]: AccountIds:' + AccountIds);
    System.Debug('[Nate]: ProductIds:' + ProductIds); 
    for(Call2_Discussion_vod__c cd: cds)
    {
        for(Product_Metrics_vod__c pm: pms)
        {
            if(pm.Account_vod__c == cd.Account_vod__c && pm.Products_vod__c == cd.Product_vod__c)
            {
                pm.Agree_BMS_CN__c = cd.Is_Achieved_BMS_CN__c;
                pm.Knowledge_BMS_CN__c = cd.Product_Knowledge_BMS_CN__c;
            }
        }
    }
    System.Debug('[Nate]: pms' + pms);
    update pms;                                     
    
}