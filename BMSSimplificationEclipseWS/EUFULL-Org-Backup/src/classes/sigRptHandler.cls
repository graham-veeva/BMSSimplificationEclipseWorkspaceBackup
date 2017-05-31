public class sigRptHandler
{
    public Document mySigDoc;
    private String folderId ;
    public String rptName {set;get;}
    public String mode {get;set;}

    public sigRptHandler () {
        folderId = [select Id from Folder where Name='SignatureReports'].Id ;
        mode = 'view' ;
        rptName = ApexPages.currentPage().getParameters().get('rptName');
    }

    public Document getmySigDoc()
    {
        mySigDoc = new Document();
        return mySigDoc;
    }
   
    public PageReference Savedoc()
    {
        try {
            // Rename current doc
            Document currentDoc = [select Id,Name,Description,CreatedDate from Document where folderId = :folderId and Name = :rptName for update] ;
            currentDoc.Name = currentDoc.Name.replace('Latest', 'Created ') + currentDoc.CreatedDate.format('yyyyMMddHHmmss', 'CST') ;
            currentDoc.Description = 'This is a previous version of a template used for the signature reports. This document should NOT be edited or deleted.' ;
            update currentDoc ;
            // Insert new doc
            mySigDoc.folderid = folderId;
            mySigDoc.Name = rptName ;
            mySigDoc.Description = 'This is a template used for the signature reports. This document should NOT be edited from the Documents tab, but only from the Signature Reports tab.' ;
            insert mySigDoc;
            mode = 'view' ;
            return NULL;
        } catch (Exception e) {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
          return null;
        }
    }   

    public PageReference doUpload()
    {
        mode = 'edit' ;
        return null ;
    }

    public PageReference cancel()
    {
        mode = 'view' ;
        return null ;
    }


    public Document [] getsigRpts () {
        return [select Id, Name, Description, BodyLength, CreatedDate, LastModifiedDate from Document where FolderId = :folderId order by Name desc] ;
    }
       
       
}