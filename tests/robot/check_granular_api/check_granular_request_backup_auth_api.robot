*** Settings ***
Documentation     Check granular backups request REST API
Library           RequestsLibrary
Resource          ../Lib/lib.robot

*** Keywords ***
Check Backup Status
    ${resp}=  Get On Session  postgres_backup_daemon  url=/backup/status/${backup_id}?namespace=${name_space}
    Should Be Equal  ${resp.status_code}  ${200}
    Delete Granular Backup

*** Test Cases ***
Check Backup Requests Status Endpoint
    [Tags]  backup full  check_granular_api
    Given Check /backups Endpoint For Granular Backups
    When Create Backup And Wait Till Complete
    Then Check Backup Status
