/* 
* BMS_CN_MI_UPD_SEND_EMAIL_FLG - Update notificaiton e-mail send flag
* Author: Roy Zhang
* Created Date: 03/15/2013
* Last Modified Date: 03/15/2013
*/ 
trigger BMS_CN_MI_UPD_SEND_EMAIL_FLG on Medical_Inquiry_vod__c (before update) {
    for(integer i = 0; i < trigger.new.size(); i++) {
        Medical_Inquiry_vod__c newMI = trigger.new[0];
        Medical_Inquiry_vod__c oldMI = trigger.old[0];
        
        // Medical Info Request
        if(newMI.Inquiry_Type_BMS_CN__c == 'Medical Info Request' && newMI.Send_Email_Flag_BMS_CN__c == false) {
            // Medical Info Request(Lock) - China
            String strRecTyp= [select Name from RecordType where SObjectType = 'Medical_Inquiry_vod__c'  and Id =: newMI.RecordTypeId ].Name;
            
            // Set Send Email Flag to true if MI is locked and mail has been sent
            if(strRecTyp == 'Medical Info Request(Lock)' && newMI.RecordTypeId == oldMI.RecordTypeId ) {
                newMI.Send_Email_Flag_BMS_CN__c = true;
            }
        }
                
         // Adverse Event/Product Problem Report
        if(newMI.Inquiry_Type_BMS_CN__c == 'Adverse Event/Product Problem Report' && newMI.Send_Email_Flag_BMS_CN__c == false) {
            // AE/Product Problem Report(Lock) - China
            String strRecTyp= [select Name from RecordType where SObjectType = 'Medical_Inquiry_vod__c'  and Id =: newMI.RecordTypeId ].Name;
            
            // Set Send Email Flag to true if MI is locked and mail has been sent
            if(strRecTyp == 'AE/Product Problem Report(Lock)' && newMI.RecordTypeId == oldMI.RecordTypeId ) {
                newMI.Send_Email_Flag_BMS_CN__c = true;
            }
        }
    }

}