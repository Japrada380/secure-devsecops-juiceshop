# Attack Surface Assessment – OWASP Juice Shop

## Target

| Item | Value |
|------|-------|
| Application | OWASP Juice Shop |
| Version | 20.0.0 |
| URL | http://127.0.0.1:3000 |
| Deployment | Docker Container |
| Container | juice-shop-vapt |

---

# Scope

The assessment was performed exclusively against the locally deployed OWASP Juice Shop instance.

No external systems, cloud resources, or third-party services were tested.

---

# Technologies Identified

| Technology | Purpose |
|------------|---------|
| Node.js | Backend |
| Express | REST API |
| Angular | Frontend |
| SQLite | Database |
| Docker | Containerization |
| JWT | Authentication |

---

# Main Components

- Authentication
- User Management
- Product Catalog
- Shopping Basket
- Search Engine
- Complaint System
- Feedback Module
- File Upload
- REST API

---

# Attack Surface Map

| Endpoint | Method | Authentication | Function | Assessment Status |
|-----------|--------|----------------|----------|------------------|
| /rest/user/login | POST | No | User authentication | Pending |
| /rest/user/signup | POST | No | User registration | Pending |
| /rest/products/search | GET | No | Product search | Pending |
| /rest/products | GET | No | Product listing | Pending |
| /rest/basket | GET | Yes | Shopping basket | Pending |
| /rest/basket | POST | Yes | Basket update | Pending |
| /rest/feedback | POST | No | Customer feedback | Pending |
| /api/Challenges | GET | No | Challenge API | Pending |
| /api/Users | GET | Yes | User information | Pending |
| /rest/saveLoginIp | POST | Yes | Login tracking | Pending |

---

# Potential Vulnerability Classes

The following vulnerability categories were evaluated according to the technical assessment requirements:

| ID | Vulnerability |
|----|---------------|
| V-01 | SQL Injection |
| V-02 | Broken Authentication / JWT |
| V-03 | SSRF |
| V-04 | XXE |
| V-05 | Mass Assignment |
| V-06 | Path Traversal |
| V-07 | Missing Rate Limiting |
| V-08 | Logging of Personally Identifiable Information (PII) |
| V-09 | IDOR |
| V-10 | Hardcoded Credentials |

---

# Assumptions and Limitations

- The assessment was limited to the locally deployed OWASP Juice Shop instance.
- Only functionality exposed during the assessment was evaluated.
- No attacks were performed against third-party infrastructure.
- Vulnerabilities were only reported when successfully reproduced with supporting evidence.
- Negative test cases were documented as validation evidence but were not classified as security findings.
