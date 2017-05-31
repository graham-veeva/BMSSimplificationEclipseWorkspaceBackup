<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
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
