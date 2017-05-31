/* 
* BMS_CN_MI_UPD_ATTACHMENT - Update Medical Info Attachment ojbect
* Author: Roy Zhang
* Created Date: 03/18/2013
* Last Modified Date: 03/18/2013
*/ 
trigger BMS_CN_MI_UPD_ATTACHMENT on Medical_Inquiry_vod__c (after insert, after update) {
	
	
    for(Medical_Inquiry_vod__c MedInqNew : trigger.new) {
    	if(medInqNew.Inquiry_Type_BMS_CN__c == 'Medical Info Request' || medInqNew.Inquiry_Type_BMS_CN__c == 'Adverse Event/Product Problem Report') {
			if(MedInqNew.Attachments_ID_BMS_CN__c <> null) {	        	
            	Med_Info_Attachments_BMS_CN__c attachment = [SELECT Id,Medical_Inquiry__c FROM Med_Info_Attachments_BMS_CN__c WHERE Id =: MedInqNew.Attachments_ID_BMS_CN__c];
            
            	//Write Medical Info ID to attachment object
            	if(attachment.Medical_Inquiry__c == null) {
                	attachment.Medical_Inquiry__c = MedInqNew.Id;
                	update attachment;
            	}
        	}
    	}
    }
}