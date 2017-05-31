public with sharing class AttachmentTool_BMS_EMEA 
{
    
    
    private ApexPages.StandardController controller {get; set;}
    public Medical_Event_vod__c medicalEvent {get; set;}
    public Master_File_BMS_EMEA__c MasterFile{get; set;}
    public Id medicalEventID {get; set;}
    public Id MasterFileID{get; set;}
    public String eventStage {get; set;}
    private Account speaker {get; set;}
    public List<DisplayRateCard> displayRateCards {get; set;}
    public List<FixedDisplayRateCard> fixedDisplayRateCards {get; set;} 
    public List<BlueFolder> files {get;set;}
    public decimal percentComplete {get;set;}
    public Address_vod__c SpeakerSummary {get;set;}
    public decimal totalCostSum {get;set;}
    public String attachmentIdToDelete {get;set;}
    public String approvalStatus {get;set;}
   
    /**************** CSABA 2014.07.18. *******************************************/
    private Set<String>  usedDescription =  new set<String>();   //CSABA 2014.07.16.
    //private String VEEVA_MEDEV_MISINGATTACH;
    //private String VEEVA_MEDEV_DUPLICATEATTACH; 
    private String BMS_EMEA_MEDEV_MISINGATTACH; //Erik, 2014.08.07.
    private String BMS_EMEA_MEDEV_DUPLICATEATTACH; //Erik, 2014.08.07.
    private String BMS_EMEA_MEDEV_DESCR; //Erik, 2014.08.07.
    private String BMS_EMEA_MEDEV_SEE_FILE; //Erik, 2014.08.07.
    /**************** CSABA 2014.07.18. *******************************************/
        
    
    public AttachmentTool_BMS_EMEA(ApexPages.StandardController controller) 
    {
 
         
        //initialize the stanrdard controller
        //this.controller = controller;
       // this.medicalEventId = ((Medical_Event_vod__c)controller.getRecord()).Id;
       // totalCostSum = 0;
       
       this.controller = controller;
       this.MasterFileID= ((Master_File_BMS_EMEA__c)controller.getRecord()).Id;
       totalCostSum = 0;
       
        //CSABA 2014.07.18.
        System.Debug('CSABA getting Messages');
        getVeevaMessages(Userinfo.getLanguage());  //CSABA 2014.07.16.       
       
        //find medical event record types
        Map<Id,RecordType> recordTypeToName = new Map<Id,RecordType>([SELECT Id, DeveloperName, Name
                                                              FROM RecordType 
                                                              WHERE SobjectType = 'Medical_Event_vod__c']);
       
       //find master file record type
       Map<Id,RecordType> recordTypeToName1 = new Map<Id,RecordType>([SELECT Id, DeveloperName, Name
                                                              FROM RecordType 
                                                              WHERE SobjectType = 'Master_File_BMS_EMEA__c']);
       
        //Get details about this medical event
        for (Medical_Event_vod__c me : [SELECT RecordTypeId, Speaker_BMS__c, Has_Rate_Card__c, Event_Type__c, Has_All_Documents_BMS__c
                                        FROM Medical_Event_vod__c
                                        WHERE Id = :this.medicalEventId]) {
            this.medicalEvent = me;
        }
        
        //Get details about this master file
        for (Master_File_BMS_EMEA__c me : [SELECT   Attachment_Validated_BMS_EMEA__c, RecordTypeId,FFM_Step_BMS_EMEA__c,Activity_Type_BMS_EMEA__c,Country_BMS_EMEA__c,Has_All_Documents_BMS_EMEA__c,Status_BMS_EMEA__c
                                        FROM Master_File_BMS_EMEA__c
                                        WHERE Id = :this.MasterFileID]) {
            this.MasterFile= me;
        }

     
        populateBlueFolder();
       
        
    }
    
    
    
    public void getApprovalStatus() 
    {
       
        for (ProcessInstance pi : [SELECT Status FROM ProcessInstance WHERE TargetObjectId = :this.medicalEvent.Id]) {
            this.approvalStatus = pi.Status;
        }
    }
    
    public void saveSpeaker() 
    {
        system.debug('JK - speaker: ' + this.medicalEvent.Speaker_BMS__c);
        update this.medicalEvent;
        populateRateCard();
        populateSpeakerSummary();
    }
    public void populateRateCard() 
    {
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


    /************************** CSABA section 2014.07.18. *************************************************/  
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
     //Erik, 2014.08.07.
     BMS_EMEA_MEDEV_DESCR = labelMap.get('BMS_EMEA_MEDEV_DESCR') == NULL ? 'Description (' : labelMap.get('BMS_EMEA_MEDEV_DESCR');    
     BMS_EMEA_MEDEV_SEE_FILE = labelMap.get('BMS_EMEA_MEDEV_SEE_FILE') == NULL ? ') is not  unique  See file: ' : labelMap.get('BMS_EMEA_MEDEV_SEE_FILE');
     
     System.Debug('Msg1 = ' +  BMS_EMEA_MEDEV_MISINGATTACH + ' msg2 = ' + BMS_EMEA_MEDEV_DUPLICATEATTACH);
        
    }

    
    /*********************************************************
    
    *********************************************************/
    private boolean CheckDuplicateDescription(String thedescr)
    {
        system.Debug('CSABA checking existing of descr: ' +  thedescr);
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
    
    
    /************************** CSABA section 2014.07.18. *************************************8*******************/   
    
    public void attachDocuments() 
    {
        system.debug('starting attach documents');
        Boolean hasAllRequired = true;
        List<Attachment> newAttachments = new List<Attachment>();
        Attachment attachment;
        
        //CSABA 2014.07.18. check if there is duplicstion in the current attach session   
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
            
            
            //CSABA 2014.07.18. chekc the existenc e of description
            if(file.description == '' && file.newAttachment.Name != NULL)
            {
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, BMS_EMEA_MEDEV_MISINGATTACH + ' '  + file.newAttachment.Name));
               continue;
            } 
            
            //CSABA 2014.07.16. chekc duplicate Description
            if(file.description != '' && file.newAttachment.Name != NULL && file.isUploaded ==  false && this.CheckDuplicateDescription(file.description))
            {
                //Erik, 2014.08.07.     
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, BMS_EMEA_MEDEV_DESCR + file.description + BMS_EMEA_MEDEV_SEE_FILE + file.newAttachment.Name));
                
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Description (' + file.description + ') is not  unique  See file: ' + file.newAttachment.Name));
                return;              
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
                file.newAttachment.ParentId = this.MasterFile.Id;
                file.newAttachment.Description = file.Description;
                system.debug('new attachment: ' + file.newAttachment);
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
            if (bf.isRequired && !bf.isUploaded) {
                hasAllRequired = false;
            }
        }
        
        system.debug('newAttachments: ' + newAttachments);
        insert newAttachments;
        //update 
        populateBlueFolder();
        //set required documents status
        system.debug('hasAllRequired: ' + hasAllRequired);
        this.MasterFile.Has_All_Documents_BMS_EMEA__c = hasAllRequired;
        update this.MasterFile;
                
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

    public PageReference deleteAttachment() {
        String attachmentId= System.currentPageReference().getParameters().get('deleteAttachment');
        System.debug('attachmentIdToDelete : '+attachmentId );
        Attachment a = new Attachment(ID = attachmentId);
        Delete a;
        populateBlueFolder();
        return null;
             
        

    }
    
    public void populateBlueFolder() {
        decimal completeCount = 0;
        decimal totalCount = 0;
        this.percentComplete = 0;
        //for now just create dummy data.
        BlueFolder bf;
        this.files = new List<BlueFolder>();
        
        //get attachments
        Map<String,Attachment> descriptionToAttachment = new Map<String,Attachment>();
        for (Attachment a : [SELECT ContentType,Description,Id,Name 
                             FROM Attachment
                             WHERE ParentId = :this.MasterFile.Id]) {
            descriptionToAttachment.put(a.Description,a);
        }                             
        
        /*
        List<Meeting_Document_Template__c> documentTemplates= [SELECT Id,Meeting_Type__c,Name, Is_Required__c 
                                                               FROM Meeting_Document_Template__c
                                                               WHERE Meeting_Type__c = :this.medicalEvent.Event_Type__c];
        */
        //get document templates
        List<Meeting_Document_Template__c> documentTemplates = new List<Meeting_Document_Template__c>();
        Map<String,Meeting_Document_Template__c> documentTemplateNameToDocument = new Map<String,Meeting_Document_Template__c>();                                                     
        for (Meeting_Document_Template__c mdt : [SELECT Id,Meeting_Type__c,Name, Is_Required__c,Activity_Type_BMS_EMEA__c,FFM_Step_BMS_EMEA__c,Country_Specific_BMS_EMEA__c 
                                                               FROM Meeting_Document_Template__c
                                                               WHERE Country_Specific_BMS_EMEA__c = :this.MasterFile.Country_BMS_EMEA__c  and Activity_Type_BMS_EMEA__c=:this.MasterFile.Activity_Type_BMS_EMEA__c and FFM_Step_BMS_EMEA__c =:this.MasterFile.FFM_Step_BMS_EMEA__c  ]) {
            documentTemplates.add(mdt);
            documentTemplateNameToDocument.put(mdt.Name,mdt);
                                                                  
        }
                                                                       
       //populate blue folder
        for (Meeting_Document_Template__c mdt : documentTemplates) {
            bf = new BlueFolder();
            if (descriptionToAttachment.containsKey(mdt.Name)) {
                Attachment a = descriptionToAttachment.get(mdt.Name);
                bf.Description = mdt.Name;
                bf.Attachment = a; 
                bf.isUploaded = true;
                bf.isRequired = mdt.Is_Required__c;
                system.debug('adding bf from template file ' + bf);
                this.files.add(bf);
                system.debug('Is_Required__c ' + mdt.Is_Required__c);
                if(mdt.Is_Required__c==true)completeCount += 1; //Viktor added IF 20150420 based on Arpi's point               
            } else {
                bf.Description = mdt.Name;
                bf.Link = '/#';
                bf.isUploaded = false;
                bf.isRequired = mdt.Is_Required__c;
                system.debug('adding bf from blank template ' + bf);
                this.files.add(bf);
                //completeCount += 1;
                //totalCount += 1;
            }
            if(bf.isRequired == true){
                totalCount += 1;
            }
        }
        //add any misc documents not in the template
        for (Attachment a : descriptionToAttachment.values()) {
            system.debug('jk - attachment ' + a);
            if (!documentTemplateNameToDocument.containsKey(a.Description)) {
                system.debug('jk - misc document ' + a);
                bf = new BlueFolder();
                bf.Description = a.Description;
                bf.Attachment = a; 
                bf.isUploaded = true;
                bf.isRequired = false;
                system.debug('adding bf from misc ' + bf);
                this.files.add(bf);
            }
        }

        bf = new BlueFolder();
        bf.Description = '';
        bf.Link = '/#';
        bf.isUploaded = false;
        bf.isRequired = false;
        this.files.add(bf);
        bf = new BlueFolder();
        bf.Description = '';
        bf.Link = '/#';
        bf.isUploaded = false;
        bf.isRequired = false;
        this.files.add(bf);
        bf = new BlueFolder();
        bf.Description = '';
        bf.Link = '/#';
        bf.isUploaded = false;
        bf.isRequired = false;
        this.files.add(bf);
        


        if (totalCount > 0) {
            this.percentComplete = (completeCount/totalCount) * 100;
        }                                       
    }
    public void populateBlueFolder_old() {
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
    public class BlueFolder {
        public Attachment newAttachment {
            get {
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
        
        public BlueFolder() {
            
        }
    }
}