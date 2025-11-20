public with sharing class EquipmentMaintenanceBatch implements Database.Batchable<SObject>, Database.Stateful {
    private Set<Id> equipmentIdsToUpdate = new Set<Id>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM Equipment__c WHERE Status__c = \'Available\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Equipment__c> scope) {

        Set<Id> equipmentIds = new Set<Id>();
        for (Equipment__c equipment : scope) {
            equipmentIds.add(equipment.Id);
        }
        
        Date checkDate = Date.today().addDays(-90);
        List<Rental__c> rentalsList = [SELECT Equipment__c FROM Rental__c WHERE Equipment__c IN :equipmentIds AND Start_Date__c >= :checkDate];

        Set<Id> idRentals = new Set<Id>();
        for (Rental__c rental: rentalsList) {
            idRentals.add(rental.Id);            
        }

        for (Equipment__c equipment: scope) {
            if (!idRentals.contains(equipment.Id)) {
                equipmentIdsToUpdate.add(equipment.Id);
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        if (!equipmentIdsToUpdate.isEmpty()) {
            List<Equipment__c> equipmentsToUpdate = [SELECT Id, Status__c FROM Equipment__c WHERE Id IN :equipmentIdsToUpdate];
            for (Equipment__c equipment: equipmentsToUpdate) {
                equipment.Status__c = 'In Service';
            }
            update equipmentsToUpdate;
        }
    }
}
