class StorageKey {
  static String currentUser = "CURRENT_USER";
  static String authorizationToken = "AUTHORIZATION_TOKEN";
  static String selectedProject = "SELECTED_PROJECT";
  static String menu = "MENU";
  static String moduleAction = "MODULE_ACTION";
  static String projectList = "PROJECT_LIST";
  static String userUniqueKey = "USER_UNIQUE_KEY";
  static String lastActiveRoute = "LAST_ACTIVE_ROUTE";
  static String menuDrawerScrollOffset = "MENU_DRAWER_SCROLL_OFFSET";

  /// App-initiated call logs (from CustomClickToContact). Not device call history.
  static String appInitiatedCallLogs = "APP_INITIATED_CALL_LOGS";

  /// Last date when app-initiated call logs were synced to backend (for nightly sync).
  static String appInitiatedCallLogsLastSyncDate =
      "APP_INITIATED_CALL_LOGS_LAST_SYNC_DATE";

  /// App version
  static const appVersion = "x.x.x";


  static const fcmToken = "";

  static String addressMasterData = "ADDRESS_MASTER_DATA";
}
