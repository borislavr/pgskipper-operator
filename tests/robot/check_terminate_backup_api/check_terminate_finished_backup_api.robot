*** Settings ***
Resource  keywords.robot


*** Test Cases ***
Check Terminate Finished Backup Api Endpoint
    [Tags]  backup full  check_terminate_backup_api
    ${res}=  Get Auth
    Run Keyword If  '${res}' == "false"  Check Termination Finished Backup With Disabled Auth
    Run Keyword If  '${res}' == "true"  Check Termination Finished Backup With Enabled Auth
    [Teardown]  Delete Test DB  ${db_name}


*** Keywords ***
Check Termination Finished Backup With Disabled Auth
    ${PGSSLMODE}=  Get Environment Variable  PGSSLMODE
    ${scheme}=  Set Variable If  '${PGSSLMODE}' == 'require'  https  http
    Create Session  postgres_backup_daemon  ${scheme}://postgres-backup-daemon:9000
    Check Termination Finished Backup

Check Termination Finished Backup With Enabled Auth
    Check Authorization
    ${auth}=  Prepare Auth
    ${PGSSLMODE}=  Get Environment Variable  PGSSLMODE
    ${scheme}=  Set Variable If  '${PGSSLMODE}' == 'require'  https  http
    Create Session  postgres_backup_daemon  ${scheme}://postgres-backup-daemon:9000  auth=${auth}
    Check Termination Finished Backup

Check Termination Finished Backup
    Prepare Test Data
    &{headers}=  Create Dictionary  Content-Type=application/json  Accept=application/json
    ${data}=  Set Variable  {}
    ${resp}=  POST On Session  postgres_backup_daemon  url=/backup/request  data=${data}  headers=${headers}
    Should Be Equal  ${resp.status_code}  ${202}
    ${backup_id}=  Get From Dictionary  ${resp.json()}  backupId
    Wait Until Keyword Succeeds  ${RETRY_TIME}  ${RETRY_INTERVAL}
    ...  Check Backup Status  ${backup_id}  Successful
    ${resp}=  POST On Session  postgres_backup_daemon  /terminate/${backup_id}  expected_status=404
    Should Be Equal  ${resp.status_code}  ${404}
    Should Contain  str(${resp.content})  There is no active backup with id: ${backup_id}
    Check Backup Status  ${backup_id}  Successful
    Check /health Endpoint For Full Backups
