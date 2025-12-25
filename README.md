# Secure AWS Cloud Perimeter Infrastructure 🛡️

## 📝 Overview
This repository contains the architecture and configuration for a production-ready secure web deployment on AWS. The project implements a **Defense-in-Depth** model to host and protect static web assets, ensuring high availability, encryption in transit, and robust perimeter defense against common web vulnerabilities.

Originally deployed manually, the entire infrastructure has been migrated to **Terraform (Infrastructure as Code)** for automated, repeatable, and secure provisioning.

## 🏗️ Infrastructure Architecture
<img width="2065" height="994" alt="Architecture Diagram" src="https://github.com/secure-static-site-s3-cloudfront-waf/img/Architecture.png" />

## 🛠️ Technology Stack
- **Amazon S3:** Hardened origin storage.
- **Amazon CloudFront:** Global Content Delivery Network (CDN) with HTTPS enforcement.
- **AWS WAF:** Layer 7 Firewall protecting against OWASP Top 10.
- **Terraform:** IaC tool for automated resource management.

## 🛡️ Implementation Layers

### Layer 1: Origin Hardening (S3)
- Provisioned a private S3 bucket with **Block All Public Access** strictly enforced.
- **Security Verification:** <img width="1559" height="305" alt="S3 Access Denied" src="https://github.com/secure-static-site-s3-cloudfront-waf/img/access-test-denied-S3.png" />
*Direct origin access is forbidden, mitigating data exfiltration risks.*

### Layer 2: Edge Delivery & Encryption (CloudFront)
- Deployed **Origin Access Control (OAC)** to restrict S3 access exclusively to CloudFront.
- Enforced **HTTPS Protocol** (TLS 1.2+) with automatic redirection.

### Layer 3: Perimeter Defense (WAF)
- Configured a Web ACL with AWS Managed Rulesets:
  - **Core Rule Set (CRS):** SQLi and XSS protection.
  - **IP Reputation:** Blocking known malicious actors.
- **Security Validation:**
<img width="2525" height="409" alt="WAF Block" src="https://github.com/secure-static-site-s3-cloudfront-waf/img/security-validation-test.png" />
*Successful mitigation of malicious request patterns at the edge.*

## 🚀 How to Use (Terraform)
To deploy this infrastructure automatically, follow these steps:

1. **Initialize Terraform:** Downloads the necessary AWS providers.
   ```bash
   cd infra/
   terraform init
   
2. **Review the Plan:** Previews the changes to be made in your AWS account.
   ```bash
   terraform plan
   
3. **Apply Changes:** Deploys the infrastructure.
   ```bash
   terraform apply
  (Type yes when prompted).

4. **Destroy (Clean up):** Removes all resources to avoid costs.
   ```bash
   terraform destroy
