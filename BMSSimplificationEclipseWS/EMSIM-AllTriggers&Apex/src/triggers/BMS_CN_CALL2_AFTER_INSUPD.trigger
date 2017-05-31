trigger BMS_CN_CALL2_AFTER_INSUPD on Call2_vod__c (after insert, after update) 
{
    //Author:           Nate Zhang
    //Create Date:      2013.01.16
    //Last Update Date: 2013.06.26(For eliquis,taxol,Paraplatin)
    //---------------------------------
    //firing check for chinese users
    BMS_Global_Trigger_Setting__c bgts = BMS_Global_Trigger_Setting__c.getinstance();
    
    if (!bgts.BMS_CN_CALL2_AFTER_INSUPD__c)
    {
        return;
    }
    
    List<Call2_vod__c> Calls = Trigger.new;
    Set<ID> AccountIds = new Set<ID>();
    List<ID> CallIDs = new List<ID>();
    Map<ID,Set<ID>> Account_ProductIds = new Map<ID,Set<ID>>();
    
    for(Call2_vod__c call : Calls)
    {
        if(call.Status_vod__c == 'Submitted_vod')
        {
            CallIDs.add(call.ID);
            AccountIds.add(call.Account_vod__c);
        }
    }
    
    List<Call2_Discussion_vod__c> Discussions = [Select Is_Achieved_BMS_CN__c, Product_Knowledge_BMS_CN__c, Account_vod__c, Product_vod__c ,Patient_Type_BMS_CN__c,
                                                 Incremental_Shift_BMS_CN__c, Call_Date_vod__c from Call2_Discussion_vod__c where Call2_vod__c in :CallIDs];
    List<Product_Metrics_vod__c> pms = [select Agree_BMS_CN__c, Account_vod__c, Products_vod__c, Knowledge_BMS_CN__c from Product_Metrics_vod__c 
                                        where Account_vod__c in :AccountIds]; 
   
    //build the mapping of Account-Products captured in call discussion.                                    
    for(Call2_Discussion_vod__c dis : Discussions)
    {
        if(!Account_ProductIds.containsKey(dis.Account_vod__c))
            Account_ProductIds.Put(dis.Account_vod__c,new Set<ID>{dis.Product_vod__c});
        else
            Account_ProductIds.Get(dis.Account_vod__c).Add(dis.Product_vod__c); 
    }
    
    if(pms.isEmpty())
    {
        for(ID account : AccountIds)
            pms.add(new Product_Metrics_vod__c(Account_vod__c = account));
    }
    
    for(ID account : Account_ProductIds.keySet())
    {
        for(ID product: Account_ProductIds.get(account))
        {
            boolean hasProduct = false;
            for(Product_Metrics_vod__c p : pms)
            {
                if(p.Account_vod__c == account && product == p.Products_vod__c)
                {
                    hasProduct = true;
                    break;
                }
            }
            if(!hasProduct)
                pms.add(new Product_Metrics_vod__c(Account_vod__c = account, Products_vod__c = product));           
        }
    }
    
    
    String ISStage = '';
    for(Product_Metrics_vod__c pm : pms)
    {
        for(Call2_Discussion_vod__c dis :Discussions)
        {
            
            if(pm.Account_vod__c == dis.Account_vod__c && pm.Products_vod__c == dis.Product_vod__c)
            {
                    
                    
                    if(dis.Incremental_Shift_BMS_CN__c == 'Monopril_IS_1_1' 
                                    || dis.Incremental_Shift_BMS_CN__c == 'Monopril_IS_2_1'
                                    || dis.Incremental_Shift_BMS_CN__c == 'Monopril_IS_3_1'
                            || dis.Incremental_Shift_BMS_CN__c == 'Monopril_IS_4_1' 
                            || dis.Incremental_Shift_BMS_CN__c == 'Regular add SU or AGI on Met for patient who Glucose uncontrol with mono Met dosage 1500mg above' 
                            || dis.Incremental_Shift_BMS_CN__c == 'Regular use SU or AGI for new diagnosed T2DM patients'
                            || dis.Incremental_Shift_BMS_CN__c == 'Glu_IS_1_1'
                            || dis.Incremental_Shift_BMS_CN__c == 'Taxol_IS_1_1'
                            || dis.Incremental_Shift_BMS_CN__c == 'Taxol_IS_2_1'
                            || dis.Incremental_Shift_BMS_CN__c == 'Treat CHB but not use ETV'
                            || dis.Incremental_Shift_BMS_CN__c == 'Baraclude_IS_2_1' 
                            || dis.Incremental_Shift_BMS_CN__c == 'Eliquis_IS_1_1'
                            //Paraplatin
                            || dis.Incremental_Shift_BMS_CN__c == 'Paraplatin_IS_1_1'
                            || dis.Incremental_Shift_BMS_CN__c == 'Paraplatin_IS_2_1'
                            )
                    {
                        ISStage = '1';
                    
                    }
                    
                    if(dis.Incremental_Shift_BMS_CN__c == 'Monopril_IS_1_2'
                     || dis.Incremental_Shift_BMS_CN__c == 'Monopril_IS_2_2'
                            || dis.Incremental_Shift_BMS_CN__c == 'Monopril_IS_3_2' 
                            || dis.Incremental_Shift_BMS_CN__c == 'Monopril_IS_4_2' 
                            || dis.Incremental_Shift_BMS_CN__c == 'Only when concern the side effect about SU or AGI,then choice add Onglyza on Met for patient who Glucose uncontrol with mono Met dosage 1500mg above'
                            || dis.Incremental_Shift_BMS_CN__c == 'Only when concern the side effect about SU or AGI,then choice Onglyza for new diagnosed T2DM patients'
                            || dis.Incremental_Shift_BMS_CN__c == 'Glu will be prescribed to new diagnosed T2DM patients as preferred initial therapy'
                            || dis.Incremental_Shift_BMS_CN__c == 'Taxol_IS_1_1'
                            || dis.Incremental_Shift_BMS_CN__c == 'Taxol_IS_2_1'
                            || dis.Incremental_Shift_BMS_CN__c == 'Baraclude_IS_1_2'
                            || dis.Incremental_Shift_BMS_CN__c == 'Baraclude_IS_2_2'
                            || dis.Incremental_Shift_BMS_CN__c == 'Eliquis_IS_1_2'
                            //Paraplatin
                            || dis.Incremental_Shift_BMS_CN__c == 'Paraplatin_IS_1_2'
                            || dis.Incremental_Shift_BMS_CN__c == 'Paraplatin_IS_2_2'
                     )
                    {
                        ISStage = '2';
                    
                    }
                    
                    //after 3 
                    if(dis.Incremental_Shift_BMS_CN__c == 'Monopril_IS_1_3'
                                    || dis.Incremental_Shift_BMS_CN__c == 'Monopril_IS_2_3'
                                    || dis.Incremental_Shift_BMS_CN__c == 'Monopril_IS_3_3'
                                    || dis.Incremental_Shift_BMS_CN__c == 'Monopril_IS_4_3'
                                    || dis.Incremental_Shift_BMS_CN__c == 'Regular add Onglyza on Met for patient who Glucose uncontrol with mono Met dosage 1500mg above'
                                    || dis.Incremental_Shift_BMS_CN__c == 'Regular use Onglyza for new diagnosed T2DM patients'
                                    || dis.Incremental_Shift_BMS_CN__c == 'Added dosage to 1.5-2g to all T2DM patients.'
                                    || dis.Incremental_Shift_BMS_CN__c == 'Taxol_IS_1_3'
                                    || dis.Incremental_Shift_BMS_CN__c == 'Taxol_IS_2_3'
                                    || dis.Incremental_Shift_BMS_CN__c == 'Baraclude_IS_1_3'
                                    || dis.Incremental_Shift_BMS_CN__c == 'Baraclude_IS_2_3'
                                    || dis.Incremental_Shift_BMS_CN__c == 'Eliquis_IS_1_3'
                                    //Paraplatin
                                            || dis.Incremental_Shift_BMS_CN__c == 'Paraplatin_IS_2_3'
                                    ) {
                    
                            ISStage = '3';
                    
                    
                    }
                    //4
                    if(dis.Incremental_Shift_BMS_CN__c == 'Monopril_IS_1_4'
                                || dis.Incremental_Shift_BMS_CN__c == 'Monopril_IS_2_4'
                                || dis.Incremental_Shift_BMS_CN__c == 'Monopril_IS_3_4'
                                || dis.Incremental_Shift_BMS_CN__c == 'Monopril_IS_4_4'
                                || dis.Incremental_Shift_BMS_CN__c == 'Regard Onglyza as the first choice for the patient who Glucose uncontrol with mono Met dosage 1500mg above'
                                || dis.Incremental_Shift_BMS_CN__c == 'Regard Onglyza as the first choice for new diagnosed T2DM patients'
                                || dis.Incremental_Shift_BMS_CN__c == 'Prescribe Glu to all T2DM patients on whole treatment.'
                                //|| dis.Incremental_Shift_BMS_CN__c == 'Taxol dose-dense regimen (biweekly or weekly) as superior chemotherapy in EBC.'
                                || dis.Incremental_Shift_BMS_CN__c == 'Taxol_IS_2_4'
                                || dis.Incremental_Shift_BMS_CN__c == 'Baraclude_IS_1_4'
                                || dis.Incremental_Shift_BMS_CN__c == 'Baraclude_IS_2_4'
                                || dis.Incremental_Shift_BMS_CN__c == 'Eliquis_IS_1_4'
                    
                    
                    ){
                        ISStage = '4';                 
                    }
                    
                    //5
                   // if(dis.Incremental_Shift_BMS_CN__c == 'Stick on 4 (3-weekly or biweekly) to 12 (weekly) cycles of Taxol regimen as adjuvant chemotherapy in EBC.'
                     //           || dis.Incremental_Shift_BMS_CN__c == 'Baraclude_IS_1_5'
                     if(dis.Incremental_Shift_BMS_CN__c == 'Baraclude_IS_1_5'
                    ){
                        ISStage = '5';
                    }
                    
                    
                    
                    
                    
            
                //updating IS and is achived
                if(dis.Patient_Type_BMS_CN__c == 'HTN with MI (NSTEMI/STEMI)' )
                {
                        if(ISStage != '')
                        {
                            pm.IS_HTN_With_MI_BMS_CN__c = ISStage ;
                        }
                    if (dis.Is_Achieved_BMS_CN__c != '')
                    {
                        pm.Is_Achieved_HTN_With_MI_BMS_CN__c = dis.Is_Achieved_BMS_CN__c;
                    }
                }
                
                else if(dis.Patient_Type_BMS_CN__c == 'HTN with UA/A-PCI' )
                {
                        if(ISStage != '')
                        {
                            pm.IS_HTN_With_UA_PCI_BMS_CN__c = ISStage ;
                        }
                    if (dis.Is_Achieved_BMS_CN__c != '')
                    {
                        pm.Is_Achieved_HTN_With_UA_PCI_BMS_CN__c = dis.Is_Achieved_BMS_CN__c;
                    }
                }
                else if(dis.Patient_Type_BMS_CN__c == 'Heart Failure' )
                {   
                        if(ISStage != '')
                        {
                        pm.IS_Heart_Failure_BMS_CN__c = ISStage ;
                    }
                    if (dis.Is_Achieved_BMS_CN__c != '')
                    {
                        pm.Is_Achieved_Heart_Failure_BMS_CN__c = dis.Is_Achieved_BMS_CN__c;
                    }
                }
                else if(dis.Patient_Type_BMS_CN__c == 'HTN with CHD' )
                {
                    if(ISStage != '')
                        {
                        pm.IS_HTN_With_CHD_BMS_CN__c = ISStage ;
                    }
                    if (dis.Is_Achieved_BMS_CN__c != '')
                    {
                        pm.Is_Achieved_HTN_With_CHD_BMS_CN__c = dis.Is_Achieved_BMS_CN__c;
                    }
                }
                else if(dis.Patient_Type_BMS_CN__c == 'New T2DM patients' ||  dis.Patient_Type_BMS_CN__c == 'New diagnosed T2DM patients')
                {
                    if(ISStage != '')
                        {
                        pm.IS_New_T2DM_Patients_BMS_CN__c = ISStage ;
                    }
                    if (dis.Is_Achieved_BMS_CN__c != '')
                    {
                        pm.Is_Achieved_New_T2DM_Patients_BMS_CN__c = dis.Is_Achieved_BMS_CN__c;
                    }
                }
                else if(dis.Patient_Type_BMS_CN__c == 'Glucose uncontrol with mono Met dosage 1500mg above T2DM patients')
                {
                    if(ISStage != '')
                        {
                        pm.IS_T3DM_Patients_BMS_CN__c = ISStage ;
                    }
                    if (dis.Is_Achieved_BMS_CN__c != '')
                    {
                        pm.Is_Achieved_T3DM_Patients_BMS_CN__c = dis.Is_Achieved_BMS_CN__c;
                    }
                }
                else if(dis.Patient_Type_BMS_CN__c == 'Early-stage Breast Cancer' )
                {
                    if(ISStage != '')
                        {
                        pm.IS_Breast_Cancer_BMS_CN__c = ISStage;     
                    }
                    if (dis.Is_Achieved_BMS_CN__c != '')
                    {               
                        pm.Is_Achieved_Breast_Cancer_BMS_CN__c = dis.Is_Achieved_BMS_CN__c;
                    }
                }
                else if(dis.Patient_Type_BMS_CN__c == 'Advanced Ovarian Cancer' )
                {
                    if(ISStage != '')
                        {
                        pm.IS_Ovarian_Cancer_BMS_CN__c = ISStage ;
                    }
                    if (dis.Is_Achieved_BMS_CN__c != '')
                    {
                        pm.Is_Achieved_Ovarian_Cancer_BMS_CN__c = dis.Is_Achieved_BMS_CN__c;
                    }
                    
                }
                else if(dis.Patient_Type_BMS_CN__c == 'Core Message' )
                {
                    if(ISStage != '')
                        {
                        pm.IS_Core_Message_BMS_CN__c = ISStage ;
                    }
                    if (dis.Is_Achieved_BMS_CN__c != '')
                    {
                        pm.Is_Achieved_Core_Message_BMS_CN__c = dis.Is_Achieved_BMS_CN__c;
                    }
                }
                else if(dis.Patient_Type_BMS_CN__c == 'Defense Generic' )
                {
                    if(ISStage != '')
                        {
                        pm.IS_Defense_Generic_BMS_CN__c = ISStage ;
                    }
                    if (dis.Is_Achieved_BMS_CN__c != '')
                    {
                        pm.Is_Achieved_Defense_Generic_BMS_CN__c = dis.Is_Achieved_BMS_CN__c;
                    }
                }
                //20130625 add eliquis
                else if(dis.Patient_Type_BMS_CN__c == 'TKR patients')
                {
                    if(ISStage != '')
                        {
                        pm.IS_TKR_Patients_BMS_CN__c= ISStage ;
                    }
                    if (dis.Is_Achieved_BMS_CN__c != '')
                    {
                        pm.Is_Achieved_TKR_Patients_BMS_CN__c = dis.Is_Achieved_BMS_CN__c;
                    }
                }
                //20130701 add Paraplatin
                else if(dis.Patient_Type_BMS_CN__c == 'SCLC')
                {
                    if(ISStage != '')
                        {
                        pm.IS_SCLC_BMS_CN__c = ISStage ;
                    }
                    if (dis.Is_Achieved_BMS_CN__c != '')
                    {
                        pm.Is_Achieved_SCLC_BMS_CN__c = dis.Is_Achieved_BMS_CN__c;
                    }
                }
                else if(dis.Patient_Type_BMS_CN__c == 'OC')
                {
                    if(ISStage != '')
                        {
                        pm.IS_OC_BMS_CN__c = ISStage ;
                    }
                    if (dis.Is_Achieved_BMS_CN__c != '')
                    {
                        pm.Is_Achieved_OC_BMS_CN__c = dis.Is_Achieved_BMS_CN__c;
                    }
                }
                
                
                else if(dis.Patient_Type_BMS_CN__c == null )
                {
                    if(ISStage != '')
                        {
                        pm.IS_NA_BMS_CN__c = ISStage ;
                    }
                    if (dis.Is_Achieved_BMS_CN__c != '')
                    {
                        pm.Is_Achieved_NA_BMS_CN__c = dis.Is_Achieved_BMS_CN__c;
                    }
                }
                
                
                //updating Productknowledge.
                Integer imonth = dis.Call_Date_vod__c.month();
                if(dis.Product_Knowledge_BMS_CN__c != '') // to judge this is from Medical, not sales
                {
                    if(imonth < 4) {
                    
                        pm.Product_Knowledge_Q1_BMS_CN__c = dis.Product_Knowledge_BMS_CN__c;
                    }
                    else if (imonth < 7)
                    {
                    
                        pm.Product_Knowledge_Q2_BMS_CN__c = dis.Product_Knowledge_BMS_CN__c;
                    }
                    
                    else if (imonth < 10)
                    {
                    
                        pm.Product_Knowledge_Q3_BMS_CN__c = dis.Product_Knowledge_BMS_CN__c;
                    }
                    
                    else
                    {
                    
                        pm.Product_Knowledge_Q4_BMS_CN__c = dis.Product_Knowledge_BMS_CN__c;
                    }
                }
            
                
            }
        }
    }
    
    upsert pms;
    
}