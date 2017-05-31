public class SigRptCfg {

    private Map<String, Schema.SObjectField> acctFieldMap ;
    private Map<String, Schema.SObjectField> callFieldMap ;
    private Map<String, Schema.SObjectField> userFieldMap ;
    private Call_Search_Settings__c CSS ;
    public String search_selfieldsTxt {get;set;}
    public String res_selfieldsTxt {get;set;}
    public String extraCondtions {get;set;}
    public String mode {get;set;}
    public List<SelectOption> searchAcctFields {get;set;}
    public List<SelectOption> searchCallFields {get;set;}
    public List<SelectOption> searchUserFields {get;set;}
    private List<SelectOption> searchSelFields ;
    public List<SelectOption> resAcctFields {get;set;}
    public List<SelectOption> resCallFields {get;set;}
    public List<SelectOption> resUserFields {get;set;}
    private List<SelectOption> resSelFields ;
    private Set <String> currSearchFieldSet ;
    private Set <String> currResFieldSet ;
    public List <String> sarray1 {get;set;}
    public List <String> sarray2 {get;set;}

    public SigRptCfg () {
        mode = 'view' ;
        sarray1 = new List<String>();
        sarray2 = new List<String>();
        searchSelFields = new List<SelectOption>();
        resSelFields = new List<SelectOption>();
        acctFieldMap = Schema.SObjectType.Account.fields.getMap();
        callFieldMap = Schema.SObjectType.Call2_vod__c.fields.getMap();
        userFieldMap = Schema.SObjectType.User.fields.getMap();
        CSS = [select Id, Result_Field_Set__c,Search_Field_Set__c,Extra_Condtion__c from Call_Search_Settings__c where name = 'Main'] ;
        extraCondtions = CSS.Extra_Condtion__c ;
        currSearchFieldSet = new Set<String> () ;
        if (CSS.Search_Field_Set__c != null && CSS.Search_Field_Set__c != '') {
            for (String xfld : CSS.Search_Field_Set__c.split(',')) {
                String fld = xfld.replaceAll(':.*', '') ;
                currSearchFieldSet.add(fld) ;
                String apiname = fld.replaceAll('.*\\.', '') ;
                String label ;
                String labelPrefix ;
                String elemId ;
                String objPrefix ;
                if (fld == 'CurrTerr') {
                    label = 'Current Territory' ;
                    labelPrefix = '' ;
                    elemId = 'p1:f1:pb1:pbs1:search_selspec' ;
                    objPrefix = '' ;
                }
                else if (fld.startsWith('ACCT.')) {
                    label = acctFieldMap.get(apiname).getDescribe().getLabel() ;
                    labelPrefix = 'Account ' ;
                    elemId = 'p1:f1:pb1:pbs1:search_selacct' ;
                    objPrefix = 'ACCT.' ;
                }
                else if (fld.startsWith('USER.')) {
                    label = userFieldMap.get(apiname).getDescribe().getLabel() ;
                    labelPrefix = 'Rep ' ;
                    elemId = 'p1:f1:pb1:pbs1:search_seluser' ;
                    objPrefix = 'USER.' ;
                }
                else {
                    label = callFieldMap.get(apiname).getDescribe().getLabel() ;
                    labelPrefix = '' ;
                    elemId = 'p1:f1:pb1:pbs1:search_selcall' ;
                    objPrefix = '' ;
                }
                searchSelFields.add (new SelectOption(objPrefix + apiname + '%' + elemId + '%' + labelPrefix,labelPrefix + label)) ;
            }
        }
        currResFieldSet = new Set<String> () ;
        if (CSS.Result_Field_Set__c != null && CSS.Result_Field_Set__c != '') {
            for (String fld : CSS.Result_Field_Set__c.split(',')) {
                currResFieldSet.add(fld) ;
                String apiname = fld.replaceAll('.*\\.', '') ;
                String label ;
                String labelPrefix ;
                String elemId ;
                String objPrefix ;
                if (fld.startsWith('ACCT.')) {
                    label = acctFieldMap.get(apiname).getDescribe().getLabel() ;
                    labelPrefix = 'Account ' ;
                    elemId = 'p1:f1:pb1:pbs2:res_selacct' ;
                    objPrefix = 'ACCT.' ;
                }
                else if (fld.startsWith('USER.')) {
                    label = userFieldMap.get(apiname).getDescribe().getLabel() ;
                    labelPrefix = 'Rep ' ;
                    elemId = 'p1:f1:pb1:pbs2:res_seluser' ;
                    objPrefix = 'USER.' ;
                }
                else {
                    label = callFieldMap.get(apiname).getDescribe().getLabel() ;
                    labelPrefix = '' ;
                    elemId = 'p1:f1:pb1:pbs2:res_selcall' ;
                    objPrefix = '' ;
                }
                resSelFields.add (new SelectOption(objPrefix + apiname + '%' + elemId + '%' + labelPrefix,labelPrefix + label)) ;
            }
        }
        searchAcctFields = getSelectListForObj(acctFieldMap, 'p1:f1:pb1:pbs1:search_selacct', 'Account ', 'ACCT.', currSearchFieldSet) ;
        searchCallFields = getSelectListForObj(callFieldMap, 'p1:f1:pb1:pbs1:search_selcall', '', '', currSearchFieldSet) ;
        searchUserFields = getSelectListForObj(userFieldMap, 'p1:f1:pb1:pbs1:search_seluser', 'Rep ', 'USER.', currSearchFieldSet) ;
        resAcctFields = getSelectListForObj(acctFieldMap, 'p1:f1:pb1:pbs2:res_selacct', 'Account ', 'ACCT.', currResFieldSet) ;
        resCallFields = getSelectListForObj(callFieldMap, 'p1:f1:pb1:pbs2:res_selcall', '', '', currResFieldSet) ;
        resUserFields = getSelectListForObj(userFieldMap, 'p1:f1:pb1:pbs2:res_seluser', 'Rep ', 'USER.', currResFieldSet) ;
    }


    private List<SelectOption> getSelectListForObj (Map<String, Schema.SObjectField> fieldMap, String elemId, String labelPrefix, String objPrefix, Set <String> currFieldSet) {

        List<SelectOption> options = new List<SelectOption>();
        for (String fld : fieldMap.keySet()) {
                String name = fieldMap.get(fld).getDescribe().getName() ;
                String label = fieldMap.get(fld).getDescribe().getLabel() ;
                String dataType = fieldMap.get(fld).getDescribe().getType().name();
                // Don't offer Signature_vod__c as an option
                if (name == 'Signature_vod__c') {
                    continue ;
                }
                // For search, skip Call_Datetime_vod__c and Call_Date_vod__c, as these are always displayed
                if (elemId == 'p1:f1:pb1:pbs1:search_selcall' && (name == 'Call_Datetime_vod__c' || name == 'Call_Date_vod__c')) {
                    continue ;
                }
                if (dataType == 'Reference') {
                    List <Schema.sObjectType> sobjs = fieldMap.get(fld).getDescribe().getReferenceTo() ;
                    String objName = sobjs[0].getDescribe().getName() ;
                    // Skip any refs to Account, Address_vod__c or Call2_vod__c
                    if (objName == 'Account' || objName == 'Address_vod__c' || objName == 'Call2_vod__c') {
                        continue ;
                    }
                }
                if (!currFieldSet.contains(objPrefix + name)) {
                    options.add(new SelectOption(objPrefix + name + '%' + elemId + '%' + labelPrefix,label));
                }
        }
        return SortOptionList(options) ;
    }


    public List<SelectOption> getSpecialFields () {

        List<SelectOption> options = new List<SelectOption>();
        if (!currSearchFieldSet.contains('CurrTerr')) {
            searchSelFields.add (new SelectOption('CurrTerr%p1:f1:pb1:pbs1:search_selspec%','Current Territory'));
        }
        return options ;

    }

    public List<SelectOption> getSearchSelFields () {
        return searchSelFields ;
    }

    public List<SelectOption> getResSelFields () {
        return resSelFields ;
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
        return xList; 
    }  

    public PageReference editmode() {
        mode = 'edit' ;
        return null ;
    }

    public PageReference viewmode() {
        mode = 'view' ;
        return null ;
    }

    public PageReference save() {
        try {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Hello Fred.'))  ;
System.debug ('hk:' + search_selfieldsTxt) ;
            CSS.Result_Field_Set__c = res_selfieldsTxt ;
            CSS.Search_Field_Set__c = search_selfieldsTxt ;
            CSS.Extra_Condtion__c = extraCondtions ;
            update CSS ;
            String currentRequestURL = URL.getCurrentRequestUrl().toExternalForm();
            PageReference pageRef = new PageReference(currentRequestURL) ;
            pageRef.setRedirect(true) ;
            return pageRef ;
        }
        catch (Exception ex) {
            ApexPages.addMessages(ex);
        }
        return null ;
    }



}