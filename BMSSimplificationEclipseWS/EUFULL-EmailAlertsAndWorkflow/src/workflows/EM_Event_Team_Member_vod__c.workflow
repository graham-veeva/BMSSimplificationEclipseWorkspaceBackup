<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_EM_2_0_User_of_addition_to_team</fullName>
        <description>Notify EM 2.0 User of addition to team</description>
        <protected>false</protected>
        <recipients>
            <field>Team_Member_vod__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Event_Team_Member_Template_2_0</template>
    </alerts>
    <alerts>
        <fullName>Processor_Review_Email</fullName>
        <description>Processor Review Email</description>
        <protected>false</protected>
        <recipients>
            <field>Team_Member_vod__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BMS_HCPTS_EM_Templates/Activity_Review_Template</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_Alert_To_Support_Member</fullName>
        <description>Send Email Alert To Support Member</description>
        <protected>false</protected>
        <recipients>
            <field>Team_Member_vod__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Activity_Team_Member_Template</template>
    </alerts>
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
    <rules>
        <fullName>Activity%3A Update Approver ID</fullName>
        <actions>
            <name>Activity_BMS_Employee_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EM_Event_Team_Member_vod__c.Role_vod__c</field>
            <operation>equals</operation>
            <value>Approver_vod</value>
        </criteriaItems>
        <description>Update the Approver ID field on EM Activity after Activity is approved</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert Team Member</fullName>
        <actions>
            <name>Send_Email_Alert_To_Support_Member</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(LastModifiedById &lt;&gt; Team_Member_vod__c ,
NOT( RecordType.DeveloperName = &apos;Activity_Team_Member_Simple_HCPTS&apos;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Alert Team Member 2%2E0 %28Simple%29</fullName>
        <actions>
            <name>Notify_EM_2_0_User_of_addition_to_team</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Alert Team Member for 2.0 Simplified build to not impact Germany</description>
        <formula>AND( 
 RecordType.DeveloperName = &apos;Activity_Team_Member_Simple_HCPTS&apos;,
NOT(ISPICKVAL(Role_vod__c,&apos;Approver_vod&apos;)), LastModifiedById &lt;&gt; Team_Member_vod__c )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Change Status to Processor Review</fullName>
        <actions>
            <name>Processor_Review_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>EM_Status_Processor_Review</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EM_Event_Team_Member_vod__c.Role_vod__c</field>
            <operation>equals</operation>
            <value>Service Coordinator</value>
        </criteriaItems>
        <criteriaItems>
            <field>EM_Event_vod__c.Status_vod__c</field>
            <operation>equals</operation>
            <value>In Draft</value>
        </criteriaItems>
        <description>Change EM Activity to In Service Coordinator Review only when a Processor is added to an Activity in Draft Status so that Service Coordinator can be notified of an Activity</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EM Service Coordinator Update Activity</fullName>
        <actions>
            <name>Processor_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Processor_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Processor_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Processor_Phone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>EM_Event_Team_Member_vod__c.Role_vod__c</field>
            <operation>equals</operation>
            <value>Service Coordinator</value>
        </criteriaItems>
        <criteriaItems>
            <field>EM_Event_vod__c.Activity_Type_Formula_HCPTS__c</field>
            <operation>notEqual</operation>
            <value>Standard Rep Presentation</value>
        </criteriaItems>
        <description>Update EM Activity with Service Coordinator information from Team Member RL</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Approver Email on Activity</fullName>
        <actions>
            <name>Update_Approver_Email_on_Activity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EM_Event_Team_Member_vod__c.Role_vod__c</field>
            <operation>equals</operation>
            <value>Approver_vod</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
