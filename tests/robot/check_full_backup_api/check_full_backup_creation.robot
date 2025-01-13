*** Settings ***
Documentation     Check daemon installation correctness
Resource          ../Lib/lib.robot

*** Test Cases ***
Check Daemon Full Backup Creation
    [Tags]  backup full  check_backup_api
    [Documentation]
    ...  This test validates if daemon pod can perform full backup
    ...
    Check Full Backup Creation

