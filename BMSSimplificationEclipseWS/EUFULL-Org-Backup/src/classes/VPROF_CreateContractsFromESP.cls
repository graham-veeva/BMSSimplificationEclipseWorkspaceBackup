public with sharing class VPROF_CreateContractsFromESP {
    EM_Event_Speaker_vod__c esp;
    String retURL = '';
    public static final String ICF_REC_TYPE_DEV_NAME_HCP_SVCS = 'ICF_HCP_Services';
    public static final String ICF_REC_TYPE_DEV_NAME_HCO_SVCS = 'ICF_HCO_Services';
    public static final String ICF_REC_TYPE_DEV_NAME_SIMPLE_ICF = 'ICF';
    
    Map<String, String> mapContractTypeToRecType = new Map<String, String>{'Events' => 'Activity_Agreement_EBD', 
                                                                            'Services' => 'Activity_Agreement_Services',
                                                                            'Sponsorship' => 'Activity_Agreement_Sponsorship'};

    public VPROF_CreateContractsFromESP(ApexPages.StandardController controller){
        List<String> fieldsToGet = new List<String>();
        fieldsToGet.add('Speaker_Contract_HCPTS__c');//FW Agreement
        fieldsToGet.add('Event_Speaker_Contract_HCPTS__c');//Activity Agreement
        fieldsToGet.add('Related_ICF_HCPTS__c');//ICF
        fieldsToGet.add('Speaker_vod__c');//Speaker
        fieldsToGet.add('Speaker_vod__r.IsPersonAccount_HCPTS__c');//Speaker
        fieldsToGet.add('Speaker_vod__r.Hourly_Rate_HCPTS__c');//Speaker
        fieldsToGet.add('Speaker_vod__r.Country_Lookup_HCPTS__c');//Speaker country reference
        fieldsToGet.add('Speaker_vod__r.Country_Lookup_HCPTS__r.Alpha_2_Code_vod__c');//Speaker country ISO code
        fieldsToGet.add('External_ID_vod__c');//External ID of ESP
        fieldsToGet.add('Event_vod__r.Name');//External ID of ESP
        fieldsToGet.add('Name');//External ID of ESP
        fieldsToGet.add('Service_Type_HCPTS__c');
        fieldsToGet.add('Service_Subtype_HCPTS__c');
//      fieldsToGet.add('Speaker_vod__r.Country_HCPTS__c');
        controller.addFields(fieldsToGet);
        esp = (EM_Event_Speaker_vod__c) controller.getRecord(); 
        retURL = ApexPages.currentPage().getParameters().get('retURL');
    }

    public Pagereference regenerateICFs(){
        if(esp.Related_ICF_HCPTS__c==null){
            ApexPages.Message myMsg = new ApexPages.Message(
                                                ApexPages.severity.ERROR,
                                                System.Label.VPROF_Err_Msg_Select_Related_ICF);
            ApexPages.addmessage(myMsg);
            return null;
        }
        String icfSOQL = CustomVeevaUtilities.getDynamicSOQLForAllEligibleFields(Information_Collection_Form__c.sObjectType);
        icfSOQL+= ' where Id = \'' + esp.Related_ICF_HCPTS__c + '\'';
        Information_Collection_Form__c theICF = Database.query(icfSOQL);
        Information_Collection_Form__c clonedICF = theICF.clone(false, false, false, false);
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Information_Collection_Form__c.getRecordTypeInfosByName();
        rtMapByName = VPROF_Javascript_Utilities.getMapByRecordTypeDevName(rtMapByName);
        ID icfRecTypeId ; 
        clonedICF.Status_HCPTS__c = 'Draft';
        clonedICF.Signature_Date_HCPTS__c = null;
        clonedICF.Contract_Address_same_as_Contact_HCPTS__c = null;
        clonedICF.Speaker_is_Contract_Party_HCPTS__c = false;
        clonedICF.Signature_HCPTS__c = null;
        clonedICF.Speaker_HCPTS__c = esp.Speaker_vod__c;
        clonedICF.Vendor_HCPTS__c = null;//null this out so that users can follow the same process as New ICF (agreed with Krishna on 10/26)
        clonedICF.Activity_Source_2__c = esp.Id ;
        
//*** CHANGE REQUESTED BY SHAHEEN/KRISHNA - EVENTS AND SPONSORSHIP ICF TYPES SHOULD NOT BE USED AT ALL***JUNE 14, 2016 - SEE EMAIL TITLED "icf type questions"
        if(esp.Speaker_vod__r.IsPersonAccount_HCPTS__c){
            clonedICF.ICF_Type_HCPTS__c = 'HCP/Non-HCP Services';
            clonedICF.RecordtypeId = rtMapByName.get(ICF_REC_TYPE_DEV_NAME_HCP_SVCS).getRecordTypeId();
        }
        else{
            clonedICF.ICF_Type_HCPTS__c = 'HCO Services';                       
            clonedICF.RecordtypeId = rtMapByName.get(ICF_REC_TYPE_DEV_NAME_HCO_SVCS).getRecordTypeId();
        }

/*** CHANGE REQUESTED BY SHAHEEN/KRISHNA - EVENTS AND SPONSORSHIP ICF TYPES SHOULD NOT BE USED AT ALL***JUNE 14, 2016  - SEE EMAIL TITLED "icf type questions"

        if(esp.Service_Type_HCPTS__c == 'Services'){
            if(esp.Speaker_vod__r.IsPersonAccount_HCPTS__c){
                clonedICF.ICF_Type_HCPTS__c = 'HCP/Non-HCP Services';
                clonedICF.RecordtypeId = rtMapByName.get('ICF HCP Services').getRecordTypeId();
            }
            else{
                clonedICF.ICF_Type_HCPTS__c = 'HCO Services';                       
                clonedICF.RecordtypeId = rtMapByName.get('ICF HCO Services').getRecordTypeId();
            }
        }
        else if(esp.Service_Type_HCPTS__c == 'Sponsorship'){
                clonedICF.ICF_Type_HCPTS__c = 'Sponsorship';    
                clonedICF.RecordtypeId = rtMapByName.get('ICF HCP Sponsorship').getRecordTypeId();
        }
        else if(esp.Service_Type_HCPTS__c == 'Events'){
                clonedICF.ICF_Type_HCPTS__c = 'Events'; 
                clonedICF.RecordtypeId = rtMapByName.get('ICF Events').getRecordTypeId();
        }
        */
        insert clonedICF;
        esp.Related_ICF_HCPTS__c = clonedICF.id;
        update esp;         
    //  return null;
        return new PageReference('/' + esp.Id);
    }   
    
    public Pagereference addContracts(){
        Boolean updateESP = false;
        /*if(esp.Speaker_Contract_HCPTS__c!=null 
                && esp.Event_Speaker_Contract_HCPTS__c!=null 
                && esp.Related_ICF_HCPTS__c!=null){
            ApexPages.Message myMsg = new ApexPages.Message(
                                                ApexPages.severity.INFO, 
                                                System.Label.VPROF_Err_Msg_Contract_ICF_Already_Exist);
            ApexPages.addmessage(myMsg);
            return null;
        }*/
        /*
        if(esp.Related_ICF_HCPTS__c!=null){

            // make sure that the Contact Party on the Framework agreement and the Activity Agreement are
            // updated to match the Contact Party on the ICF
            Information_Collection_Form__c existingIFC = [SELECT Vendor_HCPTS__c FROM Information_Collection_Form__c WHERE Id = :esp.Related_ICF_HCPTS__c];

            List<Id> contractIds = new List<Id>();
            contractIds.add(esp.Event_Speaker_Contract_HCPTS__c);
            contractIds.add(esp.Speaker_Contract_HCPTS__c);

            List<Contract_vod__c> agreements = [SELECT Id,Status_vod__c,Lock_vod__c FROM Contract_vod__c WHERE Id IN :contractIds];

            for(Contract_vod__c c: agreements){
                if(c.Status_vod__c != 'Activated' && c.Lock_vod__c != true){
                    c.Vendor_HCPTS__c = existingIFC.Vendor_HCPTS__c;
                    c.Service_Type_HCPTS__c = esp.Service_Type_HCPTS__c;
                    c.Service_Subtype_HCPTS__c = esp.Service_Subtype_HCPTS__c;
                }
        }

            update agreements;

            return new PageReference('/' + esp.Id);
        }*/
        Boolean icfAlreadyHandled = false;
        if(esp.Related_ICF_HCPTS__c!=null){
            String returnMessage = CustomVeevaUtilities.updateContractParties(esp);
            if(returnMessage == 'Success'){
                icfAlreadyHandled = true;
            //  return new PageReference('/' + esp.Id);
            }else{
                ApexPages.Message errorMessage = new ApexPages.Message(
                                                ApexPages.severity.INFO, 
                                                returnMessage);
                ApexPages.addmessage(errorMessage);
                return null;
            }
        }

        Id contractPartyFromICF = null;

        if(esp.Service_Type_HCPTS__c==null || esp.Service_Subtype_HCPTS__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(
                                                ApexPages.severity.ERROR, 
                                                System.Label.VPROF_Err_Msg_Populate_Contract_type_subtype);
            ApexPages.addmessage(myMsg);
            return null;
        }
        Savepoint sp = Database.setSavepoint();
        try{

//////
            Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Information_Collection_Form__c.getRecordTypeInfosByName();
            rtMapByName = VPROF_Javascript_Utilities.getMapByRecordTypeDevName(rtMapByName);//converts the keys to RT Devnames
            String icfRecTypefrmContracttype = '';
            String icfTypefrmContracttype = '';
            Boolean createNewICF = true;
            System.debug('esp.Service_Type_HCPTS__c = ' + esp.Service_Type_HCPTS__c);
            System.debug('esp.Speaker_vod__r.IsPersonAccount_HCPTS__c = ' + esp.Speaker_vod__r.IsPersonAccount_HCPTS__c);
            
//*** CHANGE REQUESTED BY SHAHEEN/KRISHNA - EVENTS AND SPONSORSHIP ICF TYPES SHOULD NOT BE USED AT ALL***JUNE 14, 2016  - SEE EMAIL TITLED "icf type questions"

            if(esp.Speaker_vod__r.IsPersonAccount_HCPTS__c){
                icfTypefrmContracttype = 'HCP/Non-HCP Services';
                icfRecTypefrmContracttype = ICF_REC_TYPE_DEV_NAME_HCP_SVCS;
            }
            else{
                icfTypefrmContracttype = 'HCO Services';                        
                icfRecTypefrmContracttype = ICF_REC_TYPE_DEV_NAME_HCO_SVCS;
            }
            
        /** 
        //*** CHANGE REQUESTED BY SHAHEEN/KRISHNA - EVENTS AND SPONSORSHIP ICF TYPES SHOULD NOT BE USED AT ALL***JUNE 14, 2016  - SEE EMAIL TITLED "icf type questions"
        
        if(esp.Service_Type_HCPTS__c == 'Services'){
                if(esp.Speaker_vod__r.IsPersonAccount_HCPTS__c){
                    icfTypefrmContracttype = 'HCP/Non-HCP Services';
                    icfRecTypefrmContracttype = 'ICF HCP Services';
                }
                else{
                    icfTypefrmContracttype = 'HCO Services';                        
                    icfRecTypefrmContracttype = 'ICF HCO Services';
                }
            }
            else if(esp.Service_Type_HCPTS__c == 'Sponsorship'){
                    icfTypefrmContracttype = 'Sponsorship'; 
                    icfRecTypefrmContracttype = 'ICF HCP Sponsorship';
            }
            else if(esp.Service_Type_HCPTS__c == 'Events'){
                    icfTypefrmContracttype = 'Events';  
                    icfRecTypefrmContracttype = 'ICF Events';
            }
            
            **/
           
            System.debug('icfRecTypefrmContracttype = ' + icfRecTypefrmContracttype);
            //Pull in a valid ICF for the Speaker and then regenerate if required based on COntract type on ESP
            List<Information_Collection_Form__c> eligibleICF = [Select Id, Name, RecordtypeId, RecordType.Name, ICF_Type_HCPTS__c,Vendor_HCPTS__c
                                                                from Information_Collection_Form__c 
                                                                where Speaker_HCPTS__c =: esp.Speaker_vod__c
                                                                and ( Expired_Formula_HCPTS__c = false or Expired_Formula_HCPTS__c = null)
                                                                and Status_HCPTS__c IN ('Signed', 'Signed Manually')
                                                                Order by LastModifiedDate desc
                                                                limit 1
                                                                ];
            System.debug('eligibleICF = ' + eligibleICF);                                                   
            if(eligibleICF!=null && eligibleICF.size() > 0 && !icfAlreadyHandled){
                contractPartyFromICF = eligibleICF[0].Vendor_HCPTS__c;
                createNewICF = false;
                System.debug('eligibleICF[0].ICF_Type_HCPTS__c =' + eligibleICF[0].ICF_Type_HCPTS__c );
                System.debug('icfTypefrmContracttype =' + icfTypefrmContracttype );
                if(eligibleICF[0].ICF_Type_HCPTS__c == icfTypefrmContracttype){
                    //no need to regenerate, simply attach this to current ESP and skip new ICF creation process
                    esp.Related_ICF_HCPTS__c = eligibleICF[0].id;
              //      update esp;
              		  updateESP = true;
                }
                else{
                    //need to regenerate icf from existing icf and then attach
                    String icfSOQL = CustomVeevaUtilities.getDynamicSOQLForAllEligibleFields(Information_Collection_Form__c.sObjectType);
                    icfSOQL+= ' where Id = \'' + eligibleICF[0].id + '\'';
                    Information_Collection_Form__c theICF = Database.query(icfSOQL);
                    Information_Collection_Form__c clonedICF = theICF.clone(false, false, false, false);
                    ID icfRecTypeId ; 
                    clonedICF.Status_HCPTS__c = 'Draft';
                    clonedICF.Signature_Date_HCPTS__c = null;
                    clonedICF.Contract_Address_same_as_Contact_HCPTS__c = null;
                    clonedICF.Speaker_is_Contract_Party_HCPTS__c = false;
                    clonedICF.Signature_HCPTS__c = null;
                    clonedICF.Speaker_HCPTS__c = esp.Speaker_vod__c;
                    clonedICF.RecordtypeId = rtMapByName.get(icfRecTypefrmContracttype).getRecordTypeId();
                    clonedICF.ICF_Type_HCPTS__c = icfTypefrmContracttype;
                    clonedICF.Activity_Source_2__c = esp.Id ;       
                    insert clonedICF;
                    esp.Related_ICF_HCPTS__c = clonedICF.id;
                    updateESP = true;
              //      update esp;         
                }
            }

/////////
            if(createNewICF && !icfAlreadyHandled){
            //  Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Information_Collection_Form__c.getRecordTypeInfosByName();
                ID icfRecTypeId = rtMapByName.get(ICF_REC_TYPE_DEV_NAME_SIMPLE_ICF).getRecordTypeId();//editable record type
                Information_Collection_Form__c icf =  new Information_Collection_Form__c(Speaker_HCPTS__c = esp.Speaker_vod__c
                                                                                        , RecordtypeId = icfRecTypeId, Activity_Source_2__c = esp.Id,
                                                                                        Name = 'Auto-gen');

//*** CHANGE REQUESTED BY SHAHEEN/KRISHNA - EVENTS AND SPONSORSHIP ICF TYPES SHOULD NOT BE USED AT ALL***JUNE 14, 2016  - SEE EMAIL TITLED "icf type questions"

                if(esp.Speaker_vod__r.IsPersonAccount_HCPTS__c){
                    icf.ICF_Type_HCPTS__c = 'HCP/Non-HCP Services';
                    icf.RecordtypeId = rtMapByName.get(ICF_REC_TYPE_DEV_NAME_HCP_SVCS).getRecordTypeId();
                }
                else{
                    icf.ICF_Type_HCPTS__c = 'HCO Services';                     
                    icf.RecordtypeId = rtMapByName.get(ICF_REC_TYPE_DEV_NAME_HCO_SVCS).getRecordTypeId();
                }

/*              
//*** CHANGE REQUESTED BY SHAHEEN/KRISHNA - EVENTS AND SPONSORSHIP ICF TYPES SHOULD NOT BE USED AT ALL***JUNE 14, 2016  - SEE EMAIL TITLED "icf type questions"

if(esp.Service_Type_HCPTS__c == 'Services'){
                    if(esp.Speaker_vod__r.IsPersonAccount_HCPTS__c){
                        icf.ICF_Type_HCPTS__c = 'HCP/Non-HCP Services';
                        icf.RecordtypeId = rtMapByName.get('ICF HCP Services').getRecordTypeId();
                    }
                    else{
                        icf.ICF_Type_HCPTS__c = 'HCO Services';                     
                        icf.RecordtypeId = rtMapByName.get('ICF HCO Services').getRecordTypeId();
                    }
                }
                else if(esp.Service_Type_HCPTS__c == 'Sponsorship'){
                        icf.ICF_Type_HCPTS__c = 'Sponsorship';  
                        icf.RecordtypeId = rtMapByName.get('ICF HCP Sponsorship').getRecordTypeId();
                }
                else if(esp.Service_Type_HCPTS__c == 'Events'){
                        icf.ICF_Type_HCPTS__c = 'Events';   
                        icf.RecordtypeId = rtMapByName.get('ICF Events').getRecordTypeId();
                }
                */
                insert icf;
                esp.Related_ICF_HCPTS__c = icf.id;
                    updateESP = true;
             //   update esp;
            }
            Map<String, RecordType> rtMapByDevName = new Map<String, Recordtype>();
            List<RecordType> contractRecTypeLst = [SELECT Name, Id, DeveloperName, SobjectType FROM RecordType
                                                        where Sobjecttype = 'Contract_vod__c' and IsActive = TRUE];
            for(RecordType r: contractRecTypeLst){
                rtMapByDevName.put(r.DeveloperName, r);
            }
            Contract_vod__c fwCntrct;
            Contract_vod__c aaCntrct;
            String contractRecTypeName = mapContractTypeToRecType.get(esp.Service_Type_HCPTS__c);                       
            


            if(esp.Speaker_Contract_HCPTS__c==null && esp.Service_Type_HCPTS__c == 'Services'){//applicable to Services Contract Type
                //check to see if an existing FWA/MSA already exists
                List<Contract_vod__c> existingFWA = [Select Id, Name from Contract_vod__c
                                                     where Speaker_HCPTS__c =:esp.Speaker_vod__c
                                                     and Status_vod__c = 'Activated_vod'
                                                     and Expired_vod__c = false
                                                     and RecordType.DeveloperName = 'Framework_Agreement'
                                                //   and  Service_Type_HCPTS__c = :esp.Service_Type_HCPTS__c
                                                //   and  Service_Subtype_HCPTS__c = :esp.Service_Subtype_HCPTS__c
                                                     order by LastModifiedDate desc
                                                     limit 1
                                            //       and Contract Party??
                                                     ];
                if(existingFWA!=null && existingFWA.size() > 0){
                    esp.Speaker_Contract_HCPTS__c = existingFWA[0].Id;
                    updateESP = true;
              //      update esp;
                }
                //create FWA
                else{
                    fwCntrct = new Contract_vod__c(Start_Date_vod__c = System.today(), 
                                            End_Date_vod__c = System.today().addYears(2),
                                            Speaker_HCPTS__c = esp.Speaker_vod__c,
                                    //      Name = 'FrameworkAgreement-'+ esp.Name,
                                            Service_Type_HCPTS__c = esp.Service_Type_HCPTS__c,
                                            Status_vod__c = 'Draft_vod',
                                            RecordTypeId = rtMapByDevName.get('Framework_Agreement').Id,
                                            Vendor_HCPTS__c = contractPartyFromICF);
                    insert fwCntrct;
                    //check if there is a template
                    List<Contract_vod__c> cntrctTemplate = [Select Id, Name, Is_Template_HCPTS__c, Non_standard_Contract_Template_HCPTS__c,
                                                            (SELECT Hours_HCPTS__c,Service_Name_vod__c,EM_Rate_Type_vod__c,EM_Rate_vod__c,
                                                                Fee_Reimburseable_Topic_HCPTS__c,Comments_HCPTS__c,Contract_vod__c,Service_vod__c,Id,RecordTypeId 
                                                                FROM Contract_Lines_vod__r) 
                                                            from Contract_vod__c
                                                            where Is_Template_HCPTS__c = true
                                                            and Country_HCPTS__c =: esp.Speaker_vod__r.Country_Lookup_HCPTS__c
                                                            and RecordType.DeveloperName = 'Framework_Agreement'
                                                            ORDER BY LASTMODIFIEDDATE DESC 
                                                            LIMIT 1
                                                            ];
                    if(cntrctTemplate.size() > 0){
                        Contract_vod__c c = cntrctTemplate[0];
                        fwCntrct.Non_standard_Contract_Template_HCPTS__c = c.Non_standard_Contract_Template_HCPTS__c;
                        update fwCntrct;
                        
                        List<Contract_Line_vod__c> contractLines = new List<Contract_Line_vod__c>();
                        contractLines = c.Contract_Lines_vod__r.deepClone(false, false, false);
                        for(Contract_Line_vod__c d: contractLines){
                            d.Contract_vod__c = fwCntrct.Id;
                            if(d.EM_Rate_Type_vod__c == 'Hour_vod' 
                                && esp.Speaker_vod__r.Hourly_Rate_HCPTS__c!=null 
                                && esp.Speaker_vod__r.Hourly_Rate_HCPTS__c!=0){
                                d.EM_Rate_vod__c = esp.Speaker_vod__r.Hourly_Rate_HCPTS__c;//if a Speaker rate is specified in Speaker profile, use that rate on the Contract lines instead of template rate
                            }
                        }
                        if(contractLines.size () > 0){
                            insert contractLines;
                        }
                    }
                    insert new Contract_Partner_vod__c(EM_Speaker_vod__c = esp.Speaker_vod__c, Contract_vod__c = fwCntrct.Id, Status_vod__c = 'Draft_vod');
                    esp.Speaker_Contract_HCPTS__c = fwCntrct.Id;
                    updateESP = true;
                //    update esp;
                }
            }
            
            if(esp.Event_Speaker_Contract_HCPTS__c == null){//applicable to all Contract Type
                //create AA
                     System.debug('contractPartyFromICF: ' + contractPartyFromICF);
                     aaCntrct = new Contract_vod__c(Start_Date_vod__c = System.today(), 
                                                End_Date_vod__c = System.today().addMonths(6),
                                                Speaker_HCPTS__c = esp.Speaker_vod__c,
                                    //          Name = 'ActivityAgreement-'+ esp.Name,
                                                Status_vod__c = 'Draft_vod',
                                                RecordTypeId = rtMapByDevName.get(contractRecTypeName).Id,
                                                Related_Framework_Agreement_HCPTS__c = esp.Speaker_Contract_HCPTS__c,//this should be null in all cases except Services
                                                Service_Type_HCPTS__c = esp.Service_Type_HCPTS__c,
                                                Service_Subtype_HCPTS__c = esp.Service_Subtype_HCPTS__c,
                                                Vendor_HCPTS__c = contractPartyFromICF
                                                );
                    insert aaCntrct;
                    //check if there is a template
                    List<Contract_vod__c> cntrctTemplate = [Select Id, Name, Tax_Treatment_HCPTS__c, Is_Template_HCPTS__c, Non_standard_Contract_Template_HCPTS__c,
                                                             Service_Type_HCPTS__c, Service_Subtype_HCPTS__c, Additional_Terms_HCPTS__c, Currency_HCPTS__c,
                                                             Location_Date_Content_HCPTS__c, Maximum_Events_HCPTS__c, No_Fees_are_to_be_Paid_HCPTS__c,
                                                            (SELECT Name,Service_Name_HCPTS__c,Contract_HCPTS__c,Contract_Subtype_Formula_HCPTS__c,Contract_Type_Formula_HCPTS__c,
                                                                Service_HCPTS__c 
                                                                FROM Contract_Descriptions_HCPTS__r), 
                                                            (SELECT Hours_HCPTS__c,Service_Name_vod__c,EM_Rate_Type_vod__c,EM_Rate_vod__c,
                                                                Fee_Reimburseable_Topic_HCPTS__c,Comments_HCPTS__c,Contract_vod__c,Service_vod__c,Id,RecordTypeId 
                                                                FROM Contract_Lines_vod__r) 
                                                            from Contract_vod__c
                                                            where Is_Template_HCPTS__c = true
                                                            and Service_Type_HCPTS__c =: aaCntrct.Service_Type_HCPTS__c
                                                            and Service_Subtype_HCPTS__c = :aaCntrct.Service_Subtype_HCPTS__c
                                                            and Country_HCPTS__c =: esp.Speaker_vod__r.Country_Lookup_HCPTS__c
                                                            and RecordType.DeveloperName != 'Framework_Agreement'
                                                            ORDER BY LASTMODIFIEDDATE DESC 
                                                           LIMIT 1
                                                            ];
                    if(cntrctTemplate.size() > 0){
                        Contract_vod__c c = cntrctTemplate[0];
                        aaCntrct.Tax_Treatment_HCPTS__c = c.Tax_Treatment_HCPTS__c;
                        aaCntrct.Additional_Terms_HCPTS__c = c.Additional_Terms_HCPTS__c;
                        aaCntrct.Location_Date_Content_HCPTS__c = c.Location_Date_Content_HCPTS__c;
                        aaCntrct.Maximum_Events_HCPTS__c = c.Maximum_Events_HCPTS__c;
                        aaCntrct.No_Fees_are_to_be_Paid_HCPTS__c = c.No_Fees_are_to_be_Paid_HCPTS__c;
                        aaCntrct.Currency_HCPTS__c = c.Currency_HCPTS__c;
                        aaCntrct.Non_standard_Contract_Template_HCPTS__c = c.Non_standard_Contract_Template_HCPTS__c;
                        update aaCntrct;
                        
                        List<Contract_Description_HCPTS__c> descriptions = new List<Contract_Description_HCPTS__c>();
                        List<Contract_Line_vod__c> contractLines = new List<Contract_Line_vod__c>();
                        descriptions = c.Contract_Descriptions_HCPTS__r.deepClone(false, false, false);
                        contractLines = c.Contract_Lines_vod__r.deepClone(false, false, false);
                        for(Contract_Description_HCPTS__c d: descriptions){
                            d.Contract_HCPTS__c = aaCntrct.Id;
                        }
                        for(Contract_Line_vod__c d: contractLines){
                            d.Contract_vod__c = aaCntrct.Id;
                            if(d.EM_Rate_Type_vod__c == 'Hour_vod' 
                                && esp.Speaker_vod__r.Hourly_Rate_HCPTS__c!=null 
                                && esp.Speaker_vod__r.Hourly_Rate_HCPTS__c!=0){
                                d.EM_Rate_vod__c = esp.Speaker_vod__r.Hourly_Rate_HCPTS__c;//if a Speaker rate is specified in Speaker profile, use that rate on the Contract lines instead of template rate
                            }
                        }
                        if(descriptions.size () > 0){
                            insert descriptions;
                        }
                        if(contractLines.size () > 0){
                            insert contractLines;
                        }
                    }
                                                            
                    insert new Contract_Partner_vod__c(EM_Speaker_vod__c = esp.Speaker_vod__c, Contract_vod__c = aaCntrct.Id, Status_vod__c = 'Draft_vod');
                    esp.Event_Speaker_Contract_HCPTS__c = aaCntrct.Id;
                    
                    updateESP = true;
                //    update esp;
            }  
            if(updateESP){
                update esp;
            }
            
        }catch(DMLException e){
            System.debug('DML Exception while creating Contracts/ICF' + e);
            ApexPages.Message myMsg = new ApexPages.Message(
                                                ApexPages.severity.ERROR, 
                                                System.Label.VPROF_Err_Msg_Contract_ICF_Create_Error + e.getMessage());
            ApexPages.addmessage(myMsg);
            Database.rollback(sp);
            return null;
        }
        
        return new PageReference('/' + esp.Id);
    }

}