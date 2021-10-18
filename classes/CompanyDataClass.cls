public with sharing class CompanyDataClass {
    public class PrimaryPhone{
        public String FreeFormNumber {get;set;}
    }
    public class CompanyAddress{
        public String City {get;set;}
        public String Country {get;set;}
        public String Line1 {get;set;}
        public String PostalCode {get;set;}
        public String CountrySubDivisionCode {get;set;}
    }
    public class Company {
        public String CompanyName {get; set;}
        public CompanyAddress CompanyAddr {get;set;}
        public String Id {get;set;}
        public PrimaryPhone PrimaryPhone {get;set;}
    }
    public class QueryResponse{
        public List<Company> CompanyInfo {get; set;}
    }
    public QueryResponse QueryResponse {get;set;}
}
