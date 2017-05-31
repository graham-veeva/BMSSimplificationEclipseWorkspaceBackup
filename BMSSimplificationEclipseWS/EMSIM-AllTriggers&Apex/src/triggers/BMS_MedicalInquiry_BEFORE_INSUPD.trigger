/*
* BMS_MedicalInquiry_BEFORE_INSUPD
* Author: Mark T. Boyer, Veeva Systems - Professional Services
* Date: 2013-03-25
* Summary:
*  This trigger is used to set the Product ID when a user selects the product from a picklist, or enters freehand
*  in the "other" field as specified as "Other Product/Compound (Entered Below)" on the picklist.
*
* Updated by: 
* Date: 
* Summary: 
*/
trigger BMS_MedicalInquiry_BEFORE_INSUPD on Medical_Inquiry_vod__c (before insert, before update) {
	
	static string OTHER_STR = 'Other Product/Compound (Entered Below)';
	Set<string> pNameList = new Set<string>();
	for(Medical_Inquiry_vod__c mi : trigger.new){
		pNameList.add(mi.Product__c == OTHER_STR ? mi.Other_Product_BMS__c : mi.Product__c);
	}

	map<String,String> pMap = new map<String,String>();
	List<Product_vod__c> prod = [SELECT p.Name, p.Id FROM Product_vod__c p WHERE p.Product_Type_vod__c = 'Detail' AND p.Name IN :pNameList];
	for(Product_vod__c p : prod){
		pMap.put(p.Name,p.Id);
	}
	for(Medical_Inquiry_vod__c mi : trigger.new){
		String productId = '';
		if(mi.Product__c != null) productId = pMap.get(mi.Product__c == OTHER_STR ? mi.Other_Product_BMS__c : mi.Product__c);
		if(productId != null) mi.Product_ID_BMS__c = productId;
	}

}