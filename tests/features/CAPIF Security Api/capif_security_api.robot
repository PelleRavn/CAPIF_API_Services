*** Settings ***
Resource        /opt/robot-tests/tests/resources/common.resource
Library         /opt/robot-tests/tests/libraries/bodyRequests.py
Resource        /opt/robot-tests/tests/resources/common/basicRequests.robot
Resource        ../../resources/common.resource

Test Setup      Reset Testing Environment


*** Variables ***
${APF_ID_NOT_VALID}             apf-example
${SERVICE_API_ID_NOT_VALID}     not-valid
${API_INVOKER_NOT_VALID}        not-valid


*** Test Cases ***
Create a security context for an API invoker
    [Tags]    capif_security_api-1
    # Default Invoker Registration and Onboarding
    ${register_user_info_invoker}    ${url}    ${request_body}=    Invoker Default Onboarding

    # Create Security Context
    ${request_body}=    Create Service Security Body
    ${resp}=    Put Request Capif
    ...    /capif-security/v1/trustedInvokers/${register_user_info_invoker['apiInvokerId']}
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${INVOKER_USERNAME}

    # Check Results
    Status Should Be    201    ${resp}
    Check Variable    ${resp.json()}    ServiceSecurity
    ${resource_url}=    Check Location Header    ${resp}    ${LOCATION_SECURITY_RESOURCE_REGEX}

Create a security context for an API invoker with Exposer role
    [Tags]    capif_security_api-2
    # Default Invoker Registration and Onboarding
    ${register_user_info_invoker}    ${url}    ${request_body}=    Invoker Default Onboarding

    # Register Exposer
    ${register_user_info_publisher}=    Publisher Default Registration

    # Create Security Context
    ${request_body}=    Create Service Security Body
    ${resp}=    Put Request Capif
    ...    /capif-security/v1/trustedInvokers/${register_user_info_invoker['apiInvokerId']}
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${PUBLISHER_USERNAME}

    # Check Results
    Status Should Be    403    ${resp}
    Check Problem Details    ${resp}
    ...    title=Forbidden
    ...    status=403
    ...    detail=Role not authorized for this API route
    ...    cause=User role must be invoker

Create a security context for an API invoker with Exposer entity role and invalid apiInvokerId
    [Tags]    capif_security_api-3
    # Register APF
    ${register_user_info_publisher}=    Publisher Default Registration

    # Create Security Context
    ${request_body}=    Create Service Security Body
    ${resp}=    Put Request Capif
    ...    /capif-security/v1/trustedInvokers/${API_INVOKER_NOT_VALID}
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${PUBLISHER_USERNAME}
    
    # Check Results
    Status Should Be    403    ${resp}
    Check Problem Details    ${resp}
    ...    title=Forbidden
    ...    status=403
    ...    detail=Role not authorized for this API route
    ...    cause=User role must be invoker

Create a security context for an API invoker with Invalid apiInvokerID
    [Tags]    capif_security_api-4
    # Default Invoker Registration and Onboarding
    ${register_user_info_invoker}    ${url}    ${request_body}=    Invoker Default Onboarding

    ${request_body}=    Create Service Security Body
    ${resp}=    Put Request Capif
    ...    /capif-security/v1/trustedInvokers/${API_INVOKER_NOT_VALID}
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${INVOKER_USERNAME}

    Status Should Be    404    ${resp}

Retrieve the Security Context of an API Invoker
    [Tags]    capif_security_api-5
    # Default Invoker Registration and Onboarding
    ${register_user_info_invoker}    ${url}    ${request_body}=    Invoker Default Onboarding

    ${request_body}=    Create Service Security Body
    ${resp}=    Put Request Capif
    ...    /capif-security/v1/trustedInvokers/${register_user_info_invoker['apiInvokerId']}
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${INVOKER_USERNAME}

    Status Should Be    201    ${resp}

    #Register APF
    ${register_user_info_publisher}=    Publisher Default Registration

    ${resp}=    Get Request Capif
    ...    /capif-security/v1/trustedInvokers/${register_user_info_invoker['apiInvokerId']}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${PUBLISHER_USERNAME}

    Status Should Be    200    ${resp}

Retrieve the Security Context of an API Invoker with invalid apiInvokerID
    [Tags]    capif_security_api-6
    #Register APF
    ${register_user_info_publisher}=    Publisher Default Registration

    ${resp}=    Get Request Capif
    ...    /capif-security/v1/trustedInvokers/${API_INVOKER_NOT_VALID}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${PUBLISHER_USERNAME}

    Status Should Be    404    ${resp}

Retrieve the Security Context of an API Invoker with invalid apfId
    [Tags]    capif_security_api-7
    # Default Invoker Registration and Onboarding
    ${register_user_info_invoker}    ${url}    ${request_body}=    Invoker Default Onboarding

    ${request_body}=    Create Service Security Body
    ${resp}=    Put Request Capif
    ...    /capif-security/v1/trustedInvokers/${register_user_info_invoker['apiInvokerId']}
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${INVOKER_USERNAME}

    Status Should Be    201    ${resp}

    # We will request information using invoker user, that is not allowed
    ${resp}=    Get Request Capif
    ...    /capif-security/v1/trustedInvokers/${register_user_info_invoker['apiInvokerId']}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${INVOKER_USERNAME}

    Status Should Be    403    ${resp}

Delete the Security Context of an API Invoker
    [Tags]    capif_security_api-8
    # Default Invoker Registration and Onboarding
    ${register_user_info_invoker}    ${url}    ${request_body}=    Invoker Default Onboarding

    ${request_body}=    Create Service Security Body
    ${resp}=    Put Request Capif
    ...    /capif-security/v1/trustedInvokers/${register_user_info_invoker['apiInvokerId']}
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${INVOKER_USERNAME}

    Status Should Be    201    ${resp}

    #Register APF
    ${register_user_info_publisher}=    Publisher Default Registration

    ${resp}=    Delete Request Capif
    ...    /capif-security/v1/trustedInvokers/${register_user_info_invoker['apiInvokerId']}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${PUBLISHER_USERNAME}

    Status Should Be    204    ${resp}

Delete the Security Context of an API Invoker with Invoker entity role
    [Tags]    capif_security_api-9
    # Default Invoker Registration and Onboarding
    ${register_user_info_invoker}    ${url}    ${request_body}=    Invoker Default Onboarding

    ${request_body}=    Create Service Security Body
    ${resp}=    Put Request Capif
    ...    /capif-security/v1/trustedInvokers/${register_user_info_invoker['apiInvokerId']}
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${INVOKER_USERNAME}

    Status Should Be    201    ${resp}

    ${resp}=    Delete Request Capif
    ...    /capif-security/v1/trustedInvokers/${register_user_info_invoker['apiInvokerId']}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${INVOKER_USERNAME}

    Status Should Be    403    ${resp}

Delete the Security Context of an API Invoker with Invoker entity role and invalid apiInvokerID
    [Tags]    capif_security_api-10
    # Default Invoker Registration and Onboarding
    ${register_user_info_invoker}    ${url}    ${request_body}=    Invoker Default Onboarding

    ${resp}=    Delete Request Capif
    ...    /capif-security/v1/trustedInvokers/${API_INVOKER_NOT_VALID}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${INVOKER_USERNAME}

    Status Should Be    403    ${resp}

Delete the Security Context of an API Invoker with invalid apiInvokerID
    [Tags]    capif_security_api-11
    #Register APF
    ${register_user_info_publisher}=    Publisher Default Registration

    ${resp}=    Delete Request Capif
    ...    /capif-security/v1/trustedInvokers/${API_INVOKER_NOT_VALID}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${PUBLISHER_USERNAME}

    Status Should Be    404    ${resp}

Update the Security Context of an API Invoker
    [Tags]    capif_security_api-12
    # Default Invoker Registration and Onboarding
    ${register_user_info_invoker}    ${url}    ${request_body}=    Invoker Default Onboarding

    ${request_body}=    Create Service Security Body
    ${resp}=    Put Request Capif
    ...    /capif-security/v1/trustedInvokers/${register_user_info_invoker['apiInvokerId']}
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${INVOKER_USERNAME}

    Status Should Be    201    ${resp}

    ${resp}=    Post Request Capif
    ...    /capif-security/v1/trustedInvokers/${register_user_info_invoker['apiInvokerId']}/update
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${INVOKER_USERNAME}

    Status Should Be    200    ${resp}

Update the Security Context of an API Invoker with AEF entity role
    [Tags]    capif_security_api-13
    # Default Invoker Registration and Onboarding
    ${register_user_info_invoker}    ${url}    ${request_body}=    Invoker Default Onboarding

    ${request_body}=    Create Service Security Body
    ${resp}=    Put Request Capif
    ...    /capif-security/v1/trustedInvokers/${register_user_info_invoker['apiInvokerId']}
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${INVOKER_USERNAME}

    Status Should Be    201    ${resp}

    #Register APF
    ${register_user_info_publisher}=    Publisher Default Registration

    ${resp}=    Post Request Capif
    ...    /capif-security/v1/trustedInvokers/${register_user_info_invoker['apiInvokerId']}/update
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${PUBLISHER_USERNAME}

    Status Should Be    403    ${resp}

Update the Security Context of an API Invoker with AEF entity role and invalid apiInvokerId
    [Tags]    capif_security_api-14
    #Register APF
    ${register_user_info_publisher}=    Publisher Default Registration

    ${request_body}=    Create Service Security Body
    ${resp}=    Post Request Capif
    ...    /capif-security/v1/trustedInvokers/${API_INVOKER_NOT_VALID}/update
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${PUBLISHER_USERNAME}

    Status Should Be    403    ${resp}

Update the Security Context of an API Invoker with invalid apiInvokerID
    [Tags]    capif_security_api-15
    # Default Invoker Registration and Onboarding
    ${register_user_info_invoker}    ${url}    ${request_body}=    Invoker Default Onboarding

    ${request_body}=    Create Service Security Body
    ${resp}=    Post Request Capif
    ...    /capif-security/v1/trustedInvokers/${API_INVOKER_NOT_VALID}/update
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${INVOKER_USERNAME}

    Status Should Be    404    ${resp}

Revoke the authorization of the API invoker for APIs
    [Tags]    capif_security_api-16
    # Default Invoker Registration and Onboarding
    ${register_user_info_invoker}    ${url}    ${request_body}=    Invoker Default Onboarding

    ${request_body}=    Create Service Security Body
    ${resp}=    Put Request Capif
    ...    /capif-security/v1/trustedInvokers/${register_user_info_invoker['apiInvokerId']}
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${INVOKER_USERNAME}

    Status Should Be    201    ${resp}

    #Register APF
    ${register_user_info_publisher}=    Publisher Default Registration

    ${request_body}=    Create Security Notification Body    ${register_user_info_invoker['apiInvokerId']}
    ${resp}=    Post Request Capif
    ...    /capif-security/v1/trustedInvokers/${register_user_info_invoker['apiInvokerId']}/delete
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${PUBLISHER_USERNAME}

    Status Should Be    204    ${resp}

Revoke the authorization of the API invoker for APIs without valid apfID.
    [Tags]    capif_security_api-17
    # Default Invoker Registration and Onboarding
    ${register_user_info_invoker}    ${url}    ${request_body}=    Invoker Default Onboarding

    ${request_body}=    Create Service Security Body
    ${resp}=    Put Request Capif
    ...    /capif-security/v1/trustedInvokers/${register_user_info_invoker['apiInvokerId']}
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${INVOKER_USERNAME}

    Status Should Be    201    ${resp}

    ${request_body}=    Create Security Notification Body    ${register_user_info_invoker['apiInvokerId']}
    ${resp}=    Post Request Capif
    ...    /capif-security/v1/trustedInvokers/${register_user_info_invoker['apiInvokerId']}/delete
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${INVOKER_USERNAME}

    Status Should Be    403    ${resp}

Revoke the authorization of the API invoker for APIs with invalid apiInvokerId
    [Tags]    capif_security_api-18
    #Register APF
    ${register_user_info_publisher}=    Publisher Default Registration

    ${request_body}=    Create Security Notification Body    ${API_INVOKER_NOT_VALID}
    ${resp}=    Post Request Capif
    ...    /capif-security/v1/trustedInvokers/${API_INVOKER_NOT_VALID}/delete
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${PUBLISHER_USERNAME}

    Status Should Be    404    ${resp}

Retrieve access token
    [Tags]    capif_security_api-19
    # Default Invoker Registration and Onboarding
    ${register_user_info_invoker}    ${url}    ${request_body}=    Invoker Default Onboarding

    ${request_body}=    Create Service Security Body
    ${resp}=    Put Request Capif
    ...    /capif-security/v1/trustedInvokers/${register_user_info_invoker['apiInvokerId']}
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${INVOKER_USERNAME}

    Status Should Be    201    ${resp}

    ${request_body}=    Create Access Token Req Body
    ${resp}=    Post Request Capif
    ...    /capif-security/v1/securities/${register_user_info_invoker['apiInvokerId']}/token
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${INVOKER_USERNAME}

    Status Should Be    200    ${resp}

Retrieve access token by AEF
    [Tags]    capif_security_api-20
    # Default Invoker Registration and Onboarding
    ${register_user_info_invoker}    ${url}    ${request_body}=    Invoker Default Onboarding

    ${request_body}=    Create Service Security Body
    ${resp}=    Put Request Capif
    ...    /capif-security/v1/trustedInvokers/${register_user_info_invoker['apiInvokerId']}
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${INVOKER_USERNAME}

    Status Should Be    201    ${resp}

    #Register APF
    ${register_user_info_publisher}=    Publisher Default Registration

    ${request_body}=    Create Access Token Req Body
    ${resp}=    Post Request Capif
    ...    /capif-security/v1/securities/${register_user_info_invoker['apiInvokerId']}/token
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${PUBLISHER_USERNAME}

    Status Should Be    400    ${resp}

    Should Be Equal As Strings    ${resp.json()['error']}    invalid_client
    Should Be Equal As Strings    ${resp.json()['error_description']}    Role not authorized for this API route

Retrieve access token by AEF with invalid apiInvokerId
    [Tags]    capif_security_api-21
    #Register APF
    ${register_user_info_publisher}=    Publisher Default Registration

    ${request_body}=    Create Access Token Req Body
    ${resp}=    Post Request Capif
    ...    /capif-security/v1/securities/${API_INVOKER_NOT_VALID}/token
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${PUBLISHER_USERNAME}

    Status Should Be    400    ${resp}

    Should Be Equal As Strings    ${resp.json()['error']}    invalid_client
    Should Be Equal As Strings    ${resp.json()['error_description']}    Role not authorized for this API route

Retrieve access token with invalid apiInvokerId
    [Tags]    capif_security_api-22
    # Default Invoker Registration and Onboarding
    ${register_user_info_invoker}    ${url}    ${request_body}=    Invoker Default Onboarding

    ${request_body}=    Create Access Token Req Body
    ${resp}=    Post Request Capif
    ...    /capif-security/v1/securities/${API_INVOKER_NOT_VALID}/token
    ...    json=${request_body}
    ...    server=https://${CAPIF_HOSTNAME}/
    ...    verify=ca.crt
    ...    username=${INVOKER_USERNAME}

    Status Should Be    400    ${resp}

    Should Be Equal As Strings    ${resp.json()['error']}    invalid_request
    Should Be Equal As Strings    ${resp.json()['error_description']}    No Security Context for this API Invoker
