public class queryCalls {

    public String iframeSrc {get;set;}
    public String transactionIds {get;set;}

    public List <searchField> searchFields {set;get;}

    private List<String> searchFieldSet  ;

    private Map<String, Schema.SObjectField> acctFieldMap ;
    private Map<String, Schema.SObjectField> callFieldMap ;
    private Map<String, Schema.SObjectField> userFieldMap ;

    public static List<SelectOption> acctRecTypesPlist ;
    public static List<SelectOption> callRecTypesPlist ;
    private Map <String,String> recTypeXlation = new Map <String,String> () ;

    public String returnElemId {set;get;}
    public String callDateFrom {set;get;}
    public String callDateTo {set;get;}
    public String empNumb {set;get;}
    public Integer minNumbCalls {set;get;}
    public Integer numbProfs {set;get;}

    private Call_Search_Settings__c css ;

    // Constructor
    public queryCalls () {
        iframeSrc = '' ;
        returnElemId = ApexPages.currentPage().getParameters().get('returnElemId');
        String lang = UserInfo.getLanguage() ;
        date date1 = date.today();
        date date2 = date1.addDays(-90) ;
        Time myTime = Time.newInstance(0, 0, 0, 0);
        callDateTo = datetime.newInstance(date1,myTime).format('MM/dd/yyyy') ;
        callDateFrom = datetime.newInstance(date2,myTime).format('MM/dd/yyyy') ;

        // Get Record Types for Accounts and Calls
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
        css = [select Search_Field_Set__c,Extra_Condtion__c from Call_Search_Settings__c where name = 'Main'] ;
        searchFieldSet = css.Search_Field_Set__c.split(',') ;
        // Set up search fields
        searchFields = new List <searchField> () ;
        for (String f : searchFieldSet) {
            // String has the format <fieldname>:<options>, where fieldname is the API name of the field,
            // and options, is present, contains a combination of the letters s for starts with, e for exact match,
            // and c for contains.  If any of these are upper case, that is the default option value
            String fldname = (f.split(':'))[0] ;
            String opts = (f.split(':'))[1] ;
            if (fldname == 'CurrTerr') {
                searchFields.add (new searchField('Customer Territory','CurrTerr')) ;
            }
            else if (fldname.startsWith('ACCT.')) {
                Schema.DescribeFieldResult  dfr = acctFieldMap.get(fldname.replace('ACCT.', '')).getDescribe() ;
                searchFields.add (new searchField('Account',dfr,opts)) ;
            }
            else if (fldname.startsWith('USER.')) {
                Schema.DescribeFieldResult  dfr = userFieldMap.get(fldname.replace('USER.', '')).getDescribe() ;
                searchFields.add (new searchField('User',dfr,opts)) ;
            }
            else {
                Schema.DescribeFieldResult  dfr = callFieldMap.get(fldname).getDescribe() ;
                searchFields.add (new searchField('Call2_vod__c',dfr,opts)) ;
            }
        }

    }

    public PageReference audit() {

        iframeSrc = '' ;
        // Get the Calls for the criteria
        String whereClause = 'CreatedBy.BMS_Employee_ID__c = \'' + empNumb + '\'';
        // Add Call Date and LastModifiedDate
        String origCDF = callDateFrom ;
        String origCDT = callDateTo ;
        date date1 = date.parse(callDateFrom);
        date date2 = date1.addDays(-1) ;
        Time myTime = Time.newInstance(0, 0, 0, 0);
        Datetime lastmoddate = datetime.newInstance(date2,myTime) ;
        String lastmoddatestr = lastmoddate.format('yyyy-MM-dd\'T\'HH:mm:ss.\'000Z\'') ;
        String [] mdy = callDateFrom.split('/') ;
        callDateFrom = mdy[2] + '-' + mdy[0] + '-' + mdy[1] ;
        mdy = callDateTo.split('/') ;
        callDateTo = mdy[2] + '-' + mdy[0] + '-' + mdy[1] ;
        whereClause += ' and LastModifiedDate >= ' + lastmoddatestr + ' and Call_Date_vod__c >= ' + callDateFrom.replace('/','-') + ' and Call_Date_vod__c <= ' + callDateTo.replace('/','-') ;
        callDateFrom = origCDF ;
        callDateTo = origCDT ;
        // Add any extra condtions
        if (css.Extra_Condtion__c != '' && css.Extra_Condtion__c != null) {
            whereClause += ' and ' + css.Extra_Condtion__c ;
        }

        // Get the Accounts for all Calls matching this criteria
        String query = 'select Id,Account_vod__c from Call2_vod__c where ' + whereClause ;
        Call2_vod__c [] calls = Database.query(query) ;
        if (calls.size() == 0) {
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.INFO, 'No calls found for specified criteria '));
            return null ;
        }

        // Map of AccountId to list of CallIds
        Map <String,String []> acctToCallIds = new Map<String, String[]> () ;
        // Map of random number to AcctId
        Map <Double,String> randKeyToAcctId = new Map<Double, String> () ;
        // List of Call IDs to store
        List<String> callIds = new List<String> ();
        for (Call2_vod__c c : calls) {
            // Get the Account for this Call
            String acct = c.Account_vod__c ;
            // See if there is an entry for the acct in acctToCallIds
            if (acctToCallIds.get(acct) != null) {
                String []  aCallIds = acctToCallIds.get(acct) ;
                aCallIds.add (c.Id) ;
                acctToCallIds.put(acct, aCallIds) ;
            }
            else {
                String []  aCallIds = new List<String> () ;
                aCallIds.add (c.Id) ;
                acctToCallIds.put(acct, aCallIds) ;
            }
        }

        if (acctToCallIds.size() < numbProfs) {
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.INFO, 'Not enough calls found for specified criteria '));
            return null ;
        }

        // Go thru acctToCallIds, and remove any Accounts where number of calls < min numb of calls
        for (String acct : acctToCallIds.keySet()) {
            String []  aCallIds = acctToCallIds.get(acct) ;
            if (aCallIds.size() < minNumbCalls) {
                acctToCallIds.remove(acct) ;
            }
            else {
                // Create entry for randKeyToAcctId
                randKeyToAcctId.put (Math.random(), acct) ;
                // Now randomize the calls we have for the Account if there are more than minNumbCalls
                if (aCallIds.size() > minNumbCalls) {
                    Map <Double,String> randKeyToCallId = new Map<Double, String> () ;
                    for (String cid : aCallIds) {
                        randKeyToCallId.put (Math.random(), cid) ;
                    }
                    String [] randSortedCallIds = new List<String> () ;
                    List <Double> randKeys = new List<Double> ();
                    randKeys.addAll(randKeyToCallId.keySet()) ;
                    randKeys.sort () ;
                    for (Integer i = 0; i < minNumbCalls; i++) {
                        randSortedCallIds.add(randKeyToCallId.get(randKeys[i])) ;
                    }
                    acctToCallIds.put(acct, randSortedCallIds) ;
                }
            }
        }

        if (acctToCallIds.size() < numbProfs) {
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.INFO, 'Not enough calls found for specified criteria '));
            return null ;
        }

        if (acctToCallIds.size() > numbProfs) {
            // We need to get a random selection.  Get the keys for randKeyToAcctId, which should be randomly ordered, and sort them into a list
            List <Double> randKeys = new List<Double> ();
            randKeys.addAll(randKeyToAcctId.keySet()) ;
            randKeys.sort () ;
            for (Integer i = 0; i < numbProfs; i++) {
                callIds.addAll(acctToCallIds.get(randKeyToAcctId.get(randKeys[i]))) ;
            }
        }
        else {
            // Just get them all
            for (String acctId : acctToCallIds.keySet()) {
                callIds.addAll(acctToCallIds.get(acctId)) ;
            }
        }

        // Now create where_clause to send to searchCalls
        String where_clause = 'Id in (\'' + join(callIds, '\',\'') + '\')' ;
        //ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.INFO, where_clause));
        iframeSrc = '/apex/searchCalls?where_clause=' + where_clause +'&initSortKey=Professional_Last_Name_ABT__c';
        return null ;
    }


    public PageReference search() {       
        iframeSrc = '' ;
        try {
            String whereClause = '' ;
            
            // 7/15/2012 -- Changes for handling Sample Transaction Ids            
            string visitname  = '';      
            // If transaction Ids are entered, ignore other fields and continue search ONLY with transaction Ids. 
                
            if (transactionIds != null && transactionIds != '') {
                //remove all invalid charcthers and put them in quotes  
                String transactionIdsInQuotes = '';
                transactionIdsInQuotes = '(\'' + transactionIds.replaceAll('[^\\-?STst0-9,]','').replaceAll(',', '\',\'') + '\')' ;
                string query = 'select Call_Name_vod__c from Sample_Transaction_vod__c  where name in ' + transactionIdsInQuotes + 'group by Call_Name_vod__c';
                System.debug('**** query:' + query);
                
                for (sObject st : database.query(query)) {
                    if (visitname != '') {
                        visitname = visitname + ',' + string.valueof(st.get('Call_Name_vod__c')) ;
                    }                                                     
                    else {
                        visitname = string.valueof(st.get('Call_Name_vod__c'));
                    }
                }
                System.debug('**** visitName:' + visitname);
                
                if (visitname != null && visitname != '') {
                    visitname = '(\'' + visitname.replaceAll(',', '\',\'') + '\')' ;
                    whereClause = ' NAME IN ' + visitname;
                    System.debug('***** whereClause using transaction Ids:' + whereClause);
                } else {
                    ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'There are no visits associated with these Transaction Ids.'));
                    return null ;
                }
            } 
            
            else {  
                System.debug('**** Dealing with the non-Transaction Ids search ...');
                // If transaction Ids are not entered, then search using the other fields.
                if (callDateFrom == '' || callDateTo == '') {
                    ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'Call Date From/To must be entered'));
                    return null ;
                }
                      
                // Go thru each search fields
                for (searchField sf : searchFields) {
                    if ( sf.apiname == 'Name' ){      
                        System.debug('***** visitNames:' + sf.value);                   
                        if (sf.value != '' && sf.value != 'null' && sf.value != null) {  
                            string op = 'In';
                            sf.value = sf.value.replaceAll('[\\s+]',''); // remove possible white spaces
                            sf.value = '(\'' + sf.value.replaceAll(',', '\',\'') + '\')' ;
                            if (whereClause != '') {
                                whereClause += ' AND ' ;
                            }
                            whereClause += ' ' + sf.apiname + ' ' + op + ' ' + sf.value; 
                            System.debug('**** whereClause with VisitNames: ' + sf.apiname + ':' + sf.value + ':' + whereClause);
                        }
                    }

                    // We need to handle CurrTerr in a different way
                    if (sf.apiname != 'CurrTerr' && sf.apiname != 'Name' && sf.value != '' && sf.value != 'null' && sf.value != null) {
                        String field = sf.apiname ;
                        String op = '=' ;
                        String value = sf.value ;
                        // Escape quotes in value
                        value = value.replace('\'', '\\\'') ;
    
                        if (sf.obj == 'Account') {
                            field = 'Account_vod__r.' + field ;
                        }
                        else if (sf.obj == 'User') {
                            field = 'CreatedBy.' + field ;
                        }

                        if (sf.opt_value == 'Starts With') {
                            op = 'like' ;
                            value = value + '%' ;
                        }
                        if (sf.opt_value == 'Contains') {
                            op = 'like' ;
                            value = '%' + value + '%' ;
                        }

                        if (sf.is_phone) {
                            op = 'like' ;
                            value = getPhoneRegex(value) ;
                        }
    
                        if (sf.is_pseduodate) {
                            String [] mdy = value.split('/') ;
                            value = mdy[2] + '-' + mdy[0] + '-' + mdy[1] ;
                        }
    
                        // Check for datetime field, use DAY_ONLY function
                        if (sf.is_datetime) {
                            field = 'DAY_ONLY(' + field + ')' ;
                        }
 
                        if (!sf.no_quote && field != 'Name') {
                            value = '\'' + value + '\'' ;
                        }
                        
                        system.debug('value4:' + value);                    
                        
                        if (whereClause != '') {
                            whereClause += ' AND ' ;
                        }
    
                        whereClause += ' ' + field + ' ' + op + ' ' + value;
                    }
                    else if (sf.apiname == 'CurrTerr' && sf.value != '' && sf.value != 'null' && sf.value != null) {
                        // First, find the Territory
                        Territory [] terrs = [select Id from Territory where Name = :sf.value] ;
                        if (terrs.size() == 0) {
                            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'The specified Current Territory cannot be found.'));
                            return null ;
                        }
                        String terrId = terrs[0].Id ;
                        // Find the User aligned with territory
                        UserTerritory [] uts = [select UserId from UserTerritory where TerritoryId = :terrId order by Id asc] ;
                        if (uts.size() == 0) {
                            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'There is no rep aligned with the  specified Current Territory.'));
                            return null ;
                        }
                        String userId = uts[0].UserId ;
                        if (whereClause != '') {
                            whereClause += ' AND ' ;
                        }
                        whereClause += ' CreatedById = \'' + userId + '\'' ;
                    }
                }

                system.debug('where clause is:' + whereClause);
                if (whereClause == '' && transactionIds == '') {
                    ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'At least one search criteria other than Call Date must be entered'));
                    return null ;
                }
                else if (whereClause == '' && transactionids != ''){
                    ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'At least one valid Sample Transaction ID other than Call Date must be entered'));
                    return null ;
                }

                String origCDF = callDateFrom ;
                String origCDT = callDateTo ;
                date date1 = date.parse(callDateFrom);
                date date2 = date1.addDays(-1) ;
                Time myTime = Time.newInstance(0, 0, 0, 0);
                Datetime lastmoddate = datetime.newInstance(date2,myTime) ;
                String lastmoddatestr = lastmoddate.format('yyyy-MM-dd\'T\'HH:mm:ss.\'000Z\'') ;
                String [] mdy = callDateFrom.split('/') ;
                callDateFrom = mdy[2] + '-' + mdy[0] + '-' + mdy[1] ;
                mdy = callDateTo.split('/') ;
                callDateTo = mdy[2] + '-' + mdy[0] + '-' + mdy[1] ;
                whereClause += ' and LastModifiedDate >= ' + lastmoddatestr + ' and Call_Date_vod__c >= ' + callDateFrom.replace('/','-') + ' and Call_Date_vod__c <= ' + callDateTo.replace('/','-') ;
                callDateFrom = origCDF ;
                callDateTo = origCDT ;
    
                // Add any extra condtions
                if (css.Extra_Condtion__c != '' && css.Extra_Condtion__c != null) {
                    whereClause += ' and ' + css.Extra_Condtion__c ;
                }
            }
        
            system.debug('**** where clause is: ' + whereClause);

            iframeSrc = '/apex/searchCalls?where_clause=' + whereClause ;
            system.debug('iframeSrc is:'+iframeSrc);
            
            PageReference pageRef = new PageReference('/apex/searchCalls?where_clause=' + whereClause) ;
            pageRef.setRedirect(true) ;
            return pageRef ;
        }
        catch (Exception ex) {
            ApexPages.addMessages(ex);
        }
        return null;
    }


    // Delete ALL tmpsigXXXX.png documents 
    public PageReference deleteTmpSigFiles() {
        transient Document[] deleteDocs = [SELECT Id FROM Document WHERE Name LIKE 'tmpsig%' AND type = 'png' ];
        System.debug('**** Number of docs to delete:' + deleteDocs.size());
        if (deleteDocs.size() > 0) {
            try {
                Database.DeleteResult[] DR_Dels = Database.delete(deleteDocs);
                System.debug('**** Successfully deleted ' + deleteDocs.size() + ' tmpsigxxxx.png documents.');
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'Deleted ' + deleteDocs.size() + ' documents'));
            } catch (DmlException e) {
                System.debug('**** Error in deleting tmpsig documents');
                ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'Error in deleting tmpsigxxxx.png documents'));            
            }
            deleteDocs.clear();
        } else {
            ApexPages.addMessage (new ApexPages.Message(ApexPages.Severity.ERROR, 'There are no documents to delete'));
        }    
        return null;
    }
    
    private static String getPhoneRegex (String inph) {

        Pattern pt = Pattern.compile('[^0-9]');
        String [] res = pt.split(inph) ;
        String digits = '' ;
        for (Integer i = 0 ; i < res.size(); i++) {
        System.debug ('r1:' + res[i]) ;
            digits = digits + res[i] ;
        }
        System.debug ('r2:' + digits) ;
        String retval= '';

        if (digits.length() == 10) {
            retval = '%' + digits.substring(0,3) + '%' + digits.substring(3,6) + '%' + digits.substring (6,10) + '%' ;
        }
        else if (digits.length() == 7) {
            retval = '%' + digits.substring(0,3) + '%' + digits.substring(3,7) + '%' ;
        }
        else if (digits.length() == 4) {
            retval = '%' + digits ;
        }
        else {
            retval = digits ;
        }
System.debug ('r3:' + retval) ;
        return retval ;
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


    public class searchField {

        public String obj {get;set;}
        public String label {get;set;}
        public String apiname {get;set;}
        public String value {get;set;}
        public String alvalue {get;set;}
        public String opt_value {get;set;}
        public Boolean is_picklist {get;set;}
        public Boolean is_reference {get;set;}
        public Boolean is_phone {get;set;}
        public Boolean is_bool {get;set;}
        public Boolean is_date {get;set;}
        public Boolean is_datetime {get;set;}
        public Boolean is_pseduodate {get;set;}
        public Boolean is_acctlookup {get;set;}
        public Boolean has_opt {get;set;}
        public Boolean has_sw {get;set;}
        public Boolean has_cn {get;set;}
        public Boolean has_em {get;set;}
        public Boolean no_quote {get;set;}
        public Boolean no_opt {get;set;}
        public Boolean no_picklist {get;set;}
        public List<SelectOption> plist {set;get;}
        public List<SelectOption> opt_options {set;get;}

        public searchField (String l, String a) {
            // For special fields
            label = l ;
            apiname = a ;
             is_picklist= false;
             is_reference= false;
             is_phone= false;
             is_bool= false;
             is_date= false;
             is_datetime= false;
             is_pseduodate= false;
             is_acctlookup= false;
             has_opt= false;
             has_sw= false;
             has_cn= false;
             has_em= false;
             no_quote= false;
             no_opt= true;
             no_picklist= true;
        }

        public searchField (String o, Schema.DescribeFieldResult dfr, String opts) {
System.debug ('opts is ' + opts) ;
            obj = o ;
            String prelabel = '' ;
            if (obj == 'Account') {
                prelabel = 'Customer ' ;
            }
            else if (obj == 'User') {
                prelabel = 'Rep\'s ' ;
            }
            label = prelabel + dfr.getLabel() ;
            apiname = dfr.getName () ;
            value = '' ;
            opt_value = '' ;
            has_sw = false ;
            has_cn = false ;
            has_em = false ;
            is_acctlookup = false ;
            is_reference = (dfr.getType().name() == 'Reference') ;
            is_date = (dfr.getType().name() == 'Date') ;
            is_datetime = (dfr.getType().name() == 'Datetime') ;
            is_pseduodate = is_date || is_datetime ;
            is_picklist = (dfr.getType().name() == 'Picklist') ;
            is_phone = (dfr.getType().name() == 'Phone') ;
            is_bool = (dfr.getType().name() == 'Boolean') ;
            no_quote = (dfr.getType().name() == 'Boolean' ||
                        dfr.getType().name() == 'Currency' ||
                        dfr.getType().name() == 'Date' ||
                        dfr.getType().name() == 'Datetime' ||
                        dfr.getType().name() == 'Double' ||
                        dfr.getType().name() == 'Integer' ||
                        dfr.getType().name() == 'Percent' ||
                        dfr.getType().name() == 'Time') ;
            if (is_picklist) {
                plist = new List<SelectOption> () ;
                List<Schema.PicklistEntry> P = dfr.getPicklistValues();
                plist.add(new SelectOption('','None')) ;
                for (Schema.PicklistEntry pe : P) {
                    plist.add(new SelectOption(pe.getValue(),pe.getLabel()));
                }
            }
            if (is_reference) {
                // Make it a picklist of names
                is_picklist = true ;
                // Remove trailing ' ID' from label
                label = label.replaceFirst(' ID$', '') ;
                List <Schema.sObjectType> sobjs = dfr.getReferenceTo() ;
                String objName = sobjs[0].getDescribe().getName() ;
System.debug ('objName is ' + objName) ;
                if (objName == 'RecordType') {
                    // Already calculated
                    if (obj == 'Account') {
                        plist = queryCalls.acctRecTypesPlist.clone() ;
                    }
                    else if (obj == 'Call2_vod__c') {
                        plist = queryCalls.callRecTypesPlist.clone() ;
                    }
                }
                else if (objName != 'Account') {
                    // All other references
                    plist = new List<SelectOption> () ;
                    plist.add(new SelectOption('','None')) ;
                    String query = 'select Id,Name from ' + objName + ' order by Name' ;
                    for (sObject ox : Database.query(query)) {
                        plist.add(new SelectOption((String)ox.get('Id'), (String)ox.get('Name'))) ;
                    }
                }
                else {
                    // objName is Account.  We don't want to display thousands or more Account names in a picklist,
                    // so we handle this by creating a link to aonther search page.
                    is_acctlookup = true ;
                }
System.debug ('is_acctlookup is ' + is_acctlookup) ;
            }
            has_opt = (opts != 'x') ;
            if (has_opt) {
                opt_options = new List<SelectOption>();
                if (opts.contains('s') || opts.contains('S')) {
                    opt_options.add(new SelectOption('Starts With','Starts With'));
                }
                if (opts.contains('S')) {
                    opt_value = 'Starts With' ;
                } 
                if (opts.contains('c') || opts.contains('C')) {
                    opt_options.add(new SelectOption('Contains','Contains'));
                }
                if (opts.contains('C')) {
                    opt_value = 'Contains' ;
                } 
                if (opts.contains('e') || opts.contains('E')) {
                    opt_options.add(new SelectOption('Exact Match','Exact Match'));
                }
                if (opts.contains('E')) {
                    opt_value = 'Exact Match' ;
                } 
System.debug ('opts are : ' + has_sw + '/' + has_em + '/' + has_cn) ;
            }
            no_opt = !has_opt;
            no_picklist = !is_picklist ;
        }
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
    
}