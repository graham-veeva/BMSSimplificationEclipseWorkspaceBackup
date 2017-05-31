public with sharing class EMRedirectController {
    boolean isStub = false;
    boolean isEMUser = false;
    ApexPages.StandardController controller;
    String attendeeStubId;
    String eventStubId;
    String startTime;
    String endTime;
    String country;
    String retURL;
    String parentId;
    String recordTypeId;
    
    public EMRedirectController(ApexPages.StandardController controller) {
        this.controller = controller;
        isEmUser = Schema.SObjectType.Preferences_vod__c.fields.Event_Management_User_vod__c.isAccessible(); 
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        recordTypeId= ApexPages.currentPage().getParameters().get('RecordType');
        if(isEMUser) {
            sObject record = controller.getRecord();
        	if(isAttendee()) {
                if(record.get('EM_Attendee_vod__c') != null) {
                    isStub = true;
                    attendeeStubId = (String)record.get('EM_Attendee_vod__c');
                } else if (record.get('EM_Event_Speaker_vod__c') != null) {
                    isStub = true;
                    attendeeStubId = (String)record.get('EM_Event_Speaker_vod__c');
                }
            } else if (isMedicalEvent()) {
                if(record.get('EM_Event_vod__c') != null) {
                    isStub = true;
                    eventStubId = (String)record.get('EM_Event_vod__c');
                }
            } else if(isEMEvent()) {
                DateTime tempDateTime;
                if(record.get('Start_Time_vod__c') != null) {
                    tempDateTime = (DateTime)record.get('Start_Time_vod__c');
                    startTime = tempDateTime.format();
                }
                if(record.get('End_Time_vod__c') != null) {
                    tempDateTime = (DateTime)record.get('End_Time_vod__c');
                    endTime = tempDateTime.format();
                }
                if(record.get('Id') != null) {
                    parentId = (String)record.get('Id');
                }
                if(record.get('Country_vod__c') != null) {
                    country = (String)record.get('Country_vod__c');
                }
            }    
        }   
    }

    private boolean isAttendee() {
        return controller.getRecord().getSObjectType().getDescribe().getName() == 'Event_Attendee_vod__c';
    }

    private boolean isMedicalEvent() {
    	return controller.getRecord().getSObjectType().getDescribe().getName() == 'Medical_Event_vod__c';
    }
    
    private boolean isEMEvent() {
        return controller.getRecord().getSObjectType().getDescribe().getName() == 'EM_Event_vod__c';
    }
    
    public PageReference redirectEdit() {      
        if(!isEMUser) {
            if(recordTypeId != null) {
            	return new PageReference('/' + controller.getId() + '/e?retURL=' + retURL +'&nooverride=1&RecordType=' + recordTypeId);     
            } else {
                return new PageReference('/' + controller.getId() + '/e?retURL=' + retURL +'&nooverride=1'); 
            }
        }
        
        if(isStub) {
            if(isAttendee()) {
                return new PageReference('/' + attendeeStubId + '/e?retURL=' + retURL);    
            } else if (isMedicalEvent()) {
                return new PageReference('/' + eventStubId + '/e?retURL=' + retURL);
            }           
        }
        
        if(recordTypeId != null) {
            return new PageReference('/' + controller.getId() + '/e?retURL=' + retURL +'&nooverride=1&RecordType=' + recordTypeId);     
        } else {
            return new PageReference('/' + controller.getId() + '/e?retURL=' + retURL +'&nooverride=1'); 
        }      
    }
    
    public PageReference redirectView() {
        if(!isEMUser) {
            new PageReference('/' + controller.getId() + '?retURL=' + retURL + '&nooverride=1');    
        }
        if(isStub) {
            if(isAttendee()) {
                return new PageReference('/' + attendeeStubId);    
            } else if (isMedicalEvent()) {
                return new PageReference('/' + eventStubId);
            }           
        }
        return new PageReference('/' + controller.getId() + '?retURL=' + retURL + '&nooverride=1'); 
    }
    
    public PageReference redirectNewEventChild() {     
        String eventObjectId = VOD_RedirectUtil.getObjectDurableId('EM_Event_vod');
        String childPageUrl = '/setup/ui/recordtypeselect.jsp?ent=' + EncodingUtil.urlEncode(eventObjectId.substring(0,15), 'UTF-8');      
        String eventKeyPrefix = controller.getRecord().getSObjectType().getDescribe().getKeyPrefix();
        childPageUrl += '&save_new_url=/'+ eventKeyPrefix + '/e?retURL=' + EncodingUtil.urlEncode('/' + controller.getId(), 'UTF-8');
        if(startTime != null) {
            childPageUrl += '&Start_Time_vod__c=' + startTime;   
        }
        if(endTime != null) {
            childPageUrl += '&End_Time_vod__c=' + endTime;    
        } 
        if(parentId != null) {
            childPageUrl += '&Parent_Event_vod__c=' + parentId;
        }
        if(country != null) {
            Country_vod__c countryObj = [SELECT Country_Name_vod__c FROM Country_vod__c WHERE Id =: country];
            
            childPageUrl += '&parentCountry=' + countryObj.Country_Name_vod__c;
        }
        
        PageReference newChildPage = new PageReference(childPageUrl);
        
        return newChildPage;       
    }
}