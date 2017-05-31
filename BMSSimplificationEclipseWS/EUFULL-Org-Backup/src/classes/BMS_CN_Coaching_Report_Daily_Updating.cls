global class BMS_CN_Coaching_Report_Daily_Updating implements Schedulable 
{
  global void execute(SchedulableContext SC)
  {
    String recTypeStage1 = [select Id from RecordType where Name ='BMS-CHINA-SALES-Coaching-Report-Stage1' and SobjectType = 'Coaching_Report_vod__c'].Id;
    String recTypeStage2 = [select Id from RecordType where Name ='BMS-CHINA-SALES-Coaching-Report-Stage2' and SobjectType = 'Coaching_Report_vod__c'].Id;
    String recTypeStage3 = [select Id from RecordType where Name ='BMS-CHINA-SALES-Coaching-Report-Stage3' and SobjectType = 'Coaching_Report_vod__c'].Id;
    String recTypeReadony = [select Id from RecordType where Name ='BMS-CHINA-SALES-Coaching-Report-Readonly' and SobjectType = 'Coaching_Report_vod__c'].Id;
    date dL1 = date.today().addDays(-2);
    date dL2 = date.today().addDays(-4);
    String mailtmplId1 = [select Id from EmailTemplate where name = 'BMS China Coaching Email Template For Lock1'].Id;
    String mailtmplId2 = [select Id from EmailTemplate where name = 'BMS China Coaching Email Template For Lock2'].Id;
    
    //Checking coaching record that not evaluated.
    for(Coaching_Report_vod__c CR:[Select Id,Name,Status__c,Manager_vod__c,Employee_vod__c,Review_Date__c from Coaching_Report_vod__c where (RECORDTYPEID = :recTypeStage1 OR RECORDTYPEID = :recTypeStage2)])
    {
        //record locked    
        if(CR.Review_Date__c <= dL1)
        {
            CR.RECORDTYPEID = recTypeReadony;
            CR.Status__c = '过期-经理未评价';
            update CR;
            SendAlterEmail(CR.Id,mailtmplId1);
        }
       
    }
    //checking coaching reports that not checked
     for(Coaching_Report_vod__c CR:[Select Id,Name,Status__c,Manager_vod__c,Employee_vod__c,Review_Date__c from Coaching_Report_vod__c where RECORDTYPEID = :recTypeStage3])
    {
        //record locked    
        if(CR.Review_Date__c <= dL2)
        {
            CR.RECORDTYPEID = recTypeReadony;
            CR.Status__c = '过期-代表未确认';
            update CR;
            SendAlterEmail(CR.Id,mailtmplId2);
        }
     }
   
  }
  
  
  //stype 1 Send mail informing coaching locked for no dsm evaluating.
  //stype 2 informing record locked for no rep checking
  global void SendAlterEmail(String cr,String tmpltid)
  {
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      mail.setTargetObjectId(cr);
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
  }
  
}