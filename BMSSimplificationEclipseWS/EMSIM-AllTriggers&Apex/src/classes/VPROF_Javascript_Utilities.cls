global class VPROF_Javascript_Utilities {
    
    webservice static string getEchosignAgreementIdForICF(String ICFId){

        Information_Collection_Form__c icf = [SELECT Id,Country_Formula_HCPTS__c,Preferred_Language_HCPTS__c,ICF_Type_HCPTS__c
            FROM Information_Collection_Form__c WHERE Id = :ICFId];

        List<echosign_dev1__Agreement_Template__c> agreeTemplate = [SELECT Id 
                    FROM echosign_dev1__Agreement_Template__c
                    WHERE ICF_Type_HCPTS__c = :icf.ICF_Type_HCPTS__c
                    AND Language_HCPTS__c =:icf.Preferred_Language_HCPTS__c
                    AND Country_HCPTS__r.Alpha_2_Code_vod__c =:icf.Country_Formula_HCPTS__c
                    ORDER BY LastModifiedDate DESC LIMIT 1];

        if(agreeTemplate == null || agreeTemplate.size() != 1){
            return 'Error';
        }else{
            return agreeTemplate[0].Id;
        }
        
    }

    webservice static string renewMSA(String espId) {
        
        String errorMessage = '';

        try{

            EM_Event_Speaker_vod__c esp = [SELECT Id,Speaker_vod__c,Speaker_Contract_HCPTS__c,Service_Type_HCPTS__c
                    FROM EM_Event_Speaker_vod__c WHERE Id = :espId];

            List<Information_Collection_Form__c> eligibleICF =
                    [Select Id, Name, RecordtypeId, RecordType.Name, ICF_Type_HCPTS__c,Vendor_HCPTS__c
                    FROM Information_Collection_Form__c 
                    WHERE Speaker_HCPTS__c =: esp.Speaker_vod__c
                    AND ( Expired_Formula_HCPTS__c = false or Expired_Formula_HCPTS__c = null)
                    AND Status_HCPTS__c IN ('Signed', 'Signed Manually')
                    ORDER BY LastModifiedDate desc
                    LIMIT 1];

            Id contractPartyFromICF = null;

            if(eligibleICF!=null && eligibleICF.size() > 0){
                contractPartyFromICF = eligibleICF[0].Vendor_HCPTS__c;
            }

            Map<String, RecordType> rtMapByDevName = new Map<String, Recordtype>();
            List<RecordType> contractRecTypeLst = [SELECT Name, Id, DeveloperName, SobjectType FROM RecordType
                                                    WHERE Sobjecttype = 'Contract_vod__c' and IsActive = TRUE];
            for(RecordType r: contractRecTypeLst){
                rtMapByDevName.put(r.DeveloperName, r);
            }

            if(esp.Service_Type_HCPTS__c == 'Services'){//applicable to Services Contract Type
                    Contract_vod__c fwCntrct = new Contract_vod__c(Start_Date_vod__c = System.today(), 
                                        End_Date_vod__c = System.today().addYears(2),
                                        Speaker_HCPTS__c = esp.Speaker_vod__c,
                                        //      Name = 'FrameworkAgreement-'+ esp.Name,
                                        Service_Type_HCPTS__c = esp.Service_Type_HCPTS__c,
                                        Status_vod__c = 'Draft_vod',
                                        RecordTypeId = rtMapByDevName.get('Framework_Agreement').Id,
                                        Vendor_HCPTS__c = contractPartyFromICF);
                    insert fwCntrct;
                    insert new Contract_Partner_vod__c(EM_Speaker_vod__c = esp.Speaker_vod__c, Contract_vod__c = fwCntrct.Id, Status_vod__c = 'Draft_vod');
                    esp.Speaker_Contract_HCPTS__c = fwCntrct.Id;
                    update esp;
                
            }else{
                return Label.Framework_renewal_only_Services;
            }
            errorMessage = Label.Framework_Update_Success;
        }Catch(Exception e){
            return Label.Error_updating_MSA + ' ' + e.getMessage();
        }

        return errorMessage;
    }
    
    /**
* Utilitiy function to convert a RecType Map with Names as Keys to DeveloperName as keys
*/
    public static Map<String, RecordTypeInfo> getMapByRecordTypeDevName(
                                                Map<String, RecordTypeInfo> rtMapByName){

        if(rtMapByName==null || rtMapByName.size() == 0){
            return rtMapByName;
        }
        Set<Id> rtIds = new Set<Id>();
        for(RecordTypeInfo rtInfo: rtMapByName.values()){
            rtIds.add(rtInfo.getRecordTypeId());
        }

        Map<Id, RecordType> recTypeMap = new Map<Id, RecordType> ([Select Id, DeveloperName from RecordType 
                                                                    where Id in: rtIds]);

        Map<String, RecordTypeInfo> rtMapByDevName = new Map<String, RecordTypeInfo> ();
        System.debug('rtMapByName = ' + rtMapByName);
        System.debug('recTypeMap = ' + recTypeMap);

        for(RecordTypeInfo rtInfo: rtMapByName.values()){
            System.debug('rtInfo = ' + rtInfo);
            if(rtInfo.getRecordTypeId()!=null && recTypeMap.get(rtInfo.getRecordTypeId())!=null){
                rtMapByDevName.put(recTypeMap.get(rtInfo.getRecordTypeId()).DeveloperName,
                                                    rtInfo);
            }
        }

        return rtMapByDevName;

    }   
    

}