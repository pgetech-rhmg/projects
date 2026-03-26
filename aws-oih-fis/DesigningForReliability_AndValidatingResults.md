# Designing for Reliability and Validating Results

## Design Philosophy: Utility Industry Reliability Standards

As a utility company, reliability is foundational to operations. The design philosophy for critical workloads has always been: **any single data center can fail completely, and operations must continue without human intervention.**

This principle, proven over decades in on-premises data centers, translates directly to AWS cloud architecture.

### N+1 Redundancy Model

**Traditional Approach (On-Premises)**:
- Two data centers for critical workloads
- Each data center capable of handling full load
- Complete data center failure = tested failure boundary

**AWS Cloud Approach**:
- Three Availability Zones in a single region
- N+1 redundancy where N=2 (minimum for redundancy)
- Can lose any single AZ and maintain operational redundancy
- Complete AZ failure = tested failure boundary

This provides true N+1 redundancy: three AZs where you need two, meaning any one can fail while maintaining redundant operation across the remaining two.

## Hybrid HA Architecture: Two Models Working Together

The OIH workload employs two different high availability models based on service type:

### Self-Managed Services (SQL Server DAG): Two-Node Configuration

**Architecture**:
- Primary SQL Server instance in one AZ
- Secondary SQL Server instance in another AZ
- Database Availability Group (DAG) provides automatic failover

**Rationale**:
- Cost-effective HA without three-node cluster complexity
- Proven Windows Server Failover Clustering technology
- Sufficient for workload requirements

**Testing Focus**:
- Can Secondary take over when Primary fails?
- Does failover happen autonomously?
- Do connection strings route correctly after failover?

### Cloud-Native Managed Services: Three-AZ Distribution

**Services Automatically Distributed Across Three AZs**:
- **Lambda** - Functions execute across all AZs
- **API Gateway** - Application and Integration APIs distributed
- **Database Migration Service (DMS)** - Replication instances span AZs
- **DynamoDB** - Regional service with built-in multi-AZ resilience
- **SNS** - Notification delivery across AZs
- **VPC Endpoints** - Present in all AZ subnets

**Rationale**:
- AWS-managed redundancy at no additional architectural complexity
- True N+1 operation (lose one AZ, maintain redundancy with remaining two)
- Regional service resilience

**Testing Focus**:
- Do services continue operating when an AZ fails?
- Does traffic route to healthy AZs automatically?
- Is there any degraded performance or dropped requests?

## The Subnet Network Disruption Breakthrough

### Challenge: Testing Services Without Native FIS Support

Many critical services don't have direct AWS Fault Injection Simulator (FIS) support:
- Lambda (VPC-attached)
- API Gateway (Private endpoints)
- Database Migration Service
- VPC-attached ENIs

Traditional approach would require custom automation to:
1. Identify resources in target AZ
2. Manipulate configurations to simulate failure
3. Restore configurations after test
4. Risk incomplete cleanup or persistent misconfigurations

### Solution: Subnet-Level Network Isolation

By targeting **subnets** instead of individual resources, we simulate complete AZ failure at the network layer - exactly as it would occur in a real power loss, network failure, or natural disaster.

**How It Works**:
```
FIS Experiment Target: aws:ec2:subnet
Filter: ResourceTags: FISTarget=True, FISAZRole=Primary
Action: aws:network:disrupt-connectivity (5 minutes)
Result: ALL network traffic blocked to/from Primary AZ subnets
```

**What This Simulates**:
- Complete AZ power loss
- Total network fabric failure
- Natural disaster affecting entire data center
- Any catastrophic event isolating an entire AZ

**Services Affected** (Everything with network presence in the subnet):
- EC2 instances (SQL Server, application servers)
- Lambda ENIs (VPC-attached functions)
- API Gateway VPC endpoints (Private APIs)
- DMS replication instances
- RDS instances (if in VPC subnets)
- ECS/Fargate tasks
- Application Load Balancers
- NAT Gateways
- ElastiCache nodes
- Any service with VPC network presence

### Why This Is The Right Approach

**Realistic**: This is precisely what happens during actual AZ failure - network isolation, not service-specific malfunctions

**Comprehensive**: Tests all services simultaneously, validating inter-service dependencies and failover coordination

**Autonomous**: Requires no custom scripting, manual intervention, or cleanup logic

**Repeatable**: Tag-based targeting makes it environment-agnostic and safe to run in any deployment

**Aligned with Hypothesis**: Directly tests the core design principle - "workload survives complete AZ failure without human intervention"

## Progressive Failure Testing Strategy

### Component-Level Testing (SQL Server Focus)

**Purpose**: Isolate and validate specific failure modes

1. **Disk Failure** (EBS I/O Pause)
   - Simulates: SAN failure, storage controller failure, volume corruption
   - Tests: SQL Server timeout handling, DAG failover from storage failure

2. **Server Failure** (EC2 Stop)
   - Simulates: Hardware failure, OS crash, hypervisor failure
   - Tests: Immediate DAG failover, automatic rejoin on recovery

3. **Network/Connectivity Failure** (Instance Network Disruption)
   - Simulates: Switch failure, network partition
   - Tests: Quorum loss detection, isolated instance handling

### AZ-Level Testing (Full Stack)

**Purpose**: Validate complete workload resilience under total AZ failure

**Subnet Network Disruption Experiments**:
- Simulates power loss, natural disaster, network fabric failure
- Tests SQL Server two-node DAG failover
- Tests Lambda three-AZ resilience
- Tests API Gateway endpoint failover
- Tests DMS replication continuity
- Tests application-level health checks and routing
- **Validates core hypothesis**: Autonomous survival of complete AZ loss

## Testing Validation Criteria

### SQL Server DAG (Two-Node HA)

**Success Criteria**:
- [ ] DAG detects Primary failure within detection window
- [ ] Secondary automatically promotes to Primary role
- [ ] Connection strings route to new Primary
- [ ] No data loss (synchronous commit mode)
- [ ] Original Primary rejoins as Secondary on recovery
- [ ] All actions occur without human intervention

### Cloud-Native Services (Three-AZ Distribution)

**Success Criteria**:
- [ ] Services continue processing requests during AZ failure
- [ ] No dropped requests (or within acceptable SLA)
- [ ] Latency remains within acceptable bounds
- [ ] Traffic automatically routes to healthy AZs
- [ ] No manual intervention required
- [ ] Services automatically resume using failed AZ upon recovery

### Full Stack (End-to-End)

**Success Criteria**:
- [ ] Application remains accessible via load balancer
- [ ] API requests succeed via healthy API Gateway endpoints
- [ ] Lambda functions execute in remaining AZs
- [ ] Database queries succeed via SQL Server DAG
- [ ] DMS replication continues from healthy instances
- [ ] Monitoring/alerting detects and reports failure
- [ ] All recovery happens autonomously
- [ ] System returns to normal state after 5-minute experiment

## Operational Benefits

### From On-Premises to Cloud

**On-Premises Data Center Testing**:
- Expensive, risky, infrequent
- Required maintenance windows
- Often tested via actual outages (not by choice)
- Limited ability to validate autonomous recovery

**AWS FIS Testing**:
- Low cost, low risk, frequent testing
- No maintenance windows needed (non-disruptive to users)
- Controlled, repeatable experiments
- Validates autonomous recovery before actual need
- Builds confidence in architecture decisions

### Continuous Validation

Regular FIS testing provides:
- **Confidence**: Know the system will survive AZ failure before it happens
- **Documentation**: Prove autonomous recovery to stakeholders
- **Regression Testing**: Detect when changes break HA assumptions
- **Training**: Team learns failure scenarios in controlled environment
- **Compliance**: Demonstrate DR capability for audits

## Tagging Strategy for Environment Agnosticism

### Component-Level Tags (EC2, EBS)

```bash
FISTarget: True          # Opt-in to FIS testing
FISDBRole: Primary       # Role within DAG (Primary/Secondary)
FISEBSTarget: True       # Required for EBS volume testing (three-tag requirement)
```

### AZ-Level Tags (Subnets)

```bash
FISTarget: True          # Opt-in to FIS testing
FISAZRole: Primary       # Which AZ to target (Primary/Secondary/Tertiary)
```

**Benefits**:
- No hardcoded instance IDs, AZ names, or resource identifiers
- Same experiment templates work across dev, QA, and production
- Granular control over what gets tested
- Multi-tag requirements prevent accidental targeting

## Key Insights

1. **Subnet disruption is not a shortcut** - it's the precise mechanism for testing complete AZ failure (power, network, disaster)

2. **Two HA models working together** - Two-node SQL Server DAG + three-AZ cloud services = comprehensive resilience

3. **N+1 redundancy in practice** - Three AZs where you need two for redundancy, maintaining utility industry reliability standards

4. **Progressive testing validates incrementally** - Component failures → Complete AZ failure, building confidence at each level

5. **Tag-based targeting enables repeatability** - Same experiments work across all environments without modification

## Conclusion

The combination of progressive failure testing (component-level) and complete AZ failure simulation (subnet-level) provides comprehensive validation of the OIH workload's resilience. This approach:

- Honors utility industry reliability standards (N+1 redundancy)
- Tests both self-managed (SQL Server) and cloud-native services
- Simulates realistic failure scenarios (AZ power loss, network failure, disaster)
- Validates autonomous recovery without human intervention
- Provides repeatable, auditable evidence of HA/DR capability

The testing strategy doesn't just validate that services *can* survive AZ failure - it proves they *will* survive it, autonomously, maintaining the same reliability standards that have kept utility operations running for decades.
