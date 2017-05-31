trigger RequireRejectionCommentMeeting_BMS_EMEA on Medical_Event_vod__c (before update) {

  //code block to check if this transaction belongs to legacy Medical Events or new Events Management module
  //Added by Murugesh Naidu (murugesh.naidu@veeva.com) Nov 12, 2015
  //Assumes that groups will either use EM_Event_vod or Medical_Event_vod as the primary starting point and not both
  if(Trigger.isDelete){
        if(Trigger.old[0].EM_Event_vod__c!=null){
            return;
        }
    }
    else{
        if(Trigger.new[0].EM_Event_vod__c!=null){
            return;
        }    
    }

    // Create a map that stores all the objects that require editing
    Map<Id, Medical_Event_vod__c> approvalStatements = new Map<Id, Medical_Event_vod__c>();

    for (Medical_Event_vod__c inv : trigger.new) {
        // Put all objects for update that require a comment check in a map,
        // so we only have to use 1 SOQL query to do all checks

        if (inv.Approval_Comment_Meeting_Check_BMS_EMEA__c == 'Requested') {
            approvalStatements.put(inv.Id, inv);
            // Reset the field value to null,
            // so that the check is not repeated,
            // next time the object is updated
            inv.Approval_Comment_Meeting_Check_BMS_EMEA__c = null;
        }
    }

    if (!approvalStatements.isEmpty()) {
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
                                  ]) {
            // If no comment exists, then prevent the object from saving.
            if ((pi.Steps[0].Comments == null ||
                    pi.Steps[0].Comments.trim().length() == 0) && pi.Steps[0].StepStatus == 'Rejected') {
                approvalStatements.get(pi.TargetObjectId).addError(System.Label.BMS_EMEA_Require_Comment);
            }
        }
    }
}