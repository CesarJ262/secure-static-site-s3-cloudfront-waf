# Secure AWS Cloud Perimeter Infrastructure 🛡️

## 📝 Overview
This repository contains the architecture and configuration for a production-ready secure web deployment on AWS. The project implements a **Defense-in-Depth** model to host and protect static web assets, ensuring high availability, encryption in transit, and robust perimeter defense against common web vulnerabilities.

By decoupling the origin (S3) from the edge (CloudFront) and applying an active firewall layer (WAF), the infrastructure is hardened against unauthorized access and automated threats.

## 🏗️ Infrastructure Architecture

<img width="2065" height="994" alt="image" src="https://github.com/user-attachments/assets/935237db-705e-448f-99e4-a5dfcf911722" />

## 🛠️ Technology Stack
- **Amazon S3:** Origin storage hardened with "Block Public Access" and fine-grained resource policies.
- **Amazon CloudFront:** Global Content Delivery Network (CDN) managing SSL/TLS termination and edge caching.
- **AWS WAF:** Web Application Firewall for real-time Layer 7 traffic filtering.
- **IAM / OAC:** Secure Origin Access Control to eliminate direct origin exposure.

## 🛡️ Implementation Layers

### Layer 1: Origin Hardening (S3)
- Provisioned a private S3 bucket with **Block All Public Access** strictly enforced.
- **Security Verification:** <img width="1559" height="305" alt="image" src="https://github.com/user-attachments/assets/7a2113b3-5fc5-4a34-a02f-45c6bb04c739" />

  *Direct origin access is forbidden, mitigating data exfiltration risks.*

### Layer 2: Edge Delivery & Encryption (CloudFront)
- Deployed **Origin Access Control (OAC)** to restrict S3 access exclusively to the CloudFront distribution.
- Enforced **HTTPS Protocol** (TLS 1.2+) with automatic HTTP-to-HTTPS redirection.
- Optimized headers for secure content delivery.

### Layer 3: Perimeter Defense (WAF)
- Configured a Web ACL with AWS Managed Rulesets:
  - **Core Rule Set (CRS):** Protection against OWASP Top 10 (SQLi, XSS, etc.).
  - **IP Reputation:** Proactive blocking of known malicious actors and botnets.
- **Security Validation:**
  <img width="2525" height="409" alt="image" src="https://github.com/user-attachments/assets/5c04ab99-8cae-42a3-85ef-546c27e73bd3" />

  *Successful mitigation of unauthorized/malicious request patterns at the edge.*

## 🚩 Security Assessment (Red Team Perspective)
This infrastructure is designed to neutralize common cloud-based attack vectors:
- **Origin Bypass:** Utilizing OAC prevents attackers from discovering the S3 bucket URL to bypass perimeter security.
- **Configuration Drift:** Standardized S3 settings prevent accidental exposure of sensitive assets.
- **Man-in-the-Middle (MitM):** Mandatory encryption in transit ensures data integrity from the edge to the end-user.

## 📈 Roadmap
- [ ] Migrate infrastructure to **Terraform (IaC)** for automated provisioning.
- [ ] Implement **AWS CloudWatch** dashboards for real-time security monitoring.
- [ ] Add custom WAF rules for geo-blocking and rate limiting.
