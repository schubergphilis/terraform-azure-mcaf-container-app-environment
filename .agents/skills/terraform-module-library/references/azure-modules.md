# Azure Terraform Module Patterns

## Virtual Network Module

- VNet with configurable address space
- Subnets with service delegations
- Network Security Groups (NSGs)
- Route tables and associations
- VNet peering
- Private DNS zones
- VNet Flow Logs

## AKS Module

- AKS cluster with system and user node pools
- Azure CNI / Kubenet networking
- Azure AD integration and RBAC
- Managed identities (system/user-assigned)
- Cluster autoscaler and node pool scaling
- Container Insights monitoring
- Private cluster support
- Workload identity

## Container App Environment Module

- Container App Environment with workload profiles (Consumption, Dedicated D/E-series, GPU NC-series)
- Auto-injection of Consumption profile when dedicated profiles are defined
- Container Apps with templates, ingress, secrets, probes, and identity
- Storage mounts (Azure Files)
- Custom domains with certificates
- Dapr integration
- Infrastructure resource group naming to prevent drift

## Storage Account Module

- Storage account with configurable replication (LRS, GRS, ZRS, GZRS)
- Blob containers with access tiers
- File shares
- Queue and table storage
- Private endpoints
- Encryption with customer-managed keys (CMK)
- Lifecycle management policies
- Network rules and firewall

## Azure SQL Module

- Azure SQL Server and databases
- Elastic pools
- Failover groups
- Azure AD authentication
- Transparent Data Encryption (TDE)
- Auditing and threat detection
- Private endpoints
- Firewall rules

## Key Vault Module

- Key Vault with RBAC or access policies
- Secrets, keys, and certificates management
- Soft delete and purge protection
- Private endpoints
- Diagnostic settings
- Network ACLs

## Application Gateway Module

- Application Gateway with WAF v2
- HTTP/HTTPS listeners
- Backend pools and settings
- URL path-based routing
- SSL/TLS termination
- Health probes
- Autoscaling

## Azure Cosmos DB Module

- Cosmos DB account with multi-region writes
- SQL, MongoDB, Cassandra, Gremlin, or Table API
- Hierarchical partition keys
- Serverless or provisioned throughput
- Private endpoints
- Backup policies (continuous/periodic)
- Diagnostic settings

## Private Endpoint Module

- Reusable private endpoint creation
- Private DNS zone integration
- DNS A-record registration
- Support for any Azure PaaS service
- Network interface outputs

## Azure Monitor Module

- Log Analytics workspace
- Diagnostic settings for resources
- Action groups and alert rules
- Application Insights
- Workbooks and dashboards

## Best Practices

1. Use `azurerm` provider version `>= 4.16, < 5.0`
2. Enable encryption by default (TDE, SSE, CMK where applicable)
3. Use managed identities over service principals
4. Tag all resources consistently with a `locals` block for default tags
5. Enable logging and monitoring via diagnostic settings
6. Use private endpoints for PaaS services
7. Enable zone redundancy for production workloads
8. Set secure defaults (internal LB, mTLS, HTTPS-only)
9. Use `nullable = false` for required variables
10. Use `optional()` with defaults for nested object attributes
11. Implement input validation blocks for enums and formats
12. Use `for_each` over `count` for named resource collections
13. Prefer `coalesce()` for fallback values to prevent drift
14. Follow [Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/well-architected/) guidance
15. Use Terraform native tests (`.tftest.hcl`) with `mock_provider` for unit testing
