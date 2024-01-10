import ballerina/http;
import ballerina/time;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

type User record {|
    readonly int id;
    string name;

    @sql:Column{name:"birth_date"}
    time:Date birthDate;

    @sql:Column{name:"mobile_number"}
    string mobileNumber;
    

|};

table<User> key(id) users =table[
    {id:1,name:"milanka",birthDate: {year: 2020, month: 7, day: 10},mobileNumber: "0718528522"}
];

type ErrorDetails record {
    string messages;
    string details;
    time:Utc timeStamp; 
};

type UserNotFound record {|
*http:NotFound;
ErrorDetails body;
    
|};

type NewUser record {|
    string name;
    time:Date birthDate;
    string mobileNumber;
    
|};

  mysql:Client mysqlClient = check new (host = "localhost", port = 3306, user = "root",
                                          password = "1234",database="grama");


service /new\-medium on new http:Listener(9090) {
    //new-medium/users         GET service
    resource function get users() returns User[]|error? {
        stream<User,sql:Error?> userStream = mysqlClient->query(`SELECT * FROM users`);
        return from var user in userStream select user;


        // return users.toArray();
    }

    //get users on id
     resource function get users/[int id]() returns User|UserNotFound|error? {

        User|sql:Error user=mysqlClient->queryRow(`select * from users where id=${id}`);
        if user is sql:NoRowsError{
             UserNotFound userNotFound={
                body: {messages:string `id:${id}`, details: string `user/${id}`, timeStamp: time:utcNow() }
            };
          return userNotFound;
        }
        return user;
           
        }

        // User? user=users[id];
        // if user is(){
        //     UserNotFound userNotFound={
        //         body: {messages:string `id:${id}`, details: string `user/${id}`, timeStamp: time:utcNow() }
        //     };
        //   return userNotFound;
        // }
        // return user;
   // }
        resource function post users(NewUser newUser) returns http:Created|error? {
        _=check mysqlClient->execute(`
        INSERT INTO users(birth_date, name, mobile_number)
        VALUES(${newUser.birthDate}, ${newUser.name}, ${newUser.mobileNumber});
        `);
        return http:CREATED;
    }

    //     resource function post users(NewUser newUser) returns http:Created|error? {
    //     users.add({id: users.length() + 1, ...newUser.clone()});
    //     return http:CREATED;
    // }

}
