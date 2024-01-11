import ballerina/persist as _;
import ballerina/time;

type User record {|
    readonly int id;
    string name;
    time:Date birthDate;
    string mobileNumber;
    Record irecord; // Use "?" to indicate a nullable type
|};

type Record record{|
    readonly int crimId;
    string ctype;
    string description;
    User[] users; // Renamed from "user" to "users" to avoid naming conflicts
|};
