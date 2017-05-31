global with sharing class BMS_CN_Cycle_Plan_Clone_Medical implements Database.Batchable<sObject>, Database.Stateful
{
	//Author:           Nate Zhang
    //Create Date:      2013.04.17 - Create
    //Last Update Date: 2013.04.17   
    //---------------------------------
    
    final Date startDate = Date.today().addMonths(-1).toStartOfMonth();
	final Date endDate = Date.today().toStartOfMonth().addDays(-1);
	String query;
    global Database.QueryLocator start(Database.BatchableContext BC) 
    { 
    	//Get medical plan of last month for deep cloning targets
    	query = 'SELECT Id, ' +
                '       Active_vod__c, ' +
                '       Start_Date_vod__c, '	  +
                ' 		End_Date_vod__c, ' +
                '		Territory_vod__c,' +
                '       BU_BMS_CN__c,'	   +
                '       Owner.Name '	  +
                ' FROM  Cycle_Plan_vod__c ' +
                ' WHERE Start_Date_vod__c = :startDate  '+
                ' AND   End_Date_vod__c = :endDate  ' +
                ' AND   Is_Owner_Sales_BMS_CN__c != true ' +
                ' AND   Owner.IsActive = true ' +
                ' ORDER By Territory_vod__c' ;  
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> batch) 
    { 
    	Date sDate = Date.today().toStartOfMonth();
		Date eDate = Date.today().addMonths(1).toStartOfMonth().addDays(-1);
    	for (sObject obj : batch) 
        {
        	Cycle_Plan_vod__c cp = (Cycle_Plan_vod__c)obj;
        	
        	List<Cycle_Plan_Target_vod__c> cpts = [SELECT 	  Cycle_Plan_Account_vod__c
        												FROM  Cycle_Plan_Target_vod__c
        												where Cycle_Plan_vod__c =:cp.Id
        												order by Cycle_Plan_Account_vod__c];
        												
        	Cycle_Plan_vod__c master = new Cycle_Plan_vod__c(Active_vod__c = true, 
        													 Start_Date_vod__c = sDate,
        													 End_Date_vod__c = eDate,
        													 Territory_vod__c = cp.Territory_vod__c,
        													 BU_BMS_CN__c = cp.BU_BMS_CN__c,
        													 OwnerId = cp.OwnerId,
        													 Name = '[Medical]-'+cp.Territory_vod__c + '-'+cp.Owner.Name+'-'+sDate.year()+'-'+sDate.month());
        	
        	cp.Active_vod__c = false;
        	update cp;
        													 
        	//must update cp first to Deactive the old cycle plan then insert new active cyplan plan
        	insert master;			
        										 
        	List<Cycle_Plan_Target_vod__c> cloned = new List<Cycle_Plan_Target_vod__c>();
        	for(Cycle_Plan_Target_vod__c cpt:cpts)
        	{
        		if(cpt.Cycle_Plan_Account_vod__c != null)
        			cloned.Add(new Cycle_Plan_Target_vod__c(Cycle_Plan_Account_vod__c = cpt.Cycle_Plan_Account_vod__c,
        												 Cycle_Plan_vod__c = master.id));
        	}
        	
        	if(cloned.size()>0)
        		insert cloned;
        	System.Debug('[Nate]: cloned:' + cloned);
        	
        }
    	
    }
    
    global void finish(Database.BatchableContext BC) 
    {
    	
    }

}