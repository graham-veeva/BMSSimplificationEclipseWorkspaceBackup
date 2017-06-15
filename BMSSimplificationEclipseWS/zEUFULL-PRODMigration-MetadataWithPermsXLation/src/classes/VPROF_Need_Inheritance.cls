public class VPROF_Need_Inheritance {
    
    public static Integer timeDelay = 12;

    public static void inheritHeaderInfo(EM_Event_Budget_vod__c activityBudget, EM_Event_vod__c activity,
                    BMSNeedToEventInheritance__c inheritanceSetting,EM_Budget_vod__c need){

        // get the field mappings
        String fieldCopyMapping = '';
        if(inheritanceSetting.Header_Field_Mapping__c!=null && inheritanceSetting.Header_Field_Mapping__c.trim()!=''){
            fieldCopyMapping+=inheritanceSetting.Header_Field_Mapping__c;
        }
        if(inheritanceSetting.Header_Field_Mapping_2__c!=null && inheritanceSetting.Header_Field_Mapping_2__c.trim()!=''){
            fieldCopyMapping+=inheritanceSetting.Header_Field_Mapping_2__c;
        }
        if(inheritanceSetting.Header_Field_Mapping_3__c!=null && inheritanceSetting.Header_Field_Mapping_3__c.trim()!=''){
            fieldCopyMapping+=inheritanceSetting.Header_Field_Mapping_3__c;
        }
        if(inheritanceSetting.Header_Field_Mapping_4__c!=null && inheritanceSetting.Header_Field_Mapping_4__c.trim()!=''){
            fieldCopyMapping+=inheritanceSetting.Header_Field_Mapping_4__c;
        }
        if(inheritanceSetting.Header_Field_Mapping_5__c!=null && inheritanceSetting.Header_Field_Mapping_5__c.trim()!=''){
            fieldCopyMapping+=inheritanceSetting.Header_Field_Mapping_5__c;
        }

        // populated the fields into the activity, populate the inherited need field, and udpate the activity
        if(fieldCopyMapping!=null && fieldCopyMapping.trim()!=''){
            String[] mappings = fieldCopyMapping.split(';');
            for(String aMapping: mappings){
                String budgetFieldName = aMapping.subStringBefore(':').trim();
                String eventFieldName = aMapping.subStringAfter(':').trim();
                System.debug('budgetFieldName: ' + budgetFieldName + '  eventFieldName: ' + eventFieldName);
                if(need.get(budgetFieldName)!=null){
                    activity.put(eventFieldName, need.get(budgetFieldName));//sets the Event field with Budget field value
                }
            }
        }
        activityBudget.Is_Need__c = true;
        update activity;

    }

    public static void inheritParticipants(ID activityBudgetId, Id activityId, Id needId){

        String participantQry = CustomVeevaUtilities.getDynamicSOQLForAllEligibleFields(Participants_HCPTS__c.sObjectType);
        participantQry += ' WHERE Budget_HCPTS__c = \'' + needId + '\'';
        List<Participants_HCPTS__c> parts = Database.query(participantQry);
        List<Participants_HCPTS__c> partsToInsert = new List<Participants_HCPTS__c>();
        for(Participants_HCPTS__c part: parts){
            Participants_HCPTS__c newPart = part.clone(false, true, false, false);
            newPart.Budget_HCPTS__c = null;
            newPart.Activity_HCPTS__c = activityId;
            partsToInsert.add(newPart);
        }
        insert partsToInsert;
    
    }

    public static void scheduleExpenseEstimateInheritance(Id activityBudgetId, Id activityId, Id needId){

        inheritExpenseEstimateFuture(activityBudgetId,activityId,needId,UserInfo.getUserId());

        Long startingTime = System.now().getTime(); // Num milliseconds since Jan 1 1970
        Integer delayInMilliseconds = 1000 * timeDelay;
        while (System.now().getTime() - startingTime < delayInMilliseconds)  {
            // Do nothing until desired delay has passed
        }

        System.debug('Testing if it worked: ' + System.now().getTime());

        // see if it worked, email the user to let them know that their request is being processed
        EM_Event_Budget_vod__c activityBudget = [SELECT Id,Failure_Inheriting_Expense_Estimates__c,Waiting_for_Expense_Estimate_Inheritance__c
                            FROM EM_Event_Budget_vod__c WHERE Id = :activityBudgetId];

        if(activityBudget.Failure_Inheriting_Expense_Estimates__c == false && activityBudget.Waiting_for_Expense_Estimate_Inheritance__c == true){

            Messaging.SingleEmailMessage errorEmail = new Messaging.SingleEmailMessage();
            errorEmail.setTargetObjectID(UserInfo.getUserId());
            errorEmail.setSubject(Label.Expense_Estimate_Inheritance_Delay);
            errorEmail.saveAsActivity = false;
            String emailBody = Label.Exp_Estimate_Inherit_Delay_Body_1;
            emailBody += ' ' + System.Url.getSalesforceBaseURL().toExternalForm() + '/' + activityId + ' ';
            emailBody += Label.Exp_Estimate_Inherit_Delay_Body_2;
            errorEmail.setHtmlBody(emailBody);

            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{errorEmail});

        }
    }

    public static void inheritExpenseEstimate(Id activityBudgetId, Id activityId, Id needId){
        // delete the existing expense estimates on the activity
        List<EM_Expense_Estimate_vod__c> expEstimates = [SELECT Id FROM EM_Expense_Estimate_vod__c WHERE Event_vod__c = :activityId];
        Database.DeleteResult[] results = Database.delete(expEstimates, false);

        // copy over the new expense estimates
        String needEEQry = CustomVeevaUtilities.getDynamicSOQLForAllEligibleFields(Need_Expense_Estimate_HCPTS__c.sObjectType);
        needEEQry += ' WHERE Need__c = \'' + needId + '\'';
        List<Need_Expense_Estimate_HCPTS__c> needExpEstimtes = Database.query(needEEQry);
        List<EM_Expense_Estimate_vod__c> eesToInsert = new List<EM_Expense_Estimate_vod__c>();
        for(Need_Expense_Estimate_HCPTS__c nExpEst: needExpEstimtes){
            EM_Expense_Estimate_vod__c newEstimate = new EM_Expense_Estimate_vod__c();
            newEstimate.Actual_vod__c = nExpEst.Actual_vod__c;
            newEstimate.Committed_vod__c = nExpEst.Committed_vod__c;
            newEstimate.Estimate_vod__c = nExpEst.Estimate_vod__c;
            newEstimate.Expense_Type_vod__c = nExpEst.Expense_Type_vod__c;
            newEstimate.Expense_Type_Code_vod__c = nExpEst.Expense_Type_Code_vod__c;
            newEstimate.Expense_Type_Name_vod__c = nExpEst.Expense_Type_Name_vod__c;
            newEstimate.External_ID_vod__c = nExpEst.External_ID_vod__c;
            newEstimate.Mobile_ID_vod__c = nExpEst.Mobile_ID_vod__c;
            newEstimate.Parent_Expense_Type_Code_vod__c = nExpEst.Parent_Expense_Type_Code_vod__c;
            newEstimate.Parent_Expense_Type_Name_vod__c = nExpEst.Parent_Expense_Type_Name_vod__c;
            newEstimate.zvod_Expense_Type_vod__c = nExpEst.zvod_Expense_Type_vod__c;
            newEstimate.Event_vod__c = activityId;
            newEstimate.Event_Budget_vod__c = activityBudgetId;
            eesToInsert.add(newEstimate);
        }
        insert eesToInsert;
    }

    @future
    public static void inheritExpenseEstimateFuture(Id activityBudgetId, Id activityId, Id needId, Id userId){

        System.debug('Future call starting: ' + System.now().getTime());

        try{
            
            List<LockActivityChildren__c> lockedChildren = CustomVeevaUtilities.unlockForEdits('EM_Event_Budget_vod__c');
            List<LockActivityChildren__c> lockedChildren2 = CustomVeevaUtilities.unlockForEdits('EM_Expense_Estimate_vod__c');

            inheritExpenseEstimate(activityBudgetId, activityId, needId);
            EM_Event_Budget_vod__c activityBudget = new EM_Event_Budget_vod__c();
            activityBudget.Id = activityBudgetId;
            activityBudget.Waiting_for_Expense_Estimate_Inheritance__c = false;
            update activityBudget;

            if(lockedChildren!=null && lockedChildren.size() > 0){
               CustomVeevaUtilities.relockForEdits(lockedChildren);         
            }
            if(lockedChildren2!=null && lockedChildren2.size() > 0){
               CustomVeevaUtilities.relockForEdits(lockedChildren2);            
            }

            System.debug('Future call ending: ' + System.now().getTime());

            //throw new testException('Test error! There was a problem and this is the error message.');

        }Catch(Exception e){

            //if there is an error, send the user an email to alert them

            EM_Event_Budget_vod__c activityBudget = new EM_Event_Budget_vod__c();
            activityBudget.Id = activityBudgetId;
            activityBudget.Waiting_for_Expense_Estimate_Inheritance__c = false;
            activityBudget.Failure_Inheriting_Expense_Estimates__c = true;
            update activityBudget;

            Messaging.SingleEmailMessage errorEmail = new Messaging.SingleEmailMessage();
            errorEmail.setTargetObjectID(userId);
            errorEmail.setSubject(Label.Expense_Estimate_Inheritance_Failure);
            errorEmail.saveAsActivity = false;
            String emailBody = Label.EE_Inheritance_Failure_1;
            emailBody += ' ' + System.Url.getSalesforceBaseURL().toExternalForm() + '/' + needId;
            emailBody += ' ' + Label.EE_Inheritance_Failure_2;
            emailBody += ' ' + System.Url.getSalesforceBaseURL().toExternalForm() + '/' + activityId;
            emailBody += ' ' + Label.EE_Inheritance_Failure_3;
            emailBody += '<br />' + e.getMessage();
            errorEmail.setHtmlBody(emailBody);

            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{errorEmail});

        }
    }

    //public class testException extends Exception {}

}