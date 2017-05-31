public class AttachmentValidationLogic_BMS_EMEA{

    /******************************************************Master File Attachment validation**********************************************************************************/
    public static map<Id, boolean> validationlogic(List<Master_File_BMS_EMEA__c> mfileLst){
        set<string> country = new set<string>();
        set<string> activity = new set<string>();
        set<string> ffmstep = new set<string>();
        set<Id> mfIds = new set<Id>();
        for(Master_File_BMS_EMEA__c mf:mfileLst){
           country.add(mf.Country_BMS_EMEA__c);
           activity.add(mf.Activity_Type_BMS_EMEA__c);
           ffmstep.add(mf.FFM_Step_BMS_EMEA__c);
           mfIds.add(mf.Id);
        }
        
        List<Meeting_Document_Template__c> mdtList = [SELECT Id,Meeting_Type__c,Name, Is_Required__c,Activity_Type_BMS_EMEA__c,FFM_Step_BMS_EMEA__c,Country_Specific_BMS_EMEA__c 
                                                               FROM Meeting_Document_Template__c
                                                               WHERE Is_Required__c=: true and Country_Specific_BMS_EMEA__c in:country and Activity_Type_BMS_EMEA__c in:activity and FFM_Step_BMS_EMEA__c in:ffmstep];
        
        map<Id, List<Attachment>> mapAttach = new map<Id, List<Attachment>>();
        for(Master_File_BMS_EMEA__c mf:[select Id, (select Description from Attachments) from Master_File_BMS_EMEA__c where Id in:mfIds]){
            mapAttach.put(mf.Id, mf.Attachments);
        }
        
        map<Id, boolean> mapValidation = new map<Id, boolean>();
        map<string, Attachment> mapAttachList = new map<string, Attachment>();
        
        for(Master_File_BMS_EMEA__c mf:mfileLst){
            mapValidation.put(mf.Id, true);
            mapAttachList = new map<string, Attachment>();
            if(mapAttach.get(mf.Id) != null){
            for(Attachment att:mapAttach.get(mf.Id)){
                mapAttachList.put(att.Description, att);
            }
            }
            
            for(Meeting_Document_Template__c mdt: mdtList){
                if(mapAttachList.get(mdt.Name) == null && mf.FFM_Step_BMS_EMEA__c == mdt.FFM_Step_BMS_EMEA__c && mf.Activity_Type_BMS_EMEA__c == mdt.Activity_Type_BMS_EMEA__c && mdt.Country_Specific_BMS_EMEA__c == mf.Country_BMS_EMEA__c){
                    mapValidation.put(mf.Id, false);
                    break;
                }
            }            
        
        }
        
        return mapValidation;
    }
    
    
    /******************************************************Meeting Attachment validation**********************************************************************************/
    public static map<Id, boolean> meetvalidationlogic(List<Medical_Event_vod__c> medevtLst){
        set<string> evtType = new set<string>();
        set<Id> mdIds = new set<Id>();
        
        //3 fields Update for meetings
        set<string> country = new set<string>();
        set<string> activity = new set<string>();
        set<string> ffmstep = new set<string>();
        
                 
        for(Medical_Event_vod__c me:medevtLst){
           evtType.add(me.Event_Type__c);
           //3 fields Update for meetings
           country.add(me.Country_MasterFile_BMS_EMEA__c);
           activity.add(me.FFM_Activity_Type_BMS_EMEA__c);
           ffmstep.add(me.FFM_Step_BMS_EMEA__c);
           mdIds.add(me.Id);
        }
        
        system.debug('---country ---'+country);
        system.debug('---activity ---'+activity);
        system.debug('---ffmstep ---'+ffmstep);
        
        List<Meeting_Document_Template__c> mdtList = [SELECT Id,Meeting_Type__c,Name, Is_Required__c,Activity_Type_BMS_EMEA__c,FFM_Step_BMS_EMEA__c,Country_Specific_BMS_EMEA__c 
                                                               FROM Meeting_Document_Template__c
                                                               WHERE Is_Required__c=: true and Country_Specific_BMS_EMEA__c in:country and Activity_Type_BMS_EMEA__c in:activity and FFM_Step_BMS_EMEA__c in:ffmstep];
        
        map<Id, List<Attachment>> mapAttach = new map<Id, List<Attachment>>();
        for(Medical_Event_vod__c me:[select Id, (select Description from Attachments) from Medical_Event_vod__c where Id in:mdIds]){
            mapAttach.put(me.Id, me.Attachments);
        }
        
        map<Id, boolean> mapValidation = new map<Id, boolean>();
        map<string, Attachment> mapAttachList = new map<string, Attachment>();
        
        for(Medical_Event_vod__c me:medevtLst){
            mapValidation.put(me.Id, true);
            mapAttachList = new map<string, Attachment>();
            if(mapAttach.get(me.Id) != null){
            for(Attachment att:mapAttach.get(me.Id)){
                mapAttachList.put(att.Description, att);
            }
            }
            
            for(Meeting_Document_Template__c mdt: mdtList){
             
             system.debug('---- mapAttachList.get(mdt.Name) ----'+mapAttachList.get(mdt.Name));
             
             system.debug('---- meeting  ----'+me);
             
             system.debug('---- attachment ---'+mdt);
             
             /* updated for meeting validation required'  */
             if(mapAttachList.get(mdt.Name) == null && me.FFM_Activity_Type_BMS_EMEA__c == mdt.Activity_Type_BMS_EMEA__c 
                                                && mdt.FFM_Step_BMS_EMEA__c == me.FFM_Step_BMS_EMEA__c 
                                                && mdt.Country_Specific_BMS_EMEA__c == me.Country_MasterFile_BMS_EMEA__c){
                    
                    mapValidation.put(me.Id, false);
                    break;
                }   
               
             
         //       if(mapAttachList.get(mdt.Name) == null && me.Event_Type__c == mdt.Meeting_Type__c){
        //            mapValidation.put(me.Id, false);
           
        //        }
            }            
        
        }
        
        system.debug('--- mapValidation ---'+mapValidation);
        return mapValidation;
    }

}