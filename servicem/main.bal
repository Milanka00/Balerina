import ballerina/http;
import ballerina/time;

type User record {|
    int id;
    string name;
    time:Date birthDate;
    string mobileNumber;
    

|};

service /new\-medium on new http:Listener(9090) {
    //new-medium/users         GET service
    resource function get users() returns User[]|error? {
        User joe={id:1,name:"milanka",birthDate: {year: 2020, month: 7, day: 10},mobileNumber: "0718528522"};
        return [joe];
    }
}
