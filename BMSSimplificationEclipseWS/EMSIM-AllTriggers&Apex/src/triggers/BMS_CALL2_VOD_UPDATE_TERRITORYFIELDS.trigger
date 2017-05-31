trigger BMS_CALL2_VOD_UPDATE_TERRITORYFIELDS on Call2_vod__c (before insert, before update) {
 
   Set<String> UserIds = new Set <String> (); 
   
    for (Integer j = 0 ;  j < Trigger.new.size(); j++) {
        UserIds.add(Trigger.new[j].ownerid);   
        System.debug('----1' + Trigger.new[j].ownerid);
    }
   
    Map<Id,ID> TerritoryIDS = new Map<Id,Id>();
    List <String> TerIds = new List<String> (); 
    for (UserTerritory ut : [SELECT UserId,TerritoryId from UserTerritory  where UserId in :UserIds AND IsActive = true]) {
        TerritoryIDS.put(ut.UserId,ut.TerritoryId);
        TerIds.add(ut.TerritoryId);  
    }
    
    Map<ID,Territory> Terr = new Map<ID,Territory> ([SELECT ID,BMS_Code_ID__c, BMS_Territory_ID__c, Description, Sales_Force_ID_BMS__c, Sales_Force_Name_BMS__c, Territory_Business_Code_BMS__c, Territory_Function_Code_BMS__c, Name, Territory_Region_Code_BMS__c, Territory_Sales_Area_Code_BMS__c, Territory_Type_BMS__c FROM Territory where ID in :TerIds ]);
     
    ID IDD;
    Territory Terr1 = new Territory();
    for (Integer i = 0 ;  i < Trigger.new.size(); i++) { 
        IDD = null;
        Terr1 = new Territory();
                                                                       
        if(TerritoryIDS.containsKey(Trigger.new[i].OwnerID)) {
            IDD = TerritoryIDS.get(Trigger.new[i].OwnerID);
            Terr1 = Terr.get(IDD);
            System.debug('----entered if loop -----');
            Trigger.new[i].BMS_SFA__c = Terr1.Sales_Force_Name_BMS__c;
            Trigger.new[i].Sales_Force_ID_BMS__c = Terr1.Sales_Force_ID_BMS__c;
            Trigger.new[i].Territory_Business_Code_BMS__c = Terr1.Territory_Business_Code_BMS__c;
            Trigger.new[i].Territory_Function_Code_BMS__c = Terr1.Territory_Function_Code_BMS__c;
            Trigger.new[i].Territory_Region_Code_BMS__c = Terr1.Territory_Region_Code_BMS__c;
            Trigger.new[i].Territory_Sales_Area_Code_BMS__c = Terr1.Territory_Sales_Area_Code_BMS__c;
            Trigger.new[i].BMS_Code_ID__c= Terr1.BMS_Code_ID__c;
                
            if (Trigger.new[i].Status_vod__c == 'Submitted_vod') {           
                   Trigger.new[i].Override_Lock_vod__c = true;
                   System.debug('***** Set override_lock_vod__c = true');
            }                                                                                             
        }                    
    }
}