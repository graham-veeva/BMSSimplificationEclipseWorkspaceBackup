global with sharing class BMS_CN_Schedule_Monthly_Second_Round implements Schedulable
{
	//Author:           Nate Zhang
    //Run at AM 2:00, 1st day of month
    //---------------------------------
	global void execute(SchedulableContext sc) 
	{
		BMS_CN_Retargeting_UpdatePersInfoBatch ret = new BMS_CN_Retargeting_UpdatePersInfoBatch();
		database.executebatch(ret,50); 
	}
}