/// API configuration for Agnovat Convex Backend
class ApiConfig {
  ApiConfig._();

  // Convex Deployment URL
  // Get this from: npx convex dev (for local) or Convex dashboard (for production)
  static const String convexUrl = String.fromEnvironment(
    'CONVEX_URL',
    defaultValue: 'https://striped-monitor-16.convex.cloud', // Default Convex dev server
  );

  // Convex HTTP API endpoints
  static String get queryUrl => '$convexUrl/api/query';
  static String get mutationUrl => '$convexUrl/api/mutation';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Enable logging in debug mode
  static const bool enableLogging = true;

  // Convex Function Names (matching your convex/ directory)
  // Clients
  static const String clientsCreate = 'clients:create';
  static const String clientsGet = 'clients:get';
  static const String clientsList = 'clients:list';
  static const String clientsUpdate = 'clients:update';
  static const String clientsDeactivate = 'clients:deactivate';
  static const String clientsSearch = 'clients:search';

  // Goals
  static const String goalsCreate = 'goals:create';
  static const String goalsGet = 'goals:get';
  static const String goalsList = 'goals:list';
  static const String goalsUpdate = 'goals:update';
  static const String goalsUpdateProgress = 'goals:updateProgress';
  static const String goalsArchive = 'goals:archive';

  // Activities
  static const String activitiesCreate = 'activities:create';
  static const String activitiesGet = 'activities:get';
  static const String activitiesList = 'activities:list';
  static const String activitiesUpdate = 'activities:update';

  // Stakeholders
  static const String stakeholdersCreate = 'stakeholders:create';
  static const String stakeholdersGet = 'stakeholders:get';
  static const String stakeholdersList = 'stakeholders:list';
  static const String stakeholdersUpdate = 'stakeholders:update';
  static const String stakeholdersDeactivate = 'stakeholders:deactivate';
  static const String stakeholdersSearch = 'stakeholders:search';

  // Shift Notes
  static const String shiftNotesCreate = 'shiftNotes:create';
  static const String shiftNotesGet = 'shiftNotes:get';
  static const String shiftNotesList = 'shiftNotes:list';
  static const String shiftNotesUpdate = 'shiftNotes:update';
  static const String shiftNotesDelete = 'shiftNotes:remove';
  static const String shiftNotesSubmit = 'shiftNotes:submit';
  static const String shiftNotesGetRecent = 'shiftNotes:getRecent';
  static const String shiftNotesGetForWeek = 'shiftNotes:getForWeek';
  static const String shiftNotesAddActivitySession = 'shiftNotes:addActivitySession'; // NEW
  static const String shiftNotesGetWithSessions = 'shiftNotes:getWithSessions'; // NEW

  // Dashboard
  static const String dashboardGet = 'dashboard:getDashboard';
  static const String dashboardGetClientSummary = 'dashboard:getClientSummary';
  static const String dashboardGetStatistics = 'dashboard:getStatistics';

  // Auth / Users
  static const String authGetCurrentUser = 'auth:getCurrentUser';
  static const String authGetUserProfile = 'auth:getUserProfile';
  static const String authSyncUserFromClerk = 'auth:syncUserFromClerk';
  static const String authUpdateProfile = 'auth:updateProfile';
  static const String authUpdateLastLogin = 'auth:updateLastLogin';
  static const String authEmailExists = 'auth:emailExists';
  static const String authLinkStakeholder = 'auth:linkStakeholder';
  
  // Users
  static const String usersGet = 'users:get';
  static const String usersList = 'users:list';

  // Behavior Incidents
  static const String behaviorIncidentsCreate = 'behaviorIncidents:create';
  static const String behaviorIncidentsGet = 'behaviorIncidents:getById';
  static const String behaviorIncidentsList = 'behaviorIncidents:list';
  static const String behaviorIncidentsUpdate = 'behaviorIncidents:update';
  static const String behaviorIncidentsRemove = 'behaviorIncidents:remove';
  static const String behaviorIncidentsGetStats = 'behaviorIncidents:getStats';
  static const String behaviorIncidentsGetRecentHighSeverity = 'behaviorIncidents:getRecentHighSeverity';

  // Activity Sessions
  static const String activitySessionsCreate = 'activitySessions:create';
  static const String activitySessionsGet = 'activitySessions:getById';
  static const String activitySessionsList = 'activitySessions:list';
  static const String activitySessionsUpdate = 'activitySessions:update';
  static const String activitySessionsDelete = 'activitySessions:delete';
  static const String activitySessionsGetActivityEffectivenessReport = 'activitySessions:getActivityEffectivenessReport';

  // Activity Sessions - Media Upload
  static const String activitySessionsGenerateUploadUrl = 'activitySessions:generateUploadUrl';
  static const String activitySessionsAddMedia = 'activitySessions:addMedia';
  static const String activitySessionsGetFileUrl = 'activitySessions:getFileUrl';
  static const String activitySessionsRemoveMedia = 'activitySessions:removeMedia';
}
