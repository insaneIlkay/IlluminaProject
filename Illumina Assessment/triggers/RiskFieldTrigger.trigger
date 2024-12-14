trigger RiskFieldTrigger on Account (after insert,after update) {
    List<RiskChangeEvent__e> events = new List<RiskChangeEvent__e>();
    if (Trigger.isInsert) {
        for (Account acc : Trigger.new) {
            if (acc.Risk__c == 'High') {
                events.add(new RiskChangeEvent__e(
                    AccountId__c = acc.Id,
                    RiskLevel__c = acc.Risk__c
                ));
            }
        }
    }
    if (Trigger.isUpdate) {
        for (Account acc : Trigger.new) {
            Account oldAcc = Trigger.oldMap.get(acc.Id);

            if (acc.Risk__c == 'High' && oldAcc.Risk__c != 'High') {
                events.add(new RiskChangeEvent__e(
                    AccountId__c = acc.Id,
                    RiskLevel__c = acc.Risk__c
                ));
            }
        }
    }
    if (!events.isEmpty()) {
        EventBus.publish(events);
    }
}