# Agnovat Mobile App - Flutter Requirements Document

**Version:** 1.0.0
**Last Updated:** October 26, 2024
**Target Platform:** Flutter (iOS & Android)
**Backend:** Agnovat MCP Server + Convex Database

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [System Architecture](#system-architecture)
3. [User Roles & Permissions](#user-roles--permissions)
4. [Authentication & Authorization](#authentication--authorization)
5. [Core Features & Screens](#core-features--screens)
6. [MCP Integration](#mcp-integration)
7. [Data Models](#data-models)
8. [API Specifications](#api-specifications)
9. [Security & Compliance](#security--compliance)
10. [UI/UX Guidelines](#uiux-guidelines)
11. [Technical Requirements](#technical-requirements)
12. [Development Phases](#development-phases)

---

## 1. Executive Summary

### 1.1 Project Overview

Agnovat Mobile App is a comprehensive Flutter-based mobile application for NDIS (National Disability Insurance Scheme) participant support management. The app connects to the Agnovat MCP Server as an MCP client and provides role-based access to support workers, coordinators, therapists, families, and clients themselves.

### 1.2 Key Objectives

- **Mobile-First Experience:** Provide a seamless mobile experience for field workers
- **Real-Time Sync:** Leverage Convex for real-time data synchronization
- **Role-Based Access:** Implement granular permissions based on user roles
- **Offline Support:** Allow critical operations to work offline with sync when online
- **NDIS Compliance:** Ensure all features meet NDIS documentation and privacy requirements

### 1.3 Target Users

- **Support Workers:** Field staff documenting shift notes and activities
- **Support Coordinators:** Managers overseeing multiple clients and goals
- **Therapists:** Allied health professionals tracking therapy goals
- **Families:** Family members monitoring participant progress
- **Clients:** NDIS participants viewing their own goals and activities
- **Managers:** Organization administrators with full system access
- **Super Admins:** System administrators with unrestricted access

---

## 2. System Architecture

### 2.1 Architecture Overview

```
┌─────────────────────────────────────┐
│     Flutter Mobile App (Client)     │
│                                     │
│  ┌─────────────────────────────┐   │
│  │   Presentation Layer        │   │
│  │   (Screens & Widgets)       │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │   Business Logic Layer      │   │
│  │   (BLoC/Provider/Riverpod)  │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │   Data Layer                │   │
│  │   - MCP Client              │   │
│  │   - Convex Client           │   │
│  │   - Local Storage (Hive)    │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
                 ▼
┌─────────────────────────────────────┐
│     Authentication Layer            │
│     (Clerk SDK for Flutter)         │
└─────────────────────────────────────┘
                 ▼
┌─────────────────────────────────────┐
│     Backend Services                │
│                                     │
│  ┌─────────────────────────────┐   │
│  │   Convex Database           │   │
│  │   - Real-time Queries       │   │
│  │   - Mutations               │   │
│  │   - Subscriptions           │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │   Agnovat MCP Server        │   │
│  │   - 32 Tools (CRUD)         │   │
│  │   - 6 Resources (URI)       │   │
│  │   - 6 Prompts (Workflows)   │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### 2.2 Technology Stack

#### Frontend (Flutter)
- **Framework:** Flutter 3.x
- **State Management:** Riverpod or BLoC
- **Authentication:** clerk_flutter (if available) or custom Clerk integration
- **Database (Local):** Hive or Drift for offline storage
- **HTTP Client:** Dio with retry logic
- **Real-time:** convex_flutter (if available) or WebSocket client
- **Forms:** flutter_form_builder + reactive_forms
- **UI Components:** Material 3 design system

#### Backend Integration
- **MCP Protocol:** Custom MCP client implementation
- **Convex Integration:** Direct Convex client for real-time data
- **Authentication:** Clerk authentication tokens

---

## 3. User Roles & Permissions

### 3.1 Role Definitions

#### 3.1.1 Super Admin
**Access Level:** Full system access

**Permissions:**
- ✅ Create, read, update, delete ALL entities
- ✅ Manage user accounts and roles
- ✅ View all audit logs
- ✅ Access system statistics and reports
- ✅ Configure system settings
- ✅ Assign/revoke client access to users
- ✅ Export all data

**Key Screens:**
- Admin Dashboard
- User Management
- System Settings
- Audit Logs
- Full access to all other screens

---

#### 3.1.2 Manager
**Access Level:** Organization-wide access

**Permissions:**
- ✅ View all clients, goals, activities, shift notes
- ✅ Create/update/deactivate clients
- ✅ Create/update/archive goals
- ✅ Create/update activities
- ✅ View all shift notes (cannot edit after 24h)
- ✅ Assign staff to clients
- ✅ View team performance metrics
- ✅ Generate reports

**Restrictions:**
- ❌ Cannot manage user roles
- ❌ Cannot access system settings
- ❌ Cannot delete data (soft deletes only)

**Key Screens:**
- Manager Dashboard
- Client List (all clients)
- Goal Management
- Team Performance
- Reports

---

#### 3.1.3 Support Coordinator
**Access Level:** Assigned clients + coordination duties

**Permissions:**
- ✅ View assigned clients and their full details
- ✅ Create/update goals for assigned clients
- ✅ Create/update activities for assigned clients
- ✅ View all shift notes for assigned clients
- ✅ Generate client progress reports
- ✅ Communicate with families and stakeholders

**Restrictions:**
- ❌ Cannot view unassigned clients
- ❌ Cannot manage users
- ❌ Cannot edit shift notes (view only)
- ❌ Cannot access organization-wide statistics

**Key Screens:**
- Coordinator Dashboard (assigned clients)
- Client Details
- Goal Planning
- Activity Scheduling
- Progress Reports

---

#### 3.1.4 Support Worker
**Access Level:** Assigned clients + shift documentation

**Permissions:**
- ✅ View assigned clients (limited details)
- ✅ View goals for assigned clients
- ✅ Create shift notes for assigned clients
- ✅ Update own shift notes (within 24 hours)
- ✅ Mark activities as completed
- ✅ Update goal progress during shifts
- ✅ View activity instructions

**Restrictions:**
- ❌ Cannot create/edit goals
- ❌ Cannot view sensitive client information (NDIS number, full DOB)
- ❌ Cannot view other workers' shift notes
- ❌ Cannot edit shift notes after 24 hours
- ❌ Cannot deactivate clients

**Key Screens:**
- Worker Dashboard (today's schedule)
- Client Quick View
- Shift Note Creation
- Activity Tracking
- Goal Progress Update

---

#### 3.1.5 Therapist
**Access Level:** Assigned clients + therapy-specific goals

**Permissions:**
- ✅ View assigned clients (therapy-relevant details)
- ✅ Create/update therapy-related goals
- ✅ Create therapy activities
- ✅ Document therapy session notes
- ✅ Track therapy goal progress
- ✅ Generate therapy reports

**Restrictions:**
- ❌ Cannot view non-therapy goals (unless granted)
- ❌ Cannot manage client assignments
- ❌ Cannot view support worker shift notes
- ❌ Limited access to overall client support notes

**Key Screens:**
- Therapy Dashboard
- Client Therapy Profile
- Therapy Goals
- Session Notes
- Therapy Reports

---

#### 3.1.6 Family
**Access Level:** Specific family member's data

**Permissions:**
- ✅ View family member's profile (limited)
- ✅ View family member's goals
- ✅ View family member's activities
- ✅ View shift note summaries (redacted sensitive info)
- ✅ Add family notes/observations
- ✅ View progress reports

**Restrictions:**
- ❌ Cannot create/edit goals
- ❌ Cannot create activities
- ❌ Cannot view other participants
- ❌ Cannot view detailed support worker notes
- ❌ Cannot view NDIS plan details
- ❌ Read-only access to most data

**Key Screens:**
- Family Dashboard
- Participant Profile
- Goals Overview
- Recent Activities
- Progress Summaries

---

#### 3.1.7 Client
**Access Level:** Own data only

**Permissions:**
- ✅ View own profile (limited)
- ✅ View own goals
- ✅ View own activities
- ✅ View shift summaries (simplified)
- ✅ Mark activities as favorites
- ✅ Add personal notes

**Restrictions:**
- ❌ Cannot create/edit goals
- ❌ Cannot view support worker details
- ❌ Cannot view internal notes
- ❌ Cannot view other participants
- ❌ Read-only access to all data

**Key Screens:**
- My Dashboard
- My Goals
- My Activities
- My Progress

---

### 3.2 Client Assignment System

#### Assignment Types

1. **Full Access Assignment**
   - View all client details including sensitive information
   - Create/edit goals and activities
   - Full shift note access
   - Available for: Manager, Support Coordinator, Therapist

2. **Limited Access Assignment**
   - View basic client information (name, goals)
   - Cannot view NDIS number or full DOB
   - Create shift notes but limited client history
   - Available for: Support Worker

#### Assignment Model

```dart
class ClientAssignment {
  final String id;
  final String userId;
  final String clientId;
  final String assignedRole; // Role for this specific assignment
  final AccessLevel accessLevel; // full | limited
  final String assignedBy; // User ID who assigned
  final bool active;
  final DateTime createdAt;
  final DateTime? expiresAt; // Optional expiry date
}

enum AccessLevel {
  full,
  limited,
}
```

---

## 4. Authentication & Authorization

### 4.1 Clerk Authentication Flow

#### 4.1.1 Sign Up/Sign In
```
User Opens App
     ↓
Check Local Auth Token
     ↓ (if expired or missing)
Show Clerk Sign-In Screen
     ↓
User Signs In (Email/SMS/OAuth)
     ↓
Clerk Returns JWT Token
     ↓
App Calls Backend with Token
     ↓
Backend Verifies Token
     ↓
Backend Returns User Profile + Role
     ↓
App Stores Token & User Data Locally
     ↓
Navigate to Role-Based Dashboard
```

#### 4.1.2 User Sync (Clerk Webhook)
- When user signs up in Clerk, webhook fires to Convex
- Convex creates user record with default role: `support_worker`
- Admin manually updates role as needed
- User sees limited access until role is properly set

### 4.2 Authorization Implementation

#### 4.2.1 Permission Checking

```dart
class PermissionService {
  final UserRole userRole;

  bool canViewClient(String clientId) {
    if (userRole == UserRole.superAdmin || userRole == UserRole.manager) {
      return true;
    }
    // Check client assignments
    return hasClientAssignment(clientId);
  }

  bool canEditGoal(String goalId) {
    if (userRole == UserRole.supportWorker || userRole == UserRole.family || userRole == UserRole.client) {
      return false;
    }
    // Check goal ownership and client assignment
    return canManageGoalsForClient(goalId.clientId);
  }

  bool canEditShiftNote(String shiftNoteId, DateTime shiftDate) {
    if (userRole != UserRole.supportWorker) {
      return false;
    }
    // Check 24-hour rule
    final now = DateTime.now();
    final cutoff = shiftDate.add(Duration(hours: 24));
    return now.isBefore(cutoff) && isOwnShiftNote(shiftNoteId);
  }
}
```

#### 4.2.2 Row-Level Security (Convex)
- Implement Convex query filters based on user role
- Filter client lists based on assignments
- Redact sensitive fields for limited access users

---

## 5. Core Features & Screens

### 5.1 Authentication Module

#### Screens:
1. **Splash Screen**
   - App logo
   - Check authentication status
   - Auto-navigate to dashboard or login

2. **Sign In Screen**
   - Email/password sign in
   - SMS OTP sign in (optional)
   - OAuth providers (Google, Apple)
   - "Forgot Password" link
   - Powered by Clerk

3. **Sign Up Screen**
   - Email + password
   - Name fields
   - Terms & Conditions checkbox
   - Powered by Clerk

4. **Profile Screen**
   - User name, email, photo
   - Role display (read-only)
   - Specialty (for therapists)
   - Sign out button

---

### 5.2 Dashboard Module

#### 5.2.1 Super Admin Dashboard

**Widgets:**
- Total users by role (pie chart)
- Total clients (active vs inactive)
- Total goals (by status)
- Recent audit logs (last 10 actions)
- System health indicators

**Actions:**
- Navigate to User Management
- Navigate to Audit Logs
- Navigate to System Settings
- View full dashboard (same as Manager)

---

#### 5.2.2 Manager Dashboard

**Widgets:**
- Total active clients
- Total active goals (by status)
- Recent activities (last 7 days)
- At-risk goals (behind target)
- Recent shift notes (last 10)
- Top stakeholders by activity count

**Actions:**
- Quick add client
- Quick add goal
- Generate weekly report
- View all clients

**API Calls:**
- `get_dashboard` tool
- `get_statistics` tool

---

#### 5.2.3 Support Coordinator Dashboard

**Widgets:**
- Assigned clients list (with stats)
- Goals requiring attention
- Upcoming client reviews
- Recent activities for assigned clients
- Messages/notifications

**Actions:**
- Add goal for client
- Schedule activity
- Generate client progress report

**API Calls:**
- `list_clients` (filtered by assignments)
- `list_goals` (filtered by assigned clients)
- `list_activities` (filtered by assigned clients)

---

#### 5.2.4 Support Worker Dashboard

**Widgets:**
- Today's schedule (activities)
- Clients for today
- Pending shift notes
- Quick stats (shifts this week)

**Actions:**
- Create shift note
- Mark activity complete
- View client quick view

**API Calls:**
- `list_activities` (filtered by stakeholder + date)
- `list_shift_notes` (own notes, recent)

---

#### 5.2.5 Therapist Dashboard

**Widgets:**
- Assigned clients
- Upcoming therapy sessions
- Therapy goals progress
- Recent therapy notes

**Actions:**
- Add therapy goal
- Document session
- View therapy reports

**API Calls:**
- `list_clients` (filtered by assignments)
- `list_goals` (filtered by category: health_wellbeing, therapy-related)
- `list_activities` (therapy type)

---

#### 5.2.6 Family Dashboard

**Widgets:**
- Family member profile summary
- Active goals progress (visual)
- Recent activities
- Upcoming activities
- Recent shift note summaries

**Actions:**
- View goal details
- View activity details
- Add family observation

**API Calls:**
- `get_client_summary` (family member)
- `list_goals` (family member)
- `list_activities` (family member)

---

#### 5.2.7 Client Dashboard

**Widgets:**
- My profile card
- My goals (simplified view)
- Activities I enjoyed (favorites)
- Recent progress

**Actions:**
- View my goals
- View my activities
- Mark activity as favorite

**API Calls:**
- `get_client_summary` (self)
- `list_goals` (self)
- `list_activities` (self)

---

### 5.3 Client Management Module

#### 5.3.1 Client List Screen

**For:** Super Admin, Manager, Support Coordinator (assigned only)

**Features:**
- Searchable list of clients
- Filter by active/inactive
- Sort by name, created date
- Client cards showing:
  - Name
  - Photo (if available)
  - Active goal count
  - Recent activity date
  - Status indicator

**Actions:**
- Tap client → Navigate to Client Details
- FAB: Add new client (Manager/Super Admin only)

**API Calls:**
- `list_clients` (with role-based filtering)
- `search_clients` (for search functionality)

---

#### 5.3.2 Client Details Screen

**For:** All roles (content varies by permission)

**Sections:**

1. **Header Card**
   - Name
   - Date of birth (full for Manager/Coordinator, age only for Worker)
   - NDIS number (Super Admin/Manager only)
   - Primary contact
   - Active status

2. **Tabs:**
   - **Overview:** Quick stats, support notes
   - **Goals:** List of goals with progress
   - **Activities:** Recent and upcoming activities
   - **Shift Notes:** Recent shift notes
   - **Documents:** (Future) Uploaded files

**Actions:**
- Edit client (Manager/Coordinator)
- Deactivate client (Manager/Super Admin)
- Add goal (Manager/Coordinator)
- Add activity (Manager/Coordinator/Worker)

**API Calls:**
- `get_client` (returns `ClientWithStats`)
- `list_goals` (filtered by client_id)
- `list_activities` (filtered by client_id)
- `list_shift_notes` (filtered by client_id)

---

#### 5.3.3 Create/Edit Client Screen

**For:** Manager, Super Admin

**Form Fields:**
- Name (required)
- Date of Birth (required, date picker)
- NDIS Number (optional, 11 digits validation)
- Primary Contact (optional, phone/email)
- Support Notes (optional, multiline)

**Validation:**
- Name: Required, min 2 characters
- DOB: Required, valid date, not in future
- NDIS Number: Optional, must be 11 digits
- Primary Contact: Valid phone or email format

**Actions:**
- Save (calls `create_client` or `update_client`)
- Cancel

**API Calls:**
- `create_client` (for new)
- `update_client` (for existing)

---

### 5.4 Goal Management Module

#### 5.4.1 Goal List Screen

**For:** All roles except Client (Client has simplified view)

**Features:**
- List of goals (filtered by client or all)
- Group by status: Not Started, In Progress, Achieved, On Hold
- Filter by category
- Filter by client (Manager/Coordinator)
- Sort by target date, progress

**Goal Card:**
- Title
- Client name (if multi-client view)
- Category badge
- Progress bar (0-100%)
- Target date
- Status badge
- At-risk indicator (if behind schedule)

**Actions:**
- Tap goal → Navigate to Goal Details
- FAB: Add new goal (Coordinator/Manager)

**API Calls:**
- `list_goals` (with filters)

---

#### 5.4.2 Goal Details Screen

**For:** All roles (read-only for Worker/Family/Client)

**Sections:**

1. **Header Card**
   - Title
   - Client name
   - Category
   - Status
   - Progress percentage
   - Target date
   - Created date
   - Achieved date (if applicable)

2. **Description**
   - Full goal description

3. **Milestones**
   - List of milestones
   - Checkboxes (visual only, not interactive)

4. **Related Activities**
   - Activities linked to this goal
   - Activity completion status

5. **Progress History**
   - Timeline of progress updates
   - Shift notes mentioning this goal

**Actions:**
- Edit goal (Coordinator/Manager)
- Update progress (Coordinator/Manager)
- Archive goal (Coordinator/Manager)
- Add activity for goal (Coordinator/Manager)

**API Calls:**
- `get_goal`
- `list_activities` (filtered by goal_id)
- `list_shift_notes` (with goals_progress containing this goal)

---

#### 5.4.3 Create/Edit Goal Screen

**For:** Support Coordinator, Manager, Therapist (therapy goals only)

**Form Fields:**
- Client (required, dropdown/search)
- Title (required)
- Description (optional, multiline)
- Category (required, dropdown):
  - Daily Living
  - Social & Community
  - Employment
  - Health & Wellbeing
  - Home
  - Lifelong Learning
  - Relationships
- Target Date (required, date picker)
- Milestones (optional, list of text items)

**Validation:**
- Client: Required, must be active
- Title: Required, min 3 characters
- Category: Required
- Target Date: Required, must be in future

**Actions:**
- Save (calls `create_goal` or `update_goal`)
- Cancel

**API Calls:**
- `create_goal`
- `update_goal`
- `list_clients` (for client dropdown)

---

#### 5.4.4 Update Goal Progress Screen

**For:** Support Coordinator, Manager

**Form Fields:**
- Current progress percentage (slider 0-100%)
- Status (dropdown):
  - Not Started
  - In Progress
  - Achieved
  - On Hold
  - Discontinued
- Progress notes (multiline)

**Actions:**
- Save (calls `update_goal_progress`)
- Cancel

**API Calls:**
- `update_goal_progress`

---

### 5.5 Activity Management Module

#### 5.5.1 Activity List Screen

**For:** All roles

**Features:**
- List of activities
- Filter by client
- Filter by stakeholder (own for Worker)
- Filter by type
- Filter by status
- Date range filter
- Sort by created date

**Activity Card:**
- Title
- Client name
- Stakeholder name
- Activity type badge
- Status badge
- Linked goals (count)
- Created date

**Actions:**
- Tap activity → Navigate to Activity Details
- FAB: Add new activity (Coordinator/Manager/Worker)

**API Calls:**
- `list_activities` (with filters)

---

#### 5.5.2 Activity Details Screen

**For:** All roles

**Sections:**

1. **Header Card**
   - Title
   - Client name
   - Stakeholder name
   - Activity type
   - Status
   - Created date

2. **Description**
   - Full activity description

3. **Linked Goals**
   - List of goals this activity supports
   - Goal progress indicators

4. **Outcome Notes**
   - Notes about activity outcome

**Actions:**
- Edit activity (Coordinator/Manager)
- Update status (Worker can mark as completed)

**API Calls:**
- `get_activity`

---

#### 5.5.3 Create/Edit Activity Screen

**For:** Support Coordinator, Manager, Support Worker

**Form Fields:**
- Client (required, dropdown/search)
- Stakeholder (required, dropdown/search) - auto-select self for Worker
- Title (required)
- Description (optional, multiline)
- Activity Type (required, dropdown):
  - Life Skills
  - Social & Community
  - Transport
  - Health/Medical
  - Therapy
  - Coordination
  - Other
- Status (required, dropdown):
  - Scheduled
  - In Progress
  - Completed
  - Cancelled
  - No Show
- Linked Goals (optional, multi-select from client's goals)
- Outcome Notes (optional, multiline)

**Validation:**
- Client: Required, must be active
- Stakeholder: Required, must be active
- Title: Required, min 3 characters
- Activity Type: Required
- Status: Required

**Actions:**
- Save (calls `create_activity` or `update_activity`)
- Cancel

**API Calls:**
- `create_activity`
- `update_activity`
- `list_clients` (for client dropdown)
- `list_stakeholders` (for stakeholder dropdown)
- `list_goals` (filtered by selected client)

---

### 5.6 Shift Note Module

#### 5.6.1 Shift Note List Screen

**For:** All roles except Client

**Features:**
- List of shift notes
- Filter by client
- Filter by stakeholder (own for Worker)
- Date range filter
- Sort by shift date

**Shift Note Card:**
- Client name
- Stakeholder name
- Shift date
- Shift time (start - end)
- Primary locations
- Summary (first 100 chars)
- Created date

**Actions:**
- Tap shift note → Navigate to Shift Note Details
- FAB: Add new shift note (Worker)

**API Calls:**
- `list_shift_notes` (with filters)
- `get_recent_shift_notes`
- `get_shift_notes_for_week`

---

#### 5.6.2 Shift Note Details Screen

**For:** All roles except Client (Family sees redacted version)

**Sections:**

1. **Header Card**
   - Client name
   - Stakeholder name
   - Shift date
   - Start time → End time
   - Primary locations (chips)

2. **Formatted Note** (if available)
   - AI-formatted professional note
   - Sections:
     - Morning Routine
     - Activities
     - Afternoon/Evening
     - Behaviours of Concern
     - Behaviour Support Provided
     - Home Environment
     - Summary

3. **Raw Notes**
   - Original unformatted notes from support worker

4. **Linked Activities**
   - Activities referenced in this shift

5. **Goal Progress**
   - Goals tracked during this shift
   - Progress notes per goal
   - Progress observed (1-10 rating)

**Actions:**
- Edit shift note (own Worker, within 24h)
- Format note (if not formatted yet)
- View formatted note (if formatted)

**API Calls:**
- `get_shift_note`

---

#### 5.6.3 Create/Edit Shift Note Screen

**For:** Support Worker

**Form Fields:**
- Client (required, dropdown - assigned clients only)
- Stakeholder (auto-filled, read-only - self)
- Shift Date (required, date picker - max today)
- Start Time (required, time picker)
- End Time (required, time picker - must be after start)
- Primary Locations (optional, multi-chip input)
- Raw Notes (required, multiline, min 50 characters)
- Linked Activities (optional, multi-select from recent activities)
- Goal Progress (optional, repeatable section):
  - Select Goal (dropdown from client's active goals)
  - Progress Notes (text)
  - Progress Observed (slider 1-10)

**Validation:**
- Client: Required, must be assigned
- Shift Date: Required, cannot be future
- Start Time: Required
- End Time: Required, must be after start time
- Raw Notes: Required, min 50 characters
- If Goal Progress added: Goal, Progress Notes, Progress Observed all required

**Edit Restrictions:**
- Can only edit within 24 hours of shift date
- Show warning when approaching 24-hour limit

**Actions:**
- Save (calls `create_shift_note` or `update_shift_note`)
- Cancel

**API Calls:**
- `create_shift_note`
- `update_shift_note`
- `list_clients` (assigned only)
- `list_goals` (filtered by selected client)
- `list_activities` (filtered by selected client + recent)

---

#### 5.6.4 Format Shift Note Screen (AI Integration)

**For:** Support Worker, Coordinator, Manager

**Flow:**
1. Select shift note to format
2. Call `format_shift_note` tool → Returns formatting prompt
3. Send prompt to AI model (e.g., Claude API)
4. Receive formatted note from AI
5. Preview formatted note
6. Save formatted note (calls `save_formatted_shift_note`)

**UI:**
- Loading indicator while formatting
- Split view: Raw notes (top) | Formatted notes (bottom)
- Edit formatted note before saving (optional)
- Save button

**API Calls:**
- `format_shift_note` (returns prompt)
- `save_formatted_shift_note` (saves result)

---

### 5.7 Stakeholder Management Module

#### 5.7.1 Stakeholder List Screen

**For:** Manager, Super Admin, Coordinator

**Features:**
- List of stakeholders
- Filter by role
- Filter by active/inactive
- Search by name
- Sort by name, created date

**Stakeholder Card:**
- Name
- Role badge
- Organization
- Email
- Phone
- Active status

**Actions:**
- Tap stakeholder → Navigate to Stakeholder Details
- FAB: Add new stakeholder (Manager/Super Admin)

**API Calls:**
- `list_stakeholders` (with filters)
- `search_stakeholders`

---

#### 5.7.2 Stakeholder Details Screen

**For:** Manager, Super Admin, Coordinator

**Sections:**

1. **Header Card**
   - Name
   - Role
   - Email
   - Phone
   - Organization
   - Notes
   - Active status

2. **Activity Summary**
   - Total activities
   - Recent activities (last 10)
   - Total shift notes documented

**Actions:**
- Edit stakeholder (Manager/Super Admin)
- Deactivate stakeholder (Manager/Super Admin)

**API Calls:**
- `get_stakeholder` (returns with activity summary)

---

#### 5.7.3 Create/Edit Stakeholder Screen

**For:** Manager, Super Admin

**Form Fields:**
- Name (required)
- Role (required, dropdown):
  - Support Worker
  - Support Coordinator
  - Plan Manager
  - Allied Health
  - Team Leader
  - Other
- Email (optional, email validation)
- Phone (optional, phone validation)
- Organization (optional)
- Notes (optional, multiline)

**Validation:**
- Name: Required, min 2 characters
- Role: Required
- Email: Valid email format
- Phone: Valid phone format

**Actions:**
- Save (calls `create_stakeholder` or `update_stakeholder`)
- Cancel

**API Calls:**
- `create_stakeholder`
- `update_stakeholder`

---

### 5.8 Reports & Analytics Module

#### 5.8.1 Dashboard Summary

**For:** Manager, Super Admin

**Widgets:**
- Total clients (active vs inactive)
- Total goals by status (pie chart)
- Recent activities (last 7 days)
- At-risk goals (list)
- Recent shift notes (last 10)
- Top stakeholders by activity count

**API Calls:**
- `get_dashboard`
- `get_statistics`

---

#### 5.8.2 Client Progress Report

**For:** Coordinator, Manager

**Input:**
- Select client
- Select date range (last 7/30/90 days)

**Report Sections:**
- Client summary
- Goals worked on
- Activities completed
- Shift notes from period
- Progress made on goals
- Overall assessment
- Recommendations

**Actions:**
- Export as PDF (future)
- Share via email (future)

**API Calls:**
- Use `review_client_progress` prompt
- Calls multiple tools: `get_client_summary`, `list_activities`, `list_shift_notes`, `list_goals`

---

#### 5.8.3 Weekly Report

**For:** Manager, Coordinator

**Input:**
- Select client (optional, all if not selected)
- Select week start date

**Report Sections:**

**Single Client:**
- Client overview
- Goals worked on during week
- All activities completed
- Shift notes from week
- Progress made on goals
- Upcoming activities
- Overall assessment

**All Clients:**
- Dashboard summary
- Goals achieved this week
- Goals at risk
- Total shift notes documented
- Activity completion rate
- Client-by-client highlights
- Overall team performance

**Actions:**
- Export as PDF (future)
- Share via email (future)

**API Calls:**
- Use `weekly_report` prompt
- Calls `get_dashboard`, `get_statistics`, `list_activities`, `get_shift_notes_for_week`

---

#### 5.8.4 Goal Risk Review

**For:** Manager, Coordinator

**Report:**
- List of at-risk goals from dashboard
- For each at-risk goal:
  - Client name
  - Goal title and category
  - Current progress percentage
  - Target date and days remaining
  - Recent activities related to this goal
  - Last shift note mentioning this goal
  - Suggested action plans

**Actions:**
- Tap goal → Navigate to Goal Details
- Quick update progress

**API Calls:**
- Use `goal_risk_review` prompt
- Calls `get_dashboard`, `get_goal`, `list_activities`

---

### 5.9 User Management Module (Admin Only)

#### 5.9.1 User List Screen

**For:** Super Admin

**Features:**
- List of all users
- Filter by role
- Filter by active/inactive
- Search by name or email
- Sort by created date, last login

**User Card:**
- Name
- Email
- Role badge
- Profile image
- Last login
- Active status

**Actions:**
- Tap user → Navigate to User Details
- FAB: Add new user (invite via Clerk)

**API Calls:**
- Convex query: `listUsers` (with filters)

---

#### 5.9.2 User Details Screen

**For:** Super Admin

**Sections:**

1. **Header Card**
   - Name
   - Email
   - Profile image
   - Clerk ID
   - Role
   - Specialty (if therapist)
   - Active status
   - Created date
   - Last login

2. **Client Assignments**
   - List of assigned clients
   - Assignment role
   - Access level (full/limited)
   - Expiry date (if applicable)

3. **Recent Activity**
   - Last 10 actions from audit log

**Actions:**
- Edit user (update role, specialty)
- Assign client
- Revoke client assignment
- Deactivate user

**API Calls:**
- Convex query: `getUserById`
- Convex query: `listClientAssignments` (filtered by user_id)
- Convex query: `listAuditLogs` (filtered by user_id)

---

#### 5.9.3 Edit User Screen

**For:** Super Admin

**Form Fields:**
- Name (read-only, synced from Clerk)
- Email (read-only, synced from Clerk)
- Role (editable, dropdown)
- Specialty (editable for therapists)
- Active (toggle)

**Actions:**
- Save (Convex mutation: `updateUser`)
- Cancel

---

#### 5.9.4 Assign Client Screen

**For:** Super Admin, Manager

**Form Fields:**
- User (dropdown/search)
- Client (dropdown/search)
- Assigned Role (dropdown: same as user roles)
- Access Level (toggle: Full | Limited)
- Expires At (optional, date picker)

**Actions:**
- Save (Convex mutation: `createClientAssignment`)
- Cancel

**API Calls:**
- Convex query: `listUsers`
- Convex query: `listClients`
- Convex mutation: `createClientAssignment`

---

### 5.10 Audit Log Module

#### 5.10.1 Audit Log Screen

**For:** Super Admin

**Features:**
- List of all audit log entries
- Filter by user
- Filter by action
- Filter by resource type
- Date range filter
- Sort by timestamp (desc)

**Log Entry Card:**
- Timestamp
- User email
- Action (e.g., "create_client", "update_goal")
- Resource type (e.g., "client", "goal")
- Resource ID
- Success/Failure badge
- IP address
- Error message (if failed)

**Actions:**
- Tap entry → View full details (JSON)

**API Calls:**
- Convex query: `listAuditLogs` (with filters)

---

## 6. MCP Integration

### 6.1 MCP Client Implementation

#### 6.1.1 MCP Protocol Overview

The app will implement an MCP client to communicate with the Agnovat MCP Server. This enables:
- Standardized tool calling (32 CRUD operations)
- Resource access via URIs (6 resource types)
- Guided workflows via prompts (6 prompt templates)

#### 6.1.2 MCP Client Architecture

```dart
class MCPClient {
  final String serverUrl;
  final Dio httpClient;

  Future<MCPResponse> callTool(String toolName, Map<String, dynamic> args) async {
    // Send JSON-RPC request to MCP server
    final response = await httpClient.post(
      serverUrl,
      data: {
        'jsonrpc': '2.0',
        'method': 'tools/call',
        'params': {
          'name': toolName,
          'arguments': args,
        },
        'id': generateRequestId(),
      },
    );

    return MCPResponse.fromJson(response.data);
  }

  Future<List<MCPTool>> listTools() async {
    // List all available tools
  }

  Future<String> readResource(String uri) async {
    // Read resource by URI (e.g., client:///uuid)
  }

  Future<MCPPrompt> getPrompt(String promptName, Map<String, String> args) async {
    // Get prompt template with arguments
  }
}
```

#### 6.1.3 Error Handling

```dart
class MCPError implements Exception {
  final String code;
  final String message;

  MCPError(this.code, this.message);

  factory MCPError.fromJson(Map<String, dynamic> json) {
    return MCPError(
      json['code'] as String,
      json['message'] as String,
    );
  }
}

// Error codes from MCP server:
// - VALIDATION_ERROR: Input validation failed
// - NOT_FOUND: Resource not found
// - CONFLICT: Business rule violation
// - STORAGE_ERROR: Database error
// - AUTHORIZATION_ERROR: Permission denied
```

---

### 6.2 Tool Mapping

#### 6.2.1 Client Tools (6)

| Tool Name | Dart Method | Purpose |
|-----------|-------------|---------|
| `create_client` | `createClient()` | Create new client |
| `get_client` | `getClient(id)` | Get client with stats |
| `list_clients` | `listClients(filters)` | List/search clients |
| `update_client` | `updateClient(id, data)` | Update client info |
| `deactivate_client` | `deactivateClient(id)` | Soft delete client |
| `search_clients` | `searchClients(term)` | Search by name |

---

#### 6.2.2 Goal Tools (6)

| Tool Name | Dart Method | Purpose |
|-----------|-------------|---------|
| `create_goal` | `createGoal()` | Create new goal |
| `get_goal` | `getGoal(id)` | Get goal details |
| `list_goals` | `listGoals(filters)` | List/filter goals |
| `update_goal` | `updateGoal(id, data)` | Update goal info |
| `update_goal_progress` | `updateGoalProgress(id, progress)` | Update progress |
| `archive_goal` | `archiveGoal(id)` | Soft delete goal |

---

#### 6.2.3 Activity Tools (4)

| Tool Name | Dart Method | Purpose |
|-----------|-------------|---------|
| `create_activity` | `createActivity()` | Create new activity |
| `get_activity` | `getActivity(id)` | Get activity details |
| `list_activities` | `listActivities(filters)` | List/filter activities |
| `update_activity` | `updateActivity(id, data)` | Update activity info |

---

#### 6.2.4 Stakeholder Tools (6)

| Tool Name | Dart Method | Purpose |
|-----------|-------------|---------|
| `create_stakeholder` | `createStakeholder()` | Create new stakeholder |
| `get_stakeholder` | `getStakeholder(id)` | Get stakeholder details |
| `list_stakeholders` | `listStakeholders(filters)` | List/filter stakeholders |
| `update_stakeholder` | `updateStakeholder(id, data)` | Update stakeholder info |
| `deactivate_stakeholder` | `deactivateStakeholder(id)` | Soft delete stakeholder |
| `search_stakeholders` | `searchStakeholders(term)` | Search by name |

---

#### 6.2.5 Shift Note Tools (7)

| Tool Name | Dart Method | Purpose |
|-----------|-------------|---------|
| `create_shift_note` | `createShiftNote()` | Create new shift note |
| `get_shift_note` | `getShiftNote(id)` | Get shift note details |
| `list_shift_notes` | `listShiftNotes(filters)` | List/filter shift notes |
| `update_shift_note` | `updateShiftNote(id, data)` | Update shift note (24h) |
| `get_recent_shift_notes` | `getRecentShiftNotes(limit)` | Get recent notes |
| `get_shift_notes_for_week` | `getShiftNotesForWeek(date)` | Get week's notes |
| `format_shift_note` | `formatShiftNote(id)` | Get formatting prompt |
| `save_formatted_shift_note` | `saveFormattedShiftNote(id, formatted)` | Save AI formatted note |

---

#### 6.2.6 Dashboard Tools (3)

| Tool Name | Dart Method | Purpose |
|-----------|-------------|---------|
| `get_dashboard` | `getDashboard()` | Get full dashboard metrics |
| `get_client_summary` | `getClientSummary(id)` | Get client overview |
| `get_statistics` | `getStatistics()` | Get high-level stats |

---

### 6.3 Resource URI Mapping

| URI Pattern | Example | Purpose |
|-------------|---------|---------|
| `client:///{id}` | `client:///abc-123` | Direct client access |
| `goal:///{id}` | `goal:///def-456` | Direct goal access |
| `activity:///{id}` | `activity:///ghi-789` | Direct activity access |
| `shift_note:///{id}` | `shift_note:///jkl-012` | Direct shift note access |
| `stakeholder:///{id}` | `stakeholder:///mno-345` | Direct stakeholder access |
| `dashboard://summary` | `dashboard://summary` | Dashboard summary |

**Usage:**
```dart
final clientData = await mcpClient.readResource('client:///abc-123');
final dashboard = await mcpClient.readResource('dashboard://summary');
```

---

### 6.4 Prompt Integration

#### 6.4.1 Available Prompts

| Prompt Name | Purpose | Arguments |
|-------------|---------|-----------|
| `create_shift_note_for_client` | Guide shift note creation | `client_id` |
| `review_client_progress` | Review client progress | `client_id`, `period_days` |
| `plan_activity_for_goal` | Plan goal-related activity | `goal_id`, `stakeholder_id` |
| `handover_summary` | Generate handover summary | `client_id` |
| `weekly_report` | Generate weekly report | `client_id` (optional), `week_start_date` |
| `goal_risk_review` | Review at-risk goals | (none) |

#### 6.4.2 Prompt Usage Pattern

```dart
// 1. Get prompt template
final prompt = await mcpClient.getPrompt('review_client_progress', {
  'client_id': 'abc-123',
  'period_days': '7',
});

// 2. Display prompt to user or use with AI
// prompt.messages contains the formatted prompt text

// 3. Execute the workflow (app calls multiple tools based on prompt guidance)
```

---

## 7. Data Models

### 7.1 Core Models

#### 7.1.1 User

```dart
class User {
  final String id;
  final String clerkId;
  final String email;
  final String name;
  final String? imageUrl;
  final UserRole role;
  final String? stakeholderId;
  final String? clientId;
  final String? specialty;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;
}

enum UserRole {
  superAdmin,
  manager,
  supportCoordinator,
  supportWorker,
  therapist,
  family,
  client,
}
```

---

#### 7.1.2 Client

```dart
class Client {
  final String id;
  final String name;
  final String dateOfBirth; // ISO YYYY-MM-DD
  final String? ndisNumber; // 11 digits
  final String? primaryContact;
  final String? supportNotes;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class ClientWithStats extends Client {
  final int activeGoalsCount;
  final int totalActivitiesCount;
  final DateTime? lastActivityDate;
  final DateTime? lastShiftNoteDate;
}
```

---

#### 7.1.3 Goal

```dart
class Goal {
  final String id;
  final String clientId;
  final String title;
  final String? description;
  final GoalCategory category;
  final String targetDate; // ISO YYYY-MM-DD
  final GoalStatus status;
  final int progressPercentage; // 0-100
  final List<String>? milestones;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? achievedAt;
  final bool archived;
}

enum GoalStatus {
  notStarted,
  inProgress,
  achieved,
  onHold,
  discontinued,
}

enum GoalCategory {
  dailyLiving,
  socialCommunity,
  employment,
  healthWellbeing,
  home,
  lifelongLearning,
  relationships,
}
```

---

#### 7.1.4 Activity

```dart
class Activity {
  final String id;
  final String clientId;
  final String stakeholderId;
  final String title;
  final String? description;
  final ActivityType activityType;
  final ActivityStatus status;
  final List<String>? goalIds;
  final String? outcomeNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
}

enum ActivityType {
  lifeSkills,
  socialCommunity,
  transport,
  healthMedical,
  therapy,
  coordination,
  other,
}

enum ActivityStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
  noShow,
}
```

---

#### 7.1.5 Stakeholder

```dart
class Stakeholder {
  final String id;
  final String name;
  final StakeholderRole role;
  final String? email;
  final String? phone;
  final String? organization;
  final String? notes;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
}

enum StakeholderRole {
  supportWorker,
  supportCoordinator,
  planManager,
  alliedHealth,
  teamLeader,
  other,
}
```

---

#### 7.1.6 Shift Note

```dart
class ShiftNote {
  final String id;
  final String clientId;
  final String stakeholderId;
  final String shiftDate; // ISO YYYY-MM-DD
  final String startTime; // HH:MM
  final String endTime; // HH:MM
  final List<String>? primaryLocations;
  final String rawNotes;
  final String? morningRoutine;
  final String? activities;
  final String? afternoonEvening;
  final String? behavioursOfConcern;
  final String? behaviourSupportProvided;
  final String? homeEnvironment;
  final String? summary;
  final String? formattedNote;
  final List<String>? activityIds;
  final List<GoalProgress>? goalsProgress;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class GoalProgress {
  final String goalId;
  final String progressNotes;
  final int progressObserved; // 1-10
}
```

---

#### 7.1.7 Client Assignment

```dart
class ClientAssignment {
  final String id;
  final String userId;
  final String clientId;
  final String assignedRole;
  final AccessLevel accessLevel;
  final String assignedBy;
  final bool active;
  final DateTime createdAt;
  final DateTime? expiresAt;
}

enum AccessLevel {
  full,
  limited,
}
```

---

#### 7.1.8 Audit Log

```dart
class AuditLog {
  final String id;
  final String? userId;
  final String? userEmail;
  final String action;
  final String resourceType;
  final String? resourceId;
  final String? details;
  final String? ipAddress;
  final bool success;
  final String? errorMessage;
  final DateTime timestamp;
}
```

---

### 7.2 Dashboard Models

```dart
class DashboardSummary {
  final int totalClients;
  final int activeClients;
  final GoalsSummary goalsSummary;
  final int totalActivities;
  final List<Goal> atRiskGoals;
  final List<ShiftNote> recentShiftNotes;
  final List<Activity> recentActivities;
}

class GoalsSummary {
  final int total;
  final int notStarted;
  final int inProgress;
  final int achieved;
  final int onHold;
  final int discontinued;
}

class Statistics {
  final int totalRecords;
  final Map<String, int> recordsByCollection;
}
```

---

## 8. API Specifications

### 8.1 Authentication Endpoints

#### 8.1.1 Sign In
- **Provider:** Clerk
- **Method:** Clerk SDK methods
- **Flow:** User signs in → Clerk returns JWT → App validates with backend

#### 8.1.2 Get Current User
- **Endpoint:** Convex query `getCurrentUser`
- **Input:** `{ clerk_id: string }`
- **Output:** `User` object
- **Error:** `User not found` if user doesn't exist in Convex

#### 8.1.3 Update Last Login
- **Endpoint:** Convex mutation `updateLastLogin`
- **Input:** `{ clerk_id: string }`
- **Output:** Success (no return value)

---

### 8.2 MCP Tool Endpoints

All MCP tools follow the same JSON-RPC format:

**Request:**
```json
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "create_client",
    "arguments": {
      "name": "John Doe",
      "date_of_birth": "1990-01-01",
      "ndis_number": "12345678901"
    }
  },
  "id": "request-123"
}
```

**Success Response:**
```json
{
  "jsonrpc": "2.0",
  "result": {
    "content": [
      {
        "type": "text",
        "text": "{\"id\":\"abc-123\",\"name\":\"John Doe\",...}"
      }
    ]
  },
  "id": "request-123"
}
```

**Error Response:**
```json
{
  "jsonrpc": "2.0",
  "result": {
    "content": [
      {
        "type": "text",
        "text": "{\"error\":\"Validation failed\",\"code\":\"VALIDATION_ERROR\"}"
      }
    ],
    "isError": true
  },
  "id": "request-123"
}
```

---

### 8.3 Convex Direct Queries (for real-time data)

#### 8.3.1 User Queries

**Get User by Clerk ID:**
```dart
final user = await convex.query('users:getUserByClerkId', {
  'clerk_id': clerkId,
});
```

**List Users:**
```dart
final users = await convex.query('users:listUsers', {
  'role': 'support_worker', // optional
  'active': true, // optional
});
```

---

#### 8.3.2 Client Queries

**List Clients (with filtering):**
```dart
final clients = await mcpClient.callTool('list_clients', {
  'active': true,
  'limit': 20,
  'offset': 0,
});
```

---

#### 8.3.3 Goal Queries

**List Goals by Client:**
```dart
final goals = await mcpClient.callTool('list_goals', {
  'client_id': clientId,
  'archived': false,
});
```

---

### 8.4 Permission Checking

#### 8.4.1 Check Client Assignment

```dart
bool hasClientAccess(String userId, String clientId) {
  // Query Convex for client_assignments
  final assignments = await convex.query('client_assignments:listByUser', {
    'user_id': userId,
    'client_id': clientId,
    'active': true,
  });

  return assignments.isNotEmpty;
}
```

---

## 9. Security & Compliance

### 9.1 NDIS Compliance

#### 9.1.1 Data Privacy
- **PII Protection:** All sensitive fields auto-redacted in logs
- **Role-Based Redaction:** Limited access users see redacted data
- **Audit Trail:** All actions logged with user, timestamp, IP

#### 9.1.2 Sensitive Fields (Auto-Redacted)
- `ndis_number` (except Super Admin, Manager)
- `date_of_birth` (full DOB - show age only for limited access)
- `email`, `phone`
- `password`, `token`, `secret`
- `support_notes` (for family/client roles)

---

### 9.2 Authentication Security

#### 9.2.1 Token Management
- **JWT Tokens:** Clerk-issued JWT with expiry
- **Refresh Tokens:** Auto-refresh before expiry
- **Secure Storage:** Store tokens in Flutter Secure Storage (encrypted)
- **Token Revocation:** Clerk handles token revocation on sign out

#### 9.2.2 Session Management
- **Auto Sign Out:** After 24 hours of inactivity
- **Session Timeout Warning:** 5 minutes before timeout
- **Concurrent Sessions:** Allowed (user can sign in on multiple devices)

---

### 9.3 Data Security

#### 9.3.1 Encryption
- **At Rest:** Convex handles database encryption
- **In Transit:** HTTPS/TLS 1.3 for all API calls
- **Local Storage:** Hive encryption for offline data

#### 9.3.2 Input Validation
- **Client-Side:** Flutter form validation (immediate feedback)
- **Server-Side:** Zod schema validation in MCP server (authoritative)
- **Sanitization:** All user inputs sanitized before storage

---

### 9.4 Authorization

#### 9.4.1 Permission Enforcement
- **Client-Side:** UI hides unauthorized actions
- **Server-Side:** MCP tools enforce permissions (authoritative)
- **Database-Level:** Convex queries filter by user assignments

#### 9.4.2 Business Rules
- **24-Hour Edit Window:** Shift notes cannot be edited after 24 hours
- **Client Assignment:** Workers can only access assigned clients
- **Soft Deletes Only:** No hard deletes (for audit trail)
- **Active Client Rule:** Cannot create goals for inactive clients

---

### 9.5 Audit Logging

#### 9.5.1 Logged Actions
- User sign in/sign out
- Create/update/delete operations
- Permission changes
- Failed authorization attempts
- System errors

#### 9.5.2 Audit Log Entry
```dart
{
  "user_id": "user-123",
  "user_email": "worker@example.com",
  "action": "create_shift_note",
  "resource_type": "shift_note",
  "resource_id": "note-456",
  "details": "Created shift note for client abc-123",
  "ip_address": "192.168.1.100",
  "success": true,
  "timestamp": "2024-10-26T10:30:00Z"
}
```

---

## 10. UI/UX Guidelines

### 10.1 Design System

#### 10.1.1 Material 3 Design
- **Theme:** Light + Dark mode support
- **Primary Color:** NDIS Blue (#0066CC)
- **Secondary Color:** Warm Orange (#FF6B35)
- **Success:** Green (#4CAF50)
- **Warning:** Amber (#FFC107)
- **Error:** Red (#F44336)

#### 10.1.2 Typography
- **Headings:** Roboto Bold
- **Body:** Roboto Regular
- **Monospace:** Roboto Mono (for IDs, dates)

#### 10.1.3 Iconography
- **Icon Set:** Material Icons
- **Custom Icons:** NDIS-specific (goals, activities, shift notes)

---

### 10.2 Navigation

#### 10.2.1 Bottom Navigation (Primary)
- **Home:** Dashboard (role-specific)
- **Clients:** Client list
- **Goals:** Goal list
- **Activities:** Activity list
- **More:** Settings, profile, reports

#### 10.2.2 App Bar
- **Title:** Current screen name
- **Actions:** Context-specific (filter, search, add)
- **Back Button:** When navigating deeper

---

### 10.3 Component Patterns

#### 10.3.1 Cards
- **Client Card:** Avatar, name, stats, status badge
- **Goal Card:** Title, progress bar, category badge, target date
- **Activity Card:** Title, client name, stakeholder, type badge
- **Shift Note Card:** Client name, date, time, summary

#### 10.3.2 Lists
- **Scrollable Lists:** Pull to refresh
- **Pagination:** Load more on scroll to bottom
- **Empty States:** Friendly message + action (e.g., "No clients yet. Add one!")

#### 10.3.3 Forms
- **Validation:** Real-time feedback
- **Required Fields:** Asterisk (*)
- **Help Text:** Below input fields
- **Error Messages:** Red text below field
- **Save Button:** FAB or bottom app bar

---

### 10.4 Accessibility

#### 10.4.1 Screen Readers
- Semantic labels for all interactive elements
- Screen reader announcements for actions

#### 10.4.2 Font Scaling
- Support system font size preferences
- Test with large font sizes

#### 10.4.3 Color Contrast
- WCAG AA compliance (4.5:1 for text)
- Test with color blindness simulators

---

### 10.5 Offline Support

#### 10.5.1 Offline Indicators
- **Banner:** "You are offline. Some features may be limited."
- **Icon:** Network status indicator in app bar

#### 10.5.2 Offline Capabilities
- **View Cached Data:** View previously loaded clients, goals, activities
- **Create Shift Notes:** Save locally, sync when online
- **Pending Sync Badge:** Show items pending sync

---

## 11. Technical Requirements

### 11.1 Flutter Environment

- **Flutter SDK:** 3.16 or higher
- **Dart SDK:** 3.2 or higher
- **Target Platforms:** iOS 13+, Android 8.0+

---

### 11.2 Dependencies

#### 11.2.1 Core
```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # HTTP & API
  dio: ^5.4.0
  retrofit: ^4.0.0
  json_annotation: ^4.8.0

  # Authentication
  clerk_flutter: ^1.0.0 # or custom Clerk integration
  flutter_secure_storage: ^9.0.0

  # Local Database
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Real-time (Convex)
  web_socket_channel: ^2.4.0

  # Forms
  flutter_form_builder: ^9.1.0
  reactive_forms: ^16.1.0

  # UI Components
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0

  # Date/Time
  intl: ^0.18.1
  timezone: ^0.9.2

  # Utilities
  uuid: ^4.2.0
  logger: ^2.0.0
  equatable: ^2.0.5

dev_dependencies:
  # Code Generation
  build_runner: ^2.4.6
  riverpod_generator: ^2.3.0
  json_serializable: ^6.7.1
  retrofit_generator: ^8.0.0
  hive_generator: ^2.0.1

  # Testing
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  integration_test:
    sdk: flutter
```

---

### 11.3 Project Structure

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── theme.dart
│   │   └── routes.dart
│   ├── utils/
│   │   ├── logger.dart
│   │   ├── validators.dart
│   │   └── formatters.dart
│   └── errors/
│       ├── exceptions.dart
│       └── failure.dart
│
├── data/
│   ├── models/
│   │   ├── user.dart
│   │   ├── client.dart
│   │   ├── goal.dart
│   │   ├── activity.dart
│   │   ├── stakeholder.dart
│   │   └── shift_note.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── client_repository.dart
│   │   ├── goal_repository.dart
│   │   └── ...
│   ├── datasources/
│   │   ├── mcp_client.dart
│   │   ├── convex_client.dart
│   │   └── local_storage.dart
│   └── dto/
│       └── ... (Data Transfer Objects)
│
├── domain/
│   ├── entities/
│   │   └── ... (Pure business objects)
│   └── usecases/
│       ├── get_dashboard_usecase.dart
│       ├── create_shift_note_usecase.dart
│       └── ...
│
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── client_provider.dart
│   │   └── ...
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── sign_in_screen.dart
│   │   │   └── sign_up_screen.dart
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart
│   │   ├── clients/
│   │   │   ├── client_list_screen.dart
│   │   │   ├── client_details_screen.dart
│   │   │   └── client_form_screen.dart
│   │   ├── goals/
│   │   │   └── ...
│   │   ├── activities/
│   │   │   └── ...
│   │   ├── shift_notes/
│   │   │   └── ...
│   │   └── ...
│   └── widgets/
│       ├── common/
│       │   ├── app_bar.dart
│       │   ├── loading_indicator.dart
│       │   └── error_widget.dart
│       └── cards/
│           ├── client_card.dart
│           ├── goal_card.dart
│           └── ...
│
└── services/
    ├── auth_service.dart
    ├── permission_service.dart
    ├── sync_service.dart
    └── notification_service.dart
```

---

### 11.4 Performance Requirements

#### 11.4.1 App Launch
- **Cold Start:** < 3 seconds
- **Warm Start:** < 1 second

#### 11.4.2 Screen Transitions
- **Animation:** 60 FPS
- **Navigation:** < 300ms

#### 11.4.3 API Calls
- **Average Response:** < 500ms
- **Timeout:** 10 seconds
- **Retry:** 3 attempts with exponential backoff

#### 11.4.4 Offline Sync
- **Sync Interval:** Every 30 seconds when online
- **Batch Size:** 50 items per sync

---

### 11.5 Testing Requirements

#### 11.5.1 Unit Tests
- **Coverage:** > 80%
- **Focus:** Business logic, use cases, repositories

#### 11.5.2 Widget Tests
- **Coverage:** > 70%
- **Focus:** UI components, screens

#### 11.5.3 Integration Tests
- **Focus:** Critical user flows (sign in, create shift note, etc.)

#### 11.5.4 E2E Tests
- **Focus:** Complete workflows (create client → add goal → document shift)

---

## 12. Development Phases

### Phase 1: Foundation (Weeks 1-2)

**Goals:**
- Set up Flutter project structure
- Implement authentication (Clerk integration)
- Create base UI components and theme
- Implement MCP client

**Deliverables:**
- Sign in/sign up screens
- Basic navigation structure
- MCP client service (tool calling)
- User model and auth state management

---

### Phase 2: Core Features (Weeks 3-6)

**Goals:**
- Implement client management
- Implement goal management
- Implement activity management
- Role-based permission system

**Deliverables:**
- Client CRUD screens
- Goal CRUD screens
- Activity CRUD screens
- Permission service
- Dashboard (basic version)

---

### Phase 3: Shift Notes & Reports (Weeks 7-9)

**Goals:**
- Implement shift note creation/editing
- Implement 24-hour edit restriction
- Implement AI formatting integration
- Basic reports (dashboard summary, client progress)

**Deliverables:**
- Shift note CRUD screens
- AI formatting workflow
- Dashboard with metrics
- Client progress report

---

### Phase 4: Advanced Features (Weeks 10-12)

**Goals:**
- Implement stakeholder management
- Implement client assignments
- Implement audit logging (read-only)
- User management (Super Admin)

**Deliverables:**
- Stakeholder CRUD screens
- Client assignment screens
- Audit log viewer
- User management screens

---

### Phase 5: Offline & Sync (Weeks 13-14)

**Goals:**
- Implement offline data storage (Hive)
- Implement sync service
- Implement conflict resolution
- Offline indicators

**Deliverables:**
- Offline-capable shift note creation
- Sync service with retry logic
- Offline indicators in UI

---

### Phase 6: Polish & Testing (Weeks 15-16)

**Goals:**
- UI/UX polish
- Performance optimization
- Comprehensive testing
- Bug fixes

**Deliverables:**
- Polished UI with animations
- Optimized performance
- Test coverage > 80%
- Bug-free release candidate

---

### Phase 7: Deployment (Week 17)

**Goals:**
- Prepare for App Store/Play Store
- Beta testing with real users
- Final bug fixes
- Release

**Deliverables:**
- Published app on App Store
- Published app on Play Store
- User documentation
- Admin guide

---

## Appendix A: MCP Tool Reference

### All 32 MCP Tools

#### Clients (6 tools)
1. `create_client` - Create new client profile
2. `get_client` - Retrieve client with stats
3. `list_clients` - List/search clients
4. `update_client` - Update client information
5. `deactivate_client` - Soft delete client
6. `search_clients` - Search clients by name

#### Goals (6 tools)
7. `create_goal` - Create new goal
8. `get_goal` - Retrieve goal details
9. `list_goals` - List/filter goals
10. `update_goal` - Update goal information
11. `update_goal_progress` - Update goal progress
12. `archive_goal` - Soft delete goal

#### Activities (4 tools)
13. `create_activity` - Create new activity
14. `get_activity` - Retrieve activity details
15. `list_activities` - List/filter activities
16. `update_activity` - Update activity information

#### Stakeholders (6 tools)
17. `create_stakeholder` - Create new stakeholder
18. `get_stakeholder` - Retrieve stakeholder with activity summary
19. `list_stakeholders` - List/filter stakeholders
20. `update_stakeholder` - Update stakeholder information
21. `deactivate_stakeholder` - Soft delete stakeholder
22. `search_stakeholders` - Search stakeholders by name

#### Shift Notes (7 tools)
23. `create_shift_note` - Create new shift note
24. `get_shift_note` - Retrieve shift note details
25. `list_shift_notes` - List/filter shift notes
26. `update_shift_note` - Update shift note (within 24h)
27. `get_recent_shift_notes` - Get recent shift notes
28. `get_shift_notes_for_week` - Get week's shift notes
29. `format_shift_note` - Generate formatting prompt
30. `save_formatted_shift_note` - Save AI-formatted note

#### Dashboard (3 tools)
31. `get_dashboard` - Get complete dashboard metrics
32. `get_client_summary` - Get client overview
33. `get_statistics` - Get high-level statistics

---

## Appendix B: Permission Matrix

| Feature | Super Admin | Manager | Coordinator | Worker | Therapist | Family | Client |
|---------|------------|---------|-------------|---------|-----------|--------|--------|
| View All Clients | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| View Assigned Clients | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (self) |
| Create Client | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Edit Client | ✅ | ✅ | ✅ (assigned) | ❌ | ❌ | ❌ | ❌ |
| Deactivate Client | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| View NDIS Number | ✅ | ✅ | ✅ (full access) | ❌ | ❌ | ❌ | ❌ |
| Create Goal | ✅ | ✅ | ✅ (assigned) | ❌ | ✅ (therapy) | ❌ | ❌ |
| Edit Goal | ✅ | ✅ | ✅ (assigned) | ❌ | ✅ (therapy) | ❌ | ❌ |
| Update Goal Progress | ✅ | ✅ | ✅ (assigned) | ❌ | ✅ (therapy) | ❌ | ❌ |
| Archive Goal | ✅ | ✅ | ✅ (assigned) | ❌ | ✅ (therapy) | ❌ | ❌ |
| Create Activity | ✅ | ✅ | ✅ (assigned) | ✅ (assigned) | ✅ (therapy) | ❌ | ❌ |
| Edit Activity | ✅ | ✅ | ✅ (assigned) | ❌ | ✅ (therapy) | ❌ | ❌ |
| Mark Activity Complete | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| Create Shift Note | ✅ | ✅ | ✅ | ✅ (assigned) | ✅ | ❌ | ❌ |
| Edit Shift Note | ✅ (24h) | ✅ (24h) | ✅ (24h) | ✅ (own, 24h) | ✅ (24h) | ❌ | ❌ |
| View All Shift Notes | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| View Assigned Shift Notes | ✅ | ✅ | ✅ | ✅ (own) | ✅ | ✅ (summary) | ❌ |
| Create Stakeholder | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Edit Stakeholder | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Deactivate Stakeholder | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| View Dashboard (All) | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| View Dashboard (Assigned) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Generate Reports | ✅ | ✅ | ✅ (assigned) | ❌ | ✅ (therapy) | ❌ | ❌ |
| Manage Users | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Assign Clients | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| View Audit Logs | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| System Settings | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

---

## Appendix C: Validation Rules

### Client Validation
- **Name:** Required, min 2 characters, max 100 characters
- **Date of Birth:** Required, valid date (YYYY-MM-DD), not in future, reasonable range (1900-present)
- **NDIS Number:** Optional, exactly 11 digits, unique across system
- **Primary Contact:** Optional, valid phone or email format
- **Support Notes:** Optional, max 2000 characters

### Goal Validation
- **Client ID:** Required, must be valid UUID, client must exist and be active
- **Title:** Required, min 3 characters, max 200 characters
- **Description:** Optional, max 2000 characters
- **Category:** Required, must be one of valid enum values
- **Target Date:** Required, must be valid date (YYYY-MM-DD), must be in future
- **Progress Percentage:** 0-100, integer
- **Milestones:** Optional array, each item max 200 characters

### Activity Validation
- **Client ID:** Required, must be valid UUID, client must exist and be active
- **Stakeholder ID:** Required, must be valid UUID, stakeholder must exist and be active
- **Title:** Required, min 3 characters, max 200 characters
- **Description:** Optional, max 2000 characters
- **Activity Type:** Required, must be one of valid enum values
- **Status:** Required, must be one of valid enum values
- **Goal IDs:** Optional array, each must be valid UUID, goals must exist
- **Outcome Notes:** Optional, max 2000 characters

### Stakeholder Validation
- **Name:** Required, min 2 characters, max 100 characters
- **Role:** Required, must be one of valid enum values
- **Email:** Optional, valid email format, unique across system
- **Phone:** Optional, valid phone format (international formats supported)
- **Organization:** Optional, max 200 characters
- **Notes:** Optional, max 2000 characters

### Shift Note Validation
- **Client ID:** Required, must be valid UUID, client must exist and be active
- **Stakeholder ID:** Required, must be valid UUID, stakeholder must exist and be active
- **Shift Date:** Required, valid date (YYYY-MM-DD), cannot be future
- **Start Time:** Required, valid time (HH:MM 24-hour format)
- **End Time:** Required, valid time (HH:MM 24-hour format), must be after start time
- **Primary Locations:** Optional array, each item max 200 characters
- **Raw Notes:** Required, min 50 characters, max 5000 characters
- **Goal Progress:**
  - Goal ID: Required, must be valid UUID, goal must exist
  - Progress Notes: Required, min 10 characters, max 1000 characters
  - Progress Observed: Required, integer 1-10

### User Validation
- **Clerk ID:** Required, valid string (synced from Clerk)
- **Email:** Required, valid email format, unique
- **Name:** Required, min 2 characters, max 100 characters
- **Role:** Required, must be one of valid enum values
- **Specialty:** Optional (required for therapists), max 200 characters

---

## Appendix D: Error Messages

### Authentication Errors
- `AUTH_INVALID_CREDENTIALS`: "Invalid email or password"
- `AUTH_USER_NOT_FOUND`: "User not found in system"
- `AUTH_TOKEN_EXPIRED`: "Your session has expired. Please sign in again."
- `AUTH_PERMISSION_DENIED`: "You don't have permission to perform this action"

### Validation Errors
- `VALIDATION_REQUIRED_FIELD`: "{field} is required"
- `VALIDATION_INVALID_FORMAT`: "{field} has an invalid format"
- `VALIDATION_MIN_LENGTH`: "{field} must be at least {min} characters"
- `VALIDATION_MAX_LENGTH`: "{field} must not exceed {max} characters"
- `VALIDATION_INVALID_DATE`: "Invalid date format. Use YYYY-MM-DD"
- `VALIDATION_FUTURE_DATE_REQUIRED`: "{field} must be a future date"
- `VALIDATION_PAST_DATE_REQUIRED`: "{field} cannot be a future date"

### Business Rule Errors
- `CLIENT_INACTIVE`: "Cannot perform this action on an inactive client"
- `GOAL_ARCHIVED`: "Cannot perform this action on an archived goal"
- `SHIFT_NOTE_EDIT_TIMEOUT`: "Shift notes can only be edited within 24 hours"
- `DUPLICATE_NDIS_NUMBER`: "A client with this NDIS number already exists"
- `CLIENT_NOT_ASSIGNED`: "You don't have access to this client"

### Network Errors
- `NETWORK_TIMEOUT`: "Request timed out. Please try again."
- `NETWORK_NO_CONNECTION`: "No internet connection. Some features may be limited."
- `NETWORK_SERVER_ERROR`: "Server error. Please try again later."

---

## Appendix E: Glossary

- **NDIS:** National Disability Insurance Scheme (Australian government program)
- **MCP:** Model Context Protocol (standardized protocol for AI tool integration)
- **Participant:** NDIS client receiving support services
- **Support Worker:** Field staff providing direct support to participants
- **Support Coordinator:** Manager overseeing participant support plans
- **Stakeholder:** Any person involved in participant support (workers, coordinators, therapists, etc.)
- **Shift Note:** Documentation of a support shift
- **Goal:** NDIS plan objective for participant
- **Activity:** Specific action supporting a goal
- **Soft Delete:** Marking record as inactive without deleting from database
- **At-Risk Goal:** Goal with low progress relative to target date
- **Client Assignment:** Granting a user access to specific client
- **Access Level:** Full (all client data) or Limited (basic client data)
- **Clerk:** Authentication service used for user management
- **Convex:** Real-time database backend
- **JWT:** JSON Web Token (authentication token format)
- **UUID:** Universally Unique Identifier (ID format for all entities)

---

**End of Requirements Document**

---

## Next Steps

1. **Review & Approval:** Share this document with stakeholders for review
2. **Design Mockups:** Create high-fidelity UI mockups based on wireframes
3. **Technical Setup:** Initialize Flutter project with dependencies
4. **Development Kickoff:** Begin Phase 1 (Foundation)
5. **Iterative Development:** Follow phased approach with regular demos
6. **Testing & QA:** Continuous testing throughout development
7. **Beta Release:** Deploy to beta testers in Week 15
8. **Production Release:** Launch on App Store & Play Store in Week 17

---

**Document Version:** 1.0.0
**Status:** Draft
**Next Review:** After stakeholder feedback
