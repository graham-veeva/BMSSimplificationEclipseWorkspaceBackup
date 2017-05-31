public class VPROF_EMAttendeeControllerExt {

    EM_Attendee_vod__c theAttendee;
    String retURL = ''; 
    public static final String SPON_LTR_CONTRACT_RECTYPE_DEVNAME = 'SponsorshipLetter_HCPTS';
    public ID sponLtrContractRecTypeId;
    public VPROF_EMAttendeeControllerExt(ApexPages.StandardController controller){
        List<String> fieldsToGet = new List<String>();
        fieldsToGet.add('Name');
        fieldsToGet.add('Sponsorship_Letter_HCPTS__c');
        fieldsToGet.add('Contract_Subtype_HCPTS__c');
        fieldsToGet.add('Contract_Type_HCPTS__c');
        fieldsToGet.add('Country_HCPTS__c');
        fieldsToGet.add('Country_ref_HCPTS__c');
        fieldsToGet.add('Account_vod__c');
        fieldsToGet.add('Contact_vod__c');
        fieldsToGet.add('User_vod__c');
        fieldsToGet.add('Related_ICF_HCPTS__c');
        fieldsToGet.add('Event_vod__r.Name');
        controller.addFields(fieldsToGet);
        theAttendee = (EM_Attendee_vod__c) controller.getRecord();
      //changed to support translations - use dev name instead of rectype name - mnaidu
      //  sponLtrContractRecTypeId = Contract_vod__c.SObjectType.getDescribe().getRecordTypeInfosByName().get(SPON_LTR_CONTRACT_RECTYPE).getRecordTypeId();
      RecordType sponLtrRecType = [Select Id, Name, DeveloperName from RecordType 
                                    where SObjectType = 'Contract_vod__c' and DeveloperName =: SPON_LTR_CONTRACT_RECTYPE_DEVNAME  
                                  and IsActive = TRUE];
      sponLtrContractRecTypeId = sponLtrRecType.ID;
    }
    public PageReference setupSponsorshipLetter(){
        if(theAttendee.Sponsorship_Letter_HCPTS__c!=null){
            //update any data that could have changed from Audience/Attendee record
            Contract_vod__c theLetter = [Select id, Service_type_HCPTS__c, Service_Subtype_HCPTS__c ,Country_HCPTS__c 
                                         from Contract_vod__c where Id =: theAttendee.Sponsorship_Letter_HCPTS__c];
            theLetter.Service_type_HCPTS__c = theAttendee.Contract_Type_HCPTS__c;
            theLetter.Service_Subtype_HCPTS__c = theAttendee.Contract_Subtype_HCPTS__c;
            theLetter.Country_HCPTS__c = theAttendee.Country_ref_HCPTS__c;
            return new PageReference('/' + theAttendee.Id);
        }
        Contract_vod__c sponLtr = new Contract_vod__c(Start_Date_vod__c = System.today(), 
                                                End_Date_vod__c = System.today().addMonths(6),
                                                Name = ('SponsorshipLetter-'
                                                        + theAttendee.Name 
                                                        + '-' 
                                                        + theAttendee.Event_vod__r.Name).abbreviate(80),
                                                Status_vod__c = 'Draft_vod',
                                                RecordTypeId = sponLtrContractRecTypeId,
                                                Service_Type_HCPTS__c = 'Sponsorship',
                                                Service_Subtype_HCPTS__c = theAttendee.Contract_Subtype_HCPTS__c,
                                                Country_HCPTS__c = theAttendee.Country_ref_HCPTS__c
                                                );
        insert sponLtr;
        List<Contract_vod__c> cntrctTemplate = [Select Id, Name, Tax_Treatment_HCPTS__c, Is_Template_HCPTS__c, 
                                                             Service_Type_HCPTS__c, Service_Subtype_HCPTS__c, Additional_Terms_HCPTS__c, Currency_HCPTS__c,
                                                             Location_Date_Content_HCPTS__c, Maximum_Events_HCPTS__c, No_Fees_are_to_be_Paid_HCPTS__c,
                                                            (SELECT Name,Service_Name_HCPTS__c,Contract_HCPTS__c,Contract_Subtype_Formula_HCPTS__c,Contract_Type_Formula_HCPTS__c,
                                                                Service_HCPTS__c 
                                                                FROM Contract_Descriptions_HCPTS__r), 
                                                            (SELECT Hours_HCPTS__c,Service_Name_vod__c,EM_Rate_Type_vod__c,EM_Rate_vod__c,
                                                                Fee_Reimburseable_Topic_HCPTS__c,Comments_HCPTS__c,Contract_vod__c,Service_vod__c,Id,RecordTypeId 
                                                                FROM Contract_Lines_vod__r) 
                                                            from Contract_vod__c
                                                            where Is_Template_HCPTS__c = true
                                                            and Service_Type_HCPTS__c =: sponLtr.Service_Type_HCPTS__c
                                                            and Service_Subtype_HCPTS__c = :sponLtr.Service_Subtype_HCPTS__c
                                                            and Country_HCPTS__c =: theAttendee.Country_ref_HCPTS__c
                                                            ORDER BY LASTMODIFIEDDATE DESC 
                                                           LIMIT 1
                                                            ];
        if(cntrctTemplate.size() > 0){
            Contract_vod__c c = cntrctTemplate[0];
            sponLtr.Tax_Treatment_HCPTS__c = c.Tax_Treatment_HCPTS__c;
            sponLtr.Additional_Terms_HCPTS__c = c.Additional_Terms_HCPTS__c;
            sponLtr.Location_Date_Content_HCPTS__c = c.Location_Date_Content_HCPTS__c;
            sponLtr.Maximum_Events_HCPTS__c = c.Maximum_Events_HCPTS__c;
            sponLtr.No_Fees_are_to_be_Paid_HCPTS__c = c.No_Fees_are_to_be_Paid_HCPTS__c;
            sponLtr.Currency_HCPTS__c = c.Currency_HCPTS__c;
            //  sponLtr.Name = null;
            update sponLtr;
            
            //List<Contract_Description_HCPTS__c> descriptions = new List<Contract_Description_HCPTS__c>();
            List<Contract_Line_vod__c> contractLines = new List<Contract_Line_vod__c>();
            //  descriptions = c.Contract_Descriptions_HCPTS__r.deepClone(false, false, false);
            contractLines = c.Contract_Lines_vod__r.deepClone(false, false, false);
            //  for(Contract_Description_HCPTS__c d: descriptions){
            //      d.Contract_HCPTS__c = aaCntrct.Id;
            //  }
            for(Contract_Line_vod__c d: contractLines){
                d.Contract_vod__c = sponLtr.Id;
            }
            //  if(descriptions.size () > 0){
            //      insert descriptions;
            //  }
            if(contractLines.size () > 0){
                insert contractLines;
            }
        }
            //do we need Contract Partner creation at all for Sponsorship Letter?
         //   insert new Contract_Partner_vod__c(Account_vod__c = theAttendee.Account_vod__c, Contract_vod__c = sponLtr.Id, Status_vod__c = 'Activated_vod');
            theAttendee.Sponsorship_Letter_HCPTS__c  = sponLtr.Id;
            //check to see if this Attendee/Account existed as a Speaker and if we had an "applicable" ICF
            //for this
            //Select from ICF where Spekaer.account = this account..yes? limit 1.lastmod & isactive = true
            if(theAttendee.Related_ICF_HCPTS__c==null && theAttendee.Account_vod__c!=null){
                List<Information_Collection_Form__c> icf = 
                            [Select Id, Name, RecordtypeId, RecordType.Name, ICF_Type_HCPTS__c
                             from Information_Collection_Form__c 
                             where Speaker_HCPTS__r.Account_vod__c =: theAttendee.Account_vod__c
                             and ( Expired_Formula_HCPTS__c = false or Expired_Formula_HCPTS__c = null)
                                     and Status_HCPTS__c IN ('Signed', 'Signed Manually')
                                     Order by LastModifiedDate desc
                                     limit 1];
                if(icf!=null && icf.size()>0){
                    theAttendee.Related_ICF_HCPTS__c = icf[0].Id;
                }
            }
            update theAttendee;
         
        return new PageReference('/' + theAttendee.Id);
    }
    
}