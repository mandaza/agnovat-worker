# Agnovat MCP Server - Flutter Integration Guide

**Version:** 1.0.0
**Last Updated:** November 2024
**Target Audience:** Flutter App Developers (Support Workers)

## Table of Contents

1. [Overview](#overview)
2. [Server Capabilities](#server-capabilities)
3. [Data Models](#data-models)
4. [MCP Tools Reference](#mcp-tools-reference)
5. [MCP Resources](#mcp-resources)
6. [MCP Prompts](#mcp-prompts)
7. [Flutter Integration Examples](#flutter-integration-examples)
8. [Error Handling](#error-handling)
9. [Best Practices](#best-practices)

---

## Overview

The Agnovat MCP (Model Context Protocol) Server provides a comprehensive API for managing NDIS participant support through 32 tools, 6 resources, and 6 guided prompts. This document is designed to help Flutter developers integrate the MCP server into their support worker mobile application.

### Key Capabilities

- **Client Management**: Create, read, update, and deactivate NDIS participant profiles
- **Goal Tracking**: Manage participant goals with progress monitoring
- **Activity Pool/Catalog**: Maintain a catalog of support activities
- **Shift Notes**: Document support shifts with AI-powered formatting
- **Stakeholder Management**: Track support workers, coordinators, and other stakeholders
- **Dashboard & Analytics**: Access aggregated metrics and reports

### Connection Details

- **Protocol**: MCP over stdio (JSON-RPC)
- **Transport**: Standard input/output
- **Response Format**: JSON
- **Storage Options**: JSON files or Convex database

---

## Server Capabilities

### Server Information

```json
{
  "name": "agnovat-mcp-server",
  "version": "1.0.0",
  "capabilities": {
    "tools": {},
    "resources": {},
    "prompts": {}
  }
}
```

### Statistics

- **32 MCP Tools**: CRUD operations across 5 entity types
- **6 MCP Resources**: URI-based direct entity access
- **6 MCP Prompts**: Guided workflows for common tasks
- **5 Data Collections**: clients, goals, activities, shift_notes, stakeholders

---

## Data Models

### Enumerations

#### GoalStatus
```typescript
'not_started' | 'in_progress' | 'achieved' | 'on_hold' | 'discontinued'
```

#### GoalCategory
```typescript
'daily_living' | 'social_community' | 'employment' | 'health_wellbeing' |
'home_living' | 'relationships' | 'choice_control' | 'other'
```

#### ActivityType
```typescript
'life_skills' | 'social_recreation' | 'personal_care' | 'community_access' |
'transport' | 'therapy' | 'household_tasks' | 'employment_education' |
'communication' | 'other'
```

#### ActivityStatus
```typescript
'scheduled' | 'in_progress' | 'completed' | 'cancelled' | 'no_show'
```

#### StakeholderRole
```typescript
'support_worker' | 'support_coordinator' | 'team_leader' | 'family' |
'healthcare_provider' | 'plan_manager' | 'ndis_planner' | 'other'
```

### Core Entities

#### Client

```dart
class Client {
  final String id;              // UUID v4
  final String name;            // Full name
  final String dateOfBirth;     // ISO format: YYYY-MM-DD
  final String? ndisNumber;     // 11 digits, optional
  final String? primaryContact; // Contact details
  final String? supportNotes;   // Support preferences
  final bool active;            // Soft delete flag
  final String createdAt;       // ISO 8601 timestamp
  final String updatedAt;       // ISO 8601 timestamp
}
```

**Extended: ClientWithStats**
```dart
class ClientWithStats extends Client {
  final int totalGoals;
  final int activeGoals;
  final int totalActivities;
  final String? lastShiftNoteDate;
}
```

#### Goal

```dart
class Goal {
  final String id;                  // UUID v4
  final String clientId;            // References Client
  final String title;               // Short title
  final String description;         // Detailed description
  final String category;            // GoalCategory enum
  final String targetDate;          // ISO format: YYYY-MM-DD
  final String status;              // GoalStatus enum
  final int progressPercentage;     // 0-100
  final String createdAt;           // ISO 8601
  final String updatedAt;           // ISO 8601
  final String? achievedAt;         // ISO 8601, nullable
  final bool archived;              // Soft delete flag
}
```

#### Activity

```dart
class Activity {
  final String id;                  // UUID v4
  final String clientId;            // References Client
  final String stakeholderId;       // References Stakeholder
  final String title;               // Activity title
  final String description;         // Activity description
  final String activityType;        // ActivityType enum
  final String status;              // ActivityStatus enum
  final List<String>? goalIds;      // Links to goals
  final String? outcomeNotes;       // Outcome documentation
  final String createdAt;           // ISO 8601
  final String updatedAt;           // ISO 8601
}
```

**Note**: Activities are stored in a pool/catalog. Scheduling is handled separately.

#### ShiftNote

```dart
class ShiftNote {
  final String id;                      // UUID v4
  final String clientId;                // References Client
  final String stakeholderId;           // References Stakeholder
  final String shiftDate;               // ISO format: YYYY-MM-DD
  final String startTime;               // HH:MM (24-hour)
  final String endTime;                 // HH:MM (24-hour)
  final List<String>? primaryLocations; // Locations visited
  final String rawNotes;                // Unformatted staff notes
  final String? formattedNote;          // AI-formatted professional note
  final List<String>? activityIds;      // Linked activities (legacy)
  final List<GoalProgress>? goalsProgress; // Goal progress (legacy)
  final String createdAt;               // ISO 8601
  final String updatedAt;               // ISO 8601
}
```

**Important**: Shift notes can only be updated within 24 hours of the shift date.

#### Stakeholder

```dart
class Stakeholder {
  final String id;            // UUID v4
  final String name;          // Full name
  final String role;          // StakeholderRole enum
  final String? email;        // Email address
  final String? phone;        // Phone number
  final String? organization; // Organization name
  final String? notes;        // Additional notes
  final bool active;          // Soft delete flag
  final String createdAt;     // ISO 8601
  final String updatedAt;     // ISO 8601
}
```

---

## MCP Tools Reference

### Client Tools (6 tools)

#### 1. create_client

Create a new NDIS participant profile.

**Input Schema:**
```json
{
  "name": "string (required)",
  "date_of_birth": "string (required, YYYY-MM-DD)",
  "ndis_number": "string (optional, 11 digits)",
  "primary_contact": "string (optional)",
  "support_notes": "string (optional)"
}
```

**Response:**
```json
{
  "id": "uuid",
  "name": "John Doe",
  "date_of_birth": "1990-01-15",
  "ndis_number": "12345678901",
  "primary_contact": "Jane Doe (Mother) - 0412345678",
  "support_notes": "Prefers morning appointments",
  "active": true,
  "created_at": "2024-11-02T10:30:00.000Z",
  "updated_at": "2024-11-02T10:30:00.000Z"
}
```

**Validation Rules:**
- `name` is required
- `date_of_birth` must be valid ISO date (YYYY-MM-DD)
- `ndis_number` must be exactly 11 digits if provided
- NDIS number uniqueness is enforced

---

#### 2. get_client

Retrieve a client profile with summary statistics.

**Input Schema:**
```json
{
  "client_id": "string (required, UUID or Convex ID)"
}
```

**Response:** Returns `ClientWithStats` object with aggregated metrics.

---

#### 3. list_clients

List all clients with optional filtering and pagination.

**Input Schema:**
```json
{
  "active": "boolean (optional, filter by active status)",
  "search": "string (optional, search by name)",
  "limit": "number (optional, max results)",
  "offset": "number (optional, pagination offset)"
}
```

**Response:** Array of `Client` objects.

---

#### 4. update_client

Update client information (partial updates supported).

**Input Schema:**
```json
{
  "client_id": "string (required)",
  "name": "string (optional)",
  "date_of_birth": "string (optional)",
  "ndis_number": "string (optional)",
  "primary_contact": "string (optional)",
  "support_notes": "string (optional)"
}
```

**Response:** Updated `Client` object.

---

#### 5. deactivate_client

Soft-delete a client (sets `active: false`).

**Input Schema:**
```json
{
  "client_id": "string (required)"
}
```

**Response:** Updated `Client` object with `active: false`.

---

#### 6. search_clients

Search clients by name (simple text matching).

**Input Schema:**
```json
{
  "search_term": "string (required)"
}
```

**Response:** Array of matching `Client` objects.

---

### Goal Tools (6 tools)

#### 7. create_goal

Create a new goal for a client.

**Input Schema:**
```json
{
  "client_id": "string (required)",
  "title": "string (required)",
  "description": "string (required)",
  "category": "string (required, GoalCategory enum)",
  "target_date": "string (required, YYYY-MM-DD)"
}
```

**Response:** `Goal` object with default status `'not_started'` and progress `0`.

**Business Rules:**
- Client must exist and be active
- Target date must be in the future

---

#### 8. get_goal

Retrieve a goal with details.

**Input Schema:**
```json
{
  "goal_id": "string (required)"
}
```

**Response:** `GoalWithActivities` object.

---

#### 9. list_goals

List goals with optional filtering.

**Input Schema:**
```json
{
  "client_id": "string (optional)",
  "status": "string (optional, GoalStatus enum)",
  "category": "string (optional, GoalCategory enum)",
  "archived": "boolean (optional, default: false)",
  "limit": "number (optional)",
  "offset": "number (optional)"
}
```

**Response:** Array of `Goal` objects.

---

#### 10. update_goal

Update goal information.

**Input Schema:**
```json
{
  "goal_id": "string (required)",
  "title": "string (optional)",
  "description": "string (optional)",
  "status": "string (optional)",
  "target_date": "string (optional)",
  "milestones": "array of strings (optional)"
}
```

**Response:** Updated `Goal` object.

---

#### 11. update_goal_progress

Update goal progress and status.

**Input Schema:**
```json
{
  "goal_id": "string (required)",
  "progress_percentage": "number (optional, 0-100)",
  "status": "string (optional)",
  "notes": "string (optional)"
}
```

**Response:** Updated `Goal` object.

**Special Behavior:**
- If `progress_percentage` reaches 100, status auto-updates to `'achieved'`
- `achieved_at` timestamp is set when status becomes `'achieved'`

---

#### 12. archive_goal

Soft-delete a goal (sets `archived: true`).

**Input Schema:**
```json
{
  "goal_id": "string (required)"
}
```

**Response:** Updated `Goal` object with `archived: true`.

---

### Activity Tools (4 tools)

#### 13. create_activity

Create a new activity in the activity pool/catalog.

**Input Schema:**
```json
{
  "client_id": "string (required)",
  "stakeholder_id": "string (required)",
  "title": "string (required)",
  "description": "string (optional)",
  "activity_type": "string (required, ActivityType enum)",
  "status": "string (optional, ActivityStatus enum, default: 'scheduled')",
  "goal_ids": "array of strings (optional)",
  "outcome_notes": "string (optional)"
}
```

**Response:** `Activity` object.

**Business Rules:**
- Client must exist
- Stakeholder must exist
- Goal IDs (if provided) must exist

---

#### 14. get_activity

Retrieve an activity with details.

**Input Schema:**
```json
{
  "activity_id": "string (required)"
}
```

**Response:** `Activity` object with expanded client and stakeholder names.

---

#### 15. list_activities

List activities from the pool with optional filtering.

**Input Schema:**
```json
{
  "client_id": "string (optional)",
  "stakeholder_id": "string (optional)",
  "activity_type": "string (optional)",
  "status": "string (optional)",
  "goal_id": "string (optional, filters by linked goal)",
  "limit": "number (optional)",
  "offset": "number (optional)"
}
```

**Response:** Array of `Activity` objects.

---

#### 16. update_activity

Update activity information.

**Input Schema:**
```json
{
  "activity_id": "string (required)",
  "title": "string (optional)",
  "description": "string (optional)",
  "activity_type": "string (optional)",
  "status": "string (optional)",
  "goal_ids": "array of strings (optional)",
  "outcome_notes": "string (optional)"
}
```

**Response:** Updated `Activity` object.

---

### Stakeholder Tools (6 tools)

#### 17. create_stakeholder

Create a new stakeholder (support worker, coordinator, etc.).

**Input Schema:**
```json
{
  "name": "string (required)",
  "role": "string (required, StakeholderRole enum)",
  "email": "string (optional)",
  "phone": "string (optional)",
  "organization": "string (optional)",
  "notes": "string (optional)"
}
```

**Response:** `Stakeholder` object.

---

#### 18. get_stakeholder

Retrieve stakeholder with activity summary.

**Input Schema:**
```json
{
  "stakeholder_id": "string (required)"
}
```

**Response:** `Stakeholder` object with activity statistics.

---

#### 19. list_stakeholders

List stakeholders with optional filtering.

**Input Schema:**
```json
{
  "role": "string (optional)",
  "active": "boolean (optional)",
  "search": "string (optional, search by name)",
  "limit": "number (optional)",
  "offset": "number (optional)"
}
```

**Response:** Array of `Stakeholder` objects.

---

#### 20. update_stakeholder

Update stakeholder information.

**Input Schema:**
```json
{
  "stakeholder_id": "string (required)",
  "name": "string (optional)",
  "role": "string (optional)",
  "email": "string (optional)",
  "phone": "string (optional)",
  "organization": "string (optional)",
  "notes": "string (optional)"
}
```

**Response:** Updated `Stakeholder` object.

---

#### 21. deactivate_stakeholder

Soft-delete a stakeholder (sets `active: false`).

**Input Schema:**
```json
{
  "stakeholder_id": "string (required)"
}
```

**Response:** Updated `Stakeholder` object.

---

#### 22. search_stakeholders

Search stakeholders by name.

**Input Schema:**
```json
{
  "search_term": "string (required)"
}
```

**Response:** Array of matching `Stakeholder` objects.

---

### Shift Note Tools (7 tools)

#### 23. create_shift_note

Create a new shift note from raw staff notes.

**Input Schema:**
```json
{
  "client_id": "string (required)",
  "stakeholder_id": "string (required)",
  "shift_date": "string (required, YYYY-MM-DD)",
  "start_time": "string (required, HH:MM)",
  "end_time": "string (required, HH:MM)",
  "primary_locations": "array of strings (optional)",
  "raw_notes": "string (required, unformatted staff notes)",
  "activity_ids": "array of strings (optional, legacy)",
  "goals_progress": "array of GoalProgress objects (optional, legacy)"
}
```

**Response:** `ShiftNote` object.

**Workflow:**
1. Create shift note with raw notes
2. Use `format_shift_note` to get formatting prompt
3. Send prompt to AI for formatting
4. Use `save_formatted_shift_note` to save formatted result

---

#### 24. get_shift_note

Retrieve a shift note with details.

**Input Schema:**
```json
{
  "shift_note_id": "string (required)"
}
```

**Response:** `ShiftNoteWithDetails` object including client and stakeholder names.

---

#### 25. list_shift_notes

List shift notes with optional filtering.

**Input Schema:**
```json
{
  "client_id": "string (optional)",
  "stakeholder_id": "string (optional)",
  "date_from": "string (optional, YYYY-MM-DD)",
  "date_to": "string (optional, YYYY-MM-DD)",
  "limit": "number (optional)",
  "offset": "number (optional)"
}
```

**Response:** Array of `ShiftNote` objects.

---

#### 26. update_shift_note

Update a shift note (only within 24 hours of shift date).

**Input Schema:**
```json
{
  "shift_note_id": "string (required)",
  "primary_locations": "array of strings (optional)",
  "raw_notes": "string (optional)",
  "activity_ids": "array of strings (optional)",
  "goals_progress": "array of objects (optional)"
}
```

**Response:** Updated `ShiftNote` object.

**Error:** Returns `AuthorizationError` if > 24 hours have passed.

---

#### 27. get_recent_shift_notes

Get recent shift notes (sorted by date, descending).

**Input Schema:**
```json
{
  "limit": "number (optional, default: 10)",
  "client_id": "string (optional, filter by client)"
}
```

**Response:** Array of recent `ShiftNote` objects.

---

#### 28. get_shift_notes_for_week

Get shift notes for a specific week.

**Input Schema:**
```json
{
  "week_start_date": "string (required, YYYY-MM-DD, typically Monday)",
  "client_id": "string (optional)"
}
```

**Response:** Array of `ShiftNote` objects for the week.

---

#### 29. format_shift_note

Generate a formatting prompt for raw shift notes.

**Input Schema:**
```json
{
  "shift_note_id": "string (required)"
}
```

**Response:**
```json
{
  "prompt": "A detailed prompt string to send to an AI model",
  "shift_note_data": { /* ShiftNote object */ }
}
```

**Usage:** Send the returned prompt to Claude or another AI to format the notes professionally.

---

#### 30. save_formatted_shift_note

Save the AI-formatted shift note back to the database.

**Input Schema:**
```json
{
  "shift_note_id": "string (required)",
  "formatted_note": "string (required, the complete formatted note from AI)"
}
```

**Response:** Updated `ShiftNote` object with `formatted_note` populated.

---

### Dashboard Tools (3 tools)

#### 31. get_dashboard

Get complete dashboard with aggregated metrics.

**Input Schema:**
```json
{}
```

**Response:**
```json
{
  "total_clients": 25,
  "active_clients": 23,
  "total_goals": 87,
  "active_goals": 65,
  "goals_at_risk": [
    { "goal_id": "...", "client_name": "...", "title": "...", "progress": 20, "days_to_target": 5 }
  ],
  "recent_activities": [ /* last 10 activities */ ],
  "recent_shift_notes": [ /* last 5 shift notes */ ],
  "statistics": {
    "goals_by_status": { "in_progress": 45, "achieved": 20, "not_started": 2 },
    "activities_by_type": { "life_skills": 30, "social_recreation": 25 }
  }
}
```

**Use Case:** Home screen dashboard for support workers.

---

#### 32. get_client_summary

Get quick overview of a client with goal progress.

**Input Schema:**
```json
{
  "client_id": "string (required)"
}
```

**Response:**
```json
{
  "client": { /* Client object */ },
  "goals": [ /* Array of goals with progress */ ],
  "recent_activities": [ /* Last 5 activities */ ],
  "last_shift_note": { /* Most recent shift note */ }
}
```

**Use Case:** Client detail screen in app.

---

#### 33. get_statistics

Get high-level statistics overview.

**Input Schema:**
```json
{}
```

**Response:**
```json
{
  "total_records": 350,
  "records_by_collection": {
    "clients": 25,
    "goals": 87,
    "activities": 156,
    "shift_notes": 67,
    "stakeholders": 15
  },
  "active_clients": 23,
  "active_goals": 65,
  "goals_achieved_this_month": 8
}
```

---

## MCP Resources

Resources provide URI-based direct access to entities. Use these for quick lookups without tool calls.

### Resource URIs

#### 1. Client Profile
```
client:///{client_id}
```
Returns: `ClientWithStats` object

#### 2. Goal Details
```
goal:///{goal_id}
```
Returns: `GoalWithActivities` object

#### 3. Activity Details
```
activity:///{activity_id}
```
Returns: `Activity` object with expanded details

#### 4. Shift Note
```
shift_note:///{shift_note_id}
```
Returns: `ShiftNoteWithDetails` object

#### 5. Stakeholder Profile
```
stakeholder:///{stakeholder_id}
```
Returns: `Stakeholder` object with activity summary

#### 6. Dashboard Summary
```
dashboard://summary
```
Returns: Complete dashboard object (same as `get_dashboard` tool)

### Usage in Flutter

```dart
// Read resource via MCP
final response = await mcpClient.readResource(
  'client:///550e8400-e29b-41d4-a716-446655440000'
);

// Parse JSON response
final client = ClientWithStats.fromJson(jsonDecode(response.text));
```

---

## MCP Prompts

Prompts provide guided workflows for common tasks. These return pre-formatted conversation starters.

### Available Prompts

#### 1. create_shift_note_for_client

**Arguments:**
- `client_id` (required)

**Usage:** Guides support worker through comprehensive shift note creation.

---

#### 2. review_client_progress

**Arguments:**
- `client_id` (required)
- `period_days` (optional, default: 7)

**Usage:** Reviews client progress over specified period.

---

#### 3. plan_activity_for_goal

**Arguments:**
- `goal_id` (required)
- `stakeholder_id` (required)

**Usage:** Plans an activity to work towards a specific goal.

---

#### 4. handover_summary

**Arguments:**
- `client_id` (required)

**Usage:** Generates handover summary for shift changeover.

---

#### 5. weekly_report

**Arguments:**
- `client_id` (optional, if omitted generates for all clients)
- `week_start_date` (optional)

**Usage:** Generates weekly report for client(s).

---

#### 6. goal_risk_review

**Arguments:** None

**Usage:** Reviews all at-risk goals and suggests action plans.

---

## Flutter Integration Examples

### 1. Setting Up MCP Client

```dart
import 'package:mcp_client/mcp_client.dart';

class McpService {
  late MCPClient _client;

  Future<void> initialize() async {
    _client = MCPClient(
      serverCommand: 'node',
      serverArgs: ['/path/to/agnovat-mcp/dist/index.js'],
      environment: {
        'STORAGE_TYPE': 'convex',
        'CONVEX_URL': 'https://your-convex-url.convex.cloud',
      },
    );

    await _client.connect();
  }

  Future<void> dispose() async {
    await _client.close();
  }
}
```

### 2. Creating a Client

```dart
Future<Client> createClient({
  required String name,
  required String dateOfBirth,
  String? ndisNumber,
  String? primaryContact,
  String? supportNotes,
}) async {
  final response = await _client.callTool(
    'create_client',
    arguments: {
      'name': name,
      'date_of_birth': dateOfBirth,
      if (ndisNumber != null) 'ndis_number': ndisNumber,
      if (primaryContact != null) 'primary_contact': primaryContact,
      if (supportNotes != null) 'support_notes': supportNotes,
    },
  );

  final data = jsonDecode(response.content[0].text);
  return Client.fromJson(data);
}
```

### 3. Listing Clients with Pagination

```dart
Future<List<Client>> fetchClients({
  bool? activeOnly,
  String? searchTerm,
  int? limit,
  int? offset,
}) async {
  final response = await _client.callTool(
    'list_clients',
    arguments: {
      if (activeOnly != null) 'active': activeOnly,
      if (searchTerm != null) 'search': searchTerm,
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    },
  );

  final List<dynamic> data = jsonDecode(response.content[0].text);
  return data.map((json) => Client.fromJson(json)).toList();
}
```

### 4. Creating a Shift Note with AI Formatting

```dart
Future<ShiftNote> createAndFormatShiftNote({
  required String clientId,
  required String stakeholderId,
  required String shiftDate,
  required String startTime,
  required String endTime,
  required String rawNotes,
  List<String>? primaryLocations,
}) async {
  // Step 1: Create shift note
  final createResponse = await _client.callTool(
    'create_shift_note',
    arguments: {
      'client_id': clientId,
      'stakeholder_id': stakeholderId,
      'shift_date': shiftDate,
      'start_time': startTime,
      'end_time': endTime,
      'raw_notes': rawNotes,
      if (primaryLocations != null) 'primary_locations': primaryLocations,
    },
  );

  final shiftNote = ShiftNote.fromJson(
    jsonDecode(createResponse.content[0].text)
  );

  // Step 2: Get formatting prompt
  final formatResponse = await _client.callTool(
    'format_shift_note',
    arguments: {'shift_note_id': shiftNote.id},
  );

  final promptData = jsonDecode(formatResponse.content[0].text);
  final prompt = promptData['prompt'] as String;

  // Step 3: Send to Claude for formatting
  final formattedNote = await claudeApi.complete(prompt);

  // Step 4: Save formatted note
  final saveResponse = await _client.callTool(
    'save_formatted_shift_note',
    arguments: {
      'shift_note_id': shiftNote.id,
      'formatted_note': formattedNote,
    },
  );

  return ShiftNote.fromJson(jsonDecode(saveResponse.content[0].text));
}
```

### 5. Dashboard Screen

```dart
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Dashboard> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _fetchDashboard();
  }

  Future<Dashboard> _fetchDashboard() async {
    final response = await mcpService.client.callTool(
      'get_dashboard',
      arguments: {},
    );

    return Dashboard.fromJson(jsonDecode(response.content[0].text));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Dashboard>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return ErrorWidget(snapshot.error!);
        }

        final dashboard = snapshot.data!;

        return ListView(
          children: [
            _buildMetricCard('Active Clients', dashboard.activeClients),
            _buildMetricCard('Active Goals', dashboard.activeGoals),
            _buildMetricCard('At-Risk Goals', dashboard.goalsAtRisk.length),
            _buildRecentActivities(dashboard.recentActivities),
            _buildRecentShiftNotes(dashboard.recentShiftNotes),
          ],
        );
      },
    );
  }
}
```

### 6. Updating Goal Progress

```dart
Future<Goal> updateGoalProgress({
  required String goalId,
  int? progressPercentage,
  String? status,
  String? notes,
}) async {
  final response = await _client.callTool(
    'update_goal_progress',
    arguments: {
      'goal_id': goalId,
      if (progressPercentage != null) 'progress_percentage': progressPercentage,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
    },
  );

  return Goal.fromJson(jsonDecode(response.content[0].text));
}

// Usage in UI
await updateGoalProgress(
  goalId: goal.id,
  progressPercentage: 75,
  status: 'in_progress',
  notes: 'Made significant progress this week',
);
```

### 7. Search Functionality

```dart
class ClientSearchDelegate extends SearchDelegate<Client?> {
  final McpService mcpService;

  ClientSearchDelegate(this.mcpService);

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Client>>(
      future: mcpService.searchClients(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final clients = snapshot.data!;

        return ListView.builder(
          itemCount: clients.length,
          itemBuilder: (context, index) {
            final client = clients[index];
            return ListTile(
              title: Text(client.name),
              subtitle: Text(client.ndisNumber ?? 'No NDIS number'),
              onTap: () => close(context, client),
            );
          },
        );
      },
    );
  }

  // ... implement other search delegate methods
}
```

---

## Error Handling

### Error Types

The MCP server returns structured errors with the following hierarchy:

1. **ValidationError** (Code: `VALIDATION_ERROR`)
   - Input validation failures
   - Invalid field formats (dates, NDIS numbers, etc.)
   - Example: "NDIS number must be exactly 11 digits"

2. **NotFoundError** (Code: `NOT_FOUND`)
   - Resource doesn't exist
   - Example: "Client with ID {id} not found"

3. **ConflictError** (Code: `CONFLICT`)
   - Business rule violations
   - Example: "NDIS number already exists"

4. **StorageError** (Code: `STORAGE_ERROR`)
   - Database I/O failures
   - Example: "Failed to write to storage"

5. **AuthorizationError** (Code: `AUTHORIZATION_ERROR`)
   - Operation not permitted
   - Example: "Cannot edit shift note after 24 hours"

### Error Response Format

```json
{
  "error": "Client with ID abc123 not found",
  "code": "NOT_FOUND"
}
```

### Flutter Error Handling Example

```dart
class McpException implements Exception {
  final String message;
  final String code;

  McpException(this.message, this.code);

  factory McpException.fromResponse(Map<String, dynamic> json) {
    return McpException(
      json['error'] as String,
      json['code'] as String,
    );
  }

  bool get isValidationError => code == 'VALIDATION_ERROR';
  bool get isNotFound => code == 'NOT_FOUND';
  bool get isConflict => code == 'CONFLICT';
  bool get isAuthorizationError => code == 'AUTHORIZATION_ERROR';
}

Future<T> executeTool<T>(
  String toolName,
  Map<String, dynamic> arguments,
  T Function(Map<String, dynamic>) parser,
) async {
  try {
    final response = await _client.callTool(toolName, arguments: arguments);
    final data = jsonDecode(response.content[0].text);

    // Check for error response
    if (data is Map<String, dynamic> && data.containsKey('error')) {
      throw McpException.fromResponse(data);
    }

    return parser(data);
  } on McpException catch (e) {
    // Handle specific error types
    if (e.isNotFound) {
      // Show "not found" UI
      throw Exception('Resource not found: ${e.message}');
    } else if (e.isValidationError) {
      // Show validation error to user
      throw Exception('Validation error: ${e.message}');
    } else {
      rethrow;
    }
  } catch (e) {
    // Handle unexpected errors
    throw Exception('Unexpected error: $e');
  }
}
```

---

## Best Practices

### 1. Data Freshness

- **Cache dashboard data**: Refresh every 5-10 minutes
- **Use pagination**: For lists with > 20 items
- **Optimistic updates**: Update UI immediately, sync in background

### 2. Shift Note Workflow

```dart
// Recommended workflow:
// 1. Create shift note with raw notes (during shift)
await createShiftNote(rawNotes: supportWorkerInput);

// 2. Format shift note (at end of shift)
final formattedNote = await formatAndSaveShiftNote(shiftNoteId);

// 3. Allow edits only within 24 hours
if (canEditShiftNote(shiftNote.shiftDate)) {
  await updateShiftNote(...);
} else {
  showError('Cannot edit shift note after 24 hours');
}
```

### 3. Goal Progress Tracking

```dart
// Update goal progress after activities
await completeActivity(activityId);
await updateGoalProgress(
  goalId: activity.goalIds.first,
  progressPercentage: calculateProgress(goal),
);

// Auto-refresh client summary after updates
await refreshClientSummary(clientId);
```

### 4. Offline Support

```dart
// Store pending operations locally
class PendingOperation {
  final String toolName;
  final Map<String, dynamic> arguments;
  final DateTime timestamp;
}

// Sync when back online
Future<void> syncPendingOperations() async {
  for (final operation in pendingOperations) {
    try {
      await _client.callTool(operation.toolName, arguments: operation.arguments);
      await removePendingOperation(operation);
    } catch (e) {
      // Retry later
      logError('Failed to sync operation', e);
    }
  }
}
```

### 5. Security Considerations

- **PII Protection**: The MCP server auto-redacts sensitive fields in logs
- **Soft Deletes**: Never expose deactivated clients/stakeholders in UI
- **Input Validation**: Always validate dates, NDIS numbers client-side
- **NDIS Compliance**: Ensure shift notes include all required NDIS documentation fields

### 6. Performance Tips

- Use `list_*` tools with `limit` and `offset` for pagination
- Prefer `get_client_summary` over multiple separate tool calls
- Batch operations when possible (e.g., create multiple goals)
- Use resources (`client:///id`) for quick single-entity lookups

### 7. Date/Time Handling

```dart
// Always use ISO 8601 format
final dateOfBirth = DateFormat('yyyy-MM-dd').format(selectedDate);
final shiftTime = DateFormat('HH:mm').format(selectedTime);

// Parse timestamps from server
final createdAt = DateTime.parse(client.createdAt);
```

### 8. Goal Risk Detection

```dart
// Identify at-risk goals
bool isGoalAtRisk(Goal goal) {
  final daysToTarget = DateTime.parse(goal.targetDate)
      .difference(DateTime.now())
      .inDays;

  return daysToTarget < 14 && goal.progressPercentage < 50;
}

// Show alerts for at-risk goals in UI
```

---

## Appendix: Complete Type Definitions

### Dart Models (Example)

```dart
// lib/models/client.dart
class Client {
  final String id;
  final String name;
  final String dateOfBirth;
  final String? ndisNumber;
  final String? primaryContact;
  final String? supportNotes;
  final bool active;
  final String createdAt;
  final String updatedAt;

  Client({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    this.ndisNumber,
    this.primaryContact,
    this.supportNotes,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      name: json['name'] as String,
      dateOfBirth: json['date_of_birth'] as String,
      ndisNumber: json['ndis_number'] as String?,
      primaryContact: json['primary_contact'] as String?,
      supportNotes: json['support_notes'] as String?,
      active: json['active'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date_of_birth': dateOfBirth,
      if (ndisNumber != null) 'ndis_number': ndisNumber,
      if (primaryContact != null) 'primary_contact': primaryContact,
      if (supportNotes != null) 'support_notes': supportNotes,
      'active': active,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ClientWithStats extends Client {
  final int totalGoals;
  final int activeGoals;
  final int totalActivities;
  final String? lastShiftNoteDate;

  ClientWithStats({
    required String id,
    required String name,
    required String dateOfBirth,
    String? ndisNumber,
    String? primaryContact,
    String? supportNotes,
    required bool active,
    required String createdAt,
    required String updatedAt,
    required this.totalGoals,
    required this.activeGoals,
    required this.totalActivities,
    this.lastShiftNoteDate,
  }) : super(
          id: id,
          name: name,
          dateOfBirth: dateOfBirth,
          ndisNumber: ndisNumber,
          primaryContact: primaryContact,
          supportNotes: supportNotes,
          active: active,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory ClientWithStats.fromJson(Map<String, dynamic> json) {
    return ClientWithStats(
      id: json['id'] as String,
      name: json['name'] as String,
      dateOfBirth: json['date_of_birth'] as String,
      ndisNumber: json['ndis_number'] as String?,
      primaryContact: json['primary_contact'] as String?,
      supportNotes: json['support_notes'] as String?,
      active: json['active'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      totalGoals: json['total_goals'] as int,
      activeGoals: json['active_goals'] as int,
      totalActivities: json['total_activities'] as int,
      lastShiftNoteDate: json['last_shift_note_date'] as String?,
    );
  }
}
```

---

## Support

For technical issues or questions:
- GitHub Issues: [agnovat-mcp/issues](https://github.com/your-org/agnovat-mcp/issues)
- Documentation: See `CLAUDE.md` for architecture details
- Testing Guide: See `TESTING_GUIDE.md` for server testing

---

**End of Flutter MCP Integration Guide**
