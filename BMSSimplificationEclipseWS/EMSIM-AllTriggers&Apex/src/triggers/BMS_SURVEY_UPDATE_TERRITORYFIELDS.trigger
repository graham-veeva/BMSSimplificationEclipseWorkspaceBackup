trigger BMS_SURVEY_UPDATE_TERRITORYFIELDS on Assessment__c (before insert, before update) {
 
 /*  set<String> UserIds = new set <String> (); 
   
           for (Integer j = 0 ;  j < Trigger.new.size(); j++) 
           {
                UserIds.add(Trigger.new[j].createdbyid);   
                system.debug('----1' + Trigger.new[j].createdbyid);
           }
  */  
    
   string uid = userinfo.getUserId();
        Map<Id,ID> TerritoryIDS = new Map<Id,Id>();
         List <String> TerIds = new List<String> (); 
                        for (UserTerritory ut : [SELECT UserId,TerritoryId from UserTerritory  where UserId =: uid AND IsActive = true]) {
                                  TerritoryIDS.put(ut.UserId,ut.TerritoryId);
                                   TerIds.add(ut.TerritoryId);  
                             }
         Map<ID,Territory> Terr = new Map<ID,Territory> ([SELECT ID,BMS_Code_ID__c, BMS_Territory_ID__c, Description, Sales_Force_ID_BMS__c, Sales_Force_Name_BMS__c, Territory_Business_Code_BMS__c, Territory_Function_Code_BMS__c, Name, Territory_Region_Code_BMS__c, Territory_Sales_Area_Code_BMS__c, Territory_Type_BMS__c FROM Territory where ID in :TerIds ]);
     
     ID IDD;
     Territory Terr1 = new Territory();
    
     
    for (Integer i = 0 ;  i < Trigger.new.size(); i++)         
         { 
    IDD = null;
    Terr1 = new Territory();
                                                                   
                            if(TerritoryIDS.containsKey(uid ))
                                          {
                                                     IDD = TerritoryIDS.get(uid );
                                                     Terr1 = Terr.get(IDD);
                                                        system.debug('----entered if loop -----');
                                                        
                                                        Trigger.new[i].Sales_Force_Name_BMS__c  = Terr1.Sales_Force_Name_BMS__c;
                                                     
                                                        Trigger.new[i].Territory_Business_Code_BMS__c = Terr1.Territory_Business_Code_BMS__c;
                                                        Trigger.new[i].Territory_Function_Code_BMS__c = Terr1.Territory_Function_Code_BMS__c;
                                                        Trigger.new[i].Territory_Region_Code_BMS__c = Terr1.Territory_Region_Code_BMS__c;
                                                        Trigger.new[i].Territory_Sales_Area_Code_BMS__c = Terr1.Territory_Sales_Area_Code_BMS__c;
                                                        Trigger.new[i].BMS_Code_ID__c= Terr1.BMS_Code_ID__c;                 
          } 
           
          
}
}