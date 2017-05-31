trigger BMS_CN_Coaching_Report_Before_INSUPD on Coaching_Report_vod__c (before insert, before update) 
{
	//Author:           Nate Zhang
    //Create Date:      2013.08.12		Created
    //Last Update Date: 2013.08.12		Update Employee_vod__c and Manager_vod__c for China DSM created coaching reports.
	//Last Update Date: 2013.08.14		Update Employee_vod__c and Manager_vod__c for China Training Manager created coaching reports.
	 
    for (Integer i = 0 ; i < Trigger.new.size(); i++) 
    {
       if (Trigger.new[i].Employee_BMS_CN__c != null || Trigger.new[i].Employee_TrainingScope_BMS_CN__c != null) //For BMS China
       {
       	   bms_cn_setting__c cnSetting = bms_cn_setting__c.getInstance();
       	   Double daysLimit = cnSetting.Coaching_Block_Days_BMS_CN__c;
       	   if(Trigger.new[i].Review_Date__c.daysBetween(Date.today()) > daysLimit.intValue())
       	       Trigger.new[i].addError('You cannot submit a coaching report happened ' + daysLimit + ' days ago.');
       	   Trigger.new[i].Manager_vod__c = UserInfo.getUserId();
       	   Trigger.new[i].Employee_ForView_BMS_CN__c = Trigger.new[i].Employee_BMS_CN__c != null ? Trigger.new[i].Employee_BMS_CN__c : Trigger.new[i].Employee_TrainingScope_BMS_CN__c ;
           if(Trigger.new[i].Status__c == 'Submitted')
               Trigger.new[i].Employee_vod__c = Trigger.new[i].Employee_ForView_BMS_CN__c;
           
       }
    }
}