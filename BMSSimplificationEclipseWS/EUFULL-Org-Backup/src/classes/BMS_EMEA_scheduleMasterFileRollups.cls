/**
 *
 * BMS_EMEA_scheduleMasterFileRollups
 *
 * Author: Raphael Krausz <raphael.krausz@veeva.com>
 * Date:   2014-12-15
 * Description:
 *      Provide a schedulable interface to the masterfile rollup batch class
 *      (BMS_EMEA_MasterFile_Rollup).
 *      The batch class calculates basic interaction statistics for master files.
 *
 */
global class BMS_EMEA_scheduleMasterFileRollups implements Schedulable {
   global void execute(SchedulableContext SC) {
        BMS_EMEA_MasterFile_Rollup masterFileRollups = new BMS_EMEA_MasterFile_Rollup();
        Database.executeBatch(masterFileRollups);
    }
}