public with sharing class VPROF_ICFStandardControllerExt {

    Information_Collection_Form__c theICF;
    Map<String, RecordType> mapICFTypeToRectype = new Map<String, RecordType>();
    public final String ICF_TYP_HCPNONHCPSVCS = 'HCP/Non-HCP Services';
    public final String ICF_TYP_HCOSVCS = 'HCO Services';
    public final String ICF_TYP_SPONSORSHIP = 'Sponsorship';
    public final String ICF_TYP_EVENTS = 'Events';
    public final String ICF_DRAFT_STATUS = 'Draft';

    public VPROF_ICFStandardControllerExt(ApexPages.StandardController controller){
        String icfSOQL = CustomVeevaUtilities.getDynamicSOQLForAllEligibleFields(Information_Collection_Form__c.SobjectType);
        ID icfId =   ((Information_Collection_Form__c)controller.getRecord()).Id;
        icfSOQL += ' where Id = \'' + icfId + '\'';
        theICF = (Information_Collection_Form__c) Database.query(icfSOQL);
        Map<Id, Recordtype> icfRecTypeMap
            = new Map<Id, Recordtype> ([Select Id, Name, Developername
                                      from Recordtype
                                      where sObjectType = 'Information_Collection_Form__c'
                                      and IsActive = true]);
        for(Recordtype r: icfRecTypeMap.values()){
            if(r.DeveloperName == 'ICF_Events'){
                mapICFTypeToRectype.put(ICF_TYP_EVENTS,r );
            }
            else if(r.DeveloperName == 'ICF_HCO_Services'){
                mapICFTypeToRectype.put(ICF_TYP_HCOSVCS,r );
            }
            else if(r.DeveloperName == 'ICF_HCP_Services'){
                mapICFTypeToRectype.put(ICF_TYP_HCPNONHCPSVCS,r );
            }
            else if(r.DeveloperName == 'ICF_HCP_Sponsorship'){
                mapICFTypeToRectype.put(ICF_TYP_SPONSORSHIP,r );
            }
        }
    }
    
    public PageReference unlockICF(){
        Recordtype unlockedICFRectype = mapICFTypeToRectype.get(theICF.ICF_Type_HCPTS__c);
        theICF.RecordTypeId = unlockedICFRectype.Id;
        theICF.Status_HCPTS__c = ICF_DRAFT_STATUS;
        try{
			update theICF;            
        }catch(Exception e){
            System.debug('Exception unlocking ICF' + e);
            
            ApexPages.Message myMsg = new ApexPages.Message(
                                                ApexPages.severity.ERROR, 
                                                '<br>' + e.getMessage());
            ApexPages.addmessage(myMsg);
            return null;
         }

        return new PageReference('/' + theICF.Id);
    }
    
    public PageReference createContractPartyFromICF(){
        Savepoint sp = null;
        
        // Code added 4-25-16 by Kevin Neary
        // Make sure that the current use is able to create Contract Party and PII Data record, and that the current user has view
        // encrypted data permission on either their Profile or a permission set. Else throw an error and do not let the user proceed
        
        // get current user Id
        Id currentUserId = UserInfo.getUserId();
        // get the current user record
        User myUser = [SELECT Id,ProfileId,Profile.PermissionsViewEncryptedData FROM User WHERE Id = :currentUserId];
        if(myUser.Profile.PermissionsViewEncryptedData == false){
            // profile does not allow for view encrypted data, check permission sets
            List<PermissionSetAssignment> permSetAssignments = [SELECT Id,PermissionSetId,PermissionSet.PermissionsViewEncryptedData
                                                                FROM PermissionSetAssignment WHERE AssigneeId = :currentUserId];
            boolean canViewEncryptedData = false;
            for(PermissionSetAssignment permSetAssignment: permSetAssignments){
                if(permSetAssignment.PermissionSet.PermissionsViewEncryptedData == true){
                    canViewEncryptedData = true;
                    break;
                }
            }
            if(canViewEncryptedData == false){
                ApexPages.Message myMsg = new ApexPages.Message(
                                                    ApexPages.severity.WARNING, 
                                                    System.Label.Process_Contract_Party_Permission_Error_1);
                ApexPages.addmessage(myMsg);
                return null;
            }
        }
        
        // make sure the user can create/update contract party and PII Data records
        Schema.DescribeSObjectResult contractPartyDec = EM_Vendor_vod__c.sObjectType.getDescribe();
        if(contractPartyDec.isCreateable() == false || contractPartyDec.isUpdateable() == false){
            // the user cannot update or create contract party records, throw error
            ApexPages.Message myMsg = new ApexPages.Message(
                                                    ApexPages.severity.WARNING, 
                                                    System.Label.Process_Contract_Party_Permission_Error_2);
            ApexPages.addmessage(myMsg);
            return null;
        }
        
        Schema.DescribeSObjectResult PIIDec = PII_Data_HCPTS__c.sObjectType.getDescribe();
        if(PIIDec.isCreateable() == false || PIIDec.isUpdateable() == false){
            // the user cannot update or create contract party records, throw error
            ApexPages.Message myMsg = new ApexPages.Message(
                                                    ApexPages.severity.WARNING, 
                                                    System.Label.Process_Contract_Party_Permission_Error_3);
            ApexPages.addmessage(myMsg);
            return null;
        }
        
        try{
            Map<String, Schema.SObjectField> icfFieldsMap =  Information_Collection_Form__c.SobjectType.getDescribe().fields.getMap();
            Map<String, Schema.SObjectField> vendorFieldsMap =  EM_Vendor_vod__c.SobjectType.getDescribe().fields.getMap();
            Map<String, Schema.SObjectField> piiDataFieldsMap =  PII_Data_HCPTS__c.SobjectType.getDescribe().fields.getMap();
            EM_Vendor_vod__c theContractParty = new EM_Vendor_vod__c ();
            PII_Data_HCPTS__c piiData = new PII_Data_HCPTS__c ();
            Set<String> icfPIIFieldSet = new Set<String>();
            Boolean atleastOneFieldSet = false;

            for(String icfFldAPIName: icfFieldsMap.keySet() ){
                Schema.SObjectField theICFField = icfFieldsMap.get(icfFldAPIName);
                if(theICFField!=null && theICFField.getDescribe().isEncrypted() 
                                     && piiDataFieldsMap.get(icfFldAPIName)!=null){//there is a PII encrypted field matching ICF field
                    Schema.SObjectField piiField = piiDataFieldsMap.get(icfFldAPIName);
                    if(piiField.getDescribe().isCustom() && piiField.getDescribe().isUpdateable()){
                        piiData.put(icfFldAPIName, theICF.get(icfFldAPIName));
                        icfPIIFieldSet.add(icfFldAPIName);
                        atleastOneFieldSet = true;                      
                    }
                }
                if(!icfPIIFieldSet.contains(icfFldAPIName) 
                      && vendorFieldsMap.get(icfFldAPIName)!=null){//there is a Vendor field matching ICF field
                    Schema.SObjectField vendorField = vendorFieldsMap.get(icfFldAPIName);
                    if(vendorField.getDescribe().isCustom() && vendorField.getDescribe().isUpdateable()){
                        theContractParty.put(icfFldAPIName, theICF.get(icfFldAPIName));
                        atleastOneFieldSet = true;                      
                    }
                }
            }
            sp = Database.setSavepoint();
            if(atleastOneFieldSet){
                //relate this back to the ICF
                if(theICF.Vendor_HCPTS__c!=null){
                    theContractParty.Id = theICF.Vendor_HCPTS__c;
                }
                theContractParty.Name = theICF.Contract_Party_Text_HCPTS__c;
                // added by Huron Consulting Group 2/22/2016
                theContractParty.Preferred_Language_HCPTS__c = theICF.Preferred_Language_HCPTS__c;
                // end updates

                upsert theContractParty;
                //
                if(icfPIIFieldSet.size() > 0){
                    List<EM_Vendor_vod__c> cpJustUpserted = [Select Id, PII_Data_HCPTS__c from EM_Vendor_vod__c where Id =: theContractParty.Id];
                    if(cpJustUpserted[0]!=null && cpJustUpserted[0].PII_Data_HCPTS__c!=null){
                        piiData.Id = cpJustUpserted[0].PII_Data_HCPTS__c;
                        update piiData;
                    }
                    else{
                        insert piiData;
                        theContractParty.PII_Data_HCPTS__c = piiData.Id;
                        update theContractParty;
                    }
                }

                if(theICF.Vendor_HCPTS__c==null){
                    theICF.Vendor_HCPTS__c = theContractParty.Id;
                    update theICF;
                }
                ApexPages.Message myMsg = new ApexPages.Message(
                                                    ApexPages.severity.INFO, 
                                                    System.label.VPROF_Info_Msg_Contract_Party_Create_Success);
                ApexPages.addmessage(myMsg);
                return null;            
            }
            else{
                ApexPages.Message myMsg = new ApexPages.Message(
                                                    ApexPages.severity.WARNING, 
                                                    System.Label.VPROF_Err_Msg_No_Matching_fields_to_Copy);
                ApexPages.addmessage(myMsg);
                return null;            
            }           
        }catch(Exception e){
            System.debug('Exception creating a EM_Vendor_vod record from ICF' + e);
            
            ApexPages.Message myMsg = new ApexPages.Message(
                                                ApexPages.severity.INFO, 
                                                System.Label.VPROF_Err_Msg_Create_Vendor_Failed + '<br>' + e.getMessage());
            ApexPages.addmessage(myMsg);
            if(sp!=null){
                Database.rollback(sp);
            }
            return null;            
        }

    }
}