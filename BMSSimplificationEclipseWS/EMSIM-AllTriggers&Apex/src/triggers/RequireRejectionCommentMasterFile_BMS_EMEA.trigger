trigger RequireRejectionCommentMasterFile_BMS_EMEA on Master_File_BMS_EMEA__c (before update) {

  // Create a map that stores all the objects that require editing 
  Map<Id, Master_File_BMS_EMEA__c> approvalStatements = 
  new Map<Id, Master_File_BMS_EMEA__c>{};

  for(Master_File_BMS_EMEA__c inv: trigger.new)
  {
    // Put all objects for update that require a comment check in a map,
    // so we only have to use 1 SOQL query to do all checks
    system.debug('Approval_Comment_Check_BMS_EMEA__c: ' + inv.Approval_Comment_Check_BMS_EMEA__c);
    
    if (inv.Approval_Comment_Check_BMS_EMEA__c == 'Requested')
    { 
      approvalStatements.put(inv.Id, inv);
      // Reset the field value to null, 
      // so that the check is not repeated,
      // next time the object is updated
      inv.Approval_Comment_Check_BMS_EMEA__c = null; 
    }
  }  
   
  if (!approvalStatements.isEmpty())  
  {
    // Get the last approval process step for the approval processes, 
    // and check the comments.
    for (ProcessInstance pi : [SELECT TargetObjectId, 
                                (SELECT Id, StepStatus, Comments 
                                 FROM Steps
                                 ORDER BY CreatedDate DESC
                                  LIMIT 1 
                                  )
                               FROM ProcessInstance
                               WHERE TargetObjectId In 
                                    :approvalStatements.keySet()
                               ORDER BY CreatedDate DESC
                              ])
    { 
      // If no comment exists, then prevent the object from saving.                 
      if ((pi.Steps[0].Comments == null || 
           pi.Steps[0].Comments.trim().length() == 0) && pi.Steps[0].StepStatus == 'Rejected')
      {
        approvalStatements.get(pi.TargetObjectId).addError(System.Label.BMS_EMEA_Require_Comment);
      }
    }  
  }

  
}