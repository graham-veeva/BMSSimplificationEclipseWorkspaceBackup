public class AttachmentsComponentController{

    public boolean userHasViewEncDataPermission{get;set;}
    public String currentUserID{get;set;}
    public String objID{get;set;}
    public String objName{get;set;}
    public List<Attachment> attachments{get;set;}
    public List<Attachment> ownerAttachments{get;set;}
    public String confToken{get;set;}
    public List<PermissionSet> permissionSets{get;set;}
    public boolean canViewEncryptedData{get;set;}
    public String SelectedAttachmentId{get;set;}
    public String query{get;set;}
    public boolean hasResults{get;set;}
    
    public List<notesAndAttachments> notesAndAttachmentsList{get;set;}

    public AttachmentsComponentController(){
        getData();
    }
    
    public AttachmentsComponentController(ApexPages.StandardController controller) {
        getData();
    }
    
    public void getData(){
        canViewEncryptedData = false;
        
        notesAndAttachmentsList = new List<notesAndAttachments>();
        
        // get the ID of the current user
        currentUserID = UserInfo.getUserId();
        
        List<PermissionSetAssignment> perSetAssWithViewEncryptedData = [SELECT Id,Assignee.Name,Assignee.Profile.Name,PermissionSet.Label
            FROM PermissionSetAssignment
            WHERE PermissionSet.PermissionsViewEncryptedData = true AND Assignee.ID=:currentUserID];
        
        if(perSetAssWithViewEncryptedData.size() > 0){canViewEncryptedData = true;}
        
        // get the ID of the object
        objID = ApexPages.currentPage().getParameters().get('ID');
        
        ID myUknownObjectID = Id.valueOf(objID);
        String type = myUknownObjectID.getSObjectType().getDescribe().getName();
        
        String qry = 'SELECT Name FROM ' + type + ' WHERE ID = \'' + objID +'\'';
        query = qry;
        
        List<sObject> nameList = Database.query(qry);
        
        if(nameList.size() > 0){
            objName = string.valueOf(nameList[0].get('Name'));
        }
        
        //sObject myUnknownObj = new sObject();
        //objName = String.valueOf(myUnknownObj.get('Name'));
        
        
        // get the attachments and notes from this object
        
        if(canViewEncryptedData == true){
            attachments = [SELECT Id,Name,LastModifiedDate,CreatedBy.name,CreatedBy.ID FROM Attachment WHERE ParentID = :objID];
        }else{
           attachments = [SELECT Id,Name,LastModifiedDate,CreatedBy.name,CreatedBy.ID FROM Attachment WHERE ParentID = :objID AND CreatedBy.ID=:currentUserID];
        }
        
        //ownerAttachments = [SELECT Id,Name,LastModifiedDate,CreatedBy.name,CreatedBy.ID FROM Attachment WHERE ParentID = :objID AND CreatedBy.ID=:currentUserID];
        
        List<Note> notes = [SELECT Id,Title,LastModifiedDate,CreatedBy.name,CreatedBy.ID FROM Note WHERE ParentID = :objID];
        
        if(attachments.size() > 0){
            for(Attachment t: attachments){
                notesAndAttachmentsList.add(new notesAndAttachments(t, 'Attachment'));
            }
        }
        
        if(notes.size() > 0){
            for(Note n: notes){
                notesAndAttachmentsList.add(new notesAndAttachments(n, 'Note'));
            }
        }

        if(notesAndAttachmentsList.size() > 0){
            hasResults = true;
        }else{
            hasResults = false;
        }
        
        // get the confirmation token
        confToken = ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN');
    }
    
    public void deleteAtt(){
        system.debug('in the delete method');
        if(SelectedAttachmentId == null){return;}
        // search the list of attachments
        for(notesAndAttachments a: notesAndAttachmentsList){
            if(a.myObject.ID == SelectedAttachmentId){
                system.debug('Found the attachment');
                try{
                    delete a.myObject;
                    system.debug('deleted the attachment');
                    getData();
                } catch(Exception e){
                    system.debug('There was an exception:' + e);
                    // record was not deleted
                }
            }
        }
    }
    
    public class notesAndAttachments{
        
        private String mytype;
        private sObject myObject;
        
        public notesAndAttachments(sObject obj, String objectType){
            mytype = objectType;
            myObject = obj;
        }
        
        public String type{
            get{return myType;}
        }
        
        public String Name{
            get{
                if(mytype=='Attachment'){return String.valueOf(myObject.get('Name'));}
                return String.valueOf(myObject.get('Title'));
            }
        }
        
        public String ID{
            get{
                return String.valueOf(myObject.get('ID'));
            }
        }
        
        public String lastModified{
            get{
                return ((DateTime)myObject.get('LastModifiedDate')).format('MM/dd/yyyy hh:mm a');
            }
        }
        
        public String createdByName{
            get{
                return String.valueOf(myObject.getsObject('CreatedBy').get('Name'));
                
            }
        }
        
        public String createdByID{
            get{
                return String.valueOf(myObject.getsObject('CreatedBy').get('ID'));
            }
        }
    }
}