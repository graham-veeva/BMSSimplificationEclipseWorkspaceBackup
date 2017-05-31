/*
* Name: BMS_CN_HP_Patient_Tracker_Cal_Sch
* Description: Calculate past 3 months average value of HP patient tracker
* Author: Roy Zhang
* Created Date: 06/19/2013
* Last Modified Date: 06/19/2013
*/
global class BMS_CN_HP_Patient_Tracker_Cal_Sch implements Schedulable{
    
    global void execute(SchedulableContext sc) {        
        BMS_CN_HP_Patient_Tracker_Cal EOMBat= new BMS_CN_HP_Patient_Tracker_Cal();
        Database.executeBatch(EOMBat, 150);
    }
}