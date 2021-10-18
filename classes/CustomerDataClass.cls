public class CustomerDataClass {
    public class PrimaryEmailAddr{
        public String Address {get;set;}
    }
    public class PrimaryPhone{
        public String FreeFormNumber {get;set;}
    }
    public class BillAddress{
        public String City {get;set;}
        public String Line1 {get;set;}
        public String PostalCode {get;set;}
        public String CountrySubDivisionCode {get;set;}
    }
    public class ShipAddress {
        public String City {get;set;}
        public String Line1 {get;set;}
        public String PostalCode {get;set;}
        public String CountrySubDivisionCode {get;set;}
    }

    public class Customer {
        public String GivenName {get; set;}
        public String MiddleName {get;set;}
        public String FamilyName {get; set;}
        public PrimaryEmailAddr PrimaryEmailAddr {get;set;}
        public PrimaryPhone PrimaryPhone {get;set;}
        public BillAddress BillAddr {get; set;}
        public ShipAddress ShipAddr {get; set;}
        public String Id {get; set;}
    }
    public class QueryResponse{
        public List<Customer> Customer {get; set;}
    }
    public QueryResponse QueryResponse {get;set;}
}