trigger VPROF_ICF_Utilities on Information_Collection_Form__c (before insert, before update, after update) {

    Map<String, Schema.SObjectField> icfFieldMap = Schema.SObjectType.Information_Collection_Form__c.fields.getMap();
    Map<String, Schema.SObjectField> spkrFieldMap = Schema.SObjectType.EM_Speaker_vod__c.fields.getMap();
    String defaultICFToSpeakerMappingsValue = (String) icfFieldMap
                          .get('ICF_to_Speaker_Mapping__c')
                          .getDescribe()
                          .getDefaultValueFormula();
    String defaultSpeakerToICFMappingsValue = (String) icfFieldMap
                          .get('Speaker_to_ICF_Mapping__c')
                          .getDescribe()
                          .getDefaultValueFormula();
        
    defaultICFToSpeakerMappingsValue = defaultICFToSpeakerMappingsValue.removeStart('\'').removeEnd('\'');
    defaultSpeakerToICFMappingsValue = defaultSpeakerToICFMappingsValue.removeStart('\'').removeEnd('\'');

    System.debug('defaultICFToSpeakerMappingsValue = ' +defaultICFToSpeakerMappingsValue );
    System.debug('defaultSpeakerToICFMappingsValue = ' +defaultSpeakerToICFMappingsValue );
    // after update, check to see if the ICF has been signed manually, if it has, copy the info on the ICF
    // to the service provider
    if(Trigger.isAfter && Trigger.isUpdate){

        List<EM_Speaker_vod__c> speakerList = new List<EM_Speaker_vod__c>();
        String[] mappings =  defaultICFToSpeakerMappingsValue.split(';');//default value defines the mappings
        for(Information_Collection_Form__c ICF: Trigger.new){
            
            Information_Collection_Form__c oldICF = Trigger.oldMap.get(ICF.Id);

            if(//oldICF.Status_HCPTS__c != ICF.Status_HCPTS__c
                //&& 
                ICF.Status_HCPTS__c == 'Signed Manually'
                && ICF.Speaker_HCPTS__c != null){

                // copy the info from the ICF to the speaker
                EM_Speaker_vod__c speaker = new EM_Speaker_vod__c();
                speaker.Id = ICF.Speaker_HCPTS__c;
                speakerList.add(speaker);
            //  String[] mappings = ICF.ICF_to_Speaker_Mapping__c.split(';');
                for(String aMapping: mappings){
                    String icfFieldName = aMapping.subStringBefore(':').trim();
                    String speakerFieldName = aMapping.subStringAfter(':').trim();
                    System.debug('ICF = : ' + ICF);
                    System.debug('icfFieldName: ' + icfFieldName + '  ;speakerFieldName: ' + speakerFieldName);
                    if(ICF.get(icfFieldName.remove('\''))!=null 
                      // && spkrFieldMap.get(speakerFieldName).getDescribe().isUpdateable()
                      ){ //6/7/2016 - mnaidu - added this to ensure we don't attempt to update fields that we should not
                        speaker.put(speakerFieldName, ICF.get(icfFieldName));//sets the Speaker field with ICF field value
                    }
                }
            }
        }

        try{
            update speakerList;
        }Catch(Exception e){

        }

    }

    // before insert, populate fields from speaker
    if(Trigger.isInsert && Trigger.isBefore){
        
        String theQuery = CustomVeevaUtilities.getDynamicSOQLForAllEligibleFields(EM_Speaker_vod__c.SobjectType) + ' WHERE Id IN';
        theQuery += '(';
        for(Information_Collection_Form__c ICF: Trigger.new){
            if(ICF.Speaker_HCPTS__c != null){
                theQuery+= '\'' + ICF.Speaker_HCPTS__c + '\'';
            }
        }
        theQuery += ')';

        Map<Id,EM_Speaker_vod__c> speakers = new Map<Id,EM_Speaker_vod__c>((List<EM_Speaker_vod__c>)Database.query(theQuery));
        String[] mappings =  defaultSpeakerToICFMappingsValue.split(';');//default value defines the mappings
        
        for(Information_Collection_Form__c ICF: Trigger.new){

            EM_Speaker_vod__c speaker = speakers.get(ICF.Speaker_HCPTS__c);
        //  String[] mappings = ICF.Speaker_to_ICF_Mapping__c.split(';');
            for(String aMapping: mappings){
                String speakerFieldName = aMapping.subStringBefore(':').trim();
                String ICFFieldName = aMapping.subStringAfter(':').trim();
                System.debug('speakerFieldName: ' + speakerFieldName + '  ICFFieldName: ' + ICFFieldName);
                if(speaker.get(speakerFieldName)!=null
                  && icfFieldMap.get(ICFFieldName).getDescribe().isUpdateable()){
                    ICF.put(ICFFieldName, speaker.get(speakerFieldName));//sets the ICF field with Speaker field value
                }
            }
        }
    }

    // before insert, populate the name of the ICF
    // before update, update the name of the ICF
    if((Trigger.isInsert && Trigger.isBefore) || (Trigger.isUpdate && Trigger.isBefore)){

        Set<Id> speakerIds = new Set<Id>();

        for(Information_Collection_Form__c ICF: Trigger.new){
            if(ICF.Speaker_HCPTS__c != null){
                speakerIds.add(ICF.Speaker_HCPTS__c);
            }
        }

        Map<Id,EM_Speaker_vod__c> speakers = new Map<Id,EM_Speaker_vod__c>([SELECT Id,Name,Country_Lookup_HCPTS__r.Alpha_2_Code_vod__c FROM EM_Speaker_vod__c WHERE Id IN: speakerIds]);

        for(Information_Collection_Form__c ICF: Trigger.new){
            if(ICF.Speaker_HCPTS__c != null){
                EM_Speaker_vod__c speaker = speakers.get(ICF.Speaker_HCPTS__c);
                String ICFName = speaker.name +  '-ICF-' + speaker.Country_Lookup_HCPTS__r.Alpha_2_Code_vod__c + ICF.ICF_Type_HCPTS__c;
                if(ICF.Signature_Date_HCPTS__c != null){
                    String dateStr = ICF.Signature_Date_HCPTS__c.format();
                    ICFName +=  '-' + dateStr;
                }
                 ICF.Name = ICFName.left(80);
            }
        }
    }


    // before update, if the ICF has been signed, move to read only record type
    if(Trigger.isBefore && Trigger.isUpdate){

        // find the rec type Id for Read only
        RecordType readOnlyRecType;
        try{
            readOnlyRecType = [SELECT Id FROM RecordType WHERE RecordType.DeveloperName = 'ICF_Read_Only' AND SobjectType = 'Information_Collection_Form__c'];
        }Catch(Exception e){
            return;
        }

        if(readOnlyRecType == null){return;}

        for(Information_Collection_Form__c ICF: Trigger.new){
            Information_Collection_Form__c oldICF = Trigger.oldMap.get(ICF.Id);
            if(oldICF.Status_HCPTS__c != ICF.Status_HCPTS__c && (ICF.Status_HCPTS__c == 'Signed Manually' || ICF.Status_HCPTS__c == 'Signed')){
                ICF.recordtypeId = readOnlyRecType.Id;
            }
        }
    }

}