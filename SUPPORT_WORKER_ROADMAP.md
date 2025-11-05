# Support Worker MVP - Development Roadmap

**Version:** 1.0
**Last Updated:** October 26, 2024
**Scope:** Support Worker Features Only

---

## Executive Summary

This roadmap focuses on implementing a **Minimum Viable Product (MVP)** for **Support Workers** - the primary field staff who document shifts and interact with NDIS participants. This represents approximately 30% of the full application scope and provides immediate value to frontline workers.

### Success Criteria
- Support workers can sign in and access their dashboard
- Support workers can view their assigned clients (limited details)
- Support workers can view today's schedule and activities
- Support workers can create and edit shift notes (within 24 hours)
- Support workers can mark activities as completed
- Support workers can update goal progress during shifts
- Data syncs with MCP server in real-time

---

## MVP Feature Scope

### ✅ In Scope (Support Worker Features)

#### 1. Authentication & Profile
- Sign in with Clerk (email/password)
- View own profile
- Sign out
- Session management

#### 2. Support Worker Dashboard
- Today's schedule (activities for today)
- Assigned clients list (cards)
- Pending shift notes indicator
- Quick stats (shifts this week)

#### 3. Client Quick View
- View assigned clients only
- Limited client details (name, age only - NOT full DOB or NDIS number)
- Client's active goals
- Recent activities for client

#### 4. Activity Management
- View activities assigned to me
- View activity details (title, description, linked goals)
- Mark activity as completed
- View today's activities prominently

#### 5. Shift Note Management
- Create new shift note for assigned clients
- Edit own shift notes (within 24 hours only)
- View own recent shift notes
- Shift note form:
  - Select client (assigned only)
  - Shift date (max today)
  - Start/end time
  - Primary locations (optional)
  - Raw notes (minimum 50 characters)
  - Link activities (optional)
  - Track goal progress (optional)
- 24-hour edit restriction enforcement

#### 6. Goal Progress Tracking
- View goals for assigned clients
- Update goal progress during shift note creation
- Add progress notes
- Rate progress observed (1-10 scale)

---

### ❌ Out of Scope (Future Phases)

- Goal creation/editing (Coordinator feature)
- Client creation/editing (Manager feature)
- Activity creation (Coordinator feature)
- Viewing other workers' shift notes
- AI shift note formatting (Phase 2)
- Stakeholder management (Admin feature)
- User management (Admin feature)
- Reports and analytics (Manager feature)
- Offline sync (Phase 3)
- Multi-language support
- Push notifications

---

## Technical Architecture

### Core Dependencies

```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.4.0

  # HTTP & MCP Client
  dio: ^5.4.0

  # Authentication
  flutter_secure_storage: ^9.0.0
  # Note: Clerk integration (custom implementation)

  # Forms & Validation
  flutter_form_builder: ^9.1.0
  formz: ^0.6.0

  # Date/Time
  intl: ^0.18.1

  # UI Components
  cached_network_image: ^3.3.0

  # Utilities
  uuid: ^4.2.0
  logger: ^2.0.0
  equatable: ^2.0.5
```

### Project Structure (Support Worker MVP)

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── config/
│   │   ├── app_config.dart           # Environment config
│   │   ├── theme.dart                # Material 3 theme
│   │   └── routes.dart               # Navigation routes
│   ├── utils/
│   │   ├── logger.dart
│   │   ├── validators.dart
│   │   ├── date_formatter.dart
│   │   └── constants.dart
│   └── errors/
│       ├── exceptions.dart
│       └── failures.dart
│
├── data/
│   ├── models/
│   │   ├── user.dart
│   │   ├── client.dart
│   │   ├── goal.dart
│   │   ├── activity.dart
│   │   ├── shift_note.dart
│   │   └── goal_progress.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── client_repository.dart
│   │   ├── goal_repository.dart
│   │   ├── activity_repository.dart
│   │   └── shift_note_repository.dart
│   └── datasources/
│       ├── mcp_client.dart           # Core MCP implementation
│       └── clerk_auth_client.dart    # Clerk authentication
│
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── dashboard_provider.dart
│   │   ├── client_provider.dart
│   │   ├── activity_provider.dart
│   │   └── shift_note_provider.dart
│   │
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── sign_in_screen.dart
│   │   │   └── profile_screen.dart
│   │   │
│   │   ├── dashboard/
│   │   │   └── worker_dashboard_screen.dart
│   │   │
│   │   ├── clients/
│   │   │   ├── client_list_screen.dart
│   │   │   └── client_details_screen.dart
│   │   │
│   │   ├── activities/
│   │   │   ├── activity_list_screen.dart
│   │   │   └── activity_details_screen.dart
│   │   │
│   │   └── shift_notes/
│   │       ├── shift_note_list_screen.dart
│   │       ├── shift_note_form_screen.dart
│   │       └── shift_note_details_screen.dart
│   │
│   └── widgets/
│       ├── common/
│       │   ├── app_scaffold.dart
│       │   ├── loading_overlay.dart
│       │   ├── error_widget.dart
│       │   └── empty_state.dart
│       └── cards/
│           ├── client_card.dart
│           ├── activity_card.dart
│           ├── shift_note_card.dart
│           └── goal_card.dart
│
└── services/
    ├── permission_service.dart       # Role-based permissions
    └── validation_service.dart       # Business rule validation
```

---

## Development Phases

### Phase 1: Foundation (Week 1) ⚙️

**Goal:** Set up project infrastructure and authentication

#### Tasks:
1. **Project Setup**
   - Initialize Flutter project structure
   - Add dependencies to `pubspec.yaml`
   - Configure Android/iOS platform-specific settings
   - Set up development environment variables

2. **Design System**
   - Implement Material 3 theme
   - Define color scheme (NDIS Blue #0066CC, Orange #FF6B35)
   - Create reusable widget components (buttons, cards, inputs)
   - Set up typography and spacing constants

3. **MCP Client Foundation**
   - Implement `MCPClient` class
   - Implement JSON-RPC 2.0 request/response handling
   - Add error handling for MCP errors
   - Add logging for debugging
   - Write unit tests for MCP client

4. **Authentication**
   - Integrate Clerk authentication
   - Implement sign in screen
   - Implement JWT token storage (Flutter Secure Storage)
   - Create `AuthService` and `AuthRepository`
   - Implement auth state management with Riverpod
   - Add sign out functionality

5. **Data Models**
   - Create `User` model
   - Create `Client` model (with limited view support)
   - Create `Activity` model
   - Create `Goal` model
   - Create `ShiftNote` model
   - Add JSON serialization for all models

**Deliverables:**
- ✅ Working sign in/sign out flow
- ✅ MCP client can make tool calls
- ✅ Data models with JSON serialization
- ✅ Basic theme and reusable components
- ✅ Navigation structure

**Testing:**
- Unit tests for MCP client
- Unit tests for data models
- Widget tests for sign in screen

---

### Phase 2: Dashboard & Client View (Week 2) 📊

**Goal:** Implement support worker dashboard and client viewing

#### Tasks:

1. **Dashboard Screen**
   - Create `WorkerDashboardScreen`
   - Implement "Today's Schedule" widget (list of today's activities)
   - Implement "My Clients" widget (assigned clients cards)
   - Implement "Pending Shift Notes" indicator
   - Implement quick stats (shifts this week count)
   - Wire up `get_dashboard` MCP tool (or use `list_activities` + `list_clients`)

2. **Dashboard Provider**
   - Create `DashboardProvider` with Riverpod
   - Implement data fetching logic
   - Handle loading and error states
   - Add pull-to-refresh functionality

3. **Client List Screen**
   - Create `ClientListScreen`
   - Implement client cards (name, age, active goals count)
   - Filter to show only assigned clients
   - Implement search functionality
   - Handle empty state (no assigned clients)

4. **Client Details Screen**
   - Create `ClientDetailsScreen`
   - Display limited client information:
     - Name
     - Age (NOT full date of birth)
     - Active goals list
     - Recent activities
   - Restrict sensitive data (NDIS number, full DOB)
   - Add tabs: Overview, Goals, Activities

5. **Client Repository**
   - Implement `ClientRepository`
   - Use `list_clients` MCP tool with assignment filtering
   - Use `get_client` MCP tool for details
   - Add caching for performance

**Deliverables:**
- ✅ Functional dashboard showing today's schedule
- ✅ Client list with assigned clients only
- ✅ Client details with restricted information
- ✅ Navigation between screens

**Testing:**
- Widget tests for dashboard
- Widget tests for client list/details
- Unit tests for client repository
- Integration test: Sign in → View dashboard → View client

---

### Phase 3: Activities (Week 3) 📅

**Goal:** View and manage activities

#### Tasks:

1. **Activity List Screen**
   - Create `ActivityListScreen`
   - Display activities assigned to current user
   - Filter by date (today, this week, all)
   - Sort by date/status
   - Show activity status badges

2. **Activity Details Screen**
   - Create `ActivityDetailsScreen`
   - Display activity information:
     - Title and description
     - Client name
     - Activity type
     - Status
     - Linked goals
     - Outcome notes
   - Add "Mark as Completed" action button

3. **Activity Completion**
   - Implement status update functionality
   - Call `update_activity` MCP tool
   - Update UI optimistically
   - Show success confirmation

4. **Activity Repository**
   - Implement `ActivityRepository`
   - Use `list_activities` with stakeholder filter
   - Use `get_activity` for details
   - Use `update_activity` for status changes

5. **Activity Cards Component**
   - Create reusable `ActivityCard` widget
   - Show client name, type, status
   - Make tappable for navigation

**Deliverables:**
- ✅ Activity list filtered by current user
- ✅ Activity details view
- ✅ Mark activity as completed
- ✅ Today's activities prominently shown on dashboard

**Testing:**
- Widget tests for activity screens
- Unit tests for activity repository
- Integration test: View activities → Mark complete

---

### Phase 4: Shift Notes - Part 1 (Week 4) 📝

**Goal:** View existing shift notes

#### Tasks:

1. **Shift Note List Screen**
   - Create `ShiftNoteListScreen`
   - Display user's own shift notes
   - Filter by date range
   - Sort by shift date (most recent first)
   - Show shift note cards with summary

2. **Shift Note Details Screen**
   - Create `ShiftNoteDetailsScreen`
   - Display full shift note:
     - Client name
     - Shift date and times
     - Primary locations
     - Raw notes
     - Linked activities
     - Goal progress entries
   - Show edit button (if within 24 hours)
   - Show "Cannot edit" message (if past 24 hours)

3. **Shift Note Repository**
   - Implement `ShiftNoteRepository`
   - Use `list_shift_notes` with stakeholder filter
   - Use `get_shift_note` for details
   - Add 24-hour check utility method

4. **24-Hour Rule Logic**
   - Create `canEditShiftNote()` utility function
   - Calculate time difference between now and shift date
   - Return boolean for edit eligibility
   - Show warning when approaching 24-hour limit

**Deliverables:**
- ✅ View list of own shift notes
- ✅ View shift note details
- ✅ 24-hour edit restriction displayed
- ✅ Warning indicator when approaching deadline

**Testing:**
- Widget tests for shift note list/details
- Unit tests for 24-hour calculation
- Unit tests for shift note repository

---

### Phase 5: Shift Notes - Part 2 (Week 5) ✍️

**Goal:** Create and edit shift notes

#### Tasks:

1. **Shift Note Form Screen**
   - Create `ShiftNoteFormScreen` (create + edit modes)
   - Implement form fields:
     - Client dropdown (assigned clients only)
     - Stakeholder (auto-filled, read-only)
     - Shift date picker (max: today)
     - Start time picker
     - End time picker
     - Primary locations (chip input)
     - Raw notes (multiline, min 50 chars)

2. **Form Validation**
   - Client: Required, must be assigned
   - Shift date: Required, cannot be future
   - Start time: Required
   - End time: Required, must be after start time
   - Raw notes: Required, min 50 characters
   - Real-time validation feedback

3. **Activity Linking**
   - Add "Link Activities" section
   - Multi-select from recent activities for selected client
   - Show selected activities as chips

4. **Create/Update Logic**
   - Call `create_shift_note` for new notes
   - Call `update_shift_note` for edits (with 24h check)
   - Handle MCP errors gracefully
   - Show success message
   - Navigate to details screen on success

5. **Form Provider**
   - Create `ShiftNoteFormProvider`
   - Manage form state
   - Handle validation
   - Coordinate API calls

**Deliverables:**
- ✅ Create new shift notes
- ✅ Edit shift notes (within 24 hours)
- ✅ Form validation
- ✅ Link activities to shift notes
- ✅ Cannot edit after 24 hours (enforced)

**Testing:**
- Widget tests for shift note form
- Unit tests for form validation
- Integration test: Create shift note → View in list

---

### Phase 6: Goal Progress Tracking (Week 6) 🎯

**Goal:** Track goal progress during shifts

#### Tasks:

1. **Goal List Screen**
   - Create `GoalListScreen`
   - Display goals for assigned clients
   - Filter by status (In Progress, Not Started, etc.)
   - Show progress bars
   - Navigate to goal details

2. **Goal Details Screen**
   - Create `GoalDetailsScreen`
   - Display goal information:
     - Title and description
     - Client name
     - Category
     - Progress percentage
     - Target date
     - Milestones
   - Read-only view (workers cannot edit goals)

3. **Goal Progress in Shift Notes**
   - Add "Track Goal Progress" section to shift note form
   - Allow multiple goal progress entries
   - For each entry:
     - Select goal from client's active goals
     - Add progress notes (text)
     - Rate progress observed (slider 1-10)
   - Validate: If progress added, all fields required

4. **Goal Progress Component**
   - Create reusable `GoalProgressInput` widget
   - Add/remove progress entries dynamically
   - Validate each entry

5. **Goal Repository**
   - Implement `GoalRepository`
   - Use `list_goals` filtered by client
   - Use `get_goal` for details
   - Cache goal data

**Deliverables:**
- ✅ View goals for assigned clients
- ✅ Track goal progress in shift notes
- ✅ Rate progress observed (1-10)
- ✅ Multiple goals can be tracked per shift

**Testing:**
- Widget tests for goal screens
- Widget tests for goal progress input
- Unit tests for goal repository
- Integration test: Create shift note with goal progress

---

### Phase 7: Navigation & Polish (Week 7) 🎨

**Goal:** Complete navigation, polish UI, and optimize performance

#### Tasks:

1. **Bottom Navigation**
   - Implement bottom navigation bar
   - Tabs: Home, Clients, Activities, Shift Notes, More
   - Highlight active tab
   - Persist navigation state

2. **Profile Screen**
   - Create profile screen under "More" tab
   - Display user information (name, email, role)
   - Add sign out button
   - Show app version

3. **Search & Filters**
   - Add search to client list
   - Add date filters to activity list
   - Add date range filter to shift notes
   - Persist filter preferences

4. **Loading States**
   - Add shimmer loading for all lists
   - Add loading overlays for API calls
   - Prevent duplicate submissions

5. **Error Handling**
   - Implement user-friendly error messages
   - Add retry mechanisms
   - Show offline indicator (no offline support yet, just detection)

6. **UI Polish**
   - Add animations (page transitions, card taps)
   - Improve spacing and alignment
   - Add splash screen
   - Add app icon
   - Ensure responsive design (tablets)

7. **Performance Optimization**
   - Implement list pagination
   - Add image caching
   - Optimize widget rebuilds
   - Profile with Flutter DevTools

**Deliverables:**
- ✅ Complete bottom navigation
- ✅ All screens accessible
- ✅ Polished UI with animations
- ✅ Optimized performance
- ✅ Consistent error handling

**Testing:**
- Widget tests for navigation
- Widget tests for profile screen
- Performance testing with Flutter DevTools
- Manual testing on physical devices

---

### Phase 8: Testing & Bug Fixes (Week 8) 🐛

**Goal:** Comprehensive testing and bug fixing

#### Tasks:

1. **Unit Testing**
   - Achieve >80% coverage for:
     - Repositories
     - Services
     - Utilities
   - Mock MCP client
   - Test edge cases

2. **Widget Testing**
   - Achieve >70% coverage for:
     - All screens
     - Major widgets
   - Test user interactions
   - Test different states (loading, error, empty)

3. **Integration Testing**
   - Create critical user flow tests:
     - Sign in → View dashboard
     - View client → View goals
     - Create shift note → View in list
     - Edit shift note (within 24h)
     - Cannot edit shift note (after 24h)
     - Mark activity complete

4. **Manual Testing**
   - Test on iOS physical device
   - Test on Android physical device
   - Test different screen sizes
   - Test with real MCP server
   - Test edge cases:
     - No assigned clients
     - No activities
     - Network errors
     - 24-hour boundary

5. **Bug Fixes**
   - Fix all critical bugs
   - Fix all high-priority bugs
   - Document known issues

6. **Performance Testing**
   - Test with large data sets (100+ clients, activities)
   - Measure app startup time
   - Measure screen transition times
   - Optimize slow operations

**Deliverables:**
- ✅ >80% unit test coverage
- ✅ >70% widget test coverage
- ✅ Integration tests for critical flows
- ✅ All critical bugs fixed
- ✅ Performance benchmarks met

**Testing Tools:**
- `flutter test`
- `flutter drive` (for integration tests)
- Flutter DevTools (performance)
- Xcode/Android Studio (device testing)

---

## MCP Tools Required for MVP

### Authentication
- Convex query: `getCurrentUser(clerk_id)` - Get user profile
- Convex mutation: `updateLastLogin(clerk_id)` - Update login timestamp

### Dashboard
- `list_activities` - Get today's activities for worker
- `list_clients` - Get assigned clients
- `list_shift_notes` - Get recent shift notes

### Clients
- `list_clients` - List assigned clients (with `active: true` filter)
- `get_client` - Get client details (returns limited view for workers)

### Activities
- `list_activities` - Filter by stakeholder (current user)
- `get_activity` - Get activity details
- `update_activity` - Mark activity as completed

### Goals
- `list_goals` - Filter by client_id
- `get_goal` - Get goal details

### Shift Notes
- `create_shift_note` - Create new shift note
- `get_shift_note` - Get shift note details
- `list_shift_notes` - Filter by stakeholder (current user)
- `update_shift_note` - Edit shift note (within 24h)
- `get_recent_shift_notes` - Get recent notes for dashboard

**Total: 13 MCP tools** (out of 32 available)

---

## Data Flow Examples

### Creating a Shift Note

```
User fills form → Validate locally → Call create_shift_note
                                    ↓
                        MCP Server validates & saves
                                    ↓
                          Convex updates database
                                    ↓
                        Success response returned
                                    ↓
                        UI updates & navigates to details
```

### Marking Activity Complete

```
User taps "Mark Complete" → Optimistic UI update
                                    ↓
                        Call update_activity(status: completed)
                                    ↓
                        MCP Server validates & saves
                                    ↓
                            Success/Error response
                                    ↓
                        Confirm or rollback UI
```

### 24-Hour Edit Check

```
User opens shift note → Calculate hours since shift
                                    ↓
                        if (hours < 24) → Show Edit button
                        if (hours >= 24) → Show "Cannot edit" message
                                    ↓
                    User taps Edit → Verify again on server
                                    ↓
                    Server enforces 24-hour rule (authoritative)
```

---

## Success Metrics

### Functional Metrics
- ✅ Support workers can sign in
- ✅ Support workers see only assigned clients
- ✅ Support workers can view today's activities
- ✅ Support workers can create shift notes
- ✅ Support workers can edit shift notes (within 24h)
- ✅ Support workers CANNOT edit shift notes (after 24h)
- ✅ Support workers can mark activities complete
- ✅ Support workers can track goal progress

### Performance Metrics
- App cold start: < 3 seconds
- Screen transitions: < 300ms
- API responses: < 500ms average
- Shift note form submission: < 1 second

### Quality Metrics
- Unit test coverage: > 80%
- Widget test coverage: > 70%
- Zero critical bugs
- Zero P1 bugs at launch

---

## Risk Mitigation

### Technical Risks

**Risk:** MCP server integration issues
- **Mitigation:** Create mock MCP server for development
- **Mitigation:** Implement comprehensive error handling
- **Mitigation:** Add detailed logging

**Risk:** Clerk authentication complexity
- **Mitigation:** Start with simple email/password
- **Mitigation:** Follow Clerk Flutter documentation closely
- **Mitigation:** Build custom wrapper if needed

**Risk:** 24-hour calculation edge cases
- **Mitigation:** Use timezone-aware date handling
- **Mitigation:** Test extensively with different timezones
- **Mitigation:** Server is authoritative (client is advisory only)

**Risk:** Performance issues with large data sets
- **Mitigation:** Implement pagination early
- **Mitigation:** Use lazy loading for lists
- **Mitigation:** Profile regularly with DevTools

### Project Risks

**Risk:** Scope creep
- **Mitigation:** Strictly adhere to support worker features only
- **Mitigation:** Document "future phase" requests
- **Mitigation:** Get stakeholder sign-off on scope

**Risk:** Timeline delays
- **Mitigation:** Buffer week built into 8-week plan
- **Mitigation:** Prioritize core features (shift notes)
- **Mitigation:** Daily progress tracking

---

## Post-MVP Roadmap (Future Phases)

### Phase 9: AI Shift Note Formatting
- Integrate Claude API for shift note formatting
- Implement `format_shift_note` workflow
- Preview and edit formatted notes

### Phase 10: Offline Support
- Implement Hive local storage
- Create sync service
- Handle conflict resolution
- Offline indicators in UI

### Phase 11: Enhanced Features
- Push notifications for shift reminders
- Photo attachments in shift notes
- Voice-to-text for notes
- Dark mode

### Phase 12: Other Roles
- Implement Coordinator features
- Implement Manager features
- Implement Therapist features

---

## Development Standards

### Code Style
- Follow official Flutter style guide
- Use `dart format` for consistent formatting
- Run `flutter analyze` before commits
- No warnings allowed in production code

### Git Workflow
- Feature branches: `feature/shift-notes-form`
- Commit messages: Conventional Commits format
- PR required for all changes
- Squash merge to main

### Documentation
- Document all public APIs
- README for each major module
- Update CLAUDE.md with architectural decisions
- Maintain this roadmap with progress

### Code Review
- All code requires review
- Check test coverage
- Verify error handling
- Test on both iOS and Android

---

## Appendix A: Sample Screens

### Worker Dashboard (Week 2)
```
┌─────────────────────────────────┐
│  🏠 Dashboard                   │
├─────────────────────────────────┤
│                                 │
│  📅 Today's Schedule (Oct 26)   │
│  ┌─────────────────────────┐   │
│  │ 9:00 AM - John Doe      │   │
│  │ Life Skills - Shopping   │   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │ 2:00 PM - Jane Smith    │   │
│  │ Social & Community       │   │
│  └─────────────────────────┘   │
│                                 │
│  👥 My Clients (3)              │
│  ┌─────────────────────────┐   │
│  │ John Doe, Age 32        │   │
│  │ 5 active goals          │   │
│  └─────────────────────────┘   │
│                                 │
│  ⚠️ 1 Pending Shift Note        │
│                                 │
│  📊 This Week: 12 shifts        │
│                                 │
└─────────────────────────────────┘
```

### Shift Note Form (Week 5)
```
┌─────────────────────────────────┐
│  📝 New Shift Note              │
├─────────────────────────────────┤
│                                 │
│  Client *                       │
│  [John Doe ▼]                   │
│                                 │
│  Shift Date *                   │
│  [Oct 26, 2024 📅]              │
│                                 │
│  Start Time *    End Time *     │
│  [09:00 🕐]     [11:00 🕐]      │
│                                 │
│  Primary Locations              │
│  [Home] [Shopping Centre]       │
│                                 │
│  Raw Notes * (min 50 chars)     │
│  ┌─────────────────────────┐   │
│  │ John was in a positive  │   │
│  │ mood today. We went     │   │
│  │ shopping at Coles...    │   │
│  └─────────────────────────┘   │
│                                 │
│  Link Activities                │
│  ☑ Life Skills - Shopping       │
│                                 │
│  Track Goal Progress            │
│  ┌─────────────────────────┐   │
│  │ Goal: Independent       │   │
│  │       Shopping          │   │
│  │ Notes: John selected... │   │
│  │ Progress: ●●●●●○○○○○ 5/10│   │
│  └─────────────────────────┘   │
│  [+ Add Another Goal]           │
│                                 │
│  [Cancel]  [Save Shift Note]    │
│                                 │
└─────────────────────────────────┘
```

---

## Appendix B: Timeline Summary

| Week | Phase | Key Deliverable |
|------|-------|----------------|
| 1 | Foundation | Authentication + MCP Client |
| 2 | Dashboard & Clients | Worker Dashboard + Client Views |
| 3 | Activities | View & Mark Activities Complete |
| 4 | Shift Notes Part 1 | View Existing Shift Notes |
| 5 | Shift Notes Part 2 | Create & Edit Shift Notes |
| 6 | Goal Progress | Track Goals in Shift Notes |
| 7 | Navigation & Polish | Complete UI Polish |
| 8 | Testing & Fixes | Production Ready MVP |

**Total Duration:** 8 weeks
**Estimated Effort:** 1 developer, full-time

---

## Next Steps

1. ✅ Review and approve this roadmap
2. ✅ Set up development environment
3. ✅ Create project repository
4. ✅ Begin Phase 1: Foundation
5. Weekly demos to stakeholders
6. Daily standups (if team > 1)
7. Update roadmap with actuals vs. planned

---

**Document Status:** Ready for Review
**Approval Required From:** Project Sponsor, Technical Lead
**Next Review Date:** End of Week 1
