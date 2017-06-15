<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Activity_BMS_Employee_ID</fullName>
        <description>Update Approver ID with BMS Employee ID when Team Member Role = Approver</description>
        <field>Approver_ID_HCPTS__c</field>
        <formula>Team_Member_vod__r.BMS_Employee_ID__c</formula>
        <name>Activity: BMS Employee ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Event_vod__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EM_Activity_Approver_Email_Unique_Na</fullName>
        <description>Update Approver Email with last Approver&apos;s email</description>
        <field>Approver_Email_HCPTS__c</field>
        <formula>Team_Member_vod__r.Email</formula>
        <name>EM Activity Approver Email	 	  Unique Na</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Event_vod__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EM_Status_Processor_Review</fullName>
        <description>Change EM Activity to In Processor Review only when a Processor is added to an Activity in Draft Status</description>
        <field>Status_vod__c</field>
        <literalValue>In Service Coordinator Review</literalValue>
        <name>EM Status = In Processor Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Event_vod__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Processor_Country</fullName>
        <description>Processor Country</description>
        <field>Processor_Country_HCPTS__c</field>
        <formula>Team_Member_vod__r.Country</formula>
        <name>Processor Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Event_vod__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Processor_Email</fullName>
        <description>Field update Service Coordinator email on Activity</description>
        <field>Processor_Email_HCPTS__c</field>
        <formula>Email_HCPTS__c</formula>
        <name>Service Coordinator Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Event_vod__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Processor_Email_HCPTS</fullName>
        <description>Processor Email</description>
        <field>Processor_Email_HCPTS__c</field>
        <formula>Team_Member_vod__r.Email</formula>
        <name>Processor Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Event_vod__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Processor_Name</fullName>
        <description>Update Processor Name</description>
        <field>Processor_HCPTS__c</field>
        <formula>Team_Member_vod__r.FirstName+&quot; &quot;+ Team_Member_vod__r.LastName</formula>
        <name>Processor Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Event_vod__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Processor_Phone</fullName>
        <description>Processor Phone</description>
        <field>Processor_Phone_HCPTS__c</field>
        <formula>Team_Member_vod__r.Phone</formula>
        <name>Processor Phone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Event_vod__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approver_Email_on_Activity</fullName>
        <field>Approver_Email_HCPTS__c</field>
        <formula>Email_HCPTS__c</formula>
        <name>Update Approver Email on Activity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Event_vod__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Certifier_on_Activity</fullName>
        <field>Certifier_Formula_HCPTS__c</field>
        <formula>Team_Member_vod__r.Email</formula>
        <name>Update Certifier on Activity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Event_vod__c</targetObject>
    </fieldUpdates>
</Workflow>
