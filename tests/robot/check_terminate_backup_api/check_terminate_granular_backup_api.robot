*** Settings ***
Resource  keywords.robot


*** Test Cases ***
Check Terminate Granular Backup Api Endpoint
    [Tags]  backup full  check_terminate_backup_api
    ${res}=  Get Auth
    Run Keyword If  '${res}' == "false"  Check Termination Granular Backup With Disabled Auth
    Run Keyword If  '${res}' == "true"  Check Termination Granular Backup With Enabled Auth
    [Teardown]  Delete Test DB  ${db_name}


*** Keywords ***
Check Termination Granular Backup With Disabled Auth
    ${PGSSLMODE}=  Get Environment Variable  PGSSLMODE
    ${scheme}=  Set Variable If  '${PGSSLMODE}' == 'require'  https  http
    Create Session  postgres_backup_daemon  ${scheme}://postgres-backup-daemon:9000
    Check Termination Granular Backup

Check Termination Granular Backup With Enabled Auth
    Check Authorization
    ${auth}=  Prepare Auth
    ${PGSSLMODE}=  Get Environment Variable  PGSSLMODE
    ${scheme}=  Set Variable If  '${PGSSLMODE}' == 'require'  https  http
    Create Session  postgres_backup_daemon  ${scheme}://postgres-backup-daemon:9000  auth=${auth}
    Check Termination Granular Backup

Check Termination Granular Backup
    Prepare Test Data
    ${databases}=  Create List  ${db_name}
    &{data}=  Create Dictionary  databases=${databases}
    ${json_data}=   Evaluate  json.dumps(${data})  json
    &{headers}=  Create Dictionary  Content-Type=application/json  Accept=application/json
    ${resp}=  POST On Session  postgres_backup_daemon  /backup/request  data=${json_data}  headers=${headers}
    Should Be Equal  ${resp.status_code}  ${202}
    ${backup_id}=  Get From Dictionary  ${resp.json()}  backupId
    Wait Until Keyword Succeeds  ${RETRY_TIME}  ${RETRY_INTERVAL}
    ...  Check Backup Status  ${backup_id}  In progress
    ${resp}=  POST On Session  postgres_backup_daemon  /terminate/${backup_id}
    Should Be Equal  ${resp.status_code}  ${200}
    Wait Until Keyword Succeeds  ${RETRY_TIME}  ${RETRY_INTERVAL}
    ...  Check Backup Status  ${backup_id}  Canceled
    Check /health Endpoint For Full Backups


