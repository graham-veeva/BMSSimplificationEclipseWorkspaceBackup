global with sharing class BMS_CN_Schedule_Daily_First_Round implements Schedulable
{
	//Author:           Nate Zhang
    //Run at AM 2:00, Daily
    //---------------------------------
	global void execute(SchedulableContext sc) 
	{
		BMS_CN_BATCH_CYCLE_PLAN_CALC_CALLS cpc = new BMS_CN_BATCH_CYCLE_PLAN_CALC_CALLS();
		database.executebatch(cpc,100); 
	}
}