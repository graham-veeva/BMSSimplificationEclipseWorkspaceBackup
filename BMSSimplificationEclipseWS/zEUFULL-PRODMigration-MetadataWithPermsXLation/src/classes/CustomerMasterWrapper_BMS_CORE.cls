/** Veeva BMS Customer Master web services API wrapper class.  A utility 
 ** class to make call outs to BMS CM service to add/update Account/Address
 ** being created by BMS users in Veeva.
 **
 ** This interface is to be used with Veeva Customer/Address creation or
 ** Veeva Address creation screens only.
 ***************************************************************************/

global class CustomerMasterWrapper_BMS_CORE {
    
    public static Map<String, String> transformationCommunicationTypeMap = new Map<String, String>();
    public static Map<String, String> transformationAddressTypeMap = new Map<String, String>();
        
    static{
        
        transformationCommunicationTypeMap.put('email', 'EMAIL');
        transformationCommunicationTypeMap.put('cell', 'CELL');
        transformationCommunicationTypeMap.put('fax', 'FAX');
        transformationCommunicationTypeMap.put('home', 'HOME');
        transformationCommunicationTypeMap.put('office', 'OFFICE');
        transformationCommunicationTypeMap.put('page', 'PAGE');
        transformationCommunicationTypeMap.put('url', 'URL');
        transformationCommunicationTypeMap.put('other', 'OTHER');
        
        transformationAddressTypeMap.put('bill', 'BILL');
        transformationAddressTypeMap.put('head', 'HEAD');
        transformationAddressTypeMap.put('home', 'HOME');
        transformationAddressTypeMap.put('mail', 'MAIL');
        transformationAddressTypeMap.put('office', 'OFF');
        transformationAddressTypeMap.put('shipping', 'SHIP');   
        
    }                                                                                      
         
    @future(callout=true)
    public static void callWebServiceAsync(Set<ID> addressIds){
        callWebService(addressIds);
    }
           
    public static void callWebService(Set<ID> addressIds) {

        // read the BMS CM communication and address type reference custom setttings
        try{
            List<BMS_CM_Cmmunication_Type_References__c> myBmsCommTypeRefList = BMS_CM_Cmmunication_Type_References__c.getall().values();
            
            Map<String, String> myCommunicationTypeMap = new Map<String, String>();
            for(BMS_CM_Cmmunication_Type_References__c myBMSCT : myBmsCommTypeRefList){
                myCommunicationTypeMap.put(myBMSCT.name, myBMSCT.BMS_Communication_Type_Code__c);
                System.debug('********* communication type COMPARE: '+ myBMSCT.name + '::' + myCommunicationTypeMap.get(myBMSCT.name)  + '==' + transformationCommunicationTypeMap.get(myBMSCT.name) + 'EQUAL? ' + (myCommunicationTypeMap.get(myBMSCT.name) == transformationCommunicationTypeMap.get(myBMSCT.name)));
            }
            
            if(myCommunicationTypeMap.size() > 0){
                transformationCommunicationTypeMap = myCommunicationTypeMap;
            }
        }catch(Exception bmsCmATRE){
            // do not do anything as we can use the hard code values
        }

        try{
            List<BMS_CM_Address_Usage_Type_References__c> myBmsAddessUsageTypeRefList = BMS_CM_Address_Usage_Type_References__c.getall().values();
            
            Map<String, String> myAddressTypeMap = new Map<String, String>();
            for(BMS_CM_Address_Usage_Type_References__c myBMSAT : myBmsAddessUsageTypeRefList){
                myAddressTypeMap.put(myBMSAT.name, myBMSAT.BMS_Address_Usage_Type_Code__c);
                System.debug('********* ADDRESS type COMPARE: '+ myBMSAT.name + '::' + myAddressTypeMap.get(myBMSAT.name)  + '==' + transformationAddressTypeMap.get(myBMSAT.name) + 'EQUAL? ' + (myAddressTypeMap.get(myBMSAT.name) == transformationAddressTypeMap.get(myBMSAT.name)));
            }
            
            if(myAddressTypeMap.size() > 0){
                transformationAddressTypeMap = myAddressTypeMap;
            }
        }catch(Exception bmsCmCTRE){
            // do not do anything as we can use the hard code values
        }
        
        ID errorRecordTypeId = null;        
        try{
            List<RecordType> errorLogRecordTypesList = [Select Id, DeveloperName From RecordType where sobjecttype='Error_Log_BMS__c' and isActive=true ];
    
            for(RecordType errRt : errorLogRecordTypesList){
                if(errRt.developername == 'integration'){
                    errorRecordTypeId = errRt.id;
                    break;
                }                
            }
            
            // if the record type for integration not found, just grab the one available - this should not happen at all
            if(errorRecordTypeId == null){
                errorRecordTypeId = errorLogRecordTypesList[0].id;
            }
            
        }catch(Exception ee){
            // no need to do anything - this is a configuration type thing
            // and if it does not existing the following business logic will 
        }
        
        List<BMS_CM_Integration_Constants__c> bmsIntegrationConstants = BMS_CM_Integration_Constants__c.getall().values();          
        BMS_CM_Integration_Constants__c myIntegrationConstants = new BMS_CM_Integration_Constants__c();
        System.assert(bmsIntegrationConstants != null && bmsIntegrationConstants.size() > 0 );

        // by now we would have experienced a run time exception if the integration constants
        // custom settings were not found
        // just get the first one only
        myIntegrationConstants = bmsIntegrationConstants[0];                
        String convertedAccountRecordTypeName   = myIntegrationConstants.AccountRecordTypeConvertedDeveloperName__c;
        RecordType accountConvertedRecordTypeId = [Select Id, DeveloperName From RecordType where developername=:convertedAccountRecordTypeName  and sobjecttype='Account' and isPersonType=true and isActive=true limit 1];        
        Id convertedAccountRecordTypeId         = accountConvertedRecordTypeId.id;
        String convertedAccountType             = myIntegrationConstants.ConvertedAccountType__c;
            
        Map<Id, Address_vod__c> addresses = new Map<Id, Address_vod__c>([SELECT account_vod__c, External_Id_vod__c, Inactive_vod__c, Address_line_2_vod__c, Zip_vod__c, Address_Status_BMS_CORE__c, State_vod__c, country_vod__c, Name, Id, City_vod__c,Mailing_vod__c, Office_BMS__c, Shipping_vod__c, Phone_vod__c, Phone_2_vod__c, Fax_vod__c, Fax_2_vod__c  FROM Address_vod__c WHERE id IN :addressIds]);
        
        Map<String, Address_vod__c> addressesWithUppserCaseKeys = new Map<String, Address_vod__c>();
        
        Map<Id, Id> accountIdsMap = new Map<Id, Id>();
        Map<Id, Id> addressToAccountIdMaps = new Map<Id,Id>();
        
        for(Address_vod__c tAdd : addresses.values()){
            String tAid = tAdd.Id;
            tAid        = tAid.toUpperCase();
            addressesWithUppserCaseKeys.put(tAid, tAdd);
            
            accountIdsMap.put(tAdd.account_vod__c, tAdd.account_vod__c);
            addressToAccountIdMaps.put(tAdd.Id, tAdd.account_vod__c);
        }
        
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT id, BP_ID_BMS_CORE__c, phone, personMobilePhone, personEmail, fax, firstname, lastname, Middle_vod__c, salutation, suffix_vod__c, personbirthdate, gender_vod__c, persontitle, credentials_vod__c FROM Account WHERE id IN: accountIdsMap.keySet()]);  
                     
        List<Account> accountsToBeUpdated = new List<Account>();
        List<Address_vod__c> addressesToBeUpdated = new List<Address_vod__c>();

        for(Account myAcc : accounts.values()){
            wwwBmsComMasterdataCustomerEnterpri.ProfessionalInfo bpProfessional = new wwwBmsComMasterdataCustomerEnterpri.ProfessionalInfo();
            
            // this is not a required field in Veeva, so nullcheck it and send no-text
            if(myAcc.firstName != null){
                bpProfessional.firstname    = myAcc.firstName+'';
            } else {
                bpProfessional.firstname    = '';
            }
            
            // this is a required field in Veeva
            bpProfessional.lastname     = myAcc.lastName+'';
            
            if(myAcc.BP_ID_BMS_CORE__c != null && myAcc.BP_ID_BMS_CORE__c != ''){
                bpProfessional.identifier   = myAcc.BP_ID_BMS_CORE__c+'';    
            }
            
            // this is always avaialble
            bpProfessional.sourceIdentifier = myAcc.id+'';
            
            // this is optional in Veeva
            if(myAcc.Middle_vod__c != null){
                bpProfessional.middlename   = myAcc.Middle_vod__c+'';
            } else {
                bpProfessional.middlename   = '';
            }
            
            if(myAcc.salutation != null){
                bpProfessional.salutation   = myAcc.salutation+'';
            } else {
                bpProfessional.salutation = '';
            }
            
            if(myAcc.suffix_vod__c != null){
                bpProfessional.suffix       = myAcc.suffix_vod__c+'';
            } else {
                bpProfessional.suffix       = '';
            }
            
            if(myAcc.personbirthdate != null){
                bpProfessional.birthdate    = myAcc.personbirthdate;
            }
            
            if(myAcc.gender_vod__c != null){
                bpProfessional.gendercode   = myAcc.gender_vod__c;
            }
            
            if(myAcc.persontitle != null){
                bpProfessional.title        = myAcc.persontitle;
            }
            
            // CREDENTIALS IS REQUIRED 
            if(myAcc.credentials_vod__c != null){
                // grab the first few characters before '-' and uppser case it
                String profDesig = myAcc.credentials_vod__c;            
                if(profDesig.contains('-')){
                    String[] tokens = profDesig.split('-');
                    profDesig = tokens[0];
                    profDesig = profDesig.toUpperCase();                    
                }else{
                    profDesig = profDesig.toUpperCase();
                }
                
                bpProfessional.ProfessionlDesignationCode = profDesig;
            } else {
                bpProfessional.ProfessionlDesignationCode = 'OTHE';
            }           
            
            System.debug('****** PROFESSIONAL DESIGNATION BEING SENT= '+ bpProfessional.ProfessionlDesignationCode);
            // we always send NPRS
            bpProfessional.ClassificationCode = convertedAccountType;           
            bpProfessional.ActiveIndicator = 'Y';
            
            System.debug('************** BP PROF BEING SENT='+bpProfessional);
            // now find all addresses for the above account and add that list to it
            wwwBmsComMasterdataCustomerEnterpri.CommunicationTypeInfo commTypeInfo  = null;
            
            // setup communication attributes available for this account
            List<wwwBmsComMasterdataCustomerEnterpri.CommunicationTypeInfo> commInfoList = new List<wwwBmsComMasterdataCustomerEnterpri.CommunicationTypeInfo>();
                        
            if(myAcc.Phone != null){
                commTypeInfo = new wwwBmsComMasterdataCustomerEnterpri.CommunicationTypeInfo();
                commTypeInfo.TypeCode   = transformationCommunicationTypeMap.get('office');
                commTypeInfo.ValueText  = myAcc.Phone;
                commInfoList.add(commTypeInfo);
            }
            
            if(myAcc.PersonMobilePhone != null){
                commTypeInfo = new wwwBmsComMasterdataCustomerEnterpri.CommunicationTypeInfo();
                commTypeInfo.TypeCode = transformationCommunicationTypeMap.get('cell');
                commTypeInfo.ValueText= myAcc.PersonMobilePhone;            
                commInfoList.add(commTypeInfo);
            }           
            
            if(myAcc.PersonEmail != null){
                commTypeInfo = new wwwBmsComMasterdataCustomerEnterpri.CommunicationTypeInfo();
                commTypeInfo.TypeCode = transformationCommunicationTypeMap.get('email');
                commTypeInfo.ValueText= myAcc.PersonEmail;
                commInfoList.add(commTypeInfo);
            }

            if(myAcc.Fax != null){
                commTypeInfo = new wwwBmsComMasterdataCustomerEnterpri.CommunicationTypeInfo();
                commTypeInfo.TypeCode = transformationCommunicationTypeMap.get('fax');
                commTypeInfo.ValueText= myAcc.Fax;
                commInfoList.add(commTypeInfo);
            }
            
            if(commInfoList != null && commInfoList.size() > 0){
                wwwBmsComMasterdataCustomerEnterpri.CommunicationTypeInfoList commTypeInfoList = new wwwBmsComMasterdataCustomerEnterpri.CommunicationTypeInfoList();
                commTypeInfoList.CommunicationTypeInfo = commInfoList;
                bpProfessional.CommunicationTypeInfoList = commTypeInfoList;
            }
                        
            List<wwwBmsComMasterdataCustomerEnterpri.AddressInfo> myAddressList = new List<wwwBmsComMasterdataCustomerEnterpri.AddressInfo>();
             
            for(Address_vod__c myAddress : addresses.values()){
                if(myAddress.account_vod__c == myAcc.id){
                    wwwBmsComMasterdataCustomerEnterpri.AddressInfo bpAddress = new wwwBmsComMasterdataCustomerEnterpri.AddressInfo(); 
                    //bpAddress.Identifier = myAddress.External_ID_vod__c+'';
                    bpAddress.SourceIdentifier = myAddress.id+'';
                    System.debug('*************** SETTING ADDRESS SOURCEID TO REQUEST='+myAddress.id);
                    if(myAddress.Inactive_vod__c)
                        bpAddress.ActiveIndicator  = 'N';
                    else
                        bpAddress.ActiveIndicator  = 'Y';
                        
                    if(myAddress.name != null)
                        bpAddress.AddressLine1  = myAddress.name;
                    
                    if(myAddress.Address_line_2_vod__c != null)
                        bpAddress.AddressLine2  = myAddress.Address_line_2_vod__c;
                        
                    if(myAddress.city_vod__c != null)
                        bpAddress.CityName      = myAddress.city_vod__c;
                    
                    if(myAddress.state_vod__c != null)
                        bpAddress.ProvinceCode  = myAddress.state_vod__c;
                        
                    if(myAddress.zip_vod__c != null)
                        bpAddress.PostalZoneCode= myAddress.zip_vod__c;
                        
                    // Country code is a must and needs to be 2 char code 
                    if(myAddress.country_vod__c != null){
                        bpAddress.CountryCode = myAddress.country_vod__c.toUpperCase();
                        if(bpAddress.CountryCode.equals('USA')){
                            bpAddress.CountryCode = 'US';
                        }
                        System.debug('****************** COUNTRY OF ADDRESS='+myAddress.country_vod__c);   
                    }else{
                        bpAddress.CountryCode = 'US';
                    }
                        
                    wwwBmsComMasterdataCustomerEnterpri.AddressCommunicationTypeInfo addressCommTypeInfo  = null;
                    
                    // setup communication attributes available for this account
                    List<wwwBmsComMasterdataCustomerEnterpri.AddressCommunicationTypeInfo> addressCommTypeInfoList = new List<wwwBmsComMasterdataCustomerEnterpri.AddressCommunicationTypeInfo>();          
                    
                    String addressUsageType   = 'office';      
                    String addressCommTypeCode= 'other';    
                    
                    // check for shipping type first
                    List<wwwBmsComMasterdataCustomerEnterpri.AddressUsageTypeInfo> addressUsageTypeList = new List<wwwBmsComMasterdataCustomerEnterpri.AddressUsageTypeInfo>();
                    wwwBmsComMasterdataCustomerEnterpri.AddressUsageTypeInfo aUsageTypeInfo = null;
                    
                    if(myAddress.Shipping_vod__c){
                        addressUsageType = 'shipping';
                        addressCommTypeCode = 'other';
                        aUsageTypeInfo   = new wwwBmsComMasterdataCustomerEnterpri.AddressUsageTypeInfo();
                        aUsageTypeInfo.TypeCode = transformationAddressTypeMap.get(addressUsageType);
                        addressUsageTypeList.add(aUsageTypeInfo);                               
                    }
                    
                    if(myAddress.Mailing_vod__c){
                        addressUsageType = 'mail';
                        addressCommTypeCode = 'other';
                        aUsageTypeInfo   = new wwwBmsComMasterdataCustomerEnterpri.AddressUsageTypeInfo();
                        aUsageTypeInfo.TypeCode = transformationAddressTypeMap.get(addressUsageType);
                        addressUsageTypeList.add(aUsageTypeInfo);               
                    } 
                    
                    if(myAddress.Office_BMS__c){                
                        addressUsageType = 'office';
                        addressCommTypeCode = 'office';
                        aUsageTypeInfo   = new wwwBmsComMasterdataCustomerEnterpri.AddressUsageTypeInfo();
                        aUsageTypeInfo.TypeCode = transformationAddressTypeMap.get(addressUsageType);
                        addressUsageTypeList.add(aUsageTypeInfo);               
                    }   
                    
                    if(addressUsageTypeList.size() > 0 ){
                        wwwBmsComMasterdataCustomerEnterpri.AddressUsageTypeInfoList aUsageTypeList = new wwwBmsComMasterdataCustomerEnterpri.AddressUsageTypeInfoList();
                        aUsageTypeList.AddressUsageTypeInfo = addressUsageTypeList;                         
                        bpAddress.AddressUsageTypeInfoList = aUsageTypeList;
                    } else {
                        // default to 'office' type
                        addressUsageType = 'office';
                        addressCommTypeCode = 'office';
                        aUsageTypeInfo   = new wwwBmsComMasterdataCustomerEnterpri.AddressUsageTypeInfo();
                        aUsageTypeInfo.TypeCode = transformationAddressTypeMap.get(addressUsageType);
                        addressUsageTypeList.add(aUsageTypeInfo);   
                        
                        wwwBmsComMasterdataCustomerEnterpri.AddressUsageTypeInfoList aUsageTypeList = new wwwBmsComMasterdataCustomerEnterpri.AddressUsageTypeInfoList();
                        aUsageTypeList.AddressUsageTypeInfo = addressUsageTypeList;                         
                        bpAddress.AddressUsageTypeInfoList = aUsageTypeList;                                            
                    }
                    
                    // the above order is important
                    // in case there are multiple address usage types selected
                    // we use the last one mathing          
                    if(myAddress.Phone_vod__c != null){
                        addressCommTypeInfo = new wwwBmsComMasterdataCustomerEnterpri.AddressCommunicationTypeInfo();               
                        addressCommTypeInfo.TypeCode    = transformationCommunicationTypeMap.get(addressCommTypeCode);
                        addressCommTypeInfo.ValueText   = myAddress.Phone_vod__c;
                        addressCommTypeInfoList.add(addressCommTypeInfo);
                    }
                    
                    if(myAddress.Phone_2_vod__c != null){
                        addressCommTypeInfo = new wwwBmsComMasterdataCustomerEnterpri.AddressCommunicationTypeInfo();               
                        addressCommTypeInfo.TypeCode    = transformationCommunicationTypeMap.get(addressCommTypeCode);
                        addressCommTypeInfo.ValueText   = myAddress.Phone_2_vod__c;
                        addressCommTypeInfoList.add(addressCommTypeInfo);
                    }           
        
                    if(myAddress.Fax_vod__c != null){
                        addressCommTypeInfo = new wwwBmsComMasterdataCustomerEnterpri.AddressCommunicationTypeInfo();               
                        addressCommTypeInfo.TypeCode    = transformationCommunicationTypeMap.get('fax');
                        addressCommTypeInfo.ValueText   = myAddress.Fax_vod__c;
                        addressCommTypeInfoList.add(addressCommTypeInfo);
                    }           
                            
                    if(myAddress.Fax_2_vod__c != null){
                        addressCommTypeInfo = new wwwBmsComMasterdataCustomerEnterpri.AddressCommunicationTypeInfo();               
                        addressCommTypeInfo.TypeCode    = transformationCommunicationTypeMap.get('fax');
                        addressCommTypeInfo.ValueText   = myAddress.Fax_2_vod__c;
                        addressCommTypeInfoList.add(addressCommTypeInfo);
                    }  
                                            
                    if(addressCommTypeInfoList != null && addressCommTypeInfoList.size() > 0){
                        wwwBmsComMasterdataCustomerEnterpri.AddressCommunicationTypeInfoList aCommTypeInfoList = new wwwBmsComMasterdataCustomerEnterpri.AddressCommunicationTypeInfoList();
                        aCommTypeInfoList.AddressCommunicationTypeInfo = addressCommTypeInfoList;
                        bpAddress.AddressCommunicationTypeInfoList = aCommTypeInfoList;
                    }                   
                    myAddressList.add(bpAddress);           
                }   
            }
            
            System.debug('************ ADDRESS LIST SIZE='+myAddressList.size() );
            System.debug('******** address list='+myAddressList );
            
            wwwBmsComMasterdataCustomerEnterpri.AddressInfoList bpAddressList = new wwwBmsComMasterdataCustomerEnterpri.AddressInfoList();
            bpAddressList.AddressInfo = myAddressList;  
            
            bpProfessional.AddressInfoList = bpAddressList;
            wwwBmsComMasterdataCustomerEnterpri.BusinessPartyAddUpdateRequest bpauRequest = new wwwBmsComMasterdataCustomerEnterpri.BusinessPartyAddUpdateRequest();
            bpauRequest.ProfessionalInfo   = bpProfessional;
            
            //bpauRequest.OrganizationInfo = null;
            
            // now create a Request Header               
            // create the service instance to setup the request details.        
            wwwBmsComMasterdataCustomerEnterpri.BusinessPartyMaintenanceServicePort bpmService = new wwwBmsComMasterdataCustomerEnterpri.BusinessPartyMaintenanceServicePort();
            
            // create all headers including the special request headers
            wwwBmsComV2.BMSSoapRequestType bpHeader = new wwwBmsComV2.BMSSoapRequestType();
            bpHeader.AppId      = myIntegrationConstants.appid__c+'';
            bpHeader.ClientId   = myIntegrationConstants.clientid__c+'';
            bpHeader.RequestId  = UserInfo.getUserId()+'::'+System.currentTimeMillis()+'';
            bpHeader.UserId     = myIntegrationConstants.userid__c+''; 
            
            System.debug('************* BMS integration - app/client/request/userid::' + bpHeader.AppId + '/' + bpHeader.ClientId+'/'+bpHeader.RequestId+'/'+bpHeader.UserId);
            
            // set the request headers first
            bpmService.BMSRequestHeader = bpHeader;
            
            
            // now set system headers
            bpmService.endpoint_x       = myIntegrationConstants.EndPoint__c;
            bpmService.clientCertName_x = myIntegrationConstants.ClientCertificateName__c;
            //bpmService.clientCert_x       = myIntegrationConstants.Nonce__c;
            System.debug('**************** run time out settings = []'+ myIntegrationConstants.requesttimeout__c + ']');
            if(myIntegrationConstants.requesttimeout__c == null){
                myIntegrationConstants.requesttimeout__c = 20000;
            }
            bpmService.timeout_x = Integer.valueOf(myIntegrationConstants.requesttimeout__c);
            
            wwwBmsComMasterdataCustomerEnterpri.SoapSecurity sSecurity = new wwwBmsComMasterdataCustomerEnterpri.SoapSecurity();
            wwwBmsComMasterdataCustomerEnterpri.UsernameToken unToken  = new wwwBmsComMasterdataCustomerEnterpri.UsernameToken();
            unToken.Username = myIntegrationConstants.UserName__c;
            unToken.Password = '';
                        
            sSecurity.UsernameToken = unToken;
            bpmService.Security     = sSecurity;
                    
            // now invoke the web service       
                                 
            try {
                wwwBmsComMasterdataCustomerEnterpri.BusinessPartyAddUpdateResponse bpResponse = bpmService.addUpdate(bpauRequest);              
                wwwBmsComMasterdataCustomerEnterpri.BusinessPartyIdentifierAssociation bpProfessionalIdentifiers = bpResponse.BusinessPartyIdentifierAssociation;
                                
                
                // If the account being pushed has a BP_ID_BMS_CORE__c value, itmeans this account already exists in both SFDC and BMS
                // so this request might have been generated only to push the newly created related address record.
                // If not, we just created a new account in BMS, so we need to update its SFDC BP_ID value.
                
                System.debug('********************* PB ID GOT BACK FROM BMS='+ bpProfessionalIdentifiers.Identifier);
                if(myAcc.BP_ID_BMS_CORE__c == null){
                    //Account updtAccount = new Account(id=myAcc.id, BP_ID_BMS_CORE__c = bpProfessionalIdentifiers.Identifier, recordtypeid=convertedAccountRecordTypeId, Account_Type__c = convertedAccountType);
                    Account updtAccount = new Account(id=myAcc.id, BP_ID_BMS_CORE__c = bpProfessionalIdentifiers.Identifier, Account_Type__c = convertedAccountType);
                    accountsToBeUpdated.add(updtAccount);
                }
                
                // now see if any of the address records need to be updated with BPA_ID's.
                wwwBmsComMasterdataCustomerEnterpri.AddressIdentifierAssociationList addressResponseList = bpResponse.AddressIdentifierAssociationList;
                
                for(wwwBmsComMasterdataCustomerEnterpri.AddressIdentifierAssociation addressIdentifier : addressResponseList.AddressIdentifierAssociation){
                    // get address sfdcid and external id
                    String addressSFDCId     = addressIdentifier.SourceIdentifier;
                    String addressExternalID = addressIdentifier.Identifier;
                    String uCaseAddressSFDCID= addressSFDCId.toUpperCase();
                    Address_vod__c retAddress=addressesWithUppserCaseKeys.get(uCaseAddressSFDCID);
                    System.debug('******************** ADDRESS BPA ID GOT BACK FROM BMS= ['+ addressExternalID + '] :: source identifier='+ addressSFDCId);
                    addressesTobeUpdated.add(new Address_vod__c(id=retAddress.id, External_id_vod__c = addressExternalID));                 
                }
                
                if(accountsToBeUpdated.size() > 0){
                    update accountsToBeUpdated;
                }
                
                if(addressesToBeUpdated.size() > 0){
                    update addressesTobeUpdated;
                }                   
                
                             
            } catch (DMLException de) {
                System.debug('*************************** Failed update: ' + de.getMessage());
                // create error log records and upsert them
                List<Error_Log_BMS__c> errorLogsForUpsert = createErrorRecords(addressToAccountIdMaps, de.getMessage(), myIntegrationConstants.GenericError__c, errorRecordTypeId);
                upsert errorLogsForUpsert External_ID__c;               
            } catch (CalloutException ce){
                System.debug('#####' + ce);
                System.debug('*************************** Callout failed : ' + ce.getMessage());                                
                String errMsg = ce.getMessage();
                                                 
                List<Error_Log_BMS__c> errorLogsForUpsert = createErrorRecords(addressToAccountIdMaps, errMsg , myIntegrationConstants.GenericError__c, errorRecordTypeId);
                upsert errorLogsForUpsert External_ID__c;           
            }                                
        }
    
    }
    
    private static List<Error_Log_BMS__c> createErrorRecords (Map<Id, Id> addressToAccountMap, String eMsg, String gError,  ID errorRecordTypeId){
        
        Datetime myDateTime = Datetime.now();
        String strConvertedDate = myDateTime.format('dd/MM/yyyy hh:mm:ss a', 'GMT');
        
        List<Error_Log_BMS__c> eList = new List<Error_Log_BMS__c>();
        Map<ID, Error_Log_BMS__c> existingErrorLogs = new Map<Id, Error_log_bms__c>([select id, external_id__c, error_details__c from error_log_bms__c where external_id__c in:addressToAccountMap.keySet()]);
        Map<String, Error_Log_BMS__c> existingErrorLogsByExternalIdMap = new Map<String, Error_log_bms__c>();
        for(Error_Log_BMS__c elm : existingErrorLogs.values() ){
            existingErrorLogsByExternalIdMap.put(elm.external_id__c, elm);
        }
        
        System.debug('******************** size or existing errorlog SIZE='+ existingErrorLogs.size());
        for(Error_Log_BMS__c el : existingErrorLogs.values()){
            System.debug('******************** size or existing errorlog= [0] extid='+ el.external_id__c);
        }
                
        for( ID addressId  : addressToAccountMap.keySet()){
            Error_Log_BMS__c emBMS = new Error_Log_BMS__c();
            emBMS.External_ID__c = addressId;
            emBMS.related_account__c = addressToAccountMap.get(addressId);
            emBMS.related_address__c = addressId;
            System.debug('************** does error log already exist for this address ? ' + (existingErrorLogs != null && existingErrorLogsByExternalIdMap.containsKey(addressId)) + ' :: addressid='+ addressId);
            if(existingErrorLogs != null && existingErrorLogsByExternalIdMap.containsKey(addressId)){
                Error_Log_BMS__c oldErrorLog = existingErrorLogsByExternalIdMap.get(addressId);
                if(oldErrorLog.Error_details__c == null)
                    oldErrorLog.Error_details__c = '';
                
                emBMS.Error_details__c =  '---\n\r' + myDateTime + ' : ' +  eMsg + '\n\r ---\n\r' + oldErrorLOg.Error_details__c  ;                 
            } else {
                emBMS.Error_details__c = '---\n\r' + myDateTime + ' : ' + eMsg + '\n\r ---\n\r';
            }
            
            emBMS.Resolved__c   = false;                        
            emBMS.error__c      = gError; 
            emBMS.recordtypeId  =  errorRecordTypeId;  
            eList.add(emBMS);                           
        }
        
        return eList;
    }
    
}