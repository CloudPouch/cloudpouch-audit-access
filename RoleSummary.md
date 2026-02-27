# Audit Role Permissions Summary

**Role name:** `cost-opt-audit-role`

The role is intended for read-only cost optimization auditing. It combines several AWS managed policies with a custom inline policy that adds targeted allows and two explicit deny guards.

---

## Attached AWS Managed Policies

| Policy | Purpose |
|--------|---------|
| `ReadOnlyAccess` | Broad read-only access across all AWS services |
| `job-function/ViewOnlyAccess` | View-only access to service metadata |
| `job-function/Billing` | Access to billing console and cost data |
| `AWSBillingReadOnlyAccess` | Read billing data |
| `AWSSavingsPlansReadOnlyAccess` | Read Savings Plans data |
| `ComputeOptimizerReadOnlyAccess` | Read Compute Optimizer recommendations |
| `CostOptimizationHubReadOnlyAccess` | Read Cost Optimization Hub recommendations |
| `AmazonOpenSearchServiceReadOnlyAccess` | Read OpenSearch domains |
| `CloudSearchReadOnlyAccess` | Read CloudSearch domains |

---

## Custom Policy (`cost-opt-audit-policy`)

### Explicit Denies (override any allows above)

**1. No access to customer data**
Blocks retrieval of actual data content from:
- S3 objects (`s3:GetObject`)
- DynamoDB rows (`BatchGetItem`, `GetItem`, `Query`, `Scan`)
- Secrets Manager values (`GetSecretValue`, `BatchGetSecretValue`)
- SSM parameters (`GetParameter*`)
- Kinesis stream records
- CloudWatch Logs events
- SQS messages
- Neptune and Timestream query results
- EC2 instance remote access via SSM Session Manager (`ssm:StartSession`)
- ECR image layers and authorization tokens

**2. No cost-related write actions**
Blocks modifications to:
- Billing settings (`billing:Delete*`, `Put*`, `Update*`)
- Payments (`payments:MakePayment`, `UpdatePaymentPreferences`)
- Budgets (`budgets:ModifyBudget`)
- Cost Explorer reports and notification subscriptions
- CUR report definitions
- Purchase orders

### Additional Allows

**Read access** (supplementing managed policies) to:
- Cost & billing: `ce:*`, `billing:Get*/List*`, `cur:DescribeReportDefinitions`, `invoicing:*`, `freetier:GetFreeTierUsage`, `tax:*`, `payments:Get*/List*`, `bcm-data-exports:*`, `bcm-recommended-actions:ListRecommendedActions`
- Infrastructure metadata: EC2, RDS, EFS, ELB, EKS, ECR, DynamoDB, EBS, S3 (bucket-level only), CloudFront, API Gateway, Batch, CloudWatch metrics/dashboards, CloudSearch, OpenSearch, logs group list, Organizations accounts
- Optimization tools: `compute-optimizer:*EnrollmentStatus`, `trustedadvisor:RefreshCheck`, `sustainability:GetCarbonFootprintSummary`, `pi:GetResourceMetrics`
- Pricing API: `pricing:DescribeServices`, `GetAttributeValues`, `GetProducts`

**Trigger cost analyses** (`AllowTriggerCostOptimizationAnalyses`):
- Start CE commitment purchase analysis and Savings Plans recommendation generation
- Update Compute Optimizer recommendation preferences
- Update Cost Optimization Hub enrollment status and preferences

**Compute Optimizer service-linked role management:**
- Create `AWSServiceRoleForComputeOptimizer` (restricted to Compute Optimizer service principal)
- Put inline policy on that role

---

## Summary

The role provides **comprehensive read access to cost, billing, and infrastructure metadata** while strictly **preventing access to customer data content** and **blocking any cost-related configuration changes**. The only write-like actions permitted are triggering optimization analyses and managing the Compute Optimizer service-linked role.
