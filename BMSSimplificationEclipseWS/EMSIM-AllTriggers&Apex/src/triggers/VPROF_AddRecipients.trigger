trigger VPROF_AddRecipients on echosign_dev1__SIGN_Agreement__c (after insert) {

    // when a new agreement is created, if the lookup to the ASP is populated get the signers from the related list and create
    // recipients on the agreement

    System.debug('got here');
    // only do this for single inserts
    if(Trigger.new.size() != 1){
        return;
    }

    echosign_dev1__SIGN_Agreement__c agreement = Trigger.new[0];
    if(agreement.Event_Speaker_HCPTS__c==null && agreement.Audience__c==null){
        return;
    }

    List<Contract_Signer_HCPTS__c> signers = [SELECT Id,Entity_Signatory_Email_HCPTS__c, Signer_Sequence__c
                                            FROM Contract_Signer_HCPTS__c
                                            WHERE Activity_Service_Provider__c = :agreement.Event_Speaker_HCPTS__c 
                                            ORDER BY Signer_Sequence__c ASC];
                                            
    List<Audience_Contract_Signer_HCPTS__c> audSigners = [SELECT Id,Entity_Signatory_Email_HCPTS__c, Signer_Sequence__c
                                            FROM Audience_Contract_Signer_HCPTS__c
                                            WHERE Audience__c = :agreement.Audience__c
                                            ORDER BY Signer_Sequence__c ASC];

    List<echosign_dev1__SIGN_Recipients__c> recipients = new List<echosign_dev1__SIGN_Recipients__c>();

    Integer i = 1;

    for(Contract_Signer_HCPTS__c signer: signers){

        echosign_dev1__SIGN_Recipients__c rec = new echosign_dev1__SIGN_Recipients__c();
        rec.Name = 'Rec:' + signer.Entity_Signatory_Email_HCPTS__c;
        rec.echosign_dev1__Email_Address__c = signer.Entity_Signatory_Email_HCPTS__c;
        rec.echosign_dev1__Recipient_Role__c = 'Signer';
        rec.echosign_dev1__Recipient_Type__c = 'Email';
        rec.echosign_dev1__useEmailAddress__c = true;
        rec.echosign_dev1__Order_Number__c = i;
        rec.echosign_dev1__Agreement__c = agreement.Id;
        
        recipients.add(rec);
        i++;
    }
    
    for(Audience_Contract_Signer_HCPTS__c signer: audSigners){

        echosign_dev1__SIGN_Recipients__c rec = new echosign_dev1__SIGN_Recipients__c();
        rec.Name = 'Rec:' + signer.Entity_Signatory_Email_HCPTS__c;
        rec.echosign_dev1__Email_Address__c = signer.Entity_Signatory_Email_HCPTS__c;
        rec.echosign_dev1__Recipient_Role__c = 'Signer';
        rec.echosign_dev1__Recipient_Type__c = 'Email';
        rec.echosign_dev1__useEmailAddress__c = true;
        rec.echosign_dev1__Order_Number__c = i;
        rec.echosign_dev1__Agreement__c = agreement.Id;
        
        recipients.add(rec);
        i++;
    }

    insert recipients;

}