public class TerritoryIntelligentLocator 
{
  public List<Territory> getTerritoryIntelligentLocator()
  {
     
    Set<Id> TerritoryIDs = new Set<Id>();
    for (UserTerritory ar : [SELECT TerritoryId FROM UserTerritory where userid=:userinfo.getuserid()])
      TerritoryIDs.add(ar.TerritoryId );
      List<Territory> Terr1 = new List<territory>();
      Set<ID> ID1= new Set<ID>();
//      List<Territory> Terr1= [Select BMS_Code_ID__c, BMS_Territory_ID__c,Sales_Force_ID_BMS__c, Sales_Force_Name_BMS__c,Territory_Business_Code_BMS__c,  Id, Name,Description from Territory where id in : TerritoryIDs or ParentTerritoryId in : TerritoryIDs  ];
        for(Territory  ter  : [Select BMS_Code_ID__c, BMS_Territory_ID__c,Sales_Force_ID_BMS__c, Sales_Force_Name_BMS__c,Territory_Business_Code_BMS__c,  Id, Name,Description from Territory where id in : TerritoryIDs ])
             {
              Terr1.add(ter);       
              id1.add(ter.id);
             }
             
      List<Territory> Terr2 = new List<territory>();
      Set<ID> ID2= new Set<ID>();
//      List<Territory> Terr2= [Select BMS_Code_ID__c, BMS_Territory_ID__c,Sales_Force_ID_BMS__c, Sales_Force_Name_BMS__c,Territory_Business_Code_BMS__c,  Id, Name,Description from Territory where id in : TerritoryIDs or ParentTerritoryId in : TerritoryIDs  ];
        for(Territory  ter  : [Select BMS_Code_ID__c, BMS_Territory_ID__c,Sales_Force_ID_BMS__c, Sales_Force_Name_BMS__c,Territory_Business_Code_BMS__c,  Id, Name,Description from Territory where ParentTerritoryId in : id1 ])
             {
              Terr2.add(ter);       
              id2.add(ter.id);
             }
      List<Territory> Terr3 = new List<territory>();
      Set<ID> ID3= new Set<ID>();
//      List<Territory> Terr2= [Select BMS_Code_ID__c, BMS_Territory_ID__c,Sales_Force_ID_BMS__c, Sales_Force_Name_BMS__c,Territory_Business_Code_BMS__c,  Id, Name,Description from Territory where id in : TerritoryIDs or ParentTerritoryId in : TerritoryIDs  ];
        for(Territory  ter  : [Select BMS_Code_ID__c, BMS_Territory_ID__c,Sales_Force_ID_BMS__c, Sales_Force_Name_BMS__c,Territory_Business_Code_BMS__c,  Id, Name,Description from Territory where ParentTerritoryId in : id2 ])
             {
              Terr3.add(ter);       
              id3.add(ter.id);
             }
      List<Territory> CompleteTerr =  new List<Territory>();
          CompleteTerr.addall(terr1);
          CompleteTerr.addall(terr2);
          CompleteTerr.addall(terr3);
          
 
       
      return CompleteTerr;
  }
}