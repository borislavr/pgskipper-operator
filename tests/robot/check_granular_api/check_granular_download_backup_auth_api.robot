*** Settings ***
Documentation    Check granular download backup auth API
Library          RequestsLibrary
Resource         ../Lib/lib.robot

*** Keywords ***
Check Download API
    ${resp}=  Get On Session  postgres_backup_daemon  url=/backup/download/${backup_id}?namespace=${name_space}
    Should Be Equal  ${resp.status_code}  ${200}
    Delete Granular Backup

*** Test Cases ***
Check Backup Requests Status Endpoint
    [Tags] backup full  check_granular_api
    Given Check /backups Endpoint For Granular Backups
    And Create Database  granular_base
    When Create Backup And Wait Till Complete
    Then Check Download API
    And Delete Database  granular_base


