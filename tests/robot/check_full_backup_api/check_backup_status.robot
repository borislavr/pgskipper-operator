*** Settings ***
Documentation     Check backup status request REST API
Library           RequestsLibrary
Library           Collections
Resource          ../Lib/lib.robot

*** Keywords ***
Check Backup Requests Status Endpoint REST
    [Documentation]
    ...  This test case validates that if we will request `/backup/status/<backup_id>` endpoint
    ...  response code should be `200` and response should contain one of this conditions:
    ...  'In Progress' 'Backup Failed' 'Backup Done'
    Wait Until Keyword Succeeds  2min  5sec  Is Backup Procedure Runs
    ${PGSSLMODE}=  Get Environment Variable  PGSSLMODE
    ${scheme}=  Set Variable If  '${PGSSLMODE}' == 'require'  https  http
    Create Session  postgres_backup_daemon  ${scheme}://postgres-backup-daemon:8080
    ${resp}=  GET On Session  postgres_backup_daemon  /backup/status/${backup_id}
    Should Be Equal  ${resp.status_code}  ${200}

Create Backup
    ${PGSSLMODE}=  Get Environment Variable  PGSSLMODE
    ${scheme}=  Set Variable If  '${PGSSLMODE}' == 'require'  https  http
    Create Session  postgres_backup_daemon  ${scheme}://postgres-backup-daemon:8080
    ${resp}=  POST On Session  postgres_backup_daemon  /backup
    Should Be Equal  ${resp.status_code}  ${200}
    Dictionary Should Contain Key  ${resp.json()}  backup_id
    ${queue_status}=  Get From Dictionary  ${resp.json()}  backup_requests_in_queue
    Set Test Variable  \${queue_status}  ${queue_status}
    ${backup_id}=  Get From Dictionary  ${resp.json()}  backup_id
    Set Test Variable  \${backup_id}  ${backup_id}

Is Backup Procedure Runs
    ${deamon_pod}  Get Pod Daemon
    ${resp}  ${error}=  Execute In Pod  ${deamon_pod.metadata.name}  curl -XGET localhost:8085/schedule
    ${stdout}=  Set Variable  ${resp}
    &{dict}=  Yaml To Dict  ${stdout}
    Log To Console   Result: ${dict}
    Should Be True  ${dict['requests_in_queue']} < ${queue_status}

*** Test Cases ***
Check Backup Requests Status Endpoint
    [Tags]  backup full  check_backup_api
    Given Check /health Endpoint For Full Backups
    When Create Backup
    Then Check Backup Requests Status Endpoint REST
