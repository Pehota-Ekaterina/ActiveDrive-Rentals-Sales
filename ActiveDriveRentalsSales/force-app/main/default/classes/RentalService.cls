public with sharing class RentalService {
    public static void createRental(Id equipmentId, Id contactId, Date startDate, Date endDate) {

        if (endDate < startDate || endDate < Date.today() || startDate < Date.today()) {
            System.debug('Incorrect date');
            throw new RentalException('Incorrect date');
        }
        if (!isEquipmentAvailable(equipmentId, startDate, endDate)) {
            System.debug('The equipment is not available during this period');
            throw new RentalException('The equipment is not available during this period');
        }
        
        Rental__c rental = new Rental__c();
        rental.Equipment__c = equipmentId;
        rental.Customer__c = contactId;
        rental.Start_Date__c = startDate;
        rental.End_Date__c = endDate;
        rental.Status__c = getEquipmentStatus(startDate);
        
        rental.Discount__c = getDiscount();

        //rental.Total_Amount__c = calculationRental(startDate, endDate);
        insert rental;
    }

    private static String getEquipmentStatus(Date startdate) {
        if (startDate == Date.today()) {
            return 'Active';
        } else {
            return 'New';
        }
    }

    private static Decimal getDiscount() {
        ActiveDrive_Management_Setting__mdt settings = ActiveDrive_Management_Setting__mdt.getInstance('Default');
        Decimal discount = settings.standart_Daily_Discount_Rate__c;
        return discount;
    }

    public static Boolean isEquipmentAvailable(Id equipmentId, Date startDate, Date endDate) {
        Equipment__c equipment = [SELECT Id, Status__c FROM Equipment__c WHERE Id = :equipmentId];

        if (equipment.Status__c == 'Available') {
            return true;
        }
        if (equipment.Status__c == 'Reserved' || equipment.Status__c == 'Rented') {
            List<Rental__c> rentalList = [SELECT Id, Start_Date__c, End_Date__c, Status__c FROM Rental__c WHERE Equipment__c = :equipmentId AND (Status__c IN ('New', 'Active'))];
            //Boolean isAvailable = true;
            for (Rental__c rental: rentalList) {
                if ( startDate <= rental.End_Date__c && endDate >= rental.Start_Date__c) {
                    return false;   //isAvailable = false;
                }
            }
            return true;    //return isAvailable;
        }
        return false;
    }

    public static Decimal calculationRental(Id equipmentId, Date startDate, Date endDate) {
        Equipment__c equipment = [SELECT Daily_Rent_Price__c FROM Equipment__c WHERE Id = :equipmentId];
        return (startDate.daysBetween(endDate) + 1) * equipment.Daily_Rent_Price__c;
    }

    public class RentalException extends Exception {}
}