*** Settings ***
Documentation     Check full backup request REST API
Library           RequestsLibrary
Library           Collections
Resource          ../Lib/lib.robot

*** Keywords ***
Check /healt Endpoint With Wrong Request Method
    ${PGSSLMODE}=  Get Environment Variable  PGSSLMODE
    ${scheme}=  Set Variable If  '${PGSSLMODE}' == 'require'  https  http
    Create Session  postgres_backup_daemon  ${scheme}://postgres-backup-daemon:8080  verify=False
    ${resp}=  POST On Session  postgres_backup_daemon  /health   expected_status=405   timeout=15
    Status Should Be  405  ${resp}
    Dictionary Should Contain Key  ${resp.json()}  message


*** Test Cases ***
Check /health Endpoint For Full Backups
    [Tags]  backup full  check_backup_api
    [Documentation]
    ...  This test case validates that if we will request `/health` endpoint
    ...  response code should be `200` and response should contain `storage` key
    ...  and `status` key with `UP` value
    ...
    Wait Until Keyword Succeeds   60 sec   2 sec   Check /health Endpoint For Full Backups

Check /health Endpoint For Full Backups With Wrong Request Method
    [Tags]  backup full  check_backup_api
    [Documentation]
    ...  This test case validates that if we will request `/health` endpoint
    ...  with POST method response code should not be `200` and error message should be presented
    ...
    Wait Until Keyword Succeeds   60 sec   2 sec   Check /healt Endpoint With Wrong Request Method
