*** Settings ***
Resource  keywords.robot


*** Test Cases ***
Check Restore Of Terminated Backup Api Endpoint
    [Tags]  backup full  check_terminate_backup_api
    ${res}=  Get Auth
    Run Keyword If  '${res}' == "false"  Check Restore Of Terminated Backup With Disabled Auth
    Run Keyword If  '${res}' == "true"  Check Restore Of Terminated Backup With Enabled Auth
    [Teardown]  Delete Test DB  ${db_name}


*** Keywords ***
Check Restore Of Terminated Backup With Disabled Auth
    ${PGSSLMODE}=  Get Environment Variable  PGSSLMODE
    ${scheme}=  Set Variable If  '${PGSSLMODE}' == 'require'  https  http
    Create Session  postgres_backup_daemon  ${scheme}://postgres-backup-daemon:9000
    Check Restore Of Terminated Backup

Check Restore Of Terminated Backup With Enabled Auth
    Check Authorization
    ${auth}=  Prepare Auth
    ${PGSSLMODE}=  Get Environment Variable  PGSSLMODE
    ${scheme}=  Set Variable If  '${PGSSLMODE}' == 'require'  https  http
    Create Session  postgres_backup_daemon  ${scheme}://postgres-backup-daemon:9000  auth=${auth}
    Check Restore Of Terminated Backup

Check Restore Of Terminated Backup
    Prepare Test Data
    &{headers}=  Create Dictionary  Content-Type=application/json  Accept=application/json
    ${data}=  Set Variable  {}
    ${resp}=  POST On Session  postgres_backup_daemon  /backup/request  data=${data}  headers=${headers}
    Should Be Equal  ${resp.status_code}  ${202}
    ${backup_id}=  Get From Dictionary  ${resp.json()}  backupId
    Wait Until Keyword Succeeds  ${RETRY_TIME}  ${RETRY_INTERVAL}
    ...  Check Backup Status  ${backup_id}  In progress
    ${resp}=  POST On Session  postgres_backup_daemon  /terminate/${backup_id}
    Should Be Equal  ${resp.status_code}  ${200}
    Wait Until Keyword Succeeds  ${RETRY_TIME}  ${RETRY_INTERVAL}
    ...  Check Backup Status  ${backup_id}  Canceled
    &{headers}=  Create Dictionary  Content-Type=application/json  Accept=application/json
    ${array_db_name}=  Create List  ${db_name}
    &{data}=  Create Dictionary  databases=${array_db_name}
    Set To Dictionary  ${data}  backupId=${backup_id}
    ${json_data}=  Evaluate  json.dumps(${data})  json
    ${resp}=  POST On Session  postgres_backup_daemon  /restore/request  data=${json_data}  headers=${headers}  expected_status=403
    Should Be Equal  ${resp.status_code}  ${403}
    Should Contain  str(${resp.content})  Backup status 'Canceled' is unsuitable status for restore
    Check Backup Status  ${backup_id}  Canceled
    Check /health Endpoint For Full Backups
