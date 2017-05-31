/*
    trigger: VPRO_EH_Prevent_Delete
    description: Prevent delete of Expense Headers if the Status of the Expense Header is anything by blank or draft
    history:
        2017-MAR-10 - Veeva Professional Services (wa) - initial creation
*/
trigger VPRO_EH_Prevent_Delete on Expense_Header_vod__c (before delete) {
    for(Expense_Header_vod__c eh : trigger.old) {
        if(eh.Status_vod__c == 'Draft' || String.IsBlank(eh.Status_vod__c)) {
            system.debug(LoggingLevel.Info, 'The Expense Header ' + eh.id + ' in status ' + eh.Status_vod__c + ' is being deleted');
            continue;
        }
        system.debug(LoggingLevel.Info, 'The Expense Header ' + eh.id + ' in status ' + eh.Status_vod__c + ' may not be deleted');
        eh.addError('Expense Headers in the status ' + eh.Status_vod__c + ' may not be deleted');
    }
}