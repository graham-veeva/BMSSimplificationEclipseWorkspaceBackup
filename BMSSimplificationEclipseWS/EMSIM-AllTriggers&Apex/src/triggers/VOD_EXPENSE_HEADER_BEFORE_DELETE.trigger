trigger VOD_EXPENSE_HEADER_BEFORE_DELETE on Expense_Header_vod__c (before delete) {
    Set<Id> headerIds = Trigger.oldMap.keySet();
    List<Expense_Line_vod__c> relatedExpenseLines = [SELECT Id FROM Expense_Line_vod__c WHERE Expense_Header_vod__c IN :headerIds];
    try {
        delete relatedExpenseLines;
    } catch (DmlException e) {
        for (Integer i = 0; i < e.getNumDml(); i++) {
            // Print out the error message for each failed deletion
            System.debug(e.getDmlMessage(i));
        }
    }
}