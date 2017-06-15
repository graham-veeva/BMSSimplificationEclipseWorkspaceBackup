global class BMS_CN_BATCH_CYCLE_PLAN implements Database.Batchable<sObject>, Database.Stateful 
{
    private final String initialState;
    String query;
    private final string HolidayRTid;
	Set<String> setMgrReportID = new Set<String> (); //To avoid duplicate update for manager report
    
    global BMS_CN_BATCH_CYCLE_PLAN() 
    {
		List<RecordType> ToTRT=[SELECT Id, DeveloperName, SobjectType FROM RecordType where developername='BMS_CHINA_Statutory_Holiday' and sobjecttype='Time_Off_Territory_vod__c'];
		HolidayRTid=ToTRT[0].Id;
    
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // This is the base query that dirves the chunking.
        // We are grabbing all the plans are currently active and
        // have a start or end date that is currently in need of calculation.
        //Kobe Yue Apr. 15th, 2013: To Calculate Aggregate Result by Cycle Plan Target
        //Kobe Yue Apr. 19th, 2013: Combine Calc Joint Call class, to upsert Joint call by user, by date, by territory
        query = 'SELECT Id,bu_bms_cn__c,Territory_vod__c,CN_Sales_Manager_KPI_Report_BMS_CN__c,' +
                '       Call_Duration_BMS_CN__c, ' +
                '       End_Date_vod__c,Start_Date_vod__c,' +
                '		ToT_BMS_CN__c,Working_Days_BMS_CN__c,' +
                '       H_Actual_Call_BMS_CN__c,H_Doctors_Visited_BMS_CN__c,H_Total_Dr_Number_BMS_CN__c,' +
                '       M_Actual_Call_BMS_CN__c,M_Doctors_Visited_BMS_CN__c,M_Total_Dr_Number_BMS_CN__c,' + 
                '       VH_Actual_Call_BMS_CN__c,VH_Doctors_Visited_BMS_CN__c,VH_Total_Dr_Number_BMS_CN__c' + 
                ' FROM  Cycle_Plan_vod__c ' +
                ' WHERE Active_vod__c = true';  
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> batch) {
    	//To get id of record type BMS_CHINA_Statutory_Holiday
	    List <Cycle_Plan_vod__c> plansToUpdate = new List <Cycle_Plan_vod__c> ();
		List <Sales_KPI_Report_Joint_Call_Item_BMS_CN__c> newJointItemList= new List<Sales_KPI_Report_Joint_Call_Item_BMS_CN__c>();
		List <Sales_Manager_KPI_Report_BMS_CN__c> MgrReportToUpdate = new List<Sales_Manager_KPI_Report_BMS_CN__c>();
        // Loop through all the rows in the batch of Cycle Plan
        for (sObject obj : batch) 
        {
            Cycle_Plan_vod__c Cycle=(Cycle_Plan_vod__c)obj;
	    	//To Count #Days by today.
	    	Date MonthToDate=cycle.Start_Date_vod__c.addmonths(1).adddays(-1); //if today is next month, then count # days for last month
	    	if(cycle.Start_Date_vod__c.month()==date.today().month())
	    	{
	    		MonthToDate=date.today();
	    	}
            //keep each manager report records to be updated once
            if(setMgrReportID.contains(Cycle.CN_Sales_Manager_KPI_Report_BMS_CN__c)==false && Cycle.CN_Sales_Manager_KPI_Report_BMS_CN__c<>null)
            {
            	setMgrReportID.add(Cycle.CN_Sales_Manager_KPI_Report_BMS_CN__c);
            	Sales_Manager_KPI_Report_BMS_CN__c MgrRptDetail 
            		= new Sales_Manager_KPI_Report_BMS_CN__c(ID=Cycle.CN_Sales_Manager_KPI_Report_BMS_CN__c,
            												MTD_Date__c=MonthToDate);
				MgrReportToUpdate.add(MgrRptDetail);
            }
	    	//To upsert Joint call by user, by date, by territory
        	AggregateResult[] sumJointCall =[SELECT count(id) JointCalls, Call_Date_vod__c, 
        		Territory_vod__c, ownerid FROM Call2_vod__c 
        		where territory_vod__c =:Cycle.Territory_vod__c and Coaching_Call_BMS_CN__c=true
        		and Call_date_vod__c>=:Cycle.Start_Date_vod__c
        		and  Call_date_vod__c<=:Cycle.End_Date_vod__c
        		and status_vod__c='Submitted_vod'
        		group by Territory_vod__c, Call_Date_vod__c, ownerid];
        	for(integer i=0;i<sumJointCall.size();i++)
        	{
        		Sales_KPI_Report_Joint_Call_Item_BMS_CN__c JointItem= new Sales_KPI_Report_Joint_Call_Item_BMS_CN__c();
        		JointItem.CN_Sales_Manager_KPI_Report__c=Cycle.CN_Sales_Manager_KPI_Report_BMS_CN__c;
        		JointItem.Territory__c=(string)sumJointCall[i].get('territory_vod__c');
        		JointItem.Date__c=(date)sumJointCall[i].get('Call_Date_vod__c');
        		JointItem.Rep__c=(string)sumJointCall[i].get('ownerid');
        		JointItem.External_ID__c=JointItem.Territory__c+JointItem.Date__c+JointItem.Rep__c;
        		JointItem.Joint_Calls__c=(decimal)sumJointCall[i].get('JointCalls');
        		if(JointItem.CN_Sales_Manager_KPI_Report__c<>null) newJointItemList.add(JointItem);
        	}
	    	
            //Calculate actual call, visited, Doctor number by each Dr segmentation.
            //For HP BU, aggregate by # of target Call which values are 8,6,2
            if(Cycle.BU_BMS_CN__c=='HP')
            {
	            AggregateResult[] sumCycle =[SELECT HP_Dr_Level_BMS_CN__c, sum(Call_Durations_BMS_CN__c) sumCallDuration, sum(Actual_Calls_vod__c) actualCall, sum(Visited_BMS_CN__c) visited, count(id) totalNumber from Cycle_Plan_Target_vod__c where cycle_plan_vod__r.id=:cycle.Id group by HP_Dr_Level_BMS_CN__c];
	            Cycle.Call_Duration_BMS_CN__c=0;
	            for(integer i=0;i<sumCycle.size();i++)
	            {
		            if(sumCycle[i].get('sumCallDuration')!=null)
		            	Cycle.Call_Duration_BMS_CN__c+=(decimal)sumCycle[i].get('sumCallDuration');
		            if((string)sumCycle[i].get('HP_Dr_Level_BMS_CN__c')=='8')
		            {
		            	Cycle.VH_Actual_Call_BMS_CN__c=(decimal)sumCycle[i].get('actualCall');
		            	Cycle.VH_Doctors_Visited_BMS_CN__c=(decimal)sumCycle[i].get('visited');
		            	Cycle.VH_Total_Dr_Number_BMS_CN__c=(decimal)sumCycle[i].get('totalNumber');
		            }
		            if((string)sumCycle[i].get('HP_Dr_Level_BMS_CN__c')=='6')
		            {
		            	Cycle.H_Actual_Call_BMS_CN__c=(decimal)sumCycle[i].get('actualCall');
		            	Cycle.H_Doctors_Visited_BMS_CN__c=(decimal)sumCycle[i].get('visited');
		            	Cycle.H_Total_Dr_Number_BMS_CN__c=(decimal)sumCycle[i].get('totalNumber');
		            }
		            if((string)sumCycle[i].get('HP_Dr_Level_BMS_CN__c')=='2')
		            {
		            	Cycle.M_Actual_Call_BMS_CN__c=(decimal)sumCycle[i].get('actualCall');
		            	Cycle.M_Doctors_Visited_BMS_CN__c=(decimal)sumCycle[i].get('visited');
		            	Cycle.M_Total_Dr_Number_BMS_CN__c=(decimal)sumCycle[i].get('totalNumber');
		            }
	            }
            } 
			else //Other BU than HP:Calculate actual call, visited, Doctor number by each Dr segmentation.
			{	            
	            AggregateResult[] sumCycle =[SELECT Dr_Level_BMS_CN__c, sum(Call_Durations_BMS_CN__c) sumCallDuration, sum(Actual_Calls_vod__c) actualCall, sum(Visited_BMS_CN__c) visited, count(id) totalNumber from Cycle_Plan_Target_vod__c where cycle_plan_vod__r.id=:cycle.Id group by Dr_Level_BMS_CN__c];
	            Cycle.Call_Duration_BMS_CN__c=0;
	            for(integer i=0;i<sumCycle.size();i++)
	            {
		            if(sumCycle[i].get('sumCallDuration')!=null)
		            	Cycle.Call_Duration_BMS_CN__c+=(decimal)sumCycle[i].get('sumCallDuration');
		            if((string)sumCycle[i].get('Dr_Level_BMS_CN__c')=='VH')
		            {
		            	Cycle.VH_Actual_Call_BMS_CN__c=(decimal)sumCycle[i].get('actualCall');
		            	Cycle.VH_Doctors_Visited_BMS_CN__c=(decimal)sumCycle[i].get('visited');
		            	Cycle.VH_Total_Dr_Number_BMS_CN__c=(decimal)sumCycle[i].get('totalNumber');
		            }
		            else if((string)sumCycle[i].get('Dr_Level_BMS_CN__c')=='H')
		            {
		            	Cycle.H_Actual_Call_BMS_CN__c=(decimal)sumCycle[i].get('actualCall');
		            	Cycle.H_Doctors_Visited_BMS_CN__c=(decimal)sumCycle[i].get('visited');
		            	Cycle.H_Total_Dr_Number_BMS_CN__c=(decimal)sumCycle[i].get('totalNumber');
		            }
		            else if((string)sumCycle[i].get('Dr_Level_BMS_CN__c')=='M')
		            {
		            	Cycle.M_Actual_Call_BMS_CN__c=(decimal)sumCycle[i].get('actualCall');
		            	Cycle.M_Doctors_Visited_BMS_CN__c=(decimal)sumCycle[i].get('visited');
		            	Cycle.M_Total_Dr_Number_BMS_CN__c=(decimal)sumCycle[i].get('totalNumber');
		            }
		            
	            }
			}
            //Calculate ToT, Working Days
            string ToTConvertedTerritory=';'+Cycle.Territory_vod__c +';';
            List<Time_Off_Territory_vod__c> sumToT =[select RecordTypeId, Hours_vod__c from Time_Off_Territory_vod__c where territory_vod__c=:ToTConvertedTerritory and Date_vod__c<=:MonthToDate and Date_vod__c>=:Cycle.Start_Date_vod__c];
            decimal totHour=0;
            decimal holidayHour=0;
            for(Time_Off_Territory_vod__c tot: sumToT)
            {
            	if(tot.RecordTypeId==HolidayRTid) 
            		holidayhour+=tot.hours_vod__c;
            	else 
            		tothour+=tot.hours_vod__c;
            }
            Cycle.ToT_BMS_CN__c=totHour/8;
            Cycle.Working_Days_BMS_CN__c=MonthToDate.day()-tothour/8-holidayhour/8;
			plansToUpdate.add(Cycle);	
        }
	        update (plansToUpdate);
	        upsert newJointItemList External_ID__c;
	        update (MgrReportToUpdate);
    }
    global void finish(Database.BatchableContext BC) {
        // Access initialState here
		List <Sales_Manager_KPI_Report_BMS_CN__c> MgrRptToUpdate = new List<Sales_Manager_KPI_Report_BMS_CN__c>();
		AggregateResult[] sumJointCalls =[SELECT count_distinct(date__c) JointDays,CN_Sales_Manager_KPI_Report__c from Sales_KPI_Report_Joint_Call_Item_BMS_CN__c where Joint_Call_days__c='Y' and CN_Sales_Manager_KPI_Report__r.From_Date__c>= LAST_N_DAYS:60 group by CN_Sales_Manager_KPI_Report__c];
		for(integer i=0;i<sumJointCalls.size();i++)
		{
			Sales_Manager_KPI_Report_BMS_CN__c rptDetail = 
				new Sales_Manager_KPI_Report_BMS_CN__c(
					ID=(string)sumJointCalls[i].get('CN_Sales_Manager_KPI_Report__c'),
					MTD_Joint_Call_Days__c=(decimal)sumJointCalls[i].get('JointDays')
							);
			MgrRptToUpdate.add(rptDetail);
		}
		update MgrRptToUpdate;
        
    }
}