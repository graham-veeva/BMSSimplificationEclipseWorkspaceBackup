global with sharing class BMS_CN_Schedule_Daily_Second_Round implements Schedulable
{
	//Author:           Nate Zhang
    //Run at AM 5:00, Daily
    //---------------------------------
	global void execute(SchedulableContext sc) 
	{
		BMS_CN_BATCH_CYCLE_PLAN cp = new BMS_CN_BATCH_CYCLE_PLAN();
		database.executebatch(cp,40); 
	}
}