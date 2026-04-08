# Sapphire Stay Thesis Project Context (AI Scope Guide)

This document defines the **project context and boundaries** for any AI assistant working on this repository.

## 1) Project Identity

- **Project Name:** Sapphire Stay Hotel Management Web System
- **Case Study Location:** Muzaffarabad, Pakistan
- **Primary Goal:** Build a web-based hotel management system for thesis work.
- **Current Product Direction:**
	- Room-focused hotel website and management panel
	- Dynamic database-driven data
	- No mock/static business data in active flows

## 2) Final Business Context (Use This as Source of Truth)

- **Hotel Name:** Sapphire Stay | Muzaffarabad
- **Address:** Gojra Bypass Road, Muzaffarabad, Pakistan, 13100.
- **Contact Number:** +92 317 9219995
- **Public Contact Handle:** sapphire.stay
- **Offered Core Feature:** Rooms (booking and management)

## 3) Strict Scope Rules for AI

When helping in this project, AI should:

1. Stay within hotel-management thesis scope.
2. Prefer improving existing architecture, not introducing unrelated systems.
3. Keep data **database-first** (Convex) for site content and operational records.
4. Use local media from `imgs/` / `assets/imgs/` where required.
5. Preserve existing module boundaries: customer, staff, admin.
6. Keep changes minimal, practical, and production-oriented.

AI should **not**:

- Add irrelevant features outside hotel thesis scope.
- Reintroduce mock-first behavior for customer-facing business content.
- Add default placeholder branding/location that conflicts with Muzaffarabad details.
- Add a services/amenities marketing module that contradicts current room-focused direction.

## 4) Functional Modules in Scope

### Customer Module
- Browse room information and pricing
- Submit booking requests
- View gallery images
- View contact/location information
- Read and submit reviews (if enabled in current flow)

### Staff Module
- Daily booking handling
- Check-in/check-out support
- Invoice/payment operational tasks

### Admin Module
- Manage rooms, bookings, guests
- Manage staff accounts
- Monitor reports (occupancy/revenue/booking trends)
- Maintain site content via DB-backed configuration

## 5) Why We Made This Project

This project was developed as a thesis case study to solve real hotel management problems at Sapphire Stay.

### Core reasons
- Replace manual/paper-based operations with a digital workflow.
- Reduce booking, billing, and record-keeping errors.
- Provide customers an online room browsing and booking experience.
- Improve staff efficiency for daily operations.
- Give admins better visibility through centralized reports and data.

### Expected impact
- Faster operations and fewer mistakes
- Better customer convenience and communication
- Easier reporting for decision-making
- Scalable foundation for future hotel growth

## 6) Technologies Used (and Why)

- **Flutter Web (Frontend UI)**
	- Single modern codebase for responsive web interface.
	- Faster development for thesis timeline.

- **Riverpod (State Management)**
	- Predictable and testable state flow.
	- Clean separation between UI and business/data logic.

- **GoRouter (Navigation/Routing)**
	- Structured route management for customer, staff, and admin flows.
	- Better maintainability as project grows.

- **Convex (Backend + Database + APIs)**
	- Real-time friendly backend with typed queries/mutations.
	- Central source of truth for rooms, bookings, users, reports, and site content.
	- Supports DB-first requirement and removes dependency on mock data.

- **TypeScript (Convex functions)**
	- Safer backend logic with strong typing.
	- Easier long-term maintenance.

- **Local Media Assets (`imgs/` → `assets/imgs/...`)**
	- Controlled media source for consistent branding.
	- Avoids random external placeholder dependencies.

## 7) Data/Content Policy

- Website content should come from DB-backed providers whenever available.
- Fallback constants are safety-only, not business source of truth.
- Gallery should show images without titles/captions in UI.
- Logo image is part of gallery content.

## 8) Thesis Problem and Solution Summary

### Problem
Manual hotel operations cause delays, errors, weak reporting, and poor customer access.

### Proposed Solution
Provide an integrated web system for customer booking visibility and full hotel operations management (staff/admin), improving speed, accuracy, and reporting.

## 9) Definition of Done for Future AI Tasks

A task is considered aligned only if it:

- Supports thesis objectives,
- Respects room-focused business direction,
- Keeps DB-first data flow,
- Preserves Muzaffarabad business identity,
- Does not introduce out-of-scope functionality.

---

If there is any conflict between old text and this file, **follow this file**.