# Active-Standby PostgreSQL Cluster Deployment Scheme 

Ability to deploy two separate PostgreSQL Clusters in two Kubernetes clusters with Standby Cluster replicated from an Active PostgreSQL.

# Business Case

Application being deployed in two independent Kubernetes clusters in separate Data Centers via Active Standby scheme. 

Allows to deploy two PostgreSQL clusters via active-standby scheme over two Data Centers with two Kubernetes clusters.

In case of a failure of an Active Data Center it's possible to *manually* activate Standby PostgreSQL cluster.

# Use Case

## Deployment

During deployment of PostgreSQL Operator it's possible to specify `patroni.standbyCluster` set of parameters.

If such parameters are specified, PostgreSQL Operator will configure Standby Cluster to replicate from an Active one.

# Examples

Please, find example parameters for deployment below:

```
patroni:
  standbyCluster:
    host: <ip_of_postgresql_on_active_site>
    port: 5432

```
