import 'dart:convert';
import 'dart:math';

import 'package:ams/dateTest.dart';
import 'package:ams/loginScreen.dart';
import 'package:ams/multiWindowTest.dart';
import 'package:ams/noiseTest/fftExample.dart';
import 'package:ams/noiseTest/noiseMeterTest.dart';
import 'package:ams/noiseTest/soundProcTest.dart';
import 'package:ams/participant/attendanceRecorded.dart';
import 'package:ams/participant/faceIdentificationPrompt.dart';
import 'package:ams/participant/geofenceTest.dart';
import 'package:ams/participant/participantScreen.dart';
import 'package:ams/participant/participantSessionScreen.dart';
import 'package:ams/participant/qrScanner.dart';
import 'package:ams/registerScreen.dart';
import 'package:ams/suc.dart';
import 'package:ams/supervisor/meetingDashboard.dart';
import 'package:ams/supervisor/supervisorQR.dart';
import 'package:ams/supervisor/supervisorScreen.dart';
import 'package:ams/supervisor/supervisorSessionScreen.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';


final GoRouter _router = GoRouter(
  //initialLocation: "/participant/345@gmail.com",
  initialLocation: "/",
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
      routes: [
        GoRoute(
          path: 'register',
          builder: (BuildContext context, GoRouterState state) {
            return const RegisterScreen();
          },
        ),
      ],
    ),
    GoRoute(
      path: '/participant/:participantEmail',
      builder: (BuildContext context, GoRouterState state) {
        final String participantEmail = state.pathParameters['participantEmail']!;

        return ParticipantScreen(participantEmail: participantEmail,);
      },
      routes: [
        GoRoute(
          path: 'recorded/:meetingId',
          builder: (BuildContext context, GoRouterState state) {
            final String participantEmail = state.pathParameters['participantEmail']!;
            final meetingId = int.parse(state.pathParameters['meetingId']!);
            return AttendanceRecorded(participantEmail: participantEmail, meetingId: meetingId,);
          },
        ),
        GoRoute(
          path: 'session/:sessionId/:sessionName',
          builder: (BuildContext context, GoRouterState state) {
            final int sessionId = int.parse(state.pathParameters['sessionId']!);
            final String sessionName = state.pathParameters['sessionName']!;

            return ParticipantSessionScreen(sessionId: sessionId,
              sessionName: sessionName,);
          },
          routes: [
            GoRoute(
              path: 'qrScanner/:meetingId',
              builder: (BuildContext context, GoRouterState state) {
                final sessionId = int.parse(state.pathParameters['sessionId']!);
                final meetingId = int.parse(state.pathParameters['meetingId']!);
                final String sessionName = state.pathParameters['sessionName']!;
                final String participantEmail = state.pathParameters['participantEmail']!;


                return QRViewExample(sessionName: sessionName,sessionId: sessionId as int, meetingId: meetingId as int,
                participantEmail: participantEmail,);
                //return GeofenceTest(sessionId: sessionId);
              },
            ),
            GoRoute(
              path: 'faceIdentification/:meetingId',
              builder: (BuildContext context, GoRouterState state) {
                final String participantEmail = state.pathParameters['participantEmail']!;
                final meetingId = int.parse(state.pathParameters['meetingId']!);

                return FaceIdentificationPrompt(participantEmail: participantEmail, meetingId: meetingId,);
              },
            ),
            GoRoute(
              path: 'geofence/:meetingId',
              builder: (BuildContext context, GoRouterState state) {
                final sessionId = int.parse(state.pathParameters['sessionId']!);
                final String participantEmail = state.pathParameters['participantEmail']!;
                final String sessionName = state.pathParameters['sessionName']!;
                final meetingId = int.parse(state.pathParameters['meetingId']!);


                return GeofenceTest(sessionId: sessionId, participantEmail: participantEmail, sessionName: sessionName,
                  meetingId: meetingId,);
              },
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: '/supervisor/:supervisorEmail',
      builder: (BuildContext context, GoRouterState state) {
        final String supervisorEmail = state.pathParameters['supervisorEmail']!;

        return SupervisorScreen(supervisorEmail: supervisorEmail);
      },
      routes: [
        GoRoute(
          path: 'qr/:sessionId/:meetingId/:xPos/:yPos',
          builder: (BuildContext context, GoRouterState state) {
            final int sessionId = int.parse(state.pathParameters['sessionId']!); // Safely unwrap and convert to int
            final int meetingId = int.parse(state.pathParameters['meetingId']!); // Safely unwrap and convert to int
            final String supervisorEmail = state.pathParameters['supervisorEmail']!;
            final int xPos = int.parse(state.pathParameters['xPos']!);
            final int yPos = int.parse(state.pathParameters['yPos']!);

            return SupervisorQr(sessionId: sessionId, meetingId: meetingId, supervisorEmail: supervisorEmail,
              xPos: xPos, yPos: yPos,
            );
          },
        ),
      ],
    ),
  ],
);


Future<void> main(List<String> args) async {

  if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    final argument = args[2].isEmpty  ? const {} : jsonDecode(args[2]) as Map<String, dynamic>;

    runApp(MeetingDashboard(sessionId: argument['args1'] as int, meetingId: argument['args2'] as int, windowId: windowId,));
  }
  else {
    if (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows) {
      WidgetsFlutterBinding.ensureInitialized();
      await windowManager.ensureInitialized();

      windowManager.setSize(Size(1200, 800));
      windowManager.setAlwaysOnTop(true);
      windowManager.center();
    }
    runApp(const MyApp());
  }

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}