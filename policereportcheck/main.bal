import ballerina/http;
import ballerina/sql;
import ballerina/time;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

type CriminalFiles record {|
    readonly int caseID;
    @sql:Column {name: "offender_nic"}
    string offenderNIC;
    @sql:Column {name: "offender_name"}
    string offenderName;
    @sql:Column {name: "case_title"}
    string caseTitle;
    @sql:Column {name: "case_description"}
    string caseDescription;
    @sql:Column {name: "case_penalty"}
    string casePenalty;
    @sql:Column {name: "record_date"}
    time:Date dateOfRecord;
    @sql:Column {name: "is_convicted"}
    boolean isConvicted;
|};


mysql:Client mysqlClient = check new (host = "localhost", port = 3306, user = "root",
    password = "1234", database = "grama"
);

type PoliceCheckResponse record {|
    boolean isCriminalFiles;
    CriminalFiles[] userCriminalFiles;

    
|};



service /police\-report\-check on new http:Listener(9090) {
    resource function get cRecords/[string NIC]() returns PoliceCheckResponse|error? {
        CriminalFiles[] criminalFiles = [];
    stream<CriminalFiles, error?> resultStream = mysqlClient->query(
        `SELECT * FROM CriminalFiles WHERE offender_nic = ${NIC}`);
    check from CriminalFiles userCriminalFile in resultStream
        do {
            criminalFiles.push(userCriminalFile);
        };
    check resultStream.close();
    
  PoliceCheckResponse policeCheckResponse;

    if criminalFiles.length() >0 {

        policeCheckResponse= {
        isCriminalFiles:true,
        userCriminalFiles:criminalFiles
        };
    }else{
        policeCheckResponse= {
        isCriminalFiles:false,
        userCriminalFiles:criminalFiles
        };
      
    }
    return policeCheckResponse;  
}

    }

