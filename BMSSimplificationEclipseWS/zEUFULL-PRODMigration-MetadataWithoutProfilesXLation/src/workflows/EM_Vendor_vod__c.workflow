<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Global_ID_Field_Update_HCPTS</fullName>
        <description>Updates the Customer ID field on the Contract Party when associated with an Account</description>
        <field>Global_Customer_ID2_HCPTS__c</field>
        <formula>Account_vod__r.BP_ID_BMS_CORE__c</formula>
        <name>Global ID Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_GCID_to_Contract_Party_ID</fullName>
        <description>Update Global Customer ID to Contract party ID</description>
        <field>Global_Customer_ID2_HCPTS__c</field>
        <formula>Id</formula>
        <name>Update GCID to Contract Party ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Payee_Rectype_to_Simple</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Payee_Simple_HCPTS</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Payee Rectype to Simple</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Default CMID to Record ID</fullName>
        <actions>
            <name>Update_GCID_to_Contract_Party_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow to update the Customer Master ID field with the Contract party Record ID if there is no Customer Reference, or if the Customer&apos;s Customer Master ID is blank. This is to ensure the SAP integration has an ID to map on.</description>
        <formula>AND(OR( ISBLANK( Account_vod__c ), ISBLANK(Account_vod__r.BP_ID_BMS_CORE__c)
),

CreatedById &lt;&gt; &apos;005d0000002bfc8&apos; 

)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Customer Master ID HCPTS</fullName>
        <actions>
            <name>Global_ID_Field_Update_HCPTS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow to add the Customer Master ID from the account object to the Contract Party record</description>
        <formula>Account_vod__c &lt;&gt; null</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Recordtype for Germany %28Simple%29</fullName>
        <actions>
            <name>Update_Payee_Rectype_to_Simple</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Simplified markets introduced a new rectype. This WF is to keep compatibility with Germany. When integration pushes in a new record, it does not send a RectypeId. This WF will set the rectype id.</description>
        <formula>AND ( NOT(ISBLANK(Country_vod__c)), Country_vod__r.Alpha_2_Code_vod__c  &lt;&gt; &apos;DE&apos;  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
