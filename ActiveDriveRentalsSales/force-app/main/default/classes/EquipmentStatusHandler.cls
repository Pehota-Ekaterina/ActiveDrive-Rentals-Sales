public with sharing class EquipmentStatusHandler {
    public static void updateEquipmentStatusRented(List<Rental__c> rentalsList) {
        List<Equipment__c> equipmentsList = new List<Equipment__c>();
        Set<Id> equipmentsIdList = new Set<Id>();
        for (Rental__c rental: rentalsList) {
            if (rental.Status__c == 'Active') {
                equipmentsIdList.add(rental.Equipment__c);
            }
        }
        if (equipmentsIdList.isEmpty()) {
            return;
        }

        equipmentsList = [SELECT Id, Status__c FROM Equipment__c WHERE Id IN :equipmentsIdList];
        for (Equipment__c equipment: equipmentsList) {
            equipment.Status__c = 'Rented';
        }
        update equipmentsList;
    }

    public static void updateEquipmentStatusAvailable(List<Rental__c> rentalsList, Map<Id, Rental__c> oldRentals) {
        List<Equipment__c> equipmentsList = new List<Equipment__c>();
        Set<Id> equipmentsIdList = new Set<Id>();
        for (Rental__c rental: rentalsList) {
            Rental__c oldRental = oldRentals.get(rental.Id);
            if ((rental.Status__c == 'Completed' && oldRental.Status__c != 'Completed') || (rental.Status__c == 'Canceled' && oldRental.Status__c != 'Canceled')) {
                equipmentsIdList.add(rental.Equipment__c);
            }
        }
        if (equipmentsIdList.isEmpty()) {
            return;
        }

        equipmentsList = [SELECT Id, Status__c FROM Equipment__c WHERE Id IN :equipmentsIdList];
        for (Equipment__c equipment: equipmentsList) {
            equipment.Status__c = 'Available';
        }
        update equipmentsList;
    }
}