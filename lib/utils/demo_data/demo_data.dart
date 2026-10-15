import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:alpha_track/screens/home_screen/models/all_project_models.dart'
    as proj;
import 'package:alpha_track/screens/home_screen/models/break_hours_model.dart'
    as brk;
import 'package:alpha_track/screens/home_screen/models/daily_summary_model.dart'
    as daily;
import 'package:alpha_track/screens/home_screen/models/working_hours_summary_model.dart'
    as wh;
import 'package:alpha_track/screens/notification_screen/models/notification_screen_model.dart'
    as notif;
import 'package:alpha_track/screens/profile_screen/pay_role_screen/models/payrole_model.dart'
    as pay;
import 'package:alpha_track/screens/profile_screen/gallery_screen/models/gallery_model.dart'
    as gal;
import 'package:alpha_track/screens/break_screen/model/leave_balance_mdoel.dart'
    as lb;
import 'package:alpha_track/screens/break_screen/model/leave_balance_left.dart'
    as lh;
import 'package:alpha_track/screens/home_screen/models/single_project_model.dart'
    as sp;
import 'package:alpha_track/screens/profile_screen/profile_screen_main/models/profile_model.dart'
    as pm;

/// =====================================================================
/// TEMPORARY DEMO DATA — for design testing only.
///
/// When [kDemoMode] is true, the app shows sample content WITHOUT a backend
/// or login, so every redesigned screen can be reviewed populated.
///
/// Debug and release default to **real login** ([_demoReviewEnabled] is false).
/// Demo is ON only when compiled with:
///   flutter run --dart-define=DEMO_MODE=true
///   flutter build apk --release --dart-define=DEMO_MODE=true  (reviewer only)
///
/// Production CI must never pass DEMO_MODE (see MOBILE_CI_CD.md).
/// =====================================================================
const bool _demoOverride = bool.fromEnvironment('DEMO_MODE');
const bool _demoReviewEnabled = false;
const bool kDemoMode = _demoOverride || (!kReleaseMode && _demoReviewEnabled);

class DemoData {
  DemoData._();

  // ---- Profile (Account tab + Edit Personal Information) -------------------
  // Mutable so demo edits (Save Changes) visibly persist for the session.
  static pm.ProfileModel profile = pm.ProfileModel.fromJson({
    "statusCode": 200,
    "success": true,
    "message": "demo",
    "data": {
      "_id": "demo-user",
      "name": "Marc G.",
      "email": "marc@demo.co",
      "phone": "+1 555 010 0142",
      "role": "Field Technician",
      "company": {"_id": "c1", "name": "Alpha Team Security"},
      "verified": true,
      "profile": "",
    }
  });

  // ---- Projects (Home recent + Projects tab) -------------------------------
  static proj.AllProjectModel get projects => proj.AllProjectModel.fromJson({
        "statusCode": 200,
        "success": true,
        "message": "demo",
        "data": {
          "meta": {"page": 1, "limit": 10, "total": 5, "totalPages": 1},
          "data": [
            {
              "_id": "demo_p1",
              "title": "Osterberg",
              "company": {"_id": "c1", "name": "Alpha Team Security"},
              "duration": 480,
              "projectTime": 263,
              "status": "active",
              "startDate": "2026-06-01T09:00:00.000Z",
              "endDate": "2026-08-30T17:00:00.000Z",
              "description":
                  "On-site security coverage and access-control rollout for the Alpha Team campus.",
              "employees": ["Marc G.", "Dana R.", "Ibrahim K."],
              "images": [],
              "__v": 0
            },
            {
              "_id": "demo_p2",
              "title": "Sparktech Agency",
              "company": {"_id": "c2", "name": "Design retainer"},
              "duration": 120,
              "projectTime": 38,
              "status": "active",
              "startDate": "2026-06-10T09:00:00.000Z",
              "endDate": "2026-07-10T17:00:00.000Z",
              "description":
                  "Ongoing design retainer — UI updates, marketing assets and monthly reviews.",
              "employees": ["Marc G.", "Lena P."],
              "images": [],
              "__v": 0
            },
            {
              "_id": "demo_p3",
              "title": "Northwind Co",
              "company": {"_id": "c3", "name": "Brand refresh"},
              "duration": 0,
              "projectTime": 0,
              "status": "upcoming",
              "startDate": "2026-07-15T09:00:00.000Z",
              "endDate": "2026-09-01T17:00:00.000Z",
              "description":
                  "Full brand refresh kicking off next month — logo, guidelines and website.",
              "employees": ["Marc G."],
              "images": [],
              "__v": 0
            },
            {
              "_id": "demo_p4",
              "title": "Acme Redesign",
              "company": {"_id": "c4", "name": "Web platform"},
              "duration": 2400,
              "projectTime": 1820,
              "status": "completed",
              "startDate": "2026-02-01T09:00:00.000Z",
              "endDate": "2026-05-20T17:00:00.000Z",
              "description":
                  "Delivered: web platform redesign, component library and analytics dashboard.",
              "employees": ["Marc G.", "Sara T.", "Owen H."],
              "images": [],
              "__v": 0
            },
            {
              "_id": "demo_p5",
              "title": "Helios Mobile",
              "company": {"_id": "c5", "name": "iOS app"},
              "duration": 300,
              "projectTime": 95,
              "status": "cancelled",
              "startDate": "2026-03-01T09:00:00.000Z",
              "endDate": "2026-04-01T17:00:00.000Z",
              "description": "iOS companion app — paused by the client.",
              "employees": ["Marc G."],
              "images": [],
              "__v": 0
            }
          ]
        }
      });

  static wh.WorkingHoursSummaryModel get workingHours =>
      wh.WorkingHoursSummaryModel.fromJson({
        "statusCode": 200,
        "success": true,
        "message": "demo",
        "data": {"today": 5.5, "thisWeek": 31.2, "thisMonth": 124.0}
      });

  static brk.BreakHoursModel get breakHours => brk.BreakHoursModel.fromJson({
        "statusCode": 200,
        "success": true,
        "message": "demo",
        "data": {
          "Sat": 3,
          "Sun": 0,
          "Mon": 4.5,
          "Tue": 6.0,
          "Wed": 5.0,
          "Thu": 4,
          "Fri": 2
        }
      });

  static daily.DailySummaryModel get dailySummary =>
      daily.DailySummaryModel.fromJson({
        "statusCode": 200,
        "success": true,
        "message": "demo",
        "data": {
          "totalTime": "5h 30m",
          "overtime": "1h 0m",
          "totalBreakInHours": "0.75",
          "totalBreakInHoursFormatted": "0h 45m",
          "overtimeInHoursFormatted": "1h 0m",
          "sessions": [
            {
              "_id": "s1",
              "user": "u1",
              "project": {"_id": "demo_p1"},
              "startTime": "2026-06-23T09:02:00.000Z",
              "endTime": "2026-06-23T12:15:00.000Z",
              "totalTime": 11580000,
              "status": "completed",
              "pauses": [],
              "locations": [],
              "date": "2026-06-23T00:00:00.000Z",
              "__v": 0
            },
            {
              "_id": "s2",
              "user": "u1",
              "project": {"_id": "demo_p2"},
              "startTime": "2026-06-23T13:00:00.000Z",
              "endTime": "2026-06-23T15:20:00.000Z",
              "totalTime": 8400000,
              "status": "completed",
              "pauses": [],
              "locations": [],
              "date": "2026-06-23T00:00:00.000Z",
              "__v": 0
            }
          ]
        }
      });

  // ---- Single project (Project Details) -------------------------------------
  static const Map<String, List<String>> _projectMeta = {
    'demo_p1': ['Osterberg', 'Alpha Team Security', 'active'],
    'demo_p2': ['Sparktech Agency', 'Design retainer', 'active'],
    'demo_p3': ['Northwind Co', 'Brand refresh', 'upcoming'],
    'demo_p4': ['Acme Redesign', 'Web platform', 'completed'],
    'demo_p5': ['Helios Mobile', 'iOS app', 'cancelled'],
  };

  static sp.SingleProjectModel singleProject(String id) {
    final m = _projectMeta[id] ?? ['Garden Cleaner', 'Green Co', 'active'];
    return sp.SingleProjectModel.fromJson({
      "statusCode": 200,
      "success": true,
      "message": "demo",
      "data": {
        "_id": id,
        "title": m[0],
        "company": {"_id": "c1", "name": m[1]},
        "status": m[2],
        "duration": 480,
        "projectTime": 263,
        "startDate": "2026-03-12T09:00:00.000Z",
        "endDate": null,
        "employees": ["John Doe", "Dana R."],
        "images": ["https://picsum.photos/id/1015/800/500"],
        "audio": null,
        "description":
            "Keep your lawn neat and healthy with professional mowing and grass trimming services. Our team ensures a perfectly manicured lawn by trimming edges, eliminating overgrowth, and creating a polished finish every visit.\n- Regular lawn mowing and trimming\n- Edge detailing for a polished look\n- Adjustable cutting height based on lawn type\n- Removal of clippings and debris",
        "createdAt": "2026-03-01T00:00:00.000Z",
        "updatedAt": "2026-06-01T00:00:00.000Z",
        "__v": 0
      }
    });
  }

  // ---- Project notes (Project Details > Notes tab) --------------------------
  static List<Map<String, String>> get projectNotes => [
        {
          'title': 'Lawn treatment applied',
          'body':
              'Applied slow-release feed and spot-treated weeds across the main lawn. Avoided the area near the pond as requested. Lawn should green up within two weeks.',
          'author': 'Marc G.',
          'time': 'Yesterday • 12:34',
          'images':
              'https://picsum.photos/id/1015/600/600|https://picsum.photos/id/1025/600/600|https://picsum.photos/id/1024/600/600',
          'audio': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        },
        {
          'title': 'Broken latch at Gate B',
          'body':
              'Found the side gate latch snapped clean off, probably from the storm. Secured it with a cable tie so the gate stays shut, but it won’t lock properly. Needs a replacement latch.',
          'author': 'John Doe',
          'time': 'Yesterday • 12:34',
          'images':
              'https://picsum.photos/id/1062/600/600|https://picsum.photos/id/1074/600/600',
        },
        {
          'title': 'Voice memo — site walkthrough',
          'body': 'Quick walkthrough notes recorded on site. Tap play to listen.',
          'author': 'Lena P.',
          'time': 'Yesterday • 09:10',
          'audio': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        },
        {
          'title': 'Add seasonal planting',
          'body':
              'Owner asked about adding spring colour to the front borders. Suggested a mix of tulips and pansies for the entrance beds. Awaiting approval on budget.',
          'author': 'Marc G.',
          'time': 'March 12, 2025 • 12:34',
        },
        {
          'title': 'Hedge trimming complete — north border',
          'body': 'North hedge trimmed and clippings cleared.',
          'author': 'Marc G.',
          'time': 'Yesterday • 12:34',
        },
      ];

  // ---- Notifications --------------------------------------------------------
  static notif.NotificationGetModel get notifications =>
      notif.NotificationGetModel.fromJson({
        "statusCode": 200,
        "success": true,
        "message": "demo",
        "data": {
          "meta": {"page": 1, "limit": 10, "total": 4, "totalPages": 1},
          "data": [
            {
              "_id": "n1",
              "title": "Project assigned",
              "body": "You've been added to “Osterberg” by Alpha Team Security.",
              "isRead": false,
              "from": {"_id": "f1", "name": "Alpha Team Security"},
              "createdAt": "2026-06-23T08:30:00.000Z",
              "updatedAt": "2026-06-23T08:30:00.000Z",
              "__v": 0
            },
            {
              "_id": "n2",
              "title": "Timesheet approved",
              "body": "Your hours for last week were approved.",
              "isRead": false,
              "from": {"_id": "f2", "name": "Payroll"},
              "createdAt": "2026-06-22T16:10:00.000Z",
              "updatedAt": "2026-06-22T16:10:00.000Z",
              "__v": 0
            },
            {
              "_id": "n3",
              "title": "Break reminder",
              "body": "You've been working for 4 hours — consider a short break.",
              "isRead": true,
              "from": {"_id": "f3", "name": "Alpha Track"},
              "createdAt": "2026-06-22T11:00:00.000Z",
              "updatedAt": "2026-06-22T11:00:00.000Z",
              "__v": 0
            },
            {
              "_id": "n4",
              "title": "New note",
              "body": "Lena P. added a note to “Sparktech Agency”.",
              "isRead": true,
              "from": {"_id": "f4", "name": "Lena P."},
              "createdAt": "2026-06-21T14:45:00.000Z",
              "updatedAt": "2026-06-21T14:45:00.000Z",
              "__v": 0
            }
          ]
        }
      });

  // ---- Payroll --------------------------------------------------------------
  static pay.PayrollModel get payroll => pay.PayrollModel.fromJson({
        "statusCode": 200,
        "success": true,
        "message": "demo",
        "data": [
          {
            "_id": "pay1",
            "company": "Alpha Team Security",
            "employee": {"_id": "e1", "name": "Marc G.", "email": "marc@demo.co"},
            "files": ["https://www.africau.edu/images/default/sample.pdf"],
            "createdAt": "2026-05-31T00:00:00.000Z",
            "updatedAt": "2026-05-31T00:00:00.000Z",
            "__v": 0
          },
          {
            "_id": "pay2",
            "company": "Alpha Team Security",
            "employee": {"_id": "e1", "name": "Marc G.", "email": "marc@demo.co"},
            "files": ["https://www.africau.edu/images/default/sample.pdf"],
            "createdAt": "2026-04-30T00:00:00.000Z",
            "updatedAt": "2026-04-30T00:00:00.000Z",
            "__v": 0
          },
          {
            "_id": "pay3",
            "company": "Alpha Team Security",
            "employee": {"_id": "e1", "name": "Marc G.", "email": "marc@demo.co"},
            "files": ["https://www.africau.edu/images/default/sample.pdf"],
            "createdAt": "2026-03-31T00:00:00.000Z",
            "updatedAt": "2026-03-31T00:00:00.000Z",
            "__v": 0
          }
        ]
      });

  // ---- Gallery (placeholder images load over the network) -------------------
  static gal.GalleryModel get gallery => gal.GalleryModel.fromJson({
        "statusCode": 200,
        "success": true,
        "message": "demo",
        "data": [
          {"_id": "g1", "image": "https://picsum.photos/id/1015/600/600"},
          {"_id": "g2", "image": "https://picsum.photos/id/1025/600/600"},
          {"_id": "g3", "image": "https://picsum.photos/id/1003/600/600"},
          {"_id": "g4", "image": "https://picsum.photos/id/1043/600/600"},
          {"_id": "g5", "image": "https://picsum.photos/id/1062/600/600"},
          {"_id": "g6", "image": "https://picsum.photos/id/1074/600/600"}
        ]
      });

  // ---- Leave balance + history (Break / Leave screens) ----------------------
  static lb.LeaveBalanceModel get leaveBalance => lb.LeaveBalanceModel.fromJson({
        "statusCode": 200,
        "success": true,
        "message": "demo",
        "data": [
          {
            "_id": "lbal1",
            "company": {"_id": "c1", "name": "Alpha Team Security"},
            "casualLeave": 8,
            "sickLeave": 6,
            "earnLeave": 12,
            "wpLeave": 3,
            "createdAt": "2026-01-01T00:00:00.000Z",
            "updatedAt": "2026-06-01T00:00:00.000Z",
            "__v": 0
          }
        ]
      });

  static lh.LeaveBalanceLeftModel get leaveHistory {
    // Dates are computed relative to "today" so the Upcoming and History
    // sections always have representative entries whenever the demo is run.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    String iso(int dayOffset) =>
        today.add(Duration(days: dayOffset)).toUtc().toIso8601String();

    return lh.LeaveBalanceLeftModel.fromJson({
      "statusCode": 200,
      "success": true,
      "message": "demo",
      "data": {
        "companyLeaveBalance": [
          {"type": "casual", "taken": 4, "balance": 8, "status": "active"},
          {"type": "sick", "taken": 2, "balance": 6, "status": "active"},
          {"type": "earn", "taken": 0, "balance": 12, "status": "active"},
          {"type": "wp", "taken": 1, "balance": 3, "status": "active"}
        ],
        "leavemanagements": [
          // Finished (approved, in the past) → History + shaded on calendar.
          {
            "_id": "lm1",
            "user": "u1",
            "company": {"_id": "c1", "name": "Alpha Team Security"},
            "totalDays": 2,
            "type": "casual",
            "status": "approved",
            "from": iso(-26),
            "to": iso(-25),
            "reason": "Family event",
            "__v": 0
          },
          // Rejected (in the past) → History only, never colours the calendar.
          {
            "_id": "lm2",
            "user": "u1",
            "company": {"_id": "c1", "name": "Alpha Team Security"},
            "totalDays": 1,
            "type": "sick",
            "status": "rejected",
            "from": iso(-12),
            "to": iso(-12),
            "reason": "Doctor appointment",
            "__v": 0
          },
          // Upcoming approved → Upcoming section + full colour on calendar.
          {
            "_id": "lm3",
            "user": "u1",
            "company": {"_id": "c1", "name": "Alpha Team Security"},
            "totalDays": 3,
            "type": "earn",
            "status": "approved",
            "from": iso(12),
            "to": iso(14),
            "reason": "Short trip",
            "__v": 0
          },
          // Upcoming pending → Upcoming section + full colour on calendar.
          {
            "_id": "lm4",
            "user": "u1",
            "company": {"_id": "c1", "name": "Alpha Team Security"},
            "totalDays": 1,
            "type": "casual",
            "status": "pending",
            "from": iso(25),
            "to": iso(25),
            "reason": "Personal day",
            "__v": 0
          }
        ]
      }
    });
  }
}
