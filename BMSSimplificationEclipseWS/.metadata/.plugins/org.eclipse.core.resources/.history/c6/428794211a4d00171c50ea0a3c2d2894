global with sharing class BMS_CN_Schedule_Monthly_Seg_Freq_Calc  implements Schedulable
{
    //Author:           Nate Zhang
    //Run at AM 1:00, 5th day of month
    //---------------------------------
    global void execute(SchedulableContext sc) 
    {
        BMS_CN_Cycle_Plan_Seg_Freq_Calc seg = new BMS_CN_Cycle_Plan_Seg_Freq_Calc();
        database.executebatch(seg,10); 
    }
}