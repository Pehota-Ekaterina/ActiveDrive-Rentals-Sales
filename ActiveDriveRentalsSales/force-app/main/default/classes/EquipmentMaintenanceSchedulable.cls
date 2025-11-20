public with sharing class EquipmentMaintenanceSchedulable implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new EquipmentMaintenanceBatch(), 200);
    }
}