
*** Settings ***
Library    Collections
Library    String
Library    HttpLibrary.HTTP
Library    RequestsLibrary

*** Variables ***
${url}   http://partner-api.acommerce.service/partners

@{header_response}        name    slug    active     spreadsheetPath  imagePath

${์NEW_PARTNER_CREATE_JSON}         { "name": "Partner Name", "slug": "partner-name" , "active": "true", "spreadsheetPath": "/spreadsheets/", "imagePath":"/image/"}
${์NEW_PARTNER_UPDATE_JSON}         { "name": "Partner Name", "slug": "partner-name" , "active": "true", "spreadsheetPath": "/excels/", "imagePath":"/image/"}

*** Test Cases ***
Retrive all partners should be successfully
    &{params}=    Create Dictionary    type=json
    ${resp}=  Get Retrieve all partners  ${params}
    Response Status Code Should Equal     200


Retrive a single partner should be successfully
    &{params}=    Create Dictionary    type=json
    ${resp}=  Get Retrieve a single partner  ${params}
    Response Status Code Should Equal     200

Retrive a retrieves active partners should be successfully
    &{params}=    Create Dictionary
    ...    type=json
    ...    active=true
     ${resp}=    Get partners JSON    ${params}  0
    Log Json    ${resp.content}
    Response Status should be Success    ${resp}
    ${header}=    Get Json Value and convert to Object    ${resp.content}    /Header
    Response Should Contain Keys   ${header_response}

Create a new partner should be successfully
    Create a new partner Request
    Response Status Code Should Equal     201
    Created a new partner details Should Be Correct

Updating a partner should be successfully
    Update a new partner Request
    Response Status Code Should Equal     200
    Update a new partner details Should Be Correct

Delete a partner should be successfully
    &{params}=    Create Dictionary    type=json
    ${resp}=  Delete Retrieve a single partner  ${params}
    Response Status Code Should Equal     200

*** Keywords ***
Get Retrieve all partners
    [Arguments]    ${params}
    Create Session    partnerService    ${url}
    ${resp}=    Get Request    partnerService  params=${params}
    Return From Keyword    ${resp}

Get Retrieve a single partner
    [Arguments]    ${params}  ${id}
    Create Session  partnerService  ${url}.${id}
    ${resp}=    Get Request    partnerService  params=${params}
    Return From Keyword    ${resp}

Get Retrieves active partners
    &{params}=    Create Dictionary
    ...    type=json
    ...    active=true
    Create Session  partnerService  ${url}.{0}
    ${resp}=    Get Request    partnerService
    Return From Keyword    ${resp}

Get partners JSON
    [Arguments]    ${params}  ${id}
    Create Session    partnerService    ${url}
    ${resp}=    Get Request    partnerService    /${id} ?active=true    params=${params}
    Return From Keyword    ${resp}

Delete Retrieve a single partner
    [Arguments]    ${params}  ${id}
    Create Session  partnerService  ${url}.${id}
    ${resp}=    Delete Request    partnerService  params=${params}
    Return From Keyword    ${resp}

Create a new partner Request
    Set Request Header                    Content-Type          application/json
    Set Request Body                      ${์NEW_PARTNER_CREATE_JSON}


Update a new partner Request
    Set Request Header                    Content-Type          application/json
    Set Request Body                      ${์NEW_PARTNER_UPDATE_JSON}

Response Should Contain Keys
    [Arguments]    ${object}    ${expected_keys}
    ${object_keys}    Get Dictionary Keys    ${object}
    Sort List    ${object_keys}
    Sort List    ${expected_keys}
    Log List    ${object_keys}
    Log List    ${expected_keys}
    Lists Should Be Equal    ${object_keys}    ${expected_keys}

Created a new partner details Should Be Correct
    ${result} =                           Parse Response Body To Json
    ${expectation} =                      Parse Json From File
    Should Be Equal                       ${result}                ${expectation}

Update a new partner details Should Be Correct
    ${result} =                           Parse Response Body To Json
    ${expectation} =                      Parse Json From File
    Should Be Equal                       ${result}                ${expectation}