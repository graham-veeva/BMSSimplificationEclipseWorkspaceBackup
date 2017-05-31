public class searchCalls {


    public List<resultHeader> resultHeaders {set;get;}

    public String wc {get;set;}

    private List<String> resultFieldSet  ;
    private Set <String> acctResultFields = new Set<String> () ;
    private Set <String> callResultFields = new Set<String> () ;
    private Set <String> userResultFields = new Set<String> () ;


    private Map<String, Schema.SObjectField> acctFieldMap ;
    private Map<String, Schema.SObjectField> callFieldMap ;
    private Map<String, Schema.SObjectField> userFieldMap ;

    public Map <String,String> resFieldTypeMap = new Map <String,String> () ;
    private Map <String,String> resFieldLabelMap = new Map <String,String> () ;

    public static List<SelectOption> acctRecTypesPlist ;
    public static List<SelectOption> callRecTypesPlist ;
    private Map <String,String> recTypeXlation = new Map <String,String> () ;

    public String returnElemId {set;get;}
    public String where_clause {set;get;}

    public Boolean showAllAddrs {set;get;}

    public searchResult [] results {get;set;}

    public String sortKey {get;set;}
    public String sortDir {get;set;}
    public Boolean noSig {get;set;}

    private String tmpSigFolderId ;


    // Constructor
    public searchCalls () {
        noSig = false ;
        tmpSigFolderId = [select Id from Folder where Name='TempSigs'].Id ;
        results = new List<searchResult> () ;
        returnElemId = ApexPages.currentPage().getParameters().get('returnElemId');
        where_clause = ApexPages.currentPage().getParameters().get('where_clause');
System.debug ('wc is ' + where_clause) ;
if (where_clause.length() > 300) {
    System.debug('****** wc length:' + where_clause.length() + ', last 200 chars:' 
                + where_clause.substring(where_clause.length()-200) + ':');
}
        String lang = UserInfo.getLanguage() ;

        // Get Record Types for Accounts and Call
        // We need to use the translation table, and also filter by sObjectType
        acctRecTypesPlist = new List<SelectOption> () ;
        acctRecTypesPlist.add(new SelectOption('','None')) ;
        for (RecordTypeLocalization rtl : [select ParentId, Parent.Name, Value from RecordTypeLocalization where ParentId in (select Id FROM RecordType where SobjectType = 'Account') and Language = :lang order by Value]) {
            acctRecTypesPlist.add(new SelectOption(rtl.ParentId,rtl.Value));
            recTypeXlation.put (rtl.Parent.Name, rtl.Value) ;
        }
        // Also need to pick up those Record Types not in RecordTypeLocalization
        for (RecordType rt :[select Id,Name from RecordType where SobjectType = 'Account' and Id not in (select ParentId FROM RecordTypeLocalization where Language = :lang)]) {
            acctRecTypesPlist.add(new SelectOption(rt.Id,rt.Name));
            recTypeXlation.put (rt.Name, rt.Name) ;
        }
        acctRecTypesPlist = SortOptionList(acctRecTypesPlist) ;
        // Call Record Types
        callRecTypesPlist = new List<SelectOption> () ;
        callRecTypesPlist.add(new SelectOption('','None')) ;
        for (RecordTypeLocalization rtl : [select ParentId, Parent.Name, Value from RecordTypeLocalization where ParentId in (select Id FROM RecordType where SobjectType = 'Call2_vod__c') and Language = :lang order by Value]) {
            callRecTypesPlist.add(new SelectOption(rtl.ParentId,rtl.Value));
            recTypeXlation.put (rtl.Parent.Name, rtl.Value) ;
        }
        // Also need to pick up those Record Types not in RecordTypeLocalization
        for (RecordType rt :[select Id,Name from RecordType where SobjectType = 'Call2_vod__c' and Id not in (select ParentId FROM RecordTypeLocalization where Language = :lang)]) {
            callRecTypesPlist.add(new SelectOption(rt.Id,rt.Name));
            recTypeXlation.put (rt.Name, rt.Name) ;
        }
        callRecTypesPlist = SortOptionList(callRecTypesPlist) ;

        // Get Field Maps
        acctFieldMap = Schema.SObjectType.Account.fields.getMap();
        callFieldMap = Schema.SObjectType.Call2_vod__c.fields.getMap();
        userFieldMap = Schema.SObjectType.User.fields.getMap();


        // Get values of custom settings
        Call_Search_Settings__c css = [select Result_Field_Set__c from Call_Search_Settings__c where name = 'Main'] ;
        resultFieldSet = css.Result_Field_Set__c.split(',') ;
        // Parse resultFieldSet to get result Account and Address fields
        acctResultFields = new Set<String> () ;
        callResultFields = new Set<String> () ;
        userResultFields = new Set<String> () ;
        resultHeaders = new List<resultHeader> () ;
        String initSortKey = ApexPages.currentPage().getParameters().get('initSortKey');
        sortKey = initSortKey ;
        sortDir = 'A' ;
        for (String rf : resultFieldSet) {
            if (sortKey == '' || sortKey == null) {
                // Set sortKey to first result field in list
                sortKey = rf; 
            }
            if (rf.startsWith('ACCT.')) {
                String dataType = acctFieldMap.get(rf.replace('ACCT.', '')).getDescribe().getType().name() ;
                resFieldTypeMap.put (rf, dataType) ;
                String label = acctFieldMap.get(rf.replace('ACCT.', '')).getDescribe().getLabel() ;
                if (dataType == 'Reference') {
                    // We need to add Relationship.Name to acctResultFields
                    String rel = acctFieldMap.get(rf.replace('ACCT.', '')).getDescribe().getRelationshipName() ;
                    acctResultFields.add('Account_vod__r.' + rel + '.Name') ;
                    // Remove trailing ' ID' from label
                    label = label.replaceFirst(' ID$', '') ;
                }
                resFieldLabelMap.put (rf, label) ;
                acctResultFields.add (rf.replace('ACCT.', 'Account_vod__r.')) ;
                resultHeader rh = new resultHeader () ;
                rh.label = 'Current Account '  + label ;
                rh.apiname = rf ;
                resultHeaders.add (rh) ;
            }
            else if (rf.startsWith('USER.')) {
                String dataType = userFieldMap.get(rf.replace('USER.', '')).getDescribe().getType().name() ;
                resFieldTypeMap.put (rf, dataType) ;
                String label = userFieldMap.get(rf.replace('USER.', '')).getDescribe().getLabel() ;
                if (dataType == 'Reference') {
                    // We need to add Relationship.Name to userResultFields
                    String rel = userFieldMap.get(rf.replace('USER.', '')).getDescribe().getRelationshipName() ;
                    userResultFields.add('CreatedBy.' + rel + '.Name') ;
                    // Remove trailing ' ID' from label
                    label = label.replaceFirst(' ID$', '') ;
                }
                resFieldLabelMap.put (rf, label) ;
                userResultFields.add (rf.replace('USER.', 'CreatedBy.')) ;
                resultHeader rh = new resultHeader () ;
                rh.label = 'Rep ' + label ;
                rh.apiname = rf ;
                resultHeaders.add (rh) ;
            }
            else {
                String dataType = callFieldMap.get(rf).getDescribe().getType().name() ;
                resFieldTypeMap.put (rf, dataType) ;
                String label = callFieldMap.get(rf).getDescribe().getLabel() ;
                if (dataType == 'Reference') {
                    // We need to add Relationship.Name to callResultFields
                    String rel = callFieldMap.get(rf).getDescribe().getRelationshipName() ;
                    callResultFields.add(rel + '.Name') ;
                    // Remove trailing ' ID' from label
                    label = label.replaceFirst(' ID$', '') ;
                }
                resFieldLabelMap.put (rf, label) ;
                callResultFields.add (rf) ;
                resultHeader rh = new resultHeader () ;
                rh.label = label ;
                rh.apiname = rf ;
                resultHeaders.add (rh) ;
            }
        }
        // Add the fields which we always need for Call
        callResultFields.add('Id') ;
        callResultFields.add('Name') ;
        // acctResultFields.add('FirstName') ;
        // acctResultFields.add('LastName') ;
        // acctResultFields.add('Name') ;
        // acctResultFields.add('IsPersonAccount') ;
        // callResultFields.add('Id') ;
        // callResultFields.add('Account_vod__c') ;
        // callResultFields.add('Primary_vod__c') ;
        search () ;
    }

    public PageReference sigAdminreport() {
        List<String> callIdList  = new List<String> () ;
        if (results == null || results.size() == 0) {
            return null ;
        }
System.debug ('hk1') ;
        // Find the selected Calls
        for (searchResult sr : results) {
            if (sr.isSelected == true) {
                callIdList.add(sr.callId) ;
            }
        }
System.debug ('hk2') ;
        if (callIdList.size() == 0) {
System.debug ('hk3') ;
            return null ;
        }
        else {
            Document [] sigDocs = new List<Document> () ;
            // Create temp image for each signature
            for (Call2_vod__c c : [select Id,Signature_vod__c from Call2_vod__c where Id in :callIdList]) {
                Document d = new Document();
                d.Name = 'tmpsig' + c.Id + '.png';
                d.IsPublic = true;
                d.IsInternalUseOnly = false;
                d.FolderId = tmpSigFolderId ;
                d.ContentType = 'img/png' ;
                String x = c.Signature_vod__c ;
                if (x != null && x != '') {
                    d.Body = EncodingUtil.base64Decode(x) ;
                    sigDocs.add(d) ;
                }
            }
            insert sigDocs;
            PageReference pageRef = new PageReference('/apex/SignatureAdminReport?callIds=' + join(callIdList,',')) ;
            pageRef.setRedirect(true) ;
            return pageRef ;
        }
    }

    public PageReference sigReceipt() {
        List<Id> callIds = new List<Id>();
        if (results == null || results.size() == 0) {
            return null ;
        }
        // Find the selected Calls
        for (searchResult sr : results) {
            if (sr.isSelected == true) {
                callIds.add(sr.callId);
            }
        }
        if (callIds.size() <= 0) {
            return null;
        }
        else {
			// Delete ALL old tmpsigxxxx.png documents
			transient Document[] deleteDocs = [SELECT Id FROM Document WHERE Name LIKE 'tmpsig%' AND type = 'png'];        
            
            try {
                delete deleteDocs;
                System.debug('**** Successfully deleted ' + deleteDocs.size() + ' tmpsigxxx.png documents.');
            } catch (DmlException e) {
                System.debug('**** Error in deleting tmpsig documents');
            }
            deleteDocs.clear();
            System.debug('***** heapsize 2:' + Limits.getHeapSize());
                                    
            // Create new signature documents associated with these visits
            transient List<Document> documents = new List<Document>();
            for (Call2_vod__c call : [select Id, Name, Signature_vod__c from Call2_vod__c where Id IN :callIds]) {

                // Create temp image for signature
                transient Document d = new Document();
                d.Name = 'tmpsig' + call.Id + '.png';
                d.IsPublic = true;
                d.IsInternalUseOnly = false;
                d.FolderId = tmpSigFolderId ;
                d.ContentType = 'img/png' ;
                
                String sign = call.Signature_vod__c;
                if (sign == null || sign == '') {
                    //noSig = true;
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 
                    //    'The selected call ' + call.Name + ' does not have a signature.'));
                } else {
                    System.debug('***** created Image File:' + d.Name);
                    d.Body = EncodingUtil.base64Decode(sign) ;
                    documents.add(d);
                }

                // Insert in small chunks 
                if (documents.size() >= 8) {
                    try {
                        insert documents;
                        documents.clear();
                    } catch (Exception e) {
                        System.debug('**** Error in creating signature documents:' + e.getMessage());
                    }
                }
                System.debug('***** heapsize 3:' + Limits.getHeapSize());
            }
            try {
                if (documents.size() > 0) {
                    insert documents;
                    documents.clear();
                }
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Error in creating signature documents:' + e.getMessage()));
            }
            System.debug('**** Length of callIds string passed to SignatureReceipt:' + join(callIds,',').length());
            PageReference pageRef = new PageReference('/apex/SignatureReceipt?callIds=' + join(callIds,',')) ;
            pageRef.setRedirect(true) ;
            return pageRef ;
         } 
    }
    
    
    public PageReference sigSampleReceipt() {
        String callId = '';
        if (results == null || results.size() == 0) {
            return null ;
        }
        // Find the selected Call
        for (searchResult sr : results) {
            if (sr.isSelected == true) {
                callId = sr.callId;
                break ;
            }
        }
        if (callId == '') {
            return null ;
        }
        else {
            System.debug('***** callId:' + callId + 'tmpSigFolderId:' + tmpSigFolderId);
            // Create temp image for signature
            Document d = new Document();
            d.Name = 'tmpsig' + callId + '.png';
            d.IsPublic = true;
            d.IsInternalUseOnly = false;
            d.FolderId = tmpSigFolderId ;
            d.ContentType = 'img/png' ;
            String x = [select Signature_vod__c from Call2_vod__c where Id = :callId].Signature_vod__c ;
            System.debug('**** Signature_vod__c:' + x);
            if (x == null || x == '') {
                noSig = true ;
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'The selected call does not have a signature.'));
                return null ;
            }
            d.Body = EncodingUtil.base64Decode(x) ;
            insert d;
            String imgId = d.Id ;
            System.debug('**** imgId:'+ imgId);
            PageReference pageRef = new PageReference('/apex/sigSampleReceipt?callId=' + callId + '&imgId=' + imgId);
            pageRef.setRedirect(true) ;
            return pageRef ;
        }
    }


    public PageReference sigLetterContact() {
        String callId = '';
        if (results == null || results.size() == 0) {
            return null ;
        }
        // Find the selected Call
        for (searchResult sr : results) {
            if (sr.isSelected == true) {
                callId = sr.callId;
                break ;
            }
        }
        if (callId == '') {
            return null ;
        }
        else {
            // Create temp image for signature
            Document d = new Document();
            d.Name = 'tmpsig' + callId + '.png';
            d.IsPublic = true;
            d.IsInternalUseOnly = false;
            d.FolderId = tmpSigFolderId ;
            d.ContentType = 'img/png' ;
            String x = [select Signature_vod__c from Call2_vod__c where Id = :callId].Signature_vod__c ;
            if (x == null || x == '') {
                noSig = true ;
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'The selected call does not have a signature.'));
                return null ;
            }
            d.Body = EncodingUtil.base64Decode(x) ;
            insert d;
            String imgId = d.Id ;
            PageReference pageRef = new PageReference('/apex/sigLetterContact?callId=' + callId + '&imgId=' + imgId);
            pageRef.setRedirect(true) ;
            return pageRef ;
        }
    }


    public PageReference sigVendorLetterContact() {
        String callId = '';
        if (results == null || results.size() == 0) {
            return null ;
        }
        // Find the selected Call
        for (searchResult sr : results) {
            if (sr.isSelected == true) {
                callId = sr.callId;
                break ;
            }
        }
        if (callId == '') {
            return null ;
        }
        else {
            // Create temp image for signature
            Document d = new Document();
            d.Name = 'tmpsig' + callId + '.png';
            d.IsPublic = true;
            d.IsInternalUseOnly = false;
            d.FolderId = tmpSigFolderId ;
            d.ContentType = 'img/png' ;
            String x = [select Signature_vod__c from Call2_vod__c where Id = :callId].Signature_vod__c ;
            if (x == null || x == '') {
                noSig = true ;
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'The selected call does not have a signature.'));
                return null ;
            }
            d.Body = EncodingUtil.base64Decode(x) ;
            insert d;
            String imgId = d.Id ;
            PageReference pageRef = new PageReference('/apex/sigVendorLetterContact?callId=' + callId + '&imgId=' + imgId);
            pageRef.setRedirect(true) ;
            return pageRef ;
        }
    }




    public PageReference sortResults() {
        String newSortKey = ApexPages.currentPage().getParameters().get('sortKey');
        if (newSortKey == sortKey) {
            // Just change sortDir
            if (sortDir == 'A') {
                sortDir = 'D' ;
            }
            else {
                sortDir = 'A' ;
            }
        }
        else {
            sortKey = newSortKey ;
            sortDir = 'A' ;
        }
        results = SortSearchResults(results, sortKey, sortDir) ;
        return null ;
    }

    public void search() {
        
        try {
            results = new List<searchResult> () ;

            String query ;
            callResultFields.addAll(acctResultFields);
            callResultFields.addAll(userResultFields);
System.debug ('wc is ' + where_clause) ;
            query = 'select ' + join(callResultFields,',')  + ' from Call2_vod__c where ' + where_clause ;


System.debug ('query is ' + query) ;

            for (Call2_vod__c c : Database.query(query)) {
                searchResult mainSR ;
                Integer ix = 0 ;
                searchResult sr = new searchResult () ;
                sr.callId = c.Id ;
                sr.isSelected = false ;
                // Now get field values 
                sr.srFields = new List<searchResultField> () ;
                for (String rf : resultFieldSet) {
                    String typex ;
                    searchResultField srf = new searchResultField () ;
                    srf.apiname = rf ;
                    if (rf.startsWith('ACCT.')) {
                        Account a = (Account) c.getSObject('Account_vod__r');
                        typex  = resFieldTypeMap.get(rf) ;
                        srf.value = getObjValue(a, rf, typex) ;
                        srf.label = 'Current Account ' + resFieldLabelMap.get(rf.replace('ACCT.', '')) ;
                        srf.is_User = false ;
                        srf.is_Call = false ;
                        srf.is_Acct = true ;
                    }
                    else if (rf.startsWith('USER.')) {
                        User u = (User) c.getSObject('CreatedBy');
                        typex  = resFieldTypeMap.get(rf) ;
                        srf.value = getObjValue(u, rf, typex) ;
                        srf.label = 'Rep ' + resFieldLabelMap.get(rf.replace('USER.', '')) ;
                        srf.is_User = true ;
                        srf.is_Call = false ;
                        srf.is_Acct = false ;
                    }
                    else {
                        typex  = resFieldTypeMap.get(rf) ;
                        srf.value = getObjValue(c, rf, typex) ;
                        srf.label = resFieldLabelMap.get(rf) ;
                        srf.is_Call = true ;
                        srf.is_Acct = false ;
                        srf.is_User = false ;
                    }
                    // The rawvalue of the srf will be used for sorting
                    srf.rawvalue = srf.value ;
                    if ((typex == 'Date' || typex == 'Datetime') && srf.value != '') {
                        // For sorting purposes, store rawvalue of Date/Datetime as seconds since epoch
                        String dtval = srf.value ;
                        if (typex == 'Date') {
                            dtval = Datetime.newInstance(Date.parse(srf.value), Time.newInstance(0, 0, 0, 0)).format() ;
                        }
                        srf.rawvalue = (String) Datetime.parse(dtval).getTime().format() ;
                    }
                    sr.srFields.add(srf) ;
                }
                sr.callName = c.Name ;
                sr.otherAddrs = new List<SearchResult> () ;
                mainSR = sr ;
                results.add(mainSR) ;
            }
            System.debug('***** results.size:' + results.size()); 
            
            // Sort.  Initial sort is by first result field, which has already been set in constructor
            if (results.size() > 500) {
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.WARNING, 'More than 500 records found. Please narrow your search criteria.'));
            }
            else if (results.size() > 0) {
                results = SortSearchResults(results, sortKey, sortDir) ;
            }
            else {
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.INFO, 'No records found for specified criteria.'));
            }
        }
        catch (Exception ex) {
            ApexPages.addMessages(ex);
        }
        // return null;
    }


    private static String join (Set<String> ss, String delim) {
        String retVal = '' ;
        for (String s : ss) {
            if (retVal != '')  {
                retVal += delim ;
            }
            retVal += s ;
        }
        return retVal ;
    }

    private static String join (List<String> ss, String delim) {
        String retVal = '' ;
        for (String s : ss) {
            if (retVal != '')  {
                retVal += delim ;
            }
            retVal += s ;
        }
        return retVal ;
    }


    private String getObjValue (sObject so, String fname, String typex) {
System.debug ('in gov, got ' + fname + '/' + typex) ;
        if (typex == 'Reference') {
            // Get relationship name
            String relship ;
            if (fname.startsWith('ACCT.')) {
                relship = acctFieldMap.get(fname.replace('ACCT.', '')).getDescribe().getRelationshipName() ;
            }
            else if (fname.startsWith('USER.')) {
                relship = userFieldMap.get(fname.replace('USER.', '')).getDescribe().getRelationshipName() ;
            }
            else {
                relship = callFieldMap.get(fname).getDescribe().getRelationshipName() ;
            }
            // Display Name field of lookup value
            SObject so2 = so.getSObject(relship);
            if (!fname.contains('RecordTypeId') && so2 != null) {
                return (String) so2.get('Name') ;
            }
            else if (fname.contains('RecordTypeId') && so2 != null) {
                // We have the value, we need to translate it
                return recTypeXlation.get((String) so2.get('Name'));
            }
            return '' ;
        }
        if (fname.startsWith('ACCT.')) {
            fname = fname.replace('ACCT.', '') ;
        }
        else if (fname.startsWith('USER.')) {
            fname = fname.replace('USER.', '') ;
        }
        if (typex == 'Boolean') {
            Boolean b = (Boolean) so.get(fname) ;
            return (b == true ? '[X]' : '[ ]') ;
        }
        else if (typex == 'Date') {
            Date d = (Date) so.get(fname) ;
            if (d != null) {
                return d.format() ;
            }
            else {
                return '' ;
            }
        }
        else if (typex == 'Datetime') {
            Datetime d = (Datetime) so.get(fname) ;
            if (d != null) {
                return d.format() ;
            }
            else {
                return '' ;
            }
        }
        else {
            return (String) so.get(fname) ;
        }
    }


    private List<SelectOption> SortOptionList(List<SelectOption> ListToSort) {

        // Simple quick sort : see http://improveit360.blogspot.com/2010/09/implementing-quicksort-to-sort-list-of.html
        if(ListToSort == null || ListToSort.size() <= 1)
            return ListToSort;
            
        List<SelectOption> Less = new List<SelectOption>();
        List<SelectOption> Greater = new List<SelectOption>();
        integer pivot = ListToSort.size() / 2;
          
        // save the pivot and remove it from the list
        SelectOption pivotValue = ListToSort[pivot];
        ListToSort.remove(pivot);
        
        for(SelectOption x : ListToSort)
        {
            if(x.getLabel() <= pivotValue.getLabel())
                Less.add(x);
            else if(x.getLabel() > pivotValue.getLabel()) Greater.add(x);   
        }
        List<SelectOption> xList = new List<SelectOption> ();
        xList.addAll(SortOptionList(Less));
        xList.add(pivotValue);
        xList.addAll(SortOptionList(Greater));
        // Dedupe
        List<SelectOption> returnList = new List<SelectOption> ();
        Set<String> labelSet = new Set<String> () ;
        returnList.add(new SelectOption('','None')) ;
        labelSet.add('None') ;
        for(SelectOption x : xList) {
            if (!labelSet.contains(x.getLabel())) {
                returnList.add(x) ;
                labelSet.add(x.getLabel()) ;
            }
        }
        return returnList; 
    }  

    private List<searchResult> SortSearchResults (List<searchResult> ListToSort, String keyField, String sortDir) {

        if (keyField != '') {
            // Set key field for each searchResult
            for(searchResult x : ListToSort) {
                for (searchResultField y : x.srFields) {
                    // Find the keyField
                    if (y.apiname == keyField) {
                        x.key = y.rawvalue ;
                        break ;
                    }
                }
            }
        }

        // Ok, now we have the keys, can do a simple quick sort. See : http://improveit360.blogspot.com/2010/09/implementing-quicksort-to-sort-list-of.html
        if(ListToSort == null || ListToSort.size() <= 1)
            return ListToSort;
            
        List<searchResult> Less = new List<searchResult>();
        List<searchResult> Greater = new List<searchResult>();
        integer pivot = ListToSort.size() / 2;
          
        // save the pivot and remove it from the list
        searchResult pivotValue = ListToSort[pivot];
        ListToSort.remove(pivot);
        
        if (sortDir == 'A') { // Ascending
            for(searchResult x : ListToSort)
            {
                if(x.key <= pivotValue.key)
                    Less.add(x);
                else if(x.key > pivotValue.key) Greater.add(x);   
            }
        }
        else { // Descending 
            for(searchResult x : ListToSort)
            {
                if(x.key <= pivotValue.key)
                    Greater.add(x);
                else if(x.key > pivotValue.key) Less.add(x);   
            }
        }
        List<searchResult> returnList = new List<searchResult> ();
        returnList.addAll(SortSearchResults(Less, '', sortDir));
        returnList.add(pivotValue);
        returnList.addAll(SortSearchResults(Greater, '', sortDir));
        return returnList; 
    }  

    public class searchResult {

        public String callId {get;set;}
        public String callName {get;set;}
        public Boolean isSelected {get;set;}
        public String key {set;get;}
        public List<searchResultField> srFields {get;set;}
        public List<searchResult> otherAddrs {get;set;}

    }

    public class searchResultField {

        public String apiname {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String rawvalue {get;set;}
        public Boolean is_Acct {get;set;}
        public Boolean is_Call {get;set;}
        public Boolean is_User {get;set;}

    }

    public class resultHeader {

        public String label {set;get;} 
        public String apiname {set;get;} 

    }
}