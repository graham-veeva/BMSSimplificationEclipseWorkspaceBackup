trigger BMS_COACHINGRPT_UPDATE_STAMPTERRITORYFIELDS_CORE on Coaching_Report_vod__c (before insert, before update) {
 
   set<String> UserIds = new set <String> (); 
   
           for (Integer j = 0 ;  j < Trigger.new.size(); j++) 
           {
                UserIds.add(Trigger.new[j].Manager_vod__c);   
                system.debug('----1' + Trigger.new[j].ownerid);
           }
   
        
        Map<Id,ID> TerritoryIDS = new Map<Id,Id>();
         List <String> TerIds = new List<String> (); 
                        for (UserTerritory ut : [SELECT UserId,TerritoryId from UserTerritory  where UserId in :UserIds AND IsActive = true]) {
                                  TerritoryIDS.put(ut.UserId,ut.TerritoryId);
                                   TerIds.add(ut.TerritoryId);  
                             }
         Map<ID,Territory> Terr = new Map<ID,Territory> ([SELECT ID,Code_ID_BMS_CORE__c, Territory_ID_BMS_CORE__c, Description, Sales_Force_ID_BMS_CORE__c, Sales_Force_Name_BMS_CORE__c, Territory_Business_Code_BMS_CORE__c, Territory_Function_Code_BMS_CORE__c, Name, Territory_Region_Code_BMS_CORE__c, Territory_Sales_Area_Code_BMS_CORE__c, Territory_Type_BMS_CORE__c FROM Territory where ID in :TerIds ]);
     
     ID IDD;
     Territory Terr1 = new Territory();
        for (Integer i = 0 ;  i < Trigger.new.size(); i++)         
         { 
    IDD = null;
    Terr1 = new Territory();
                                                                       
                                          if(TerritoryIDS.containsKey(Trigger.new[i].Manager_vod__c))
                                          {
                                                     IDD = TerritoryIDS.get(Trigger.new[i].Manager_vod__c);
                                                     Terr1 = Terr.get(IDD);
                                                        system.debug('----entered if loop -----');
                                                        //Trigger.new[i].Sales_Force_Name_BMS_CORE__c = Terr1.Sales_Force_Name_BMS_CORE__c;
                                                        //Trigger.new[i].Sales_Force_ID_BMS_CORE__c = Terr1.Sales_Force_ID_BMS_CORE__c;
                                                        //Trigger.new[i].Territory_Business_Code_BMS_CORE__c = Terr1.Territory_Business_Code_BMS_CORE__c;
                                                        //Trigger.new[i].Territory_Function_Code_BMS_CORE__c = Terr1.Territory_Function_Code_BMS_CORE__c;
                                                       // Trigger.new[i].Territory_Region_Code_BMS_CORE__c = Terr1.Territory_Region_Code_BMS_CORE__c;
                                                        //Trigger.new[i].Territory_Sales_Area_Code_BMS_CORE__c = Terr1.Territory_Sales_Area_Code_BMS_CORE__c;
                                                       // Trigger.new[i].Code_ID_BMS_CORE__c= Terr1.Code_ID_BMS_CORE__c;
                                                        Trigger.new[i].Territory_Description_BMS__c= Terr1.Description;
                                                        
                                                                                                                                              
                                   }                    
          }
}