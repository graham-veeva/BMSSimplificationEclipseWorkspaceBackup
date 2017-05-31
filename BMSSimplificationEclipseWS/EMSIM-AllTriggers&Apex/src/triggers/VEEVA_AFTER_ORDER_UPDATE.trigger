trigger VEEVA_AFTER_ORDER_UPDATE on Order_vod__c (after update) {
    // propogate status to child orders
    List<Order_vod__c> childOrders = new List<Order_vod__c>();
    for (Order_vod__c child : [SELECT Id, Lock_vod__c, Status_vod__c, Parent_Order_vod__r.Status_vod__c FROM Order_vod__c WHERE Parent_Order_vod__c IN :Trigger.newMap.keySet()]) {
        if (child.Status_vod__c != 'Submitted_vod' && !child.Lock_vod__c && child.Status_vod__c != child.Parent_Order_vod__r.Status_vod__c) {
            Order_vod__c toUpdate = new Order_vod__c(
                Id = child.Id,
                Status_vod__c = child.Parent_Order_vod__r.Status_vod__c
            );
            childOrders.add(toUpdate);
        }
    }
    if (!childOrders.isEmpty()) {
        update childOrders;
    }
}