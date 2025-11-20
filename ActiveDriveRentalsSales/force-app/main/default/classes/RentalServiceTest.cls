@IsTest
public class RentalServiceTest {
    @TestSetup
    static void makeData(){
        List<Equipment__c> equipments = new List<Equipment__c>();
        Equipment__c equipmentAvailable = new Equipment__c(Name = 'Test0', Category__c = 'Car', Status__c = 'Available', Daily_Rent_Price__c = 100);
        equipments.add(equipmentAvailable);
        Equipment__c equipmentInService = new Equipment__c(Name = 'Test1', Category__c = 'Car', Status__c = 'In Service', Daily_Rent_Price__c = 100);
        equipments.add(equipmentInService);
        Equipment__c equipmentRented = new Equipment__c(Name = 'Test2', Category__c = 'Car', Status__c = 'Rented', Daily_Rent_Price__c = 100);
        equipments.add(equipmentRented);
        Equipment__c equipmentSold = new Equipment__c(Name = 'Test3', Category__c = 'Car', Status__c = 'Sold', Daily_Rent_Price__c = 100);
        equipments.add(equipmentSold);
        Equipment__c equipmentReserved = new Equipment__c(Name = 'Test4', Category__c = 'Car', Status__c = 'Reserved', Daily_Rent_Price__c = 100);
        equipments.add(equipmentReserved);
        insert equipments; 
        
        Contact contact = new Contact();
        contact.FirstName = 'RentalService';
        contact.LastName = 'Test';
        insert contact;
    }

    @IsTest
    public static void testCalculationRental() {
        Equipment__c equipment = [SELECT Id, Status__c, Daily_Rent_Price__c FROM Equipment__c WHERE Name = 'Test0' LIMIT 1];
        Date startDate = Date.today();
        Date endDate = startDate.addDays(3);
        Decimal result = RentalService.calculationRental(equipment.Id, startDate, endDate);
        System.assertEquals((startDate.daysBetween(endDate) + 1) * equipment.Daily_Rent_Price__c, result, 'methode calculationRental is not working correctly');
    }

    @IsTest
    public static void testIsEquipmentAvailable() {
        Date startDate = Date.today();
        Date endDate = startDate.addDays(3);
        Equipment__c equipmentAvailable = [SELECT Id, Status__c, Daily_Rent_Price__c FROM Equipment__c WHERE Status__c = 'Available' LIMIT 1];
        Equipment__c equipmentInService = [SELECT Id, Status__c, Daily_Rent_Price__c FROM Equipment__c WHERE Status__c = 'In Service' LIMIT 1];
        Equipment__c equipmentRented = [SELECT Id, Status__c, Daily_Rent_Price__c FROM Equipment__c WHERE Status__c = 'Rented' LIMIT 1];
        Equipment__c equipmentSold = [SELECT Id, Status__c, Daily_Rent_Price__c FROM Equipment__c WHERE Status__c = 'Sold' LIMIT 1];
        Equipment__c equipmentReserved = [SELECT Id, Status__c, Daily_Rent_Price__c FROM Equipment__c WHERE Status__c = 'Reserved' LIMIT 1];

        

        System.assertEquals(true, RentalService.isEquipmentAvailable(equipmentAvailable.Id, startDate, endDate), 'methode isEquipmentAvailable is not working correctly with Available status');
        System.assertEquals(false, RentalService.isEquipmentAvailable(equipmentInService.Id, startDate, endDate), 'methode isEquipmentAvailable is not working correctly with In Service status');
        System.assertEquals(false, RentalService.isEquipmentAvailable(equipmentSold.Id, startDate, endDate), 'methode isEquipmentAvailable is not working correctly with Sold status');

        //System.assertEquals(, RentalService.isEquipmentAvailable(equipmentRented.Id, startDate, endDate), 'methode isEquipmentAvailable is not working correctly with Rented status');
        //System.assertEquals(, RentalService.isEquipmentAvailable(equipmentReserved.Id, startDate, endDate), 'methode isEquipmentAvailable is not working correctly with Reserved status');
    }

    @IsTest
    public static void testCreateRental() {

        Date startDate1 = Date.today();
        Date endDate1 = startDate1.addDays(3);
        Date startDate2 = startDate1.addDays(5);
        Date endDate2 = startDate2.addDays(3);
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Equipment__c equipment = [SELECT Id, Status__c, Daily_Rent_Price__c FROM Equipment__c LIMIT 1];

        RentalService.createRental(equipment.Id, contact.Id, startDate1, endDate1);
        RentalService.createRental(equipment.Id, contact.Id, startDate2, endDate2);

        List<Rental__c> rentals = [SELECT Id, Status__c FROM Rental__c];
        List<Rental__c> rentalsNew = [SELECT Id, Status__c FROM Rental__c WHERE Status__c = 'New'];
        List<Rental__c> rentalsActive = [SELECT Id, Status__c FROM Rental__c WHERE Status__c = 'Active'];
        System.assertEquals(2, rentals.size(), 'methode createRental is not working correctly');
        System.assertEquals(1, rentalsNew.size(), 'methode createRental is not working correctly');
        System.assertEquals(1, rentalsActive.size(), 'methode createRental is not working correctly');
    }
}