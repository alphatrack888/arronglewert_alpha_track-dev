import 'package:alpha_track/screens/break_screen/leave_screen/leave_type_display.dart';

/// Maps apply-leave UI translation keys to API `type` values.
String leaveTypeKeyToApi(String uiKey) => apiTypeFromUiKey(uiKey);

bool isValidLeaveApiType(String apiType) =>
    kLeaveApiTypes.contains(apiType.toLowerCase());
