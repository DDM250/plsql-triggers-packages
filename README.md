# plsql-triggers-packages
# PL/SQL Database Development - Class Activity

**Course:** INSY 8311 - Database development with PL/SQL  
**Instructor:** Eric Maniraguha  
**Academic Year:** 2025-2026, SEM II  
**Date:** November 25, 2025  
**Group Members:** Diego Gaju, Ishimwe Daniel, Muyoboke Emmanuel, Niyomugabo Kevin Nice 
## 📋 What the Question Was About

This assignment had two main parts:

### Part I: AUCA System Access Policy
Create triggers to enforce business rules:
- No system access on Sabbath (Saturday & Sunday)
- Access only Monday-Friday, 8:00 AM to 5:00 PM
- Block unauthorized access and log violations automatically

### Part II: HR Employee Management Package
Design a PL/SQL package with:
- Functions to calculate RSSB tax and net salary
- Dynamic procedures for HR operations
- Security context using USER/CURRENT_USER
- Bulk processing capabilities

## How We Solved It

### Step 1: Database Schema Setup
We created tables for employee data and access violation logging.

### Step 2: Trigger Implementation
- **Access Restriction Trigger**: Blocks operations outside allowed hours
- **Violation Logging Trigger**: Automatically logs unauthorized access attempts

### Step 3: HR Package Development
- **Tax Calculation Functions**: Compute RSSB tax and net salary
- **Dynamic Procedures**: Flexible HR operations using dynamic SQL
- **Security Context**: Proper use of invoker vs definer rights
- **Bulk Processing**: Handle multiple employees efficiently

## Code Implementation
**Inserting sample data**
![sample data](https://github.com/user-attachments/assets/2e92f84d-47df-4082-aa17-a36ee1636cc8)

## Testing package procedures
![dynamic procedures](https://github.com/user-attachments/assets/bfe3b14c-bd3f-4b35-be78-606ee8ad6204)

## Testing package functions
![dynamic procedures](https://github.com/user-attachments/assets/e8d3a2e0-76d9-47d4-a951-898d16ce6946)


