trigger VPROF_ExpenseLine_BeforeInsert_BeforeUpdate on Expense_Line_vod__c (before insert, before update) {

    /*
    ** This trigger is replacing the workflow rules Expense Line: Update Actuals with SAP Actuals
    ** and Update OrigSysLineNum to prevent the update triggers on Expense Line from firing
    ** on insert (after the workflows have updated thier fields)
    */
    Set<Id> headerIds = new Set<Id>();
    for(Expense_Line_vod__c expLine: Trigger.new){
        headerIds.add(expLine.Expense_Header_vod__c);
    }
    Map<ID,Expense_Header_vod__c > headerMap = new Map<ID,Expense_Header_vod__c > (
    [SELECT Id,Expense_Line_Items_Number_HCPTS__c, RecordType.DeveloperName FROM Expense_Header_vod__c WHERE Id IN :headerIds]);
    List<Expense_Header_vod__c> headers = headerMap.values();
 
    if(trigger.isInsert){
        // we need to keep track of the number of inserts because each expense line needs
        // a unique number. Use the field Expense_Header_vod__r.Expense_Line_Items_Number_HCPTS__c
        // as the starting number and then increment the number for each update
        Map<Id,Integer> expenseHeaderToNumberOfInserts = new Map<Id,Integer>();
        for(Expense_Line_vod__c expLine: Trigger.new){
            if(!expenseHeaderToNumberOfInserts.containsKey(expLine.Expense_Header_vod__c)){
                for(Expense_Header_vod__c header : headers){
                    if(header.Id == expLine.Expense_Header_vod__c){
                        expLine.OriginatingSystemLineNumber_HCPTS__c = String.valueOf(header.Expense_Line_Items_Number_HCPTS__c + 1);
                        expenseHeaderToNumberOfInserts.put(header.Id,1);
                        break;
                    }
                }
            }else{
                for(Expense_Header_vod__c header : headers){
                    if(header.Id == expLine.Expense_Header_vod__c){
                        System.debug('header.Expense_Line_Items_Number_HCPTS__c: ' + header.Expense_Line_Items_Number_HCPTS__c);
                        System.debug('expenseHeaderToNumberOfInserts.get(header.Id): ' + expenseHeaderToNumberOfInserts.get(header.Id));
                        System.debug('expenseHeaderToNumberOfInserts: ' + expenseHeaderToNumberOfInserts);
                        expLine.OriginatingSystemLineNumber_HCPTS__c = String.ValueOf(header.Expense_Line_Items_Number_HCPTS__c + 1 + expenseHeaderToNumberOfInserts.get(header.Id));
                        expenseHeaderToNumberOfInserts.put(header.Id,expenseHeaderToNumberOfInserts.get(header.Id) + 1);
                        break;
                    }
                }
            }
        }
    }

    //mnaidu - Feb 10th, 2017 - Simplification Phase change
    //Copy over Committed_vod to Committed_Amount_in_Requested_HCPTS__c if it is empty
    if(Trigger.IsInsert || Trigger.IsUpdate){
        for(Expense_Line_vod__c el: Trigger.New){
        	System.debug('Trigger.IsInsert = ' + Trigger.IsInsert + ', Expense Header Rectype = ' + headerMap.get(el.Expense_Header_vod__c).Recordtype.DeveloperName);
            if(headerMap.get(el.Expense_Header_vod__c).Recordtype.DeveloperName == 'Simple_Expense_Header'
             && (el.Committed_Amount_in_Requested_HCPTS__c == null || el.Committed_Amount_in_Requested_HCPTS__c == 0)){
            	el.Committed_Amount_in_Requested_HCPTS__c = el.Committed_vod__c;                
            }
        }
    }
    //mnaidu - March 8th, 2016
    //Updated logic to fire only if SAP_Actuals_Sum__c has changed
    //This should ensure this logic only fires if SAP Lines exist or are
    //applicable to an Expense Line
   // for(Expense_Line_vod__c expLine: Trigger.new){
     //   if(Trigger.isUpdate
       //    && Trigger.oldMap.get(expLine.Id).SAP_Actuals_Sum__c != expLine.SAP_Actuals_Sum__c){
         //       expLine.Actual_vod__c = expLine.SAP_Actuals_Sum__c;
          // }
   // }


}