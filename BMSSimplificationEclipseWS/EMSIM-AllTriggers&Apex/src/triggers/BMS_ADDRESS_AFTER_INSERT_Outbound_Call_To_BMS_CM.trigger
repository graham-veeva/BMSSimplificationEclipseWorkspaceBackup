/********************************************************************
** This BMS trigger invokes asynchronous call passing all the newly
** created Address record IDs to be used to make outbound call outs
** to BMS Customer Master service
**
** Turn this trigger off during data migrations.
*********************************************************************/

trigger BMS_ADDRESS_AFTER_INSERT_Outbound_Call_To_BMS_CM on Address_vod__c (after insert) {     
    Boolean foundCandidateRecords = false;
    Boolean okayToMoveForward     = false;
    
    
    // FOR TESTING ONLY - SINCE INFORMATICA PEOPLE ARE MASS LOADING ACCOUNTS
    // if its not this following logged in user in Veeva do not trigger rest of the logic.
    // if(!(UserInfo.getUserName() == 'vinod@bms.com.dev')){
    //  return;
    //}
    // get the Accout record type developer name for 'Individual'
    String individualRecordTypeDeveloperName = '';
    String individualRecordTypeConvertedDeveloperName = '';
    
    try{            
        List<BMS_CM_Integration_Constants__c> bmsIntegrationConstants = BMS_CM_Integration_Constants__c.getall().values();          
        BMS_CM_Integration_Constants__c myIntegrationConstants = bmsIntegrationConstants[0];
        individualRecordTypeDeveloperName = myIntegrationConstants.AccountRecordTypeDeveloperName__c;
        individualRecordTypeConvertedDeveloperName = myIntegrationConstants.AccountRecordTypeConvertedDeveloperName__c;
        
        if(individualRecordTypeDeveloperName == '' || individualRecordTypeDeveloperName == null ||
           individualRecordTypeConvertedDeveloperName == '' || individualRecordTypeConvertedDeveloperName == null){
            okayToMoveForward = false;
            System.debug('Account Record Type Developer Name not setup in custom settings - BMS_CM_Integration_Constants__c');
        }else{
            okayToMoveForward = true;
        }             
    }catch (Exception ee){
        okayToMoveForward = false;
    }
    
    // no need to continue if we did not find our target record type name defined in the custom settings
    if(!okayToMoveForward){
        System.debug('*********************** BMS INTEGRATION TRIGGER ERROR - Individual recordtype developername not defined in the custom settings - BMS_CM_Integration_Constants__c - settings not initialized potentially.');
        return;
    }    
    
    ID INDIVIDUAL_ACCOUNT_RECORDTYPE_ID;
    
    List<RecordType> iaRecordTypesList = new List<RecordType>();
    
    try {
        // Individual type Accounts are our candidate type records
        iaRecordTypesList = [SELECT Id, SobjectType, Name, IsPersonType, IsActive, DeveloperName FROM RecordType WHERE isPersonType=true AND isActive=true AND SobjectType='Account' AND (DeveloperName =:individualRecordTypeDeveloperName or DeveloperName =:individualRecordTypeConvertedDeveloperName) ];
        
        if(iaRecordTypesList == null || iaRecordTypesList.size() <=0){          
            okayToMoveForward = false;
            System.debug('*********************** BMS INTEGRATION TRIGGER ERROR - Individual recordtype developername not defined in this Org., potentially.');
            return;
        }       
    } catch(Exception rtLE){
            okayToMoveForward = false;
            System.debug('*********************** BMS INTEGRATION TRIGGER ERROR - Individual recordtype developername not defined in this Org., potentially.');
            return;     
    }

    
    //collect account ids 
    List<Id> accountIds             = new List<ID>();
    for(Address_vod__c tmpAvc : trigger.new){
        accountIds.add(tmpAvc.account_vod__c);
    }
    
    Map<Id, Account> candidateAccountsMap = new Map<Id, Account>([SELECT id, recordtypeid FROM Account WHERE recordtypeid in :iaRecordTypesList AND Integration_Status_BMS__c = false AND id IN :accountIds ]); 
    List<Account> candidateAccounts = candidateAccountsMap.values();
    if(candidateAccounts != null && candidateAccounts.size() > 0){
        foundCandidateRecords = true;
    } else {
        // no need to continue, as the related Accounts are not concerned w/BMS CM integration
        System.debug('******************* BMS INTEGRATION - No matching Individual accounts found for push to BMS CM - returning');
        return;
    }
    
    // now invoke the async. callout to update the records with bp_id'S fetched from web service ONLY if we found concerned accounts
    if(foundCandidateRecords){   
        System.debug(foundCandidateRecords);        
        CustomerMasterWrapper_BMS.callWebServiceAsync(Trigger.newMap.keySet());
    }
}