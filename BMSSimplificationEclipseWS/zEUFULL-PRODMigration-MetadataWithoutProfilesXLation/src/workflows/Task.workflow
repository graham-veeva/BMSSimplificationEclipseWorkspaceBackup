<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Veeva_Task_Assignment_Alert</fullName>
        <description>Veeva Task Assignment Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Veeva_Task_Assignment_Notification</template>
    </alerts>
    <rules>
        <fullName>Send Task Assignment Email</fullName>
        <actions>
            <name>Veeva_Task_Assignment_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send Task Assignment Email</description>
        <formula>AND (  BEGINS(WhatId ,  $Label.EM_EVENT_VOD_OBJ_ID ) , OR(ISNEW(),ISCHANGED(OwnerId)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
