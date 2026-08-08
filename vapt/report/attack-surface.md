# Attack Surface – OWASP Juice Shop

## Target

- Application: OWASP Juice Shop
- URL: http://localhost:3000

## Components

- Web Frontend
- REST API
- Authentication
- Product Catalog
- Shopping Basket
- User Management
- File Upload
- Search Functionality

## Technologies

- Node.js
- Express
- Angular
- SQLite
- Docker

## Authentication

- Login endpoint
- JWT-based authentication

## Potential Attack Vectors

- SQL Injection
- Cross-Site Scripting (XSS)
- Broken Authentication
- IDOR
- SSRF
- XXE
- Path Traversal
- Mass Assignment
- Sensitive Data Exposure
- Missing Rate Limiting

## Assumptions and Limitations

The attack surface was identified based on the functionality exposed by the deployed OWASP Juice Shop instance during the assessment. Components or services not accessible within the assessment scope were not evaluated.