trigger VEEVA_INVENTORY_ORDER_LINE_BEFORE_DEL on Inventory_Order_Line_vod__c (before delete) {
    for (Integer i = 0 ; i < Trigger.old.size(); i++) {
        String status = Trigger.old[i].Inventory_Order_Line_Status_vod__c;
        if ((status != 'New_vod') && (status != 'Saved_vod') && (status != 'Canceled_vod')) {
            Trigger.old[i].addError('Order line cannot be deleted because of status.');
        }
    }
}