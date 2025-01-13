*** Settings ***
Documentation     Check master pod availible
Resource          ../Lib/lib.robot

*** Test Cases ***
Check Patroni REST
    [Tags]  patroni simple  check_patroni_rest
    [Documentation]
    ...
    ...  Check patroni REST
    ...
    Check If Patroni REST Authentication Working
    Insert Test Record
