trigger RentalTrigger on Rental__c (after insert, after update) {
    if (Trigger.isInsert) {
        EquipmentStatusHandler.updateEquipmentStatusRented(Trigger.new);
    }
    if (Trigger.isUpdate) {
        EquipmentStatusHandler.updateEquipmentStatusAvailable(Trigger.new, Trigger.oldMap);        
    }
}