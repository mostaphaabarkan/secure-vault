# ADR 0001: Use eu-south-2 (Spain) as the primary AWS region

## Status

Accepted

## Context

Secure Vault stores user files, so data location matters. I am based in Spain,
and eu-south-2 keeps data in Spain with low latency. It is an opt-in region and
has fewer services than eu-west-1 (Ireland).

## Decision

Use eu-south-2 for all regional resources (S3, Lambda, API Gateway, Cognito,
DynamoDB, IAM Identity Center). CloudFront certificates (ACM) must be created
in us-east-1, as AWS requires.

## Consequences

- Data stays in Spain.
- The region must be enabled in each account before use.
- Each service must be verified in eu-south-2 before it is used.
- If a needed service is missing, revisit this decision and consider eu-west-1.
