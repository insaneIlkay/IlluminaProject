trigger RiskEventSubscriber on RiskChangeEvent__e (after insert) {
    List<Case> casesToCreate = new List<Case>();

    for (RiskChangeEvent__e event : Trigger.new) {
        Account acc = [SELECT Id, OwnerId FROM Account WHERE Id = :event.AccountId__c LIMIT 1];

        User otherUser = [SELECT Id FROM User WHERE Id != :acc.OwnerId AND IsActive = true LIMIT 1];

        casesToCreate.add(new Case(
            AccountId = acc.Id,
            Subject = 'High Risk Case',
            Status = 'New',
            OwnerId = otherUser.Id,
            Description = 'Case triggered due to High Risk selection.'
        ));
    }

    if (!casesToCreate.isEmpty()) {
        insert casesToCreate;
    }
}