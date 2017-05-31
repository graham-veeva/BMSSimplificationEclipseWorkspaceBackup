public with sharing class EventsManagement_BMS_EMEA {
    
    private ApexPages.StandardController controller {get; set;}
    public Medical_Event_vod__c medicalEvent {get; set;}
    public Id medicalEventID {get; set;}
    public String eventStage {get; set;}
    private Account speaker {get; set;}
    public List<DisplayRateCard> displayRateCards {get; set;}
    public List<FixedDisplayRateCard> fixedDisplayRateCards {get; set;} 
    
    private Set<String>  usedDescription =  new set<String>();   //CSABA 2014.07.16.
    //private String VEEVA_MEDEV_MISINGATTACH;
    //private String VEEVA_MEDEV_DUPLICATEATTACH;
    private String BMS_EMEA_MEDEV_MISINGATTACH; //Erik, 2014.08.07.
    private String BMS_EMEA_MEDEV_DUPLICATEATTACH; //Erik, 2014.08.07.
    
    public List<BlueFolder> files {get;set;}   //used in VF page  pageblocktable
    
    public decimal percentComplete {get;set;}
    public Address_vod__c SpeakerSummary {get;set;}
    public decimal totalCostSum {get;set;}
    public String attachmentIdToDelete {get;set;}
    public String approvalStatus {get;set;}
    public Boolean checkAttachmentDelete {get;set;}
    
    public EventsManagement_BMS_EMEA(ApexPages.StandardController controller) {
 
        checkAttachmentDelete = false;
 
        //initialize the stanrdard controller
        this.controller = controller;
        this.medicalEventId = ((Medical_Event_vod__c)controller.getRecord()).Id;
        System.Debug('CSABA:  MedEventID = ' + medicalEventId);
        totalCostSum = 0;
        
        System.Debug('CSABA getting Messages');
        getVeevaMessages(Userinfo.getLanguage());  //CSABA 2014.07.16.
        
        //find medical event record types
        Map<Id,RecordType> recordTypeToName = new Map<Id,RecordType>([SELECT Id, DeveloperName, Name
                                                              FROM RecordType 
                                                              WHERE SobjectType = 'Medical_Event_vod__c']);
        
  //      RecordType MPE_Face = [SELECT Id, DeveloperName, Name FROM RecordType WHERE SobjectType ='Medical_Event_vod__c' and DeveloperName = 'BMS_EMEA_2_Meeting_Post_Execution' limit 1];
        
    
        
        
        //Get details about this medical event
        for (Medical_Event_vod__c me : [SELECT FFM_Activity_Type_BMS_EMEA__c,Activity_Type_BMS_EMEA__c,FFM_Step_BMS_EMEA__c,Country_MasterFile_BMS_EMEA__c,RecordTypeId,Attachment_Validated_BMS_EMEA__c ,MeetingRecordTypeDelete_BMS_EMEA__c, Status_BMS_CORE__c, Speaker_BMS__c, Has_Rate_Card__c, Event_Type__c, Has_All_Documents_BMS__c
                                        FROM Medical_Event_vod__c
                                        WHERE Id = :this.medicalEventId]) {
            this.medicalEvent = me;
        }
        
        // Removed recordtype check to FFM step picklist value.
      //  if(this.medicalEvent.RecordTypeId == MPE_Face.Id){
     //       checkAttachmentDelete = true;
     //   }
        
        if(this.medicalEvent.FFM_Step_BMS_EMEA__c == 'Meeting Post-Execution'){
            checkAttachmentDelete = true;
        }
        
        
        //find what stage we are in
        if (recordTypeToName.get(this.medicalEvent.RecordTypeId) == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Record Type Not Found'));
            return;
        }

        this.eventStage = recordTypeToName.get(this.medicalEvent.RecordTypeId).DeveloperName;
        system.debug('JK - eventStage: ' + this.eventStage);
        
        //override stage if in approval
        getApprovalStatus();
        if (this.approvalStatus == 'Pending') 
        {
            this.eventStage = 'Planning_2';
        }
        
        populateBlueFolder();
        /*
        if (this.eventStage == 'Planning') {
            if (this.medicalEvent.Speaker_BMS__c != null) {
                populateRateCard();
                populateSpeakerSummary();
            }
        } else if (this.eventStage == 'Planning_2') {
            populateRateCard();
            populateSpeakerSummary();
        } else if (this.eventStage == 'Execution') {
            populateRateCard();
            populateSpeakerSummary();
        } else if (this.eventStage == 'Close_out') {
            populateBlueFolder();
            populateSpeakerSummary();
            system.debug('JK - populate blue folder');          
        }
        */
        
          
        
    }
    public void getApprovalStatus() {
       
        for (ProcessInstance pi : [SELECT Status FROM ProcessInstance WHERE TargetObjectId = :this.medicalEvent.Id]) {
            this.approvalStatus = pi.Status;
        }
    }
    public void saveSpeaker() {
        system.debug('JK - speaker: ' + this.medicalEvent.Speaker_BMS__c);
        update this.medicalEvent;
        populateRateCard();
        populateSpeakerSummary();
    }
    public void populateRateCard() {
        DisplayRateCard drc;
        FixedDisplayRateCard fdrc;
        this.displayRateCards = new List<DisplayRateCard>();
        this.fixedDisplayRateCards = new List<FixedDisplayRateCard>();
        totalCostSum = 0;
        
        if (this.MedicalEvent.Has_Rate_Card__c) {
            for (Rate_Card__c rc : [SELECT Hourly_Rate__c,Hours__c,Id,Medical_Event__c,Name,Type__c, Is_Hourly__c 
                                    FROM Rate_Card__c
                                    WHERE Medical_Event__c = :this.medicalEvent.Id]) {
                if (rc.Is_Hourly__c) {
                    drc = new DisplayRateCard();
                    drc.HourlyRate = rc.Hourly_Rate__c;
                    drc.Hours = rc.Hours__c;
                    drc.isTemplate = false;
                    drc.Name = rc.Name;
                    drc.Type = rc.Type__c;
                    drc.Id = rc.Id;
                    drc.Total = rc.Hours__c * rc.Hourly_Rate__c;
                    this.displayRateCards.add(drc);
                    totalCostSum += (rc.Hours__c * rc.Hourly_Rate__c); 
                } else {
                    fdrc = new FixedDisplayRateCard();
                    fdrc.Total = rc.Hourly_Rate__c;
                    fdrc.Name = rc.Name;
                    this.fixedDisplayRateCards.add(fdrc);
                    totalCostSum += rc.Hourly_Rate__c; 
                }                                       
            }           
        } else {
            for (Rate_Card_Template__c rct : [SELECT Hourly_Rate__c,Hours__c,Id,Name,Type__c 
                                              FROM Rate_Card_Template__c
                                              WHERE Type__c = :this.medicalEvent.Event_Type__c]) {
                drc = new DisplayRateCard();
                drc.HourlyRate = rct.Hourly_Rate__c;
                drc.Hours = rct.Hours__c;
                drc.isTemplate = true;
                drc.Name = rct.Name;
                drc.Type = rct.Type__c;
                drc.Id = rct.Id;
                drc.Total = rct.Hours__c * rct.Hourly_Rate__c;
                this.displayRateCards.add(drc);
                totalCostSum += (rct.Hours__c * rct.Hourly_Rate__c);                    
            }
            
        }
        if (this.eventStage == 'Planning') {
            for (Integer i = 0; i < 3; i++) {
                fdrc = new FixedDisplayRateCard();
                fdrc.Name = '';
                fdrc.Total = 0;
                this.fixedDisplayRateCards.add(fdrc);
            }
        }                
        system.debug('JK - displayRateCards: ' + displayRateCards);
    }
    public void createElectronicSignaturePage() {
        
    }
    public void sendDocuments() {
        
    }
    

    /*****************************************
    
    *****************************************/
    private void getVeevaMessages(String lang)  
    {
        
     System.Debug('CSABA getting Veeva messages for language ' + lang);         
     ExternalString[] labels = [Select Value, Name, Category, (Select Value, language From Localization where language = :lang) From ExternalString  where Category = 'BMS EMEA FFM'];
   
     Map<String,String> labelMap = new Map<String,String>() ;
     for(ExternalString label : labels) 
        {
         ExternalStringLocalization[] localized = label.Localization;   
         if(localized.size() == 1)
            labelMap.put(label.Name, String.escapeSingleQuotes(localized[0].Value)) ;
         else
            labelMap.put(label.Name, String.escapeSingleQuotes(label.value)) ;
        } 
  
     BMS_EMEA_MEDEV_MISINGATTACH = labelMap.get('BMS_EMEA_MEDEV_MISINGATTACH') == NULL ? 'Must specify a description for file' : labelMap.get('BMS_EMEA_MEDEV_MISINGATTACH');    
     BMS_EMEA_MEDEV_DUPLICATEATTACH = labelMap.get('BMS_EMEA_MEDEV_DUPLICATEATTACH') == NULL ? 'Description already in use' : labelMap.get('BMS_EMEA_MEDEV_DUPLICATEATTACH');
     
     System.Debug('Msg1 = ' +  BMS_EMEA_MEDEV_MISINGATTACH + ' msg2 = ' + BMS_EMEA_MEDEV_DUPLICATEATTACH);
        
    }

    
    /*********************************************************
    
    *********************************************************/
    private boolean CheckDuplicateDescription(String thedescr)
    {
        system.Debug('CSABA checking existing of descr: ' +  thedescr);
        //system.debug('ERIK USED DESCRIPTION: ' + this.usedDescription);
        
        if(this.usedDescription.contains(thedescr))
           return true;
           
        return false;
    }
    
    /*************************************************
    Load  all  Description  into a set  and into  a list
    then compare them
    *************************************************/
    private boolean checkDuplicatedDescriptionOnline()
    {
        
        List<String>  list1 = new List<String>();
        Set<String>   set1 = new set<String>();
        
        for (BlueFolder file : files)
        {
            if(file.description == '')
               continue;
            list1.add(file.description);
            set1.add(file.description);
        }
        
        if(list1.size() != set1.size())
           return true;
        
        return false;
    }
    
    /****************************
    CSABA 2014.07.16.  
    ****************************/
    public void attachDocuments() 
    {
        system.debug('starting attach documents');
        Boolean hasAllRequired = true;
        List<Attachment> newAttachments = new List<Attachment>();
        Attachment attachment;
                  
        System.Debug('CSABA Nr  of used Descr =' + this.usedDescription.size());
        for(String s :this.usedDescription)
           System.Debug('CSABA: Desc: = ' + s);
           
        //check if there is duplicstion in the current attach session   
        if(checkDuplicatedDescriptionOnline())
        {
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, BMS_EMEA_MEDEV_DUPLICATEATTACH));
               return;          
        }
           
        
        for (BlueFolder file : files) 
        {

            system.debug('file.isUploaded ' + file.isUploaded);
            system.debug('file.newAttachment.Name ' + file.newAttachment.Name);
            system.debug('file.description ' + file.description);
            
            //CSABA 2014.07.16. chekc the existenc e of description
            if(file.description == '' && file.newAttachment.Name != NULL)
            {
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, BMS_EMEA_MEDEV_MISINGATTACH + ' '  + file.newAttachment.Name));
               continue;
            }
            
            //CSABA 2014.07.16. chekc duplicate Description
            if(file.description != '' && file.newAttachment.Name != NULL && file.isUploaded ==  false && this.CheckDuplicateDescription(file.description))
            {
               //Commented by Erik, 2014.08.05.
               //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Description (' + file.description + ') is not  unique  See file: ' + file.newAttachment.Name));
               //return;              
            }
            
            if (!file.isUploaded && file.newAttachment.Name != null) 
            {
                /*
                attachment = new Attachment();
                attachment.ParentId = this.medicalEvent.Id;
                attachment.Name = file.newAttachment.Name;
                attachment.Description = file.Description;
                attachment.Body = file.newAttachment.Body;
                attachment.ContentType = file.newAttachment.ContentType;
                */
                file.newAttachment.ParentId = this.medicalEvent.Id;
                file.newAttachment.Description = file.Description;
                system.debug('new attachment: ' + file.newAttachment + ' CSABA 1 with description: ' + file.Description);
                newAttachments.add(file.newAttachment);
                file.isUploaded = true;
            }
        }
        
        for (BlueFolder bf : files) 
        {
            system.debug('JK - starting');
            system.debug('JK - bf.Description ' + bf.Description );
            system.debug('JK - bf.isUploaded' + bf.isUploaded);
            system.debug('JK - bf.isRequired ' + bf.isRequired );
            if (bf.isRequired && !bf.isUploaded) 
            {
                hasAllRequired = false;
            }
        }
        
        system.debug('newAttachments: ' + newAttachments);
        insert newAttachments;
        //update 
        populateBlueFolder();
        //set required documents status
        system.debug('hasAllRequired: ' + hasAllRequired);
        this.medicalEvent.Has_All_Documents_BMS__c = hasAllRequired;
        update this.medicalEvent;
              
    }
    
    
    public void saveRateCard() {
        if (this.MedicalEvent.Has_Rate_Card__c) {
            delete [SELECT Id FROM Rate_Card__c WHERE Medical_Event__c = :this.medicalEvent.Id];
        } 

        Rate_Card__c rc;
        Decimal amount = 0;
        List<Rate_Card__c> rateCards = new List<Rate_Card__c>();
        for (DisplayRateCard drc : this.displayRateCards) {
            
                rc = new Rate_Card__c();
                rc.Is_Hourly__c = true;
                if (drc.Hours > 0) {
                    rc.Hours__c = drc.Hours;
                } else {
                    rc.Hours__c = 0;
                }
                rc.Medical_Event__c = this.medicalEvent.Id;
                rc.Name = drc.Name;
                rc.Type__c = drc.Type;
                rc.Hourly_Rate__c = drc.HourlyRate;
                rateCards.add(rc);
                amount += (rc.Hours__c * rc.Hourly_Rate__c);   
                system.debug('jk - rate card: ' + rc);
            
        }
        for (FixedDisplayRateCard fdrc : this.fixedDisplayRateCards) {
            system.debug('jk - fixed rate card: ' + rc);
            if (fdrc.Total > 0) {
                rc = new Rate_Card__c();
                rc.Is_Hourly__c = false;
                rc.Hours__c = 1;
                rc.Medical_Event__c = this.medicalEvent.Id;
                rc.Name = fdrc.Name;
                rc.Hourly_Rate__c = fdrc.Total;
                rateCards.add(rc);
                amount += fdrc.Total;
                system.debug('jk - adding fixed rate card: ' + rc);
            }
        }
        system.debug('rate cards: ' + rateCards);
        insert rateCards;
        this.MedicalEvent.Has_Rate_Card__c = true;
        this.MedicalEvent.Planned_Expense_Amount__c = amount;
        update this.medicalEvent;
        populateRateCard();
    
    }




    /**************************************
    CSABa  must refrsh the page after delete
    **************************************/
    public PageReference deleteAttachment() 
    {
        String attachmentId= System.currentPageReference().getParameters().get('deleteAttachment');
        System.debug('attachmentIdToDelete : '+attachmentId );
        Attachment a = new Attachment(ID = attachmentId);
        Delete a;

        populateBlueFolder();
        this.usedDescription.clear();  //2014.07.16
          
        return null;
             
    }
    
    /*******************************
    populate the files  List  CSABA*
    *******************************/
    public void populateBlueFolder() 
    {
        decimal completeCount = 0;
        decimal totalCount = 0;
        this.percentComplete = 0;
        //for now just create dummy data.
        BlueFolder bf;
        this.files = new List<BlueFolder>();
        
        //get attachments
        Map<String,Attachment> descriptionToAttachment = new Map<String,Attachment>();
        for (Attachment a : [SELECT ContentType,Description,Id,Name,LastModifiedDate 
                             FROM Attachment
                             WHERE ParentId = :this.medicalEvent.Id]) 
        {
            descriptionToAttachment.put(a.Description,a);
        }   
        
        system.debug('CSABA1 descriptionToAttachment size = ' +  descriptionToAttachment .size());                          
        
        /*
        List<Meeting_Document_Template__c> documentTemplates= [SELECT Id,Meeting_Type__c,Name, Is_Required__c 
                                                               FROM Meeting_Document_Template__c
                                                               WHERE Meeting_Type__c = :this.medicalEvent.Event_Type__c];
        */
        //get document templates
        List<Meeting_Document_Template__c> documentTemplates = new List<Meeting_Document_Template__c>();
        Map<String,Meeting_Document_Template__c> documentTemplateNameToDocument = new Map<String,Meeting_Document_Template__c>();                                                     
        for (Meeting_Document_Template__c mdt : [SELECT Id,Meeting_Type__c,Name, Is_Required__c,Country_Specific_BMS_EMEA__c,FFM_Step_BMS_EMEA__c,Activity_Type_BMS_EMEA__c
                                                               FROM Meeting_Document_Template__c
                                                               WHERE 
                                                               Country_Specific_BMS_EMEA__c =: this.medicalEvent.Country_MasterFile_BMS_EMEA__c
                                                               and FFM_Step_BMS_EMEA__c =: this.medicalEvent.FFM_Step_BMS_EMEA__c
                                                               and Activity_Type_BMS_EMEA__c =: this.medicalEvent.FFM_Activity_Type_BMS_EMEA__c]) 
        {
            documentTemplates.add(mdt);
            documentTemplateNameToDocument.put(mdt.Name,mdt);
                                                                  
        }
        
        System.Debug('CSABA2 documentTemplates size = ' + documentTemplates.size());
        
                                                                       
       //populate blue folder
        for (Meeting_Document_Template__c mdt : documentTemplates) 
        {
            bf = new BlueFolder();
            if (descriptionToAttachment.containsKey(mdt.Name)) 
            {
                Attachment a = descriptionToAttachment.get(mdt.Name);
                bf.Description = mdt.Name;
                bf.Attachment = a; 
                bf.isUploaded = true;
                bf.isRequired = mdt.Is_Required__c;
                system.debug('adding bf from template file ' + bf  + '  CSABA3 with description: ' + mdt.Name );
                
                this.files.add(bf);
                
                if(bf.Description != NULL && bf.Description != '')
                {
                   System.Debug('CSABA X adding :' +  bf.Description);      
                   this.usedDescription.add(bf.Description);  //CSAB: 2014.07.16.
                   
                   //System.Debug('CSABA X adding :' +  bf.Attachment);      
                   //this.usedDescription.add(bf.Attachment);  //CSAB: 2014.07.16.
                }
                   
                if(mdt.Is_Required__c==true)completeCount += 1; //Viktor added IF 20150420 based on Arpi's point
            } 
            else 
            {
                bf.Description = mdt.Name;
                bf.Link = '/#';
                bf.isUploaded = false;
                bf.isRequired = mdt.Is_Required__c;
                system.debug('adding bf from blank template ' + bf  + ' CSABA4 with description: ' + mdt.Name );
                this.files.add(bf);
                
                if(bf.Description != NULL && bf.Description != '')
                {
                System.Debug('CSABA Y adding :' +  bf.Description);       
                this.usedDescription.add(bf.Description);  //CSAB: 2014.07.16.
                }
                
                //completeCount += 1;
                //totalCount += 1;
            }
            
            if(bf.isRequired == true)
            {
                totalCount += 1;
            }
            
        }
        
        //add any misc documents not in the template
        system.debug('CSABA5 add any misc documents not in the template');
        for (Attachment a : descriptionToAttachment.values()) 
        {
            system.debug('jk - attachment ' + a);
            if (!documentTemplateNameToDocument.containsKey(a.Description)) 
            {
                system.debug('jk - misc document ' + a);
                bf = new BlueFolder();
                bf.Description = a.Description;
                bf.Attachment = a; 
                bf.isUploaded = true;
                bf.isRequired = false;
                system.debug('adding bf from misc ' + bf  + ' CSABA6  with description: ' + a.Description);
                this.files.add(bf);
                
                if(bf.Description != NULL && bf.Description != '')
                {
                   System.Debug('CSABA Z adding :' +  bf.Description);  
                   this.usedDescription.add(bf.Description);  //CSAB: 2014.07.16. 
                }
            }
        }


        system.debug('CSABA7  why we are doing this? These might be the  2  empty  lines  for new  attachments!');
        bf = new BlueFolder();
        bf.Description = '';
        //bf.Description = 'CSABA  to be  filled';
        bf.Link = '/#';
        bf.isUploaded = false;
        bf.isRequired = false;
        this.files.add(bf);
        
        if(bf.Description != NULL && bf.Description != '')
        {
          System.Debug('CSABA A adding :' +  bf.Description);   
          this.usedDescription.add(bf.Description);  //CSAB: 2014.07.16.     
        }
        
        bf = new BlueFolder();
        bf.Description = '';
        //bf.Description = 'CSABA  to be  filled';
        bf.Link = '/#';
        bf.isUploaded = false;
        bf.isRequired = false;
        this.files.add(bf);
        
        if(bf.Description != NULL && bf.Description != '')
        {
          System.Debug('CSABA B adding :' +  bf.Description);   
          this.usedDescription.add(bf.Description);  //CSAB: 2014.07.16.
        }
       
        if (totalCount > 0) 
        {
            this.percentComplete = (completeCount/totalCount) * 100;
        } 
        
        system.Debug('CSABA  UserDescr nr = ' + this.usedDescription.size());
        
        system.Debug('CSABA: Nr  of items in the List = ' + this.files.size());                                      
    }
    
    
    public void populateBlueFolder_old() 
    {
        decimal completeCount = 0;
        decimal totalCount = 0;
        this.percentComplete = 0;
        //for now just create dummy data.
        BlueFolder bf;
        this.files = new List<BlueFolder>();
        //dummy 1
        bf = new BlueFolder();
        bf.Description = 'Document 1';
        bf.Link = '/#';
        bf.isUploaded = true;
        this.files.add(bf);
        completeCount += 1;
        totalCount += 1;
        //dummy 2
        bf = new BlueFolder();
        bf.Description = 'Document 2';
        bf.Link = '/#';
        bf.isUploaded = true;
        this.files.add(bf);
        completeCount += 1;
        totalCount += 1;
        //dummy 3
        bf = new BlueFolder();
        bf.Description = 'Document 3';
        bf.Link = '/#';
        bf.isUploaded = false;
        this.files.add(bf);
        totalCount += 1;
        //dummy 4
        bf = new BlueFolder();
        bf.Description = 'Document 4';
        bf.Link = '/#';
        bf.isUploaded = true;
        this.files.add(bf);
        completeCount += 1;
        totalCount += 1;
        system.debug('JK - completeCount: ' + completeCount);
        system.debug('JK - totalCount: ' + totalCount);
        this.percentComplete = (completeCount/totalCount) * 100;
        system.debug('JK - this.percentComplete: ' + this.percentComplete);
        system.debug('JK - files: ' + files);
    }
    
    public void populateSpeakerSummary() {
        //
        
        //get speaker info
        this.speakerSummary = new Address_vod__c();
        for(Address_vod__c ad : [SELECT Address_line_2_vod__c,City_vod__c,Name,Primary_vod__c,State_vod__c,Zip_vod__c, 
                                               Account_vod__r.Credentials_vod__c,Account_vod__r.PersonEmail,Account_vod__r.Phone,
                                               Account_vod__r.Specialty_1_vod__c,Account_vod__r.ONYX_Contract_Number_BMS__c,Account_vod__r.IsPersonAccount 
                                 FROM Address_vod__c 
                                 WHERE Account_vod__r.Id =:medicalEvent.Speaker_BMS__c AND
                                       Primary_vod__c = true]){
            this.speakerSummary = ad;                           
        }       
    }
    

    public class DisplayRateCard {
        public boolean isTemplate {get;set;}
        public string Name {get;set;}
        public decimal Hours {get;set;}
        public string Type {get;set;}
        public decimal HourlyRate {get;set;}
        public Id Id {get;set;}
        public decimal Total {get;set;}
        
        
        public DisplayRateCard() {
            
        }
    }
    public class FixedDisplayRateCard {
        public string Name {get;set;}
        public decimal Total {get;set;}
        
        public FixedDisplayRateCard() {
            
        }   
    }
    
    
    public class BlueFolder 
    {
        public Attachment newAttachment 
        {
            get 
            {
                if (attachment == null)
                    attachment = new Attachment();
                    return attachment;
            }
            set;
        }
        public string Description {get;set;}
        public string Link {get;set;}
        public boolean isUploaded {get;set;}
        public Id id {get;set;}
        public Attachment attachment {get;set;}
        public boolean isRequired {get;set;}
        
        public BlueFolder() 
        {
            
        }
    }
}