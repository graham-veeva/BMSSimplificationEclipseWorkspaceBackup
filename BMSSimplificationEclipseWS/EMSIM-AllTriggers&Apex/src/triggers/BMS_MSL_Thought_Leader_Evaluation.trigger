/*
* @author - Jason Wigg, Veeva Systems, Inc.
* @date - UPDATED ON 2013.06.11
* @description - MSL TL Evaluation - added custom settings to control which method is used in each org
*/

trigger BMS_MSL_Thought_Leader_Evaluation on Account (before update) {

   BMS_Global_Trigger_Setting__c settings = BMS_Global_Trigger_Setting__c.getOrgDefaults();
   Account[] accs = Trigger.new;

   if (settings.BMS_MSL_Thought_Leader_Evaluation__c == 'NA' || settings.BMS_MSL_Thought_Leader_Evaluation__c == null) {
   BMSMSLTLEvaluation.calculateThoughtLeaderType(accs);
   }
   if (settings.BMS_MSL_Thought_Leader_Evaluation__c == 'IC') {
   BMSMSLTLEvaluation.calculateThoughtLeaderTypeIC(accs);
   }
}