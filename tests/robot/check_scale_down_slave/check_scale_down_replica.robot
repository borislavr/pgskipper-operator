*** Settings ***
Documentation     Check scaledown replicas
Library           Collections
Library           OperatingSystem
Library           String
Resource          ../Lib/lib.robot


*** Test Cases ***
Check Scale Down Replica
    [Tags]    patroni full   check_scale_down_replica
    # skip check scale down replica if only one patroni pod
    ${pg_node_qty}=   Get Environment Variable   PG_NODE_QTY   default=1
    ${pg_node_qty}=  Convert To Integer  ${pg_node_qty}
    Pass Execution If   '${pg_node_qty}'<'2'   Log To Console skip test because pg_node_qty ${pg_node_qty}
    Run Keyword   Checks Before Tests
    @{scaled_replica_stateful_sets}   Create List
    ${MASTER}=   Get Master Pod
    # insert test record
    ${RID}   ${EXPECTED}=   Insert Test Record
    @{REPLICAS}=  Get Pods  label=pgtype:replica   status=Running
    FOR   ${REPLICA}   IN   @{REPLICAS}
       ${REPLICA_POD_NAME}   Set Variable  ${REPLICA.metadata.name}
       ${REPLICA_STATEFULSET_NAME}=  Evaluate  "${REPLICA_POD_NAME}".rsplit("-", 1)[0]
       Log To Console   Stateful Set To Scale Down: ${REPLICA_STATEFULSET_NAME}
       Scale Down Stateful Set  ${REPLICA_STATEFULSET_NAME}
       Sleep  10s
       Log To Console  Stateful Set ${REPLICA_STATEFULSET_NAME} scaled down successefully
       Append To List   ${scaled_replica_stateful_sets}   ${REPLICA_STATEFULSET_NAME}
    END
    Log To Console  \nCheck if master still work
    ${NEW_MASTER}=   Get Master Pod
    Should Be Equal As Strings   ${MASTER.metadata.name}   ${NEW_MASTER.metadata.name}   msg=Oh, master changed?!
    Wait Until Keyword Succeeds   ${120}   1 sec   check test record   ${MASTER.status.pod_ip}   ${RID}   ${EXPECTED}
    # check if scaled > 0 stateful sets
    ${scaled}=   Get Length   ${scaled_replica_stateful_sets}
    Should Be True   ${scaled} > 0   msg=scaled ${scaled} stateful set, should be more 0
    # check if master still working
    Log To Console  Insert New Record While Replica Offline
    ${RID2}   ${EXPECTED2}=   Insert Test Record   ${MASTER}
    Check Test Record    ${MASTER.status.pod_ip}   ${RID2}   ${EXPECTED2}
    Log To Console  Lets Scale up replicas:
    FOR   ${stateful_set}   IN   @{scaled_replica_stateful_sets}
       Log To Console   Stateful set to scale up: ${stateful_set}
       Scale Up Stateful Set  ${stateful_set}
    END

    #wait replica pods scale up
    Wait Until Keyword Succeeds   120 sec   2 sec   Wait Replica Pods In Up State

    # check if last test record replicated
    Log To Console  Search Test Record On Replicas
    @{REPLICAS}=   Get Pods   label=pgtype:replica   status=Running
    FOR   ${pod}   IN   @{REPLICAS}
       Log To Console   Check In ${pod.metadata.name}
       Check Test Record    ${pod.status.pod_ip}   ${RID2}   ${EXPECTED2}
    END
