/* 
* @author - Murugesh Naidu, Veeva Systems Professional Services
* @createdDate - Jul 8, 2013
* @description - CustomVeevaUtilities - contains custom generic helper methods that can be applicable across a spectrum of customizations
*/
public with sharing class CustomVeevaUtilities {

    public static String getDynamicSOQLForAllEligibleFields(Schema.SobjectType sObjType){
        
        if(!sObjType.getDescribe().isQueryable()){
            throw new ApplicationException ('Object ' + sObjType.getDescribe().getName() + ' cannot be queried');
        }
        if(!sObjType.getDescribe().isAccessible()){
            throw new ApplicationException ('Object ' + sObjType.getDescribe().getName() + ' cannot be accessed');
        }
        
        Map<String, Schema.SObjectField> mapFields = sObjType.getDescribe().fields.getMap();
        
        String dynamicSOQL = 'Select ';
        for(Schema.SObjectField aField: mapFields.values()){
            if(aField.getDescribe().isAccessible()){
                dynamicSOQL += aField.getDescribe().getName() ;
                dynamicSOQL += ', ';
            }
        }
        dynamicSOQL = dynamicSOQL.substringBeforeLast(',');
        dynamicSOQL += ' From ' + sObjType.getDescribe().getName();
        System.debug('dynamicSOQL ==>' + dynamicSOQL);
        return dynamicSOQL;
    }
    
    public static String getDynamicChildFieldsSOQL(Schema.ChildRelationship childRelationship, ID parentIdValue){
        String dynamicSOQL = getDynamicSOQLForAllEligibleFields(childRelationship.getChildSObject());
        //apply the where clause to only return child records related to parent
        dynamicSOQL += ' where ' + childRelationship.getField().getDescribe().getName() + ' = \'' + parentIdValue + '\'';
        System.debug('dynamicChild fields SOQL ==>' + dynamicSOQL);
        
        return dynamicSOQL;
    }
    
    public static Schema.SObjectType getSObjectType(String objectAPIName){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        return gd.get(objectAPIName);
    }
    
    public static Schema.SObjectField getSObjectField(String objectAPIName, String fieldAPIName){
        Schema.SObjectType sObjType = getSObjectType(objectAPIName);
        Schema.SObjectField sObjField = null;
        if(sObjType!=null){
            sObjField =  sObjType.getDescribe().fields.getMap().get(fieldAPIName);
        }
        return sObjField;
    }
    
    public static Set<String> getFieldTokens(String s, String startKey, String endKey, Boolean includeKeys){
        if(s==null || s.trim() == '' || (!s.contains(startKey) && !s.contains(endKey))){
            return null;
        }
        Set<String> tokenList = new Set<String> ();
        
        while(s.indexOf(startKey)!=-1){
            String theToken = s.substringBetween(startKey,endKey);
            if(includeKeys){
                theToken = startKey + theToken + endKey;
            }
            tokenList.add(theToken);
            s = s.replaceFirst(startKey, '');
            s = s.replaceFirst(endKey, '');
        }
        System.debug('The tokenList = ' + tokenList);
        return tokenList;
    }
        
    public class ApplicationException extends Exception {
        
    }

    // created by Huron Consulting Group 1-20-2016
    public static String updateContractParties(EM_Event_Speaker_vod__c esp){

        if(esp.Related_ICF_HCPTS__c!=null){

            // make sure that the Contact Party on the Framework agreement and the Activity Agreement are
            // updated to match the Contact Party on the ICF
            Information_Collection_Form__c existingIFC = [SELECT Vendor_HCPTS__c FROM Information_Collection_Form__c WHERE Id = :esp.Related_ICF_HCPTS__c];

            List<Id> contractIds = new List<Id>();
            contractIds.add(esp.Event_Speaker_Contract_HCPTS__c);
            contractIds.add(esp.Speaker_Contract_HCPTS__c);

            List<Contract_vod__c> agreements = [SELECT Id,Status_vod__c,Lock_vod__c,Vendor_HCPTS__c FROM Contract_vod__c WHERE Id IN :contractIds];
            List<Contract_vod__c> agreementsToUpdate = new List<Contract_vod__c>();
            for(Contract_vod__c c: agreements){
                if(c.Status_vod__c != 'Activated' && c.Lock_vod__c != true && c.Vendor_HCPTS__c != existingIFC.Vendor_HCPTS__c){
                    c.Vendor_HCPTS__c = existingIFC.Vendor_HCPTS__c;
                    c.Service_Type_HCPTS__c = esp.Service_Type_HCPTS__c;
                    c.Service_Subtype_HCPTS__c = esp.Service_Subtype_HCPTS__c;
                    agreementsToUpdate.add(c);
                }else if((c.Status_vod__c == 'Activated' || c.Lock_vod__c == true) && c.Vendor_HCPTS__c != existingIFC.Vendor_HCPTS__c){
                    return Label.ActiveContractWithWrongContractParty;
                }
            }
            try{
                update agreementsToUpdate;
            }Catch(DmlException e){
                return System.label.VPROF_Error_Updating_Contract_Party + e;
            }
        }

        return 'Success';
    }

    public static String getDynamicSOQLForAllEligibleFieldsWithoutFrom(Schema.SobjectType sObjType){
        
        if(!sObjType.getDescribe().isQueryable()){
            throw new ApplicationException ('Object ' + sObjType.getDescribe().getName() + ' cannot be queried');
        }
        if(!sObjType.getDescribe().isAccessible()){
            throw new ApplicationException ('Object ' + sObjType.getDescribe().getName() + ' cannot be accessed');
        }
        
        Map<String, Schema.SObjectField> mapFields = sObjType.getDescribe().fields.getMap();
        
        String dynamicSOQL = 'Select ';
        for(Schema.SObjectField aField: mapFields.values()){
            if(aField.getDescribe().isAccessible()){
                dynamicSOQL += aField.getDescribe().getName() ;
                dynamicSOQL += ', ';
            }
        }
        dynamicSOQL = dynamicSOQL.substringBeforeLast(',');
        //dynamicSOQL += ' From ' + sObjType.getDescribe().getName();
        System.debug('dynamicSOQL ==>' + dynamicSOQL);
        return dynamicSOQL;
    }
    
    public static List<LockActivityChildren__c> unlockForEdits(String objectAPIName){
        List<LockActivityChildren__c> lockedChildren = [Select Id, EditLock__c, Object__c from LockActivityChildren__c where  Object__c =:objectAPIName and EditLock__c = true];
        for(LockActivityChildren__c c: lockedChildren){
            c.EditLock__c = false;
        }       
        update lockedChildren;
        return lockedChildren;
        
    }
    
    public static void relockForEdits(List<LockActivityChildren__c> childrenToLock){
        for(LockActivityChildren__c c: childrenToLock){
            c.EditLock__c = true;
        }
        update childrenToLock;
        
    }
    
    /**
    */
    @future
    public static void updateEventSpeakerEmployerConsentsAsync(List<ID> eventSpeakerIds){
        List<EM_Event_Speaker_vod__c> eventSpeakers = [Select Id, Name, Employer_Consent_Required_HCPTS__c, Speaker_vod__c
                                                        from EM_Event_Speaker_vod__c
                                                        where Id in: eventSpeakerIds];
        Set<ID> speakerIds = new Set<ID>();
        
        for(EM_Event_Speaker_vod__c esp: eventSpeakers){
            speakerIds.add(esp.Speaker_vod__c);
        }
        
        Map<Id, EM_Speaker_vod__c> speakerMap = new Map<Id, EM_Speaker_vod__c> (
                                                                        [Select Id, Employer_Consent_Required_HCPTS__c 
                                                                        from EM_Speaker_vod__c where id in: speakerIds]) ;
        
        updateEventSpeakerEmployerConsents(eventSpeakers, speakerMap);
        
    }
    /**
    */
    public static void updateEventSpeakerEmployerConsents(List<EM_Event_Speaker_vod__c> eventSpeakers, 
                                                            Map<Id, EM_Speaker_vod__c> speakerMap){
        for(EM_Event_Speaker_vod__c esp: eventSpeakers){
            esp.Employer_Consent_Required_HCPTS__c = speakerMap.get(esp.Speaker_vod__c).Employer_Consent_Required_HCPTS__c;
        }
        List<LockActivityChildren__c> childrenToLock = unlockForEdits('EM_Event_Speaker_vod__c');
        List<Database.SaveResult> SR = Database.update(eventSpeakers, false);
        relockForEdits(childrenToLock);
        System.debug('Update result - ' + SR);
    }

}