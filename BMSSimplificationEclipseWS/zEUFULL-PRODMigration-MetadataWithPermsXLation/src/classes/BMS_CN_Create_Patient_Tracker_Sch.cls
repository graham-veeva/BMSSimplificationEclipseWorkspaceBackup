/*
* Name: BMS_CN_Create_Patient_Tracker_Sch
* Description: Monthly create patient tracker for HCP
* Author: Roy Zhang
* Created Date: 06/19/2013
* Last Modified Date: 06/19/2013
*/
global class BMS_CN_Create_Patient_Tracker_Sch implements Schedulable{
    
    global void execute(SchedulableContext sc) {        

        BMS_CN_Create_Patient_Tracker EOMBat= new BMS_CN_Create_Patient_Tracker();
        Database.executeBatch(EOMBat, 200);
    }
}