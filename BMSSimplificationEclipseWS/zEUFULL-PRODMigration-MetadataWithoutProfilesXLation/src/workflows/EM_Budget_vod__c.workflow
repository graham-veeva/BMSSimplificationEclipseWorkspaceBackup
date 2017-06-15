<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Approval_Status_Business_Approved</fullName>
        <field>Approval_Status_HCPTS__c</field>
        <literalValue>Business Approved</literalValue>
        <name>Approval Status Business Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_to_Draft</fullName>
        <field>Approval_Status_HCPTS__c</field>
        <literalValue>In Draft</literalValue>
        <name>Approval Status to Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Availability_Status_to_Draft</fullName>
        <field>Status_vod__c</field>
        <literalValue>Draft_vod</literalValue>
        <name>Availability Status to Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>In_Activation</fullName>
        <field>Status_vod__c</field>
        <literalValue>In Pre-Activation</literalValue>
        <name>In Activation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Increase_Version_0_1</fullName>
        <description>Increase Version 0.1</description>
        <field>Version_HCPTS__c</field>
        <formula>Version_HCPTS__c + 0.1</formula>
        <name>Increase Version 0.1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Increase_Version_1</fullName>
        <description>Increase Version by 1</description>
        <field>Version_HCPTS__c</field>
        <formula>CEILING(Version_HCPTS__c)</formula>
        <name>Increase Version 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Need_Sent_for_Approval</fullName>
        <description>Need- Sent for Approval</description>
        <field>Approval_Status_HCPTS__c</field>
        <literalValue>Sent For Approval</literalValue>
        <name>Need: Sent for Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Need_Update_Approval_Status_Review_Appr</fullName>
        <description>Update the Approval Status on the Need to Reviewer Approved</description>
        <field>Approval_Status_HCPTS__c</field>
        <literalValue>Review Completed</literalValue>
        <name>Need: Update Approval Status Review Appr</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Need_Update_to_In_Activiation</fullName>
        <description>Once Need is Approved, change Availability status to In Activation</description>
        <field>Status_vod__c</field>
        <literalValue>In Pre-Activation</literalValue>
        <name>Need: Update to In Pre Activiation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rec_Type_to_Serial_Need</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Budget_with_Speaker_Meeting_Serial_Guidance</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Rec Type to Serial Need</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status_To_Approved</fullName>
        <field>Approval_Status_HCPTS__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Approval Status To Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status_to_Draft</fullName>
        <description>Update Approval Status to Draft</description>
        <field>Approval_Status_HCPTS__c</field>
        <literalValue>In Draft</literalValue>
        <name>Update Approval Status to Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Budget_Identifier_for_Simple_Need</fullName>
        <description>Updates Budget Id for simple needs to include WBS/CC number</description>
        <field>Budget_Identifier_vod__c</field>
        <formula>LEFT(&apos;ND-&apos; &amp; TEXT(YEAR( Start_Date_vod__c )) &amp; &apos;-&apos; &amp;  Company_Code_HCPTS__r.Plant_Code_HCPTS__r.Country_HCPTS__c &amp; &apos;-&apos; &amp; 
 IF(ISBLANK( WBS_Number_HCPTS__c ), Cost_Center_Code_HCPTS__r.Name ,WBS_Number_HCPTS__r.Name) 
&amp;
&apos;-&apos; &amp; Need_ID_HCPTS__c,80)</formula>
        <name>Update Budget Identifier for Simple Need</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Budget_Identifier_to_NEED_ID</fullName>
        <description>Updates the Budget ID field with Need ID..specific system generated format</description>
        <field>Budget_Identifier_vod__c</field>
        <formula>LEFT(&apos;ND-&apos; &amp; TEXT(YEAR( Start_Date_vod__c )) &amp; &apos;-&apos; &amp; Funding_Country_HCPTS__r.Alpha_2_Code_vod__c &amp; &apos;-&apos; &amp; Product_vod__r.Name &amp; &apos;-&apos; &amp;   TEXT(Activity_Type_HCPTS__c)   &amp; &apos;-&apos; &amp; Need_ID_HCPTS__c,80)</formula>
        <name>Update Budget Identifier to NEED ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Budget_Status_to_Expired</fullName>
        <description>Moves Active Budgets to Expired State  - req 534 - mnaidu- simplification</description>
        <field>Status_vod__c</field>
        <literalValue>Expired</literalValue>
        <name>Update Budget Status to Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Budget_Status_vod_to_Available</fullName>
        <description>Update Veeva Status field (status_vod) to Available for Use so its selectable in UI</description>
        <field>Status_vod__c</field>
        <literalValue>Available_For_Use_vod</literalValue>
        <name>Update Budget Status_vod to Available</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Recordtype_to_Partial_Lock</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Speaker_Meeting_PartiallyLocked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Recordtype to Partial Lock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Rectype_to_Serial_Open</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Budget_with_Speaker_Meeting_Serial_Guidance</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Rectype to Serial Open</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Rejected</fullName>
        <description>Update Status to Rejected</description>
        <field>Approval_Status_HCPTS__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Approval Status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Rejected_By_Certifier</fullName>
        <description>Update Approval Status to Rejected By Certifier</description>
        <field>Approval_Status_HCPTS__c</field>
        <literalValue>Rejected by Certifier</literalValue>
        <name>Update Status to Rejected By Certifier</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Rejected_By_Reviewer</fullName>
        <description>Update Status to Rejected By Reviewer</description>
        <field>Approval_Status_HCPTS__c</field>
        <literalValue>Rejected by Reviewer</literalValue>
        <name>Update Status to Rejected By Reviewer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Review_Completed</fullName>
        <field>Approval_Status_HCPTS__c</field>
        <literalValue>Review Completed</literalValue>
        <name>Update Status to Review Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_vod_to_Draft</fullName>
        <description>Update Status_vod to Draft</description>
        <field>Status_vod__c</field>
        <literalValue>Draft_vod</literalValue>
        <name>Update Status_vod to Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
