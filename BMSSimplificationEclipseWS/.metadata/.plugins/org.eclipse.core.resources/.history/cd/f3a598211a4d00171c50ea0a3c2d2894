global class Schedule_Cycle_Plan_Seg_Freq_Calc implements Schedulable
{
	global void Execute(SchedulableContext sc)
	{
		BMS_CN_Cycle_Plan_Seg_Freq_Calc cpsfc = new BMS_CN_Cycle_Plan_Seg_Freq_Calc();
		Database.executeBatch(cpsfc,50); 
	}
}