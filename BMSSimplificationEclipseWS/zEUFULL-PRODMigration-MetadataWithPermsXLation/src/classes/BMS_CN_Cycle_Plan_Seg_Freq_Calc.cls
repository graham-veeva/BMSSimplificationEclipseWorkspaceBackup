//Monthly Run - Repeated Run Supported
global with sharing class BMS_CN_Cycle_Plan_Seg_Freq_Calc implements Database.Batchable<sObject>, Database.Stateful
{
	//Author:           Nate Zhang
    //Create Date:      2013.04.01
    //Update Date: 		2013.04.16 Nate - Add update doctor segmentation(including OTC) for Product Metrics
    //Update Date: 		2013.04.17 Nate - Deactive the old cycle plan at the start method instead of finish method
    //Update Date:      2013.05.13 Nate - Update PMOfSpecificBU constructing way to avoid code statements governer limit
    //Update Date: 		2013.05.14 Nate - Update toBeUpdatedPM as function level variable to avoid Total number of records processed as a result of DML statements governer limit
    //Update Date:		2013.07.17 Nate - CRs Implementation(New CV DB ONCO-TAXOL ONCO-SPRYCEL HP OTC algorithm)
    final Date startDate = Date.today().toStartOfMonth();
	final Date endDate = Date.today().addMonths(1).toStartOfMonth().addDays(-1);
	String query;
	List<Segmentation_Calc_Param_Detail_BMS_CN__c> segDetails = new List<Segmentation_Calc_Param_Detail_BMS_CN__c>();
	List<Segmentation_Target_Frequency_BMS_CN__c> segTargetFrequencies = new List<Segmentation_Target_Frequency_BMS_CN__c>();
	Map<ID,String> DB_HospitalID_Rank = new Map<ID,String>(); // for DB only	
	Map<ID,String> CV_HospitalID_Rank = new Map<ID,String>(); // for CV only		
	//Map<String,Set<Product_Metrics_vod__c>> BU_PMs = new Map<String,Set<Product_Metrics_vod__c>>();
	//List<Cycle_Plan_Target_vod__c> toBeUpdated_CPT = new List<Cycle_Plan_Target_vod__c>();
	//List<Cycle_Plan_vod__c> toBeUpdated_CP = new List<Cycle_Plan_vod__c>();	
	
    global BMS_CN_Cycle_Plan_Seg_Freq_Calc () 
    {
    	segDetails = [SELECT Segmentation_Calc_Param_Master_BMS_CN__r.BU_BMS_CN__c, 
    						 Segmentation_Calc_Param_Master_BMS_CN__r.Type_BMS_CN__c, 
    						 Segmentation_Calc_Param_Master_BMS_CN__r.Weight_BMS_CN__c, 
    						 Segmentation_Calc_Param_Master_BMS_CN__r.Products_BMS_CN__c,
    						 Name,
    						 Target_Value_BMS_CN__c, 
    						 Value_Max_BMS_CN__c, 
    						 Value_Min_BMS_CN__c 
    				  FROM Segmentation_Calc_Param_Detail_BMS_CN__c];
    				  
    	segTargetFrequencies = [SELECT BU_BMS_CN__c, 
    								   HP_Usage_Level_BMS_CN__c, 
    								   OTC_Administrative_Title_BMS_CN__c, 
    								   OTC_Department_BMS_CN__c, 
    								   OTC_Outpatients_Monthly_Max_BMS_CN__c, 
    								   OTC_Outpatients_Monthly_Min_BMS_CN__c, 
    								   OTC_Pres_Amount_Monthly_Max_BMS_CN__c, 
    								   OTC_Pres_Amount_Monthly_Min_BMS_CN__c,
    								   Segmentation_BMS_CN__c,  
    								   Target_Frequency_BMS_CN__c, 
    								   Value_Max_BMS_CN__c, 
    								   Value_Min_BMS_CN__c,
    								   Algorithm_BMS_CN__c,
    								   Algorithm_Products_BMS_CN__c 
    							FROM Segmentation_Target_Frequency_BMS_CN__c];
    						
       for(Product_Metrics_vod__c pm :[ select Account_vod__c, 
       										   Hospital_Rank_BMS_CN__c,
       										   products_vod__r.BU_BMS_CN__c
       								     from Product_Metrics_vod__c 
       								     where  Account_vod__r.IsPersonAccount = false 
       								     and (products_vod__r.BU_BMS_CN__c = 'DB' or products_vod__r.BU_BMS_CN__c = 'CV') ])
   	   {
   	   	   if(pm.products_vod__r.BU_BMS_CN__c == 'DB')
   	   	   {
	   	   	   if(!DB_HospitalID_Rank.containsKey(pm.Account_vod__c))
	   	           DB_HospitalID_Rank.put(pm.Account_vod__c,pm.Hospital_Rank_BMS_CN__c);	
   	   	   }	
   	   	   else if(pm.products_vod__r.BU_BMS_CN__c == 'CV')	
   	   	   {
   	   	       if(!CV_HospitalID_Rank.containsKey(pm.Account_vod__c))
	   	           CV_HospitalID_Rank.put(pm.Account_vod__c,pm.Hospital_Rank_BMS_CN__c);
   	   	   }		     	
   	   }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
    	Date sDate = Date.today().addMonths(-1).toStartOfMonth();
	    Date eDate = Date.today().toStartOfMonth().addDays(-1);	    
	    
    	List<Cycle_Plan_vod__c> toBeDeActiviated = [Select Id, Active_vod__c  
    												FROM  Cycle_Plan_vod__c 
    												WHERE Start_Date_vod__c = :sDate 
    												AND   End_Date_vod__c = :eDate  
    												AND   Is_Owner_Sales_BMS_CN__c = true
    												AND   Active_vod__c = true];
    	for(Cycle_Plan_vod__c cp :toBeDeActiviated)
    		cp.Active_vod__c = false;
    		
    	update toBeDeActiviated;
    	
    	query = 'SELECT Id, ' +
                '       Active_vod__c, ' +
                '       Start_Date_vod__c, '+
                ' 		End_Date_vod__c, ' +
                '		Territory_vod__c,' +
                '       BU_BMS_CN__c,'	   +
                '		Algorithm_BMS_CN__c,'+
                '       OwnerId '	  +
                ' FROM  Cycle_Plan_vod__c ' +
                ' WHERE Start_Date_vod__c = :startDate  '+
                ' AND   End_Date_vod__c = :endDate  ' +
                ' AND   Is_Owner_Sales_BMS_CN__c = true ' +
                ' AND   Owner.IsActive = true ' +
                ' ORDER By Territory_vod__c' ;  
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> batch) 
    {  
    	string BU=null;
    	List<Product_Metrics_vod__c> PMOfSpecificBU = new List<Product_Metrics_vod__c>();   
    	Map<ID,List<Product_Metrics_vod__c>> Account_PMs = new Map<ID,List<Product_Metrics_vod__c>>();
        for (sObject obj : batch) 
        {
        	Set<Product_Metrics_vod__c> toBeUpdatedPM = new Set<Product_Metrics_vod__c>();
        	
        	Cycle_Plan_vod__c cp = (Cycle_Plan_vod__c)obj;
        	BU = cp.BU_BMS_CN__c;
        	if(String.isBlank(BU))
        		BU = [SELECT BU_BMS_CN__c from User where Id =:cp.OwnerId].BU_BMS_CN__c;        	
        	System.Debug('Nate: BU: '+ BU);        	
        	if(String.isNotBlank(BU)) // cannot calc cycle plan without BU
        	{
        		PMOfSpecificBU = [SELECT Id, Account_vod__c, Potential_BMS_CN__c
   								  FROM Product_Metrics_vod__c 
   								  WHERE  Account_vod__r.IsPersonAccount = true 
   								  AND products_vod__r.BU_BMS_CN__c = :BU 
   								  AND Account_vod__c in 
   								  (Select Cycle_Plan_Account_vod__c 
   								   from Cycle_Plan_Target_vod__c 
   								   where Cycle_Plan_vod__c =:cp.Id)
   								  ];    
   				for(Product_Metrics_vod__c pm :PMOfSpecificBU)		
   				{
   					if(!Account_PMs.containsKey(pm.Account_vod__c))
   						Account_PMs.put(pm.Account_vod__c,new List<Product_Metrics_vod__c>{pm});
   					Account_PMs.get(pm.Account_vod__c).add(pm);
   				}		     
        		List<Cycle_Plan_Target_vod__c> cpts = [SELECT Dr_Level_BMS_CN__c, 
        													  Algorithm_Products_BMS_CN__c,
        													  Cycle_Plan_Account_vod__c,
        													  Cycle_Plan_Account_vod__r.Primary_Parent_vod__c, 
        													  Cycle_Plan_Account_vod__r.Beds_BMS_CN__c, // CV(for Eliquis,Managed Beds)
        													  Cycle_Plan_Account_vod__r.Paraplatin_Level_BMS_CN__c, //ONCO-TAXOL(A/B/C)
        													  Cycle_Plan_Account_vod__r.L_Key_BMS_CN__c, //OTC
        													  Cycle_Plan_Account_vod__r.Is_KOL_BMS_CN__c, //ONCO-TAXOL
        													  Cycle_Plan_Account_vod__r.Taxol_Level_BMS_CN__c, //ONCO-TAXOL(A/B/C)
        													  Cycle_Plan_Account_vod__r.Monthly_Operations_BMS_CN__c, // CV(for Eliquis, Monthly Surgeries)
        													  Cycle_Plan_Account_vod__r.Is_Onglyza_Focus_Doctor_BMS_CN__c, // DB (for Onglyza focus doctor)
        													  Cycle_Plan_Account_vod__r.Department_BMS_CN__c, // CV DB ONC-TAXOL ONC-SPRYCEL HP
        													  Cycle_Plan_Account_vod__r.Decision_of_Beds_Index_BMS_CN__c, //CV
        													  Cycle_Plan_Account_vod__r.Weekly_Out_Patients_BMS_CN__c, // CV
        													  Cycle_Plan_Account_vod__r.Administrative_Title_BMS_CN__c, //DB ONC-TAXOL ONC-SPRYCEL
        													  Cycle_Plan_Account_vod__r.Type2_Diabetes_Patients_BMS_CN__c, //DB
        													  //Cycle_Plan_Account_vod__r.Monthly_Taxol_Prescription_BMS_CN__c, //ONC-TAXOL
        													  //Cycle_Plan_Account_vod__r.Monthly_Brand_Prescription_BMS_CN__c, // ONC-TAXOL       
        													  Cycle_Plan_Account_vod__r.Is_GIPAP_TIPAP_Dr_BMS_CN__c, //ONC-SPRYCEL
        													  Cycle_Plan_Account_vod__r.CML_Patients_BMS_CN__c, //ONC-SPRYCEL
        													  Cycle_Plan_Account_vod__r.Weekly_HBV_Out_patients_BMS_CN__c, //HP
        													  Cycle_Plan_Account_vod__r.HBV_Beds_BMS_CN__c, //HP
        													  Cycle_Plan_Account_vod__r.Technical_Title_BMS_CN__c, //HP
        													  Cycle_Plan_Account_vod__r.HP_Usage_Level_BMS_CN__c, //HP
        													  Cycle_Plan_Account_vod__r.Monthly_Prescription_Amount_BMS_CN__c,//OTC
        													  Cycle_Plan_Account_vod__r.Monthly_Out_patients_BMS_CN__c, //OTC
        													  Planned_Calls_vod__c
        												FROM  Cycle_Plan_Target_vod__c
        												where Cycle_Plan_vod__c =:cp.Id
        												order by Cycle_Plan_Account_vod__c];
        		
        		for(Cycle_Plan_Target_vod__c cpt :cpts)
        		{
        			string hospitalRank = null;
        			if(BU == 'DB')
        				hospitalRank = DB_HospitalID_Rank.get(cpt.Cycle_Plan_Account_vod__r.Primary_Parent_vod__c);
        			else if(BU == 'CV')
        				hospitalRank = CV_HospitalID_Rank.get(cpt.Cycle_Plan_Account_vod__r.Primary_Parent_vod__c);
        			Double potential = 0;        			
        			for(Segmentation_Calc_Param_Detail_BMS_CN__c param : segDetails)
        			{
        				if((param.Segmentation_Calc_Param_Master_BMS_CN__r.BU_BMS_CN__c == BU && param.Segmentation_Calc_Param_Master_BMS_CN__r.Products_BMS_CN__c == null && cp.Algorithm_BMS_CN__c == null)
        				   ||(param.Segmentation_Calc_Param_Master_BMS_CN__r.BU_BMS_CN__c == BU && 
        				   		(param.Segmentation_Calc_Param_Master_BMS_CN__r.Products_BMS_CN__c != null && param.Segmentation_Calc_Param_Master_BMS_CN__r.Products_BMS_CN__c == cpt.Algorithm_Products_BMS_CN__c))
        				  )
        				{
        					// process Picklist type
        					if(param.Segmentation_Calc_Param_Master_BMS_CN__r.Type_BMS_CN__c == 'Picklist')
        					{
        						if(cpt.Cycle_Plan_Account_vod__r.Department_BMS_CN__c == param.Name 
        							|| cpt.Cycle_Plan_Account_vod__r.Administrative_Title_BMS_CN__c == param.Name
        							|| cpt.Cycle_Plan_Account_vod__r.Technical_Title_BMS_CN__c == param.Name 
        							|| (String.isNotBlank(hospitalRank) && hospitalRank == param.Name)
        							|| cpt.Cycle_Plan_Account_vod__r.Is_GIPAP_TIPAP_Dr_BMS_CN__c == param.Name
        							|| cpt.Cycle_Plan_Account_vod__r.Department_BMS_CN__c + cpt.Cycle_Plan_Account_vod__r.Administrative_Title_BMS_CN__c == param.Name //Eliquis
        							)
        						{
        							potential += param.Segmentation_Calc_Param_Master_BMS_CN__r.Weight_BMS_CN__c * param.Target_Value_BMS_CN__c / 100;
        						}	   						
        					}
        					// process Number type
        					else if (param.Segmentation_Calc_Param_Master_BMS_CN__r.Type_BMS_CN__c == 'Number')
        					{
    							if(param.Value_Max_BMS_CN__c == -1)
    							{
    								if(
    								(param.Name.contains('Decision Beds Index') && cpt.Cycle_Plan_Account_vod__r.Decision_of_Beds_Index_BMS_CN__c >= param.Value_Min_BMS_CN__c)
    								||(param.Name.contains('CV Weekly OutPatients') && cpt.Cycle_Plan_Account_vod__r.Weekly_Out_Patients_BMS_CN__c >= param.Value_Min_BMS_CN__c)
    								||(param.Name.contains('CV Monthly Surgeries') && cpt.Cycle_Plan_Account_vod__r.Monthly_Operations_BMS_CN__c >= param.Value_Min_BMS_CN__c) // New - CV
    								||(param.Name.contains('CV Managed Beds') && cpt.Cycle_Plan_Account_vod__r.Beds_BMS_CN__c >= param.Value_Min_BMS_CN__c) // New - CV
    								||(param.Name.contains('DB Number of Tuesday Diabetic Patients') && cpt.Cycle_Plan_Account_vod__r.Type2_Diabetes_Patients_BMS_CN__c >= param.Value_Min_BMS_CN__c )
    								||(param.Name.contains('Byetta Number of Tuesday Diabetic Patients') && cpt.Cycle_Plan_Account_vod__r.Type2_Diabetes_Patients_BMS_CN__c >= param.Value_Min_BMS_CN__c) // New - DB
    								//||(param.Name.contains('Taxol Monthly Prescription Counts') && cpt.Cycle_Plan_Account_vod__r.Monthly_Taxol_Prescription_BMS_CN__c >= param.Value_Min_BMS_CN__c)
    								//||(param.Name.contains('The branded drugs Monthly prescription count') && cpt.Cycle_Plan_Account_vod__r.Monthly_Brand_Prescription_BMS_CN__c >= param.Value_Min_BMS_CN__c)
    								||(param.Name.contains('CML Patient Number') && cpt.Cycle_Plan_Account_vod__r.CML_Patients_BMS_CN__c >= param.Value_Min_BMS_CN__c)
    								||(param.Name.contains('HP Weekly outpatients') && cpt.Cycle_Plan_Account_vod__r.Weekly_HBV_Out_patients_BMS_CN__c >= param.Value_Min_BMS_CN__c)
    								||(param.Name.contains('HP Beds') && cpt.Cycle_Plan_Account_vod__r.HBV_Beds_BMS_CN__c >= param.Value_Min_BMS_CN__c)
    								)
    									potential += param.Segmentation_Calc_Param_Master_BMS_CN__r.Weight_BMS_CN__c * param.Target_Value_BMS_CN__c / 100;
    									
    							}
    							else
    							{
    								if(
    								(param.Name.contains('Decision Beds Index') && cpt.Cycle_Plan_Account_vod__r.Decision_of_Beds_Index_BMS_CN__c >= param.Value_Min_BMS_CN__c && cpt.Cycle_Plan_Account_vod__r.Decision_of_Beds_Index_BMS_CN__c < param.Value_Max_BMS_CN__c )
    								||(param.Name.contains('CV Weekly OutPatients') && cpt.Cycle_Plan_Account_vod__r.Weekly_Out_Patients_BMS_CN__c >= param.Value_Min_BMS_CN__c && cpt.Cycle_Plan_Account_vod__r.Weekly_Out_Patients_BMS_CN__c < param.Value_Max_BMS_CN__c)
    								||(param.Name.contains('CV Monthly Surgeries') && cpt.Cycle_Plan_Account_vod__r.Monthly_Operations_BMS_CN__c >= param.Value_Min_BMS_CN__c && cpt.Cycle_Plan_Account_vod__r.Monthly_Operations_BMS_CN__c < param.Value_Max_BMS_CN__c) // New - CV
    								||(param.Name.contains('CV Managed Beds') && cpt.Cycle_Plan_Account_vod__r.Beds_BMS_CN__c >=param.Value_Min_BMS_CN__c && cpt.Cycle_Plan_Account_vod__r.Beds_BMS_CN__c < param.Value_Max_BMS_CN__c) // New - CV
    								||(param.Name.contains('DB Number of Tuesday Diabetic Patients') && cpt.Cycle_Plan_Account_vod__r.Type2_Diabetes_Patients_BMS_CN__c >= param.Value_Min_BMS_CN__c && cpt.Cycle_Plan_Account_vod__r.Type2_Diabetes_Patients_BMS_CN__c < param.Value_Max_BMS_CN__c)
    								||(param.Name.contains('Byetta Number of Tuesday Diabetic Patients') && cpt.Cycle_Plan_Account_vod__r.Type2_Diabetes_Patients_BMS_CN__c >= param.Value_Min_BMS_CN__c && cpt.Cycle_Plan_Account_vod__r.Type2_Diabetes_Patients_BMS_CN__c < param.Value_Max_BMS_CN__c) // New - DB
    								//||(param.Name.contains('Taxol Monthly Prescription Counts') && cpt.Cycle_Plan_Account_vod__r.Monthly_Taxol_Prescription_BMS_CN__c >= param.Value_Min_BMS_CN__c && cpt.Cycle_Plan_Account_vod__r.Monthly_Taxol_Prescription_BMS_CN__c < param.Value_Max_BMS_CN__c)
    								//||(param.Name.contains('The branded drugs Monthly prescription count') && cpt.Cycle_Plan_Account_vod__r.Monthly_Brand_Prescription_BMS_CN__c >= param.Value_Min_BMS_CN__c && cpt.Cycle_Plan_Account_vod__r.Monthly_Brand_Prescription_BMS_CN__c < param.Value_Max_BMS_CN__c)
    								||(param.Name.contains('CML Patient Number') && cpt.Cycle_Plan_Account_vod__r.CML_Patients_BMS_CN__c >= param.Value_Min_BMS_CN__c && cpt.Cycle_Plan_Account_vod__r.CML_Patients_BMS_CN__c < param.Value_Max_BMS_CN__c)
    								||(param.Name.contains('HP Weekly outpatients') && cpt.Cycle_Plan_Account_vod__r.Weekly_HBV_Out_patients_BMS_CN__c >= param.Value_Min_BMS_CN__c && cpt.Cycle_Plan_Account_vod__r.Weekly_HBV_Out_patients_BMS_CN__c < param.Value_Max_BMS_CN__c)
    								||(param.Name.contains('HP Beds') && cpt.Cycle_Plan_Account_vod__r.HBV_Beds_BMS_CN__c >= param.Value_Min_BMS_CN__c && cpt.Cycle_Plan_Account_vod__r.HBV_Beds_BMS_CN__c < param.Value_Max_BMS_CN__c)
    								)
    									potential += param.Segmentation_Calc_Param_Master_BMS_CN__r.Weight_BMS_CN__c * param.Target_Value_BMS_CN__c /100;
    							}
        					}
        				}
        				else
        					continue;
        			}
        			// Process those specific potential calculation - Eliquis(CV) + HP 
        			if(BU == 'HP') // HP
        			{
        				if(cpt.Cycle_Plan_Account_vod__r.Department_BMS_CN__c != 'TRP' &&
        				   cpt.Cycle_Plan_Account_vod__r.Department_BMS_CN__c != 'INF' &&
        				   cpt.Cycle_Plan_Account_vod__r.Department_BMS_CN__c != 'HEP' &&
        				   cpt.Cycle_Plan_Account_vod__r.Department_BMS_CN__c != 'GI' &&
        				   cpt.Cycle_Plan_Account_vod__r.Department_BMS_CN__c != 'TMD' &&
        				   cpt.Cycle_Plan_Account_vod__r.Department_BMS_CN__c != 'INT' &&
        				   cpt.Cycle_Plan_Account_vod__r.Department_BMS_CN__c != 'HSUR' &&
        				   cpt.Cycle_Plan_Account_vod__r.Department_BMS_CN__c != 'GER' &&
        				   cpt.Cycle_Plan_Account_vod__r.Department_BMS_CN__c != 'HEM' &&
        				   cpt.Cycle_Plan_Account_vod__r.Department_BMS_CN__c != 'IHEP' &&
        				   cpt.Cycle_Plan_Account_vod__r.Department_BMS_CN__c != 'ONC' 
        				   )
        				   {
        				   		potential += 4 * 0.25;
        				   }
        			}
        			else if((cpt.Algorithm_Products_BMS_CN__c != null && cpt.Algorithm_Products_BMS_CN__c == '艾乐妥(Eliquis)')
        					|| cp.Algorithm_BMS_CN__c == 'CV-Eliquis'
        			  	   ) // Eliquis(CV)
        			{
        				String deptAdminTitle = cpt.Cycle_Plan_Account_vod__r.Department_BMS_CN__c + cpt.Cycle_Plan_Account_vod__r.Administrative_Title_BMS_CN__c;
        				if(cpt.Cycle_Plan_Account_vod__r.Administrative_Title_BMS_CN__c == 'A004') //带组医生/主治医生
        				{
        					potential += 8 * 0.25;
        				}
        				else if(cpt.Cycle_Plan_Account_vod__r.Administrative_Title_BMS_CN__c == 'A007') // 住院医生
        				{
        					potential += 6 * 0.25;
        				}
        				else if(deptAdminTitle != 'OTPA002' && deptAdminTitle != 'OJSA002' && deptAdminTitle != 'JSA002')
        				{
        					potential += 4 * 0.25; // 其他
        				}
        			}
        			// End of potential calculation
        			// Start of Segmentation 
        			for(Segmentation_Target_Frequency_BMS_CN__c stf :segTargetFrequencies)
        			{
        				if(BU == stf.BU_BMS_CN__c)
        				{
	        				if(BU=='HP') //HP
	        				{
	        					if(stf.HP_Usage_Level_BMS_CN__c == cpt.Cycle_Plan_Account_vod__r.HP_Usage_Level_BMS_CN__c 
	        						&& potential >= stf.Value_Min_BMS_CN__c && potential < stf.Value_Max_BMS_CN__c)
	        					{
	        						cpt.Dr_Level_BMS_CN__c = stf.Segmentation_BMS_CN__c;
	        						cpt.Planned_Calls_vod__c = stf.Target_Frequency_BMS_CN__c;
	        						break;
	        					}
	        				}	        				
	        				else if(BU=='OTC') //OTC
	        				{
	        					if(stf.Segmentation_BMS_CN__c == 'L-KEY')
	        					{
	        						if(cpt.Cycle_Plan_Account_vod__r.L_Key_BMS_CN__c)
	        						{
	        							cpt.Dr_Level_BMS_CN__c = stf.Segmentation_BMS_CN__c;
    									cpt.Planned_Calls_vod__c = stf.Target_Frequency_BMS_CN__c;
    									break;
	        						}
	        					}
	        					else
	        					{
	        						if(!cpt.Cycle_Plan_Account_vod__r.L_Key_BMS_CN__c)
	        						{
			        					if(stf.OTC_Outpatients_Monthly_Max_BMS_CN__c == -1)
			        					{
			        						if(cpt.Cycle_Plan_Account_vod__r.Monthly_Out_patients_BMS_CN__c >= stf.OTC_Outpatients_Monthly_Min_BMS_CN__c)
			        						{
			        							if(stf.OTC_Pres_Amount_Monthly_Max_BMS_CN__c == -1)
			        							{
			        								if(cpt.Cycle_Plan_Account_vod__r.Monthly_Prescription_Amount_BMS_CN__c >= stf.OTC_Pres_Amount_Monthly_Min_BMS_CN__c)
			        								{
			        									cpt.Dr_Level_BMS_CN__c = stf.Segmentation_BMS_CN__c;
			        									cpt.Planned_Calls_vod__c = stf.Target_Frequency_BMS_CN__c;
			        									break;
			        								}
			        							}
			        							else
			        							{
			        								if(cpt.Cycle_Plan_Account_vod__r.Monthly_Prescription_Amount_BMS_CN__c >= stf.OTC_Pres_Amount_Monthly_Min_BMS_CN__c
			        									&& cpt.Cycle_Plan_Account_vod__r.Monthly_Prescription_Amount_BMS_CN__c < stf.OTC_Pres_Amount_Monthly_Max_BMS_CN__c)
		        									{
		        										cpt.Dr_Level_BMS_CN__c = stf.Segmentation_BMS_CN__c;
			        									cpt.Planned_Calls_vod__c = stf.Target_Frequency_BMS_CN__c;
			        									break;
		        									}
			        							}
			        						}
			        					}
			        					else
			        					{
			        						if(cpt.Cycle_Plan_Account_vod__r.Monthly_Out_patients_BMS_CN__c >= stf.OTC_Outpatients_Monthly_Min_BMS_CN__c 
			        							&& cpt.Cycle_Plan_Account_vod__r.Monthly_Out_patients_BMS_CN__c < stf.OTC_Outpatients_Monthly_Max_BMS_CN__c)
			        						{
			        							if(stf.OTC_Pres_Amount_Monthly_Max_BMS_CN__c == -1)
			        							{
			        								if(cpt.Cycle_Plan_Account_vod__r.Monthly_Prescription_Amount_BMS_CN__c >= stf.OTC_Pres_Amount_Monthly_Min_BMS_CN__c)
			        								{
			        									cpt.Dr_Level_BMS_CN__c = stf.Segmentation_BMS_CN__c;
			        									cpt.Planned_Calls_vod__c = stf.Target_Frequency_BMS_CN__c;
			        									break;
			        								}
			        							}
			        							else
			        							{
			        								if(cpt.Cycle_Plan_Account_vod__r.Monthly_Prescription_Amount_BMS_CN__c >= stf.OTC_Pres_Amount_Monthly_Min_BMS_CN__c
			        									&& cpt.Cycle_Plan_Account_vod__r.Monthly_Prescription_Amount_BMS_CN__c < stf.OTC_Pres_Amount_Monthly_Max_BMS_CN__c)
			        								{
			        									/* Old Logic - commented by Nate on 2013.07.11
			        									if(cpt.Cycle_Plan_Account_vod__r.Department_BMS_CN__c == stf.OTC_Department_BMS_CN__c
			        										||cpt.Cycle_Plan_Account_vod__r.Administrative_Title_BMS_CN__c == stf.OTC_Administrative_Title_BMS_CN__c)
		        										{
		        											cpt.Dr_Level_BMS_CN__c = stf.Segmentation_BMS_CN__c;
			        										cpt.Planned_Calls_vod__c = stf.Target_Frequency_BMS_CN__c;
			        										break;
		        										}
		        										else
		        										{        										
		        											cpt.Dr_Level_BMS_CN__c = stf.Segmentation_BMS_CN__c;
			        										cpt.Planned_Calls_vod__c = stf.Target_Frequency_BMS_CN__c;
			        										break;
		        										}
		        										**/
		        										
		        										cpt.Dr_Level_BMS_CN__c = stf.Segmentation_BMS_CN__c;
		        										cpt.Planned_Calls_vod__c = stf.Target_Frequency_BMS_CN__c;
		        										break;
			        								}
			        							}
			        						}
			        					}
	        						}
	        					}
	        				}
	        				else if (BU == 'ONCO-TAXOL') //ONCO-TAXOL
	        				{
	        					if(stf.Segmentation_BMS_CN__c == 'VH')
	        					{
	        						if((cpt.Cycle_Plan_Account_vod__r.Paraplatin_Level_BMS_CN__c == 'A' && cpt.Cycle_Plan_Account_vod__r.Taxol_Level_BMS_CN__c =='A')
	        							||(cpt.Cycle_Plan_Account_vod__r.Is_KOL_BMS_CN__c && (cpt.Cycle_Plan_Account_vod__r.Paraplatin_Level_BMS_CN__c == 'A' || cpt.Cycle_Plan_Account_vod__r.Taxol_Level_BMS_CN__c =='A')) 
	        						)
	        						{
	        							cpt.Dr_Level_BMS_CN__c = stf.Segmentation_BMS_CN__c;
										cpt.Planned_Calls_vod__c = stf.Target_Frequency_BMS_CN__c;
										break;
	        						}
	        					}
	        					else if(stf.Segmentation_BMS_CN__c == 'H')
	        					{
	        						if(cpt.Cycle_Plan_Account_vod__r.Is_KOL_BMS_CN__c || cpt.Cycle_Plan_Account_vod__r.Paraplatin_Level_BMS_CN__c == 'A' || cpt.Cycle_Plan_Account_vod__r.Taxol_Level_BMS_CN__c =='A')
	        						{
	        							cpt.Dr_Level_BMS_CN__c = stf.Segmentation_BMS_CN__c;
										cpt.Planned_Calls_vod__c = stf.Target_Frequency_BMS_CN__c;
										break;
	        						}
	        					}
	        					else if(stf.Segmentation_BMS_CN__c == 'M')
	        					{
	        						if(cpt.Cycle_Plan_Account_vod__r.Paraplatin_Level_BMS_CN__c == 'B' || cpt.Cycle_Plan_Account_vod__r.Taxol_Level_BMS_CN__c =='B')
	        						{
	        							cpt.Dr_Level_BMS_CN__c = stf.Segmentation_BMS_CN__c;
										cpt.Planned_Calls_vod__c = stf.Target_Frequency_BMS_CN__c;
										break;
	        						}
	        					}
	        					else // 'L'
	        					{
	        						if(cpt.Cycle_Plan_Account_vod__r.Paraplatin_Level_BMS_CN__c == 'C' || cpt.Cycle_Plan_Account_vod__r.Taxol_Level_BMS_CN__c =='C')
	        						{
	        							cpt.Dr_Level_BMS_CN__c = stf.Segmentation_BMS_CN__c;
										cpt.Planned_Calls_vod__c = stf.Target_Frequency_BMS_CN__c;
										break;
	        						}
	        					}
	        				}
	        				else //CV DB ONCO-SPRYCEL
	        				{	        					
	        					if(stf.Algorithm_BMS_CN__c != null ) 
	        					{
	        						if(stf.Algorithm_Products_BMS_CN__c == null || (stf.Algorithm_Products_BMS_CN__c != null && stf.Algorithm_Products_BMS_CN__c == cpt.Algorithm_Products_BMS_CN__c))
	        						{
		        						if(stf.Algorithm_BMS_CN__c == cp.Algorithm_BMS_CN__c)
		        						{
		        							if(potential >= stf.Value_Min_BMS_CN__c && potential < stf.Value_Max_BMS_CN__c)
			        						{
			        							cpt.Dr_Level_BMS_CN__c = stf.Segmentation_BMS_CN__c;
				        						cpt.Planned_Calls_vod__c = stf.Target_Frequency_BMS_CN__c;	        						
				        						break;
			        						}
		        						}
	        						}
	        					}
	        					else 
	        					{	    
	        						    						
        							if(potential >= stf.Value_Min_BMS_CN__c && potential < stf.Value_Max_BMS_CN__c)
	        						{
	        							cpt.Dr_Level_BMS_CN__c = stf.Segmentation_BMS_CN__c;
		        						cpt.Planned_Calls_vod__c = stf.Target_Frequency_BMS_CN__c;	        						
		        						break;
	        						}	        						
	        					}
	        				}
        				}
        			}
        			// specific rule for Onglyza Segmentation
        			if(cpt.Algorithm_Products_BMS_CN__c == '安立泽(Onglyza)')
        			{
        				if(cpt.Cycle_Plan_Account_vod__r.Is_Onglyza_Focus_Doctor_BMS_CN__c 
        				   && (cpt.Cycle_Plan_Account_vod__r.Administrative_Title_BMS_CN__c == 'A001'
        				   	   || cpt.Cycle_Plan_Account_vod__r.Administrative_Title_BMS_CN__c == 'A008'
        				   	   || cpt.Cycle_Plan_Account_vod__r.Department_BMS_CN__c == 'PHA'
        				   	   )
        				   )
        				 {
        				 	if(cpt.Dr_Level_BMS_CN__c != 'VH')
        				 	{
        				 		cpt.Dr_Level_BMS_CN__c = 'H';
        				 		cpt.Planned_Calls_vod__c = 3;
        				 	}
        				 }
        			}
        			        			
        			System.Debug('[Nate:Account]: ' + cpt.Cycle_Plan_Account_vod__c);
        			System.Debug('[Nate:Potential]:' + potential);
        			System.Debug('[Nate]Doctor Level: ' + cpt.Dr_Level_BMS_CN__c);
        			System.Debug('[Nate]Planned Calls:' + cpt.Planned_Calls_vod__c);
        			
        			// check the Segmentation & Frequency  
        			List<Product_Metrics_vod__c> pm_Account_BU = Account_PMs.get(cpt.Cycle_Plan_Account_vod__c);
        			if(pm_Account_BU != null && pm_Account_BU.size()>0)
        			{
	        			for(Product_Metrics_vod__c pm: pm_Account_BU)
	        			{	        				
        					if(BU == 'OTC')
        						pm.Potential_OTC_BMS_CN__c = cpt.Dr_Level_BMS_CN__c;
        					else
        						pm.Potential_BMS_CN__c = cpt.Dr_Level_BMS_CN__c;        						
        					toBeUpdatedPM.Add(pm);		
	        			}
        			}
        		}
        		update cpts;	
        	}
        	cp.Active_vod__c = true;
        	update cp;    
        	
        	List<Product_Metrics_vod__c> toBeUpdatedPMList = new List<Product_Metrics_vod__c>();
    		toBeUpdatedPMList.addAll(toBeUpdatedPM);
    		System.Debug('[Nate]:toBeUpdatedPMList size: '+toBeUpdatedPMList.size()+' Rows.');
    		update toBeUpdatedPMList;
        	 	
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {
    	
    }
    
}