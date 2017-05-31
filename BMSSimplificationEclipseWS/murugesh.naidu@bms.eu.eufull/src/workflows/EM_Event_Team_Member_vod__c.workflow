<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
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
    <rules>
        <fullName>Alert Team Member</fullName>
        <actions>
            <name>Send_Email_Alert_To_Support_Member</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( NOT(ISPICKVAL(Role_vod__c,&apos;Approver_vod&apos;)), LastModifiedById &lt;&gt; Team_Member_vod__c )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
