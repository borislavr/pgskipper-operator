*** Settings ***
Documentation     Check master pod exists
Library           Collections
Library           OperatingSystem
Library           String
Resource          ../Lib/lib.robot

*** Test Cases ***
Check Patroni REST Authentication
    [Tags]   patroni full   check_rest_api_auth
    [Documentation]
    ...
    ...  Check responce of REST on all patroni pods
    ...  curl -s pod_ip:8008
    ...
    Check If Patroni REST Authentication Working
