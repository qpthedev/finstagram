import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notifications = FlutterLocalNotificationsPlugin();

//Settings to load on app initialization
initNotification() async {
  //For Android
  var androidSetting = AndroidInitializationSettings('app_icon');

  //iOS Permission requests
  var iosSetting = IOSInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  var initializationSettings =
      InitializationSettings(android: androidSetting, iOS: iosSetting);
  await notifications.initialize(
    initializationSettings,
    //onSelectNotification: function to run on notification press
  );
}

//code to show notifications
showNotification() async {
  var androidDetails = AndroidNotificationDetails(
    'notification id',
    'notification description',
    priority: Priority.high,
    importance: Importance.max,
    color: Color.fromARGB(255, 255, 0, 0),
  );

  var iosDetails = IOSNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  // Setting notification id, title, description
  notifications.show(
    1,
    'Title 1',
    'Description 1',
    NotificationDetails(android: androidDetails, iOS: iosDetails),
  );
}

showNotification2() async {
  tz.initializeTimeZones();

  var androidDetails = const AndroidNotificationDetails(
    'notification id',
    'notification description',
    priority: Priority.high,
    importance: Importance.max,
    color: Color.fromARGB(255, 255, 0, 0),
  );
  var iosDetails = const IOSNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  notifications.zonedSchedule(
    2,
    'Title 2',
    'Description 2',
    tz.TZDateTime.now(tz.local).add(Duration(seconds: 5)),
    NotificationDetails(android: androidDetails, iOS: iosDetails),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

makeDate(hour, min, sec) {
  var now = tz.TZDateTime.now(tz.local);
  var when =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, min, sec);
  if (when.isBefore(now)) {
    return when.add(Duration(days: 1));
  } else {
    return when;
  }
}
