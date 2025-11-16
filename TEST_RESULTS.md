# AnimalGuardian Comprehensive Test Results

**Test Date:** 2025-11-16 14:00:08

## Test Summary

- **Total Tests:** 20
- **Passed:** 5 ✅
- **Failed:** 4 ❌
- **Skipped:** 11 ⚠️
- **Success Rate:** 25.0%

---

## Backend Connectivity

### ✅ Backend Health Check

- **Status:** PASS
- **Message:** Status: 200
- **Details:** Backend is reachable at https://animalguardian-backend-production-b5a8.up.railway.app/api

---

## Authentication

### ✅ User Registration

- **Status:** PASS
- **Message:** Status: 400
- **Details:** Registration endpoint working

### ❌ Login (Email)

- **Status:** FAIL
- **Message:** Status: 403
- **Details:** {"error":"Your account is pending approval from an administrator or sector veterinarian. Please wait for approval before logging in.","pending_approval":true}

### ❌ Login (Phone)

- **Status:** FAIL
- **Message:** Status: 403
- **Details:** {"error":"Your account is pending approval from an administrator or sector veterinarian. Please wait

### ✅ Password Reset Request

- **Status:** PASS
- **Message:** Status: 200
- **Details:** Password reset endpoint exists

---

## Cases Management

### ⚠️ All Tests

- **Status:** SKIP
- **Message:** No auth token

---

## Livestock Management

### ⚠️ All Tests

- **Status:** SKIP
- **Message:** No auth token

---

## User Management

### ⚠️ All Tests

- **Status:** SKIP
- **Message:** No auth token

---

## Dashboard

### ⚠️ All Tests

- **Status:** SKIP
- **Message:** No auth token

---

## Notifications

### ⚠️ All Tests

- **Status:** SKIP
- **Message:** No auth token

---

## Community

### ⚠️ All Tests

- **Status:** SKIP
- **Message:** No auth token

---

## Marketplace

### ❌ List Products

- **Status:** FAIL
- **Message:** Status: 500
- **Details:** Marketplace products endpoint working

### ❌ List Categories

- **Status:** FAIL
- **Message:** Status: 500
- **Details:** Categories endpoint working

---

## Weather

### ⚠️ All Tests

- **Status:** SKIP
- **Message:** No auth token

---

## Files

### ⚠️ All Tests

- **Status:** SKIP
- **Message:** No auth token

---

## USSD Service

### ⚠️ USSD Health Check

- **Status:** SKIP
- **Message:** USSD service not running locally
- **Details:** Start with: cd ussd-service && python app.py

### ⚠️ USSD Handler

- **Status:** SKIP
- **Message:** USSD service not running
- **Details:** HTTPConnectionPool(host='localhost', port=5000): Max retries exceeded with url: /ussd (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x0000023B0F02D950>: Failed to establish a new connection: [WinError 10061] No connection could be made because the target machine actively refused it'))

### ⚠️ SMS Handler

- **Status:** SKIP
- **Message:** USSD service not running
- **Details:** HTTPConnectionPool(host='localhost', port=5000): Max retries exceeded with url: /sms (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x0000023B0F02DD10>: Failed to establish a new connection: [WinError 10061] No connection could be made because the target machine actively refused it'))

---

## Web Dashboard

### ✅ Dashboard Accessibility

- **Status:** PASS
- **Message:** Status: 200
- **Details:** Web dashboard is accessible

### ✅ Dashboard API Config

- **Status:** PASS
- **Message:** Status: 200
- **Details:** Dashboard API configuration check

---

