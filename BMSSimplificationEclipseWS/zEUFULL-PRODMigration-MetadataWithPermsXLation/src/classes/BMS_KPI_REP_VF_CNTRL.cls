/*
Controller Extension to facilitate PSR KPI REPORT GUI

Summary: 
Controller will query the current active PSR KPI REPORT
*/

public with sharing class BMS_KPI_REP_VF_CNTRL {
    //Object in view

    UserTerritory currUT = new UserTerritory();
    Territory currTerri = new Territory();        
    List<KPI_Rep_Activity_BMS_CN__c> repActivities = new List<KPI_Rep_Activity_BMS_CN__c>();
    List<KPI_Rep_Call_BMS_CN__c>  repCalls = new List<KPI_Rep_Call_BMS_CN__c>();
    List<KPI_Rep_Calls_by_Level_BMS_CN__c> repCallLevel = new List<KPI_Rep_Calls_by_Level_BMS_CN__c>();    
      
    public BMS_KPI_REP_VF_CNTRL() {
        //Query all related information
        ID owner = ApexPages.currentPage().getParameters().get('id');
        if(owner != null) { 
             currUT = [select TerritoryId, UserId from UserTerritory where UserId = :owner limit 1];  
             currTerri = [select Name,id, ParentTerritoryId from Territory where Id = : currUT.TerritoryId];
         }  
    }        
    
    public KPI_Rep_Activity_BMS_CN__c getRepActivity(){
        //Return object and related info
        repActivities = [SELECT Id, 
                    Daily_Calls_Inv_BMS_CN__c, 
                    MTD_Calls_BMS_CN__c, 
                    TOT_BMS_CN__c, 
                    Target_Working_Days_BMS_CN__c, 
                    MTD_Calls_Day_BMS_CN__c 
                    FROM KPI_Rep_Activity_BMS_CN__c 
                    limit 1];
/*
        if(repActivities.size() <= 0){
            KPI_Rep_Activity_BMS_CN__c repActivity = new KPI_Rep_Activity_BMS_CN__c();
            repActivity.Territory__c = 'None';
            repActivities.add(repActivity);
        }
*/       
        return repActivities[0];
    }   

    public List<KPI_Rep_Call_BMS_CN__c> getRepCall(){
        //Return object and related info       
        repCalls = [SELECT id,
                     Act_Call_BMS_CN__c, 
                     Call_Freq_BMS_CN__c, 
                     Doctors_Visited_BMS_CN__c, 
                     Dr_Coverage_BMS_CN__c, 
                     Dr_Level_BMS_CN__c, 
                     Total_Dr_Num_BMS_CN__c 
                     FROM KPI_Rep_Call_BMS_CN__c
                     ];
        return repCalls;
    }   
/*
    public List <KPI_Rep_Calls_by_Level_BMS_CN__c> getRepCallLevel(){
        //Return object and related info       
        repCallLevel = [SELECT Account_BMS_CN__c, 
                     Act_Calls_BMS_CN__c, 
                     Dr_Level_BMS_CN__c, 
                     Hsp_Name_BMS_CN__c, 
                     KPI_Rep_Call_Summary__c,  
                     Need_to_Call_BMS_CN__c, 
                     Id, 
                     KPI_Rep_Call_BMS_CN__r.Act_Call_BMS_CN__c, 
                     KPI_Rep_Call_BMS_CN__r.Call_Freq_BMS_CN__c, 
                     KPI_Rep_Call_BMS_CN__r.Doctors_Visited_BMS_CN__c, 
                     KPI_Rep_Call_BMS_CN__r.Dr_Coverage_BMS_CN__c, 
                     KPI_Rep_Call_BMS_CN__r.Dr_Level_BMS_CN__c, 
                     KPI_Rep_Call_BMS_CN__r.Total_Dr_Num_BMS_CN__c 
                     FROM KPI_Rep_Calls_by_Level_BMS_CN__c
                     ];
        return repCallLevel;
    }   
*/
}