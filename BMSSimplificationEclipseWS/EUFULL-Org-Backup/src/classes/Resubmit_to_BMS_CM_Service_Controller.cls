public class Resubmit_to_BMS_CM_Service_Controller {
    String resubmitStatus = 'submitting...';
    Id eLogId = null;
    
    ApexPages.StandardController myController = null;
    
    public Resubmit_to_BMS_CM_Service_Controller(ApexPages.StandardController controller) {
    	myController = controller;
        eLogId = controller.getId();
    }


    public PageReference reSubmitToBMSCM() {
        // hardcoding for testing
	
        Error_log_bms__c eLog = [select id, external_id__c, related_account__c, related_address__c, Resolved__c from error_log_bms__c where id=:myController.getId() ];
        
        CustomerMasterWrapper_BMS.callWebService(new Set<ID>{eLog.related_address__c });
        Account myAcc    		= [select id, bp_id__c from account where id=:eLog.related_account__c];
        Address_vod__c myAdd    = [select id, external_id_vod__c from address_vod__c where id=:eLog.Related_Address__c];
        
        if(myAcc.bp_id__c != null && myAdd.external_id_vod__c != null){
            resubmitStatus = 'Re-submit success..';
            eLog.Resolved__c = true;
            update eLog;          	                                   
        } else {
          	resubmitStatus = 'Re-submit failed..';
        }     
        return null;
    }
   
    public String getResubmitStatus(){
        return resubmitStatus;
    }

}