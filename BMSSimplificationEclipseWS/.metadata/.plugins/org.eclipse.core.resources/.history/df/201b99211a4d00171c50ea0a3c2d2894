public class SignatureReports {

    private String [] callIds ;
    private String callId ;
    public Call2_vod__c masterCall {get;set;}
    public String todayx {get;set;}
    public String todaylong {get;set;}
    public String nowx {get;set;}
    public String imgId {get;set;}
    public String baseURL {get;set;}

    public SignatureReports () {
        String x = URL.getSalesforceBaseUrl().toExternalForm() ;
        // Convert VF domain to regular domain
        baseURL  = x.replaceFirst('c.', '').replace('visual.force.com','salesforce.com') ;
        System.debug('**** baseURL:' + baseURL);
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        if (ApexPages.currentPage().getParameters().get('callIds') != null) {
            callIds = ApexPages.currentPage().getParameters().get('callIds').split(',');
        }
        else {
            callId = ApexPages.currentPage().getParameters().get('callId');
            imgId = ApexPages.currentPage().getParameters().get('imgId');
            masterCall = [select CreatedBy.EmployeeNumber, Territory_vod__c, Call_Date_vod__c, Signature_Date_vod__c, Name,Signature_vod__c,Address_Line_1_vod__c, Address_Line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, License_vod__c, account_vod__r.name from Call2_vod__c where Id = :callId] ;
        }
        todayx = Date.today().format() ;
        nowx = Datetime.now().format() ;
        todaylong = Datetime.now().format('MMMM d, yyyy') ;
    }

    public callWithImage[] getSigAdminCalls () {
System.debug (callIds) ;
        List <callWithImage> retval = new List<callWithImage> () ;
        Call2_vod__c [] calls =  [select Id, Name, CreatedBy.Name, Signature_Date_vod__c, Signature_vod__c, account_vod__r.firstname, account_vod__r.lastname from Call2_vod__c where Id in :callIds order by Signature_Date_vod__c] ;
        // Get all the images we need, sig image has the name 'tmpsig' + callId + '.png'
        Map <String, String> callIdToImgId = new Map <String, String> () ;
        List<String> imgNameList = new List<String> () ;
        for (String callId : callIds) {
            imgNameList.add ('tmpsig' + callId + '.png') ;
        }
System.debug ('hk:imgNameList:' + imgNameList) ;
        for (Document d : [select Id,Name from Document where Name in :imgNameList order by CreatedDate desc]) {
            String callId = d.Name.replace('tmpsig','').replace('.png','') ;
            callIdToImgId.put (callId, d.Id) ;
        }
System.debug ('hk:callIdToImgId:' + callIdToImgId) ;
        for (Call2_vod__c c : calls) {
            String imgId = callIdToImgId.get(c.Id) ;
            if (imgId == null) {
                imgId = '' ;
            }
            retval.add (new callWithImage(c,imgId)) ;
        }
System.debug ('hk:retval:' + retval) ;
        return retval ;
    }

    public signatureReceipt[] getSignatureReceipts() {
        System.debug('**** callIds.size():' + callIds.size());
        List <signatureReceipt> retval = new List<signatureReceipt> ();
        
        transient List<Id> accountIds = new List<Id>(); 
        transient List<String> callNames = new List<String>();
        // get accountIds and callNames 
        for (Call2_vod__c c :  [select Id, Name, account_vod__c 
                            FROM Call2_vod__c WHERE Id in :callIds]) {
            accountIds.add(c.Account_vod__c);
            callNames.add(c.Name);                              
        }
    
        // Get the sample drops for the call2_vod__c. Since there could be more than one for each call2_vod__c,
        // order them by the call2_vod__c, Call_date_vod__c, and the lastModifiedDate
        Map<Id,Call2_Sample_vod__c[]> call2SampleMap = new Map<Id,Call2_Sample_vod__c[]>();
        for (Call2_Sample_vod__c cs : [SELECT ID, Quantity_vod__c, Sample_Lot_BMS_SHARED__c, 
                        Call2_vod__c, Call_Date_vod__c FROM Call2_Sample_vod__c 
                        WHERE call2_vod__c IN :callIds AND Product_Type_BMS_SHARED__c IN ('Sample','BRC') 
                        ORDER BY Call2_vod__c, Call_Date_vod__c, LastModifiedDate ] ) {

            // get the call/visit for this sample
            if (call2SampleMap.get(cs.call2_vod__c) != null) {
                Call2_Sample_vod__c[] samples = call2SampleMap.get(cs.call2_vod__c);
                samples.add(cs);
                call2SampleMap.put(cs.call2_vod__c, samples);
            } else {
                Call2_Sample_vod__c[] samples = new List<Call2_Sample_vod__c>();
                samples.add(cs);
                call2SampleMap.put(cs.call2_vod__c, samples); 
            } 
        }
        System.debug('*****call2SampleMap size:' + call2SampleMap.size());
                 
        // Get all the images we need, sig image has the name 'tmpsig' + callId + '.png'
        transient Map <String, String> callIdToImgId = new Map <String, String> () ;
        transient List<String> imgNameList = new List<String> () ;
        for (String callId : callIds) {
            imgNameList.add ('tmpsig' + callId + '.png') ;
        }

        for (Document d : [select Id, Name FROM Document WHERE Name in :imgNameList ORDER BY CreatedDate desc]) {
            String callId = d.Name.replace('tmpsig','').replace('.png','') ;
            callIdToImgId.put(callId, d.Id) ;
        }
        imgNameList.clear();
        
        for (Call2_vod__c c :  [select Id, Name, CreatedBy.Name, CreatedBy.BMS_Territory_ID_BMS_SHARED__c, owner_territory__c,
                                CreatedBy.Title, Signature_Date_vod__c, Product__c, account_vod__r.BP_ID__c, 
                                account_vod__r.name, account_vod__r.Credentials_vod__c, Address_vod__c, License_vod__c, Disclaimer_vod__c 
                                FROM Call2_vod__c WHERE Id in :callIds ORDER BY Signature_Date_vod__c]) {
            String imgId = callIdToImgId.get(c.Id) ;
            if (imgId != null && imgId != '') {
                retval.add(new signatureReceipt(c,call2SampleMap.get(c.Id),imgId));

                System.debug('***** Image: ' + imgId + ', heapsize:' + Limits.getHeapSize());
            }
        }
        System.debug('**** retval size:' + retval.size());
        System.debug('***** heapsize:' + Limits.getHeapSize());
        return retval ; 
    }
    
    public Component.Apex.OutputText getSigSampleReceipt () {
        Component.Apex.OutputText ot = new Component.Apex.OutputText() ;
        ot.escape = false;
        Blob bd = [SELECT Body FROM Document WHERE Name = 'SignatureSampleReceiptHTML - Latest'].Body ;
        String contents = bd.toString();
        ot.expressions.value = contents ;
        return ot ;
    }

    public Component.Apex.OutputText getSigLetterContact () {
        Component.Apex.OutputText ot = new Component.Apex.OutputText() ;
        ot.escape = false;
        Blob bd = [SELECT Body FROM Document WHERE Name = 'SampleSignatureLetterContactHTML - Latest'].Body ;
        String contents = bd.toString();
        ot.expressions.value = contents ;
        return ot ;
    }

    public Component.Apex.OutputText getSigVendorLetterContact () {
        Component.Apex.OutputText ot = new Component.Apex.OutputText() ;
        ot.escape = false;
        Blob bd = [SELECT Body FROM Document WHERE Name = 'SignatureVendorLetterContactHTML - Latest'].Body ;
        String contents = bd.toString();
        ot.expressions.value = contents ;
        return ot ;
    }

    public String getSamples () {
        Call2_Sample_vod__c [] csamps = [select Call2_vod__c, Quantity_vod__c, Product_vod__r.Name, Product_vod__r.Product_Type_vod__c,Product_vod__r.Manufacturer_vod__c,Lot_vod__c from Call2_Sample_vod__c where Call2_vod__c = :callId and Product_vod__r.Product_Type_vod__c in ('Sample','BRC')] ;
        String retval = '<table><tr><td valign="top">Qty</td><td valign="top">Sample</td><td valign="top">Manufacturer</td><td valign="top">Ship/Received</td><td valign="top">Lot Number</td></tr>' ;
        for (Call2_Sample_vod__c cs : csamps) {
            retval += '<tr><td valign="top">' + cs.Quantity_vod__c + '</td><td valign="top">' + cs.Product_vod__r.Name + '</td><td valign="top">' + cs.Product_vod__r.Manufacturer_vod__c + '</td><td valign="top">' + (cs.Product_vod__r.Product_Type_vod__c == 'BRC' ? 'Shipped' : 'Received') + '</td><td valign="top">' + cs.Lot_vod__c + '</td></tr>' ;
        }
        retval += '</table>' ;
        retval = retval.replaceAll('null','') ;
        return retval ;
    }

    public class callWithImage {

        public Call2_vod__c call {get;set;}
        public String imgId {get;set;}

        public callWithImage (Call2_vod__c c, String i) {
            call = c ;
            imgId = i ;
        }

    }

    public class signatureReceipt {
        public Call2_vod__c call {get;set;}
        public Call2_Sample_vod__c[] cs {get;set;}
        public String imgId {get;set;}

        public signatureReceipt(Call2_vod__c c, Call2_Sample_vod__c[] s, String i) {
            call = c ;
            cs = s;
            imgId = i ;
        }
    }
}