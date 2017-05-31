/* 
* BMS_CN_MI_BEFORE_DEL - prevent delete MI saved by others
* Author: Roy Zhang
* Created Date: 04/24/2013
* Last Modified Date: 04/24/2013
*/ 
trigger BMS_CN_MI_BEFORE_DEL on Medical_Inquiry_vod__c (before delete) {
	for(Medical_Inquiry_vod__c MedInq : trigger.old) {
		if(MedInq.Inquiry_Type_BMS_CN__c == 'Medical Info Request' || MedInq.Inquiry_Type_BMS_CN__c == 'Adverse Event/Product Problem Report') {
			if(userINfo.getUserId() <> MedInq.CreatedById) {
				Trigger.old[0].AddError('Cannot delete Medical Inquiry submitted by others!');
			}
		}
	}
}