global with sharing class BMS_CN_Schedule_Monthly_First_Round implements Schedulable
{
	//Author:           Nate Zhang
    //Run at AM 1:00, 1st day of month
    //---------------------------------
	global void execute(SchedulableContext sc) 
	{
		BMS_CN_Cycle_Plan_Clone_Medical med = new BMS_CN_Cycle_Plan_Clone_Medical();
		database.executebatch(med,50); 
		
		BMS_CN_Retargeting_CreateDoctorBatch  ret = new BMS_CN_Retargeting_CreateDoctorBatch (); 
		database.executebatch(ret,100);
	}
}