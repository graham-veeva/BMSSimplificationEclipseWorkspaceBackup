/*
* Name: BMS_CN_RetargetingExt
* Description: Retargeting VF controller extension
* Author: Roy Zhang
* Created Date: 02/28/2013
* Last Modified Date: 06/20/2013
*/
public without sharing class BMS_CN_RetargetingExt {
	public Retargeting_BMS_CN__c retargeting{get;set;}
	public List<Account> actList {get; set;}
	
	/* Common method */
	//Get period
	private String getPeriod() {
		Date nextMonth = Date.Today().addMonths(1);
	    String s=String.ValueOf(nextMonth);
	    String[] ymd = s.split('-', -1);
	    return (ymd[0]+'/'+ymd[1]);
	}

	// Constructor
	public BMS_CN_RetargetingExt (ApexPages.StandardController stdController) {
		
		this.retargeting = (Retargeting_BMS_CN__c )stdController.getRecord();
    }
    
    
    /* Page Event */
    // Search account list
	public PageReference search() {
		// Get Hospital ID
		Id hospId = [SELECT
						Id,
						Account_BMS_CN__c
					FROM
						Retargeting_Hospital_BMS_CN__c
					WHERE
						Id =: retargeting.Retargeting_Hospital_BMS_CN__c].Account_BMS_CN__c;
		// Search customer list
		String strDocName = '%'+retargeting.Doctor_Name_BMS_CN__c+'%';
		actList = [SELECT
						Id,
						Lastname,
						Department_BMS_CN__c,
						Primary_Parent_vod__c,
						Primary_Parent_vod__r.name,
						Primary_Parent_vod__r.BP_ID_BMS_CORE__c,
						Gender_vod__c,
						Administrative_Title_BMS_CN__c,
						Technical_Title_BMS_CN__c,
						BP_ID_BMS_CORE__c
					FROM
						Account
					WHERE
						Primary_Parent_vod__c =: hospId AND
						Department_BMS_CN__c =: retargeting.Department_BMS_CN__c AND
                        Lastname LIKE : strDocName AND
                        IsActive_BMS_CN__c = true AND
                        RecordTypeId IN (SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'BMS - Individual')
						LIMIT 1000];
						
		// Search result exceed 1000 records     
        If(actList.size() == 1000) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '检索结果超过1000条，仅返回前1000条记录'));
		}
		return null;
    }

	// Add an existing customer
    public PageReference add() {
    	// Check Re-targeting window flag
    	bms_cn_setting__c cnSetting = bms_cn_setting__c.getInstance(UserInfo.getProfileId());
    	if(cnSetting.Enable_Retargeting_BMS_CN__c <> true) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '请在目标客户调整期间调整目标客户！'));
			return null; 	
    	}   	
    	
    	// Get Period
    	String strPeriod = getPeriod();
    	Id strRecTypId = [SELECT Id FROM RecordType WHERE SobjectType = 'Retargeting_BMS_CN__c' AND Name = 'Edit Retargeting'].Id;    	
    	User currentUser = [SELECT Id, BU_BMS_CN__c, Next_Month_Territory_BMS_CN__c FROM User WHERE Id =: UserInfo.getUserId()];
    	String strNextTerr = currentUser.Next_Month_Territory_BMS_CN__c;
    	String strBU = currentUser.BU_BMS_CN__c;
    	
    	// Check BU info
    	if(strBU == null || strBU =='') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '没有BU信息，请联系管理员！'));
			return null;   		
    	}
    	
    	// Check next cycle terr exist or not
    	if(strNextTerr == null || strNextTerr =='') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '没有下月辖区信息，请联系管理员！'));
			return null;   		
    	}
    	
    	Account newDoc;
		//Get Account                                                                                   
		for(Account doc : actList) {                    
			if(doc.Id == ApexPages.currentPage().getParameters().get('MasterID')) {
				newDoc = doc;                           
			}
		}
    	if(newDoc == null) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '无法添加该医生，请联系管理员！'));
    		return null;
    	}
    	
    	// Check in next customer list or not
    	Integer iCount = [SELECT
    						COUNT()
    					FROM
    						Retargeting_BMS_CN__c
    					WHERE
    						Period_BMS_CN__c =: strPeriod AND
    						Doctor_BMS_CN__c =: newDoc.Id AND
    						BU_BMS_CN__c =: strBU AND
    						Territory_BMS_CN__c =: strNextTerr AND
    						OwnerId =: UserInfo.getUserId() AND
    						Status_BMS_CN__c IN ('Saved','Submitted','Verified','Approved')];
    	if(iCount > 0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '该医生已存在于下月目标列表中'));
			return null;    		
    	}
    	
    	Retargeting_BMS_CN__c newTarget = new Retargeting_BMS_CN__c();
    	
    	newTarget.Active_BMS_CN__c = true;
    	newTarget.BU_BMS_CN__c = strBU;    	
    	newTarget.Administrative_Title_BMS_CN__c = newDoc.Administrative_Title_BMS_CN__c;
    	newTarget.Administrative_Title_Original_BMS_CN__c = newDoc.Administrative_Title_BMS_CN__c;
    	newTarget.Department_BMS_CN__c = newDoc.Department_BMS_CN__c;
    	newTarget.Department_Original_BMS_CN__c = newDoc.Department_BMS_CN__c;
    	newTarget.Doctor_BMS_CN__c = newDoc.Id;
    	newTarget.Doctor_ID_BMS_CN__c = newDoc.BP_ID_BMS_CORE__c;
    	newTarget.Doctor_Name_BMS_CN__c = newDoc.LastName;
    	newTarget.Gender_BMS_CN__c = newDoc.Gender_vod__c;
    	newTarget.Gender_Original_BMS_CN__c = newDoc.Gender_vod__c;
    	newTarget.Hospital_BMS_CN__c = newDoc.Primary_Parent_vod__c;
    	newTarget.Hospital_Original_BMS_CN__c = newDoc.Primary_Parent_vod__c;
    	newTarget.Hospital_ID_BMS_CN__c = newDoc.Primary_Parent_vod__r.BP_ID_BMS_CORE__c;
    	newTarget.Inventiv_Check_BMS_CN__c = false;
    	newTarget.Period_BMS_CN__c = strPeriod;
    	newTarget.Retargeting_Hospital_BMS_CN__c = retargeting.Retargeting_Hospital_BMS_CN__c;
    	newTarget.Retargeting_Hospital_Original_BMS_CN__c = retargeting.Retargeting_Hospital_BMS_CN__c;  
    	newTarget.Status_BMS_CN__c = 'Saved';
    	newTarget.Technical_Title_BMS_CN__c = newDoc.Technical_Title_BMS_CN__c;
    	newTarget.Technical_Title_Original_BMS_CN__c = newDoc.Technical_Title_BMS_CN__c;
    	newTarget.Territory_BMS_CN__c = strNextTerr;
    	newTarget.Action_Type_BMS_CN__c = 'EDIT';
    	newTarget.OwnerId = UserInfo.getUserId();
    	newTarget.RecordTypeId = strRecTypId;
		insert newTarget;
		
		// Redirect to edit page of added customer
		Schema.DescribeSObjectResult sObjResult = Retargeting_BMS_CN__c.sObjectType.getDescribe();
		PageReference newPage = new ApexPages.StandardController(newTarget).edit();
		newPage.setRedirect(true);
		return newPage;
    }
    
    // create a new doctor
    public PageReference create() {
    	// Check Re-targeting window flag
    	bms_cn_setting__c cnSetting = bms_cn_setting__c.getInstance(UserInfo.getProfileId());
    	if(cnSetting.Enable_Retargeting_BMS_CN__c <> true) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '请在目标客户调整期间调整目标客户！'));
			return null; 	
    	}
    	
    	// Get Period
    	String strPeriod = getPeriod();
    	Id strRecTypId = [SELECT Id FROM RecordType WHERE SobjectType = 'Retargeting_BMS_CN__c' AND Name = 'Add Retargeting'].Id;    	
    	User currentUser = [SELECT Id, BU_BMS_CN__c, Next_Month_Territory_BMS_CN__c FROM User WHERE Id =: UserInfo.getUserId()];
    	String strNextTerr = currentUser.Next_Month_Territory_BMS_CN__c;
    	String strBU = currentUser.BU_BMS_CN__c;
    	
    	// Check BU info
    	if(strBU == null || strBU =='') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '没有BU信息，请联系管理员！'));
			return null;   		
    	}
    	
    	// Check next cycle terr exist or not
    	if(strNextTerr == null || strNextTerr =='') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '没有下月辖区信息，请联系管理员！'));
			return null;   		
    	}
    	
    	Retargeting_BMS_CN__c newTarget = new Retargeting_BMS_CN__c();
    	
    	Account hosp = [SELECT Id, Name, BP_ID_BMS_CORE__c FROM Account WHERE Id IN (SELECT Account_BMS_CN__c FROM Retargeting_Hospital_BMS_CN__c WHERE Id =: retargeting.Retargeting_Hospital_BMS_CN__c)];
    	    	
    	newTarget.Active_BMS_CN__c = true;
    	newTarget.BU_BMS_CN__c = strBU;
    	newTarget.Department_BMS_CN__c = retargeting.Department_BMS_CN__c;
    	newTarget.Department_Original_BMS_CN__c = retargeting.Department_BMS_CN__c;
    	newTarget.Doctor_Name_BMS_CN__c = retargeting.Doctor_Name_BMS_CN__c;
    	newTarget.Hospital_BMS_CN__c = hosp.Id;
    	newTarget.Hospital_Original_BMS_CN__c = hosp.Id;
    	newTarget.Hospital_ID_BMS_CN__c = hosp.BP_ID_BMS_CORE__c;
    	newTarget.Inventiv_Check_BMS_CN__c = true;
    	newTarget.Period_BMS_CN__c = strPeriod;
    	newTarget.Retargeting_Hospital_BMS_CN__c = retargeting.Retargeting_Hospital_BMS_CN__c;   
    	newTarget.Retargeting_Hospital_Original_BMS_CN__c = retargeting.Retargeting_Hospital_BMS_CN__c;  
    	newTarget.Status_BMS_CN__c = 'Saved';
    	newTarget.Territory_BMS_CN__c = strNextTerr;
    	newTarget.Action_Type_BMS_CN__c = 'ADD';
    	newTarget.OwnerId = UserInfo.getUserId();
    	newTarget.RecordTypeId = strRecTypId;
		insert newTarget;
    	
    	// Redirect to edit page of added customer
		Schema.DescribeSObjectResult sObjResult = Retargeting_BMS_CN__c.sObjectType.getDescribe();
		PageReference newPage = new ApexPages.StandardController(newTarget).edit();
		newPage.setRedirect(true);
		return newPage;
    }
}