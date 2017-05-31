global class speakerContractValidation{
    
    //mnaidu Feb 7th, 2016
    webservice static string getActivitySpeakerCongaIds(String SpeakerID){
        EM_Event_Speaker_vod__c eventSpeaker = [SELECT Can_Generate_Contract__c,Related_ICF_HCPTS__c, 
                                           Service_type_HCPTS__c, Contract_Language_HCPTS__c,
                                                Speaker_Contract_HCPTS__r.Non_standard_Contract_Template_HCPTS__c, 
                                                Event_Speaker_Contract_HCPTS__r.Non_standard_Contract_Template_HCPTS__c,
                                                Speaker_Contract_HCPTS__r.Status_vod__c,
                                                Event_Speaker_Contract_HCPTS__r.Status_vod__c,
                                                Contract_Format_HCPTS__c, Speaker_vod__r.Country_Lookup_HCPTS__c
                                            
                FROM EM_Event_Speaker_vod__c
                WHERE Id=:SpeakerID LIMIT 1];  

            System.debug('Retrieved Event Speaker: ' + eventSpeaker);
            //mnaidu - Feb 7th, 2016
            //additional logic to refresh the Template Ids based on parameters
            String templateIds = '';
            if(eventSpeaker.Contract_Format_HCPTS__c == 'Long-term' 
               && eventSpeaker.Speaker_Contract_HCPTS__r.Status_vod__c != 'Activated_vod'
               ){
                if(eventSpeaker.Speaker_Contract_HCPTS__r.Non_standard_Contract_Template_HCPTS__c !=null){
                    templateIds += eventSpeaker.Speaker_Contract_HCPTS__r.Non_standard_Contract_Template_HCPTS__c + ',';
                System.debug('Nonstandard template id');
                System.debug('templateIds = ' + templateIds);
                }
                else{
                    
                    List<APXTConga4__Conga_Template__c> fwCongaTemplate = [Select Id 
                                                                           from APXTConga4__Conga_Template__c 
                                   where Contract_Type_HCPTS__c = :eventSpeaker.Service_Type_HCPTS__c 
                                    AND Contract_Format_HCPTS__c = :eventSpeaker.Contract_Format_HCPTS__c 
                                    AND Language_HCPTS__c = :eventSpeaker.Contract_Language_HCPTS__c 
                                    AND Country_Lookup_HCPTS__c = :eventSpeaker.Speaker_vod__r.Country_Lookup_HCPTS__c
                                    AND Is_Framework_Agreement_HCPTS__c = True
                                    AND APXTConga4__Template_Group__c = 'EventAgreements'
                                    Order by LastModifiedDate DESC
                                    LIMIT 1];
                    if(fwCongaTemplate!=null && fwCongaTemplate.size()>0){
                        templateIds += fwCongaTemplate[0].Id + ',';
                System.debug('standard fwa template id');
                System.debug('templateIds = ' + templateIds);
                    }
                }
            }
            if(eventSpeaker.Event_Speaker_Contract_HCPTS__r.Status_vod__c!='Activated_vod'){
                //Only Activity agreement
                System.debug('Not activated contract .. running query now');
                System.debug('eventSpeaker = ' + eventSpeaker);
                System.debug('Contract_Format_HCPTS__c = ' + eventSpeaker.Contract_Format_HCPTS__c);
                System.debug('Contract_Type_HCPTS__c = ' + eventSpeaker.Service_Type_HCPTS__c);
                System.debug('Language_HCPTS__c = ' + eventSpeaker.Contract_Language_HCPTS__c);
                if(eventSpeaker.Event_Speaker_Contract_HCPTS__r.Non_standard_Contract_Template_HCPTS__c !=null){
                    templateIds += eventSpeaker.Event_Speaker_Contract_HCPTS__r.Non_standard_Contract_Template_HCPTS__c;
                System.debug('Nonstandard aa template id');
                System.debug('templateIds = ' + templateIds);
                }
                else{
                    String contractType = eventSpeaker.Service_Type_HCPTS__c;
                    String contractLang = eventSpeaker.Contract_Language_HCPTS__c;
                    ID contractCountry = eventSpeaker.Speaker_vod__r.Country_Lookup_HCPTS__c;
                    String contractFormat = eventSpeaker.Contract_Format_HCPTS__c;
                    String query = 'Select Id from APXTConga4__Conga_Template__c '
                                     +  ' where Contract_Type_HCPTS__c = :contractType' 
                                  //   + ' AND Contract_Format_HCPTS__c = :eventSpeaker.Contract_Format_HCPTS__c' 
                                     + ' AND Language_HCPTS__c = :contractLang '
                                     + ' AND Country_Lookup_HCPTS__c = :contractCountry '
                                     + ' AND (Is_Framework_Agreement_HCPTS__c = False '
                                     +   ' OR Is_Framework_Agreement_HCPTS__c = null)'
                                    + ' AND APXTConga4__Template_Group__c = \'EventAgreements\'';
                    if(eventSpeaker.Contract_Format_HCPTS__c!=null && eventSpeaker.Contract_Format_HCPTS__c.trim()!=''){
                        query += + ' AND Contract_Format_HCPTS__c = :contractFormat' ;
                    }
                    query += ' Order by LastModifiedDate DESC LIMIT 1'  ;           
                    List<APXTConga4__Conga_Template__c> aaCongaTemplate = Database.query(query);
                    if(aaCongaTemplate!=null && aaCongaTemplate.size()>0){
                        templateIds += aaCongaTemplate[0].Id;
                System.debug('standard template id');
                System.debug('templateIds = ' + templateIds);
                    }
                }
                
            }
            System.debug('Returning template Ids = ' + templateIds);
         return templateIds;
    }
    //mnaidu Feb 7th, 2016
    webservice static string getAudienceCongaIds(String audienceId){

        EM_Attendee_vod__c audience = [SELECT Contract_type_HCPTS__c, Language__c, Country_ref_HCPTS__c, Audience_Type_HCPTS__c
                                        FROM EM_Attendee_vod__c
                                        WHERE Id=:audienceId LIMIT 1]; 
        
        List<APXTConga4__Conga_Template__c> congaTemplateIds = [ SELECT Id FROM APXTConga4__Conga_Template__c 
                                                                    WHERE Contract_Type_HCPTS__c =: audience.Contract_type_HCPTS__c
                                                                    AND Country_Lookup_HCPTS__c =: audience.Country_ref_HCPTS__c
                                                                    AND Language_HCPTS__c =: audience.Language__c
                                                                    AND Audience_Type__c INCLUDES (:audience.Audience_Type_HCPTS__c)
                                                                    AND APXTConga4__Template_Group__c = 'AudienceContracts'
                                                                    ORDER BY LastModifiedDate DESC LIMIT 1];
                                                                    
         System.debug('audience = ' + audience);
         System.debug('congaTemplateIds = ' + congaTemplateIds);
         
         return congaTemplateIds[0].Id;
    }
    webservice static string testSpeaker(String SpeakerID){

        EM_Event_Speaker_vod__c eventSpeaker = [SELECT Id
                FROM EM_Event_Speaker_vod__c
                WHERE Id=:SpeakerID LIMIT 1];
        
        
        String errorMessage = '';
        
        Savepoint sp = Database.setSavepoint();
       
       
        try{
            List<LockActivityChildren__c> lockedChildren = CustomVeevaUtilities.unlockForEdits('EM_Event_Speaker_vod__c');
    
            eventSpeaker.Can_Generate_Contract__c = 'true';
            
            Database.SaveResult saveResult = Database.update(eventSpeaker, false);
            
            System.debug('saveResult: ' + saveResult);
    
            if (saveResult.isSuccess()) {
                //success, undo changes
                eventSpeaker.Can_Generate_Contract__c = '';
                Database.update(eventSpeaker);
                
                //we are also going to update the contract party and service type
                //on the contracts (Framework Agreement and Activity Agreement)
                //based on the ICF in case it has changed
                 errorMessage = CustomVeevaUtilities.updateContractParties(eventSpeaker);
    
                //return 'Success';
            }else{
                //error, return the messages
                for(Database.Error err : saveResult.getErrors()) {
                    errorMessage = errorMessage + err.getMessage() + '\n';
                }
            }
           if(lockedChildren!=null && lockedChildren.size() > 0){
               CustomVeevaUtilities.relockForEdits(lockedChildren);         
           }

            String congaId = getActivitySpeakerCongaIds(SpeakerID);

            if(congaId == null || congaId == ''){
                errorMessage = System.Label.VPROF_No_Contracting_Template;
            }

            return errorMessage;
         //   errorMessage = errorMessage + '';         
        }catch(DMLException e){
            System.debug('DML Exception while creating Generating contracts' + e);
            errorMessage = 'DML Exception while creating Generating contracts, no updates were made-' + e.getMessage();
            Database.rollback(sp);
        //  return null;
        }

        // Added 7-12-16, make sure that there is a conga template for this ASP
        String congaId = getActivitySpeakerCongaIds(SpeakerID);

        if(congaId == null || congaId == ''){
            errorMessage += System.Label.VPROF_No_Contracting_Template;
        }

        return errorMessage;
    }

    webservice static string testAudience(String audId){
        String errorMessage = '';
        EM_Attendee_vod__c aud = new EM_Attendee_vod__c();
        aud.Id = audId;
        aud.Can_Generate_Contract__c = 'true';
        Savepoint sp = Database.setSavepoint();
        
        try{
            List<LockActivityChildren__c> lockedChildren = CustomVeevaUtilities.unlockForEdits('EM_Attendee_vod__c');
            Database.SaveResult saveResult = Database.update(aud, false);
    
            System.debug('saveResult: ' + saveResult);
    
            if (saveResult.isSuccess()) {
                aud.Can_Generate_Contract__c = '';
                Database.update(aud);
                errorMessage = 'Success';
            }else{
                for(Database.Error err : saveResult.getErrors()) {
                    errorMessage = errorMessage + err.getMessage() + '\n';
                }
            }
            
           if(lockedChildren!=null && lockedChildren.size() > 0){
               CustomVeevaUtilities.relockForEdits(lockedChildren);         
           }
            
            
            
        }catch(DMLException e){
            System.debug('DML Exception while creating Generating contracts' + e);
            errorMessage = 'DML Exception while creating Generating contracts, no updates were made-' + e.getMessage();
            Database.rollback(sp);
        //  return null;
        }
        
        EM_Attendee_vod__c audience = [SELECT Contract_type_HCPTS__c, Language__c, Country_ref_HCPTS__c, Audience_Type_HCPTS__c
                                        FROM EM_Attendee_vod__c
                                        WHERE Id=:audId LIMIT 1];
        
        List<APXTConga4__Conga_Template__c> congaTemplateIds = [ SELECT Id FROM APXTConga4__Conga_Template__c 
                                                                    WHERE Contract_Type_HCPTS__c =: audience.Contract_type_HCPTS__c
                                                                    AND Country_Lookup_HCPTS__c =: audience.Country_ref_HCPTS__c
                                                                    AND Language_HCPTS__c =: audience.Language__c
                                                                    AND Audience_Type__c INCLUDES (:audience.Audience_Type_HCPTS__c)
                                                                    AND APXTConga4__Template_Group__c = 'AudienceContracts'
                                                                    ORDER BY LastModifiedDate DESC LIMIT 1];
        if(congaTemplateIds.size() != 1){
            return System.Label.VPROF_No_Contracting_Template;
        }
        
        return errorMessage;

    }

    webservice static string testContractParty(String cpID){

        List<EM_Vendor_vod__c> contractPartyList = [SELECT Id
                FROM EM_Vendor_vod__c
                WHERE Id=:cpID LIMIT 1];

        EM_Vendor_vod__c contractParty;
        
        if(contractPartyList.size() != 1){
            return 'Error, could not find the contract party.';
        }else{
            contractParty = contractPartyList[0];
        }
        
        String errorMessage = '';
       
        try{

            contractParty.Can_Generate_VMF__c = 'true';
            
            Database.SaveResult saveResult = Database.update(contractParty, false);
    
            if (saveResult.isSuccess()) {
                //success, undo changes
                contractParty.Can_Generate_VMF__c = '';
                Database.update(contractParty);
                return 'Success';
            }else{
                //error, return the messages
                for(Database.Error err : saveResult.getErrors()) {
                    errorMessage = errorMessage + err.getMessage() + '\n';
                }
            }
            return errorMessage;       
        }catch(DMLException e){
            return errorMessage;
        }
    }
}