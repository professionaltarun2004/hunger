// ignore_for_file: unnecessary_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'routes/app_router.dart';
import 'package:flutter/foundation.dart';
import 'utils/responsive_utils.dart';

// Environment configuration
const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://subfggmfnkhrmissnwfo.supabase.co');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN1YmZnZ21mbmtocm1pc3Nud2ZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg4ODg5NzcsImV4cCI6MjA2NDQ2NDk3N30.kxqgol4-2C4ZfnBb9GNJWvcutsKprQ1g8wou27wzyp0');

void main() async {
  // Catch and log uncaught exceptions
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Uncaught Flutter Error: ${details.exception}');
    debugPrint('Stack Trace: ${details.stack}');
  };

  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with error handling
  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Failed to initialize Supabase: $e');
    // Show error dialog or handle initialization failure
    return;
  }

  // Set preferred orientations with error handling
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    debugPrint('Failed to set preferred orientations: $e');
  }

  // Run the app with error boundary
  runZonedGuarded(() {
    runApp(const ProviderScope(child: MyApp()));
  }, (error, stack) {
    debugPrint('Uncaught error: $error');
    debugPrint('Stack trace: $stack');
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 12 Pro size as baseline
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: ThemeData(
            primaryColor: Colors.redAccent,
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: Colors.black,
            cardTheme: CardTheme(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            textTheme: TextTheme(
              bodyLarge: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
              ),
              bodyMedium: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
              ),
              bodySmall: TextStyle(
                color: Colors.white70,
                fontSize: 12.sp,
              ),
              titleLarge: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20.sp,
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.black,
              elevation: 4,
              titleTextStyle: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
              iconTheme: IconThemeData(
                color: Colors.white,
                size: 24.w,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE23744),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                textStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.grey[600]!,
                  width: 1.w,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                textStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
            snackBarTheme: SnackBarThemeData(
              backgroundColor: const Color(0xFFE23744),
              contentTextStyle: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              behavior: SnackBarBehavior.floating,
              insetPadding: EdgeInsets.all(16.w),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.black,
              selectedItemColor: const Color(0xFFE23744),
              unselectedItemColor: Colors.grey[600],
              type: BottomNavigationBarType.fixed,
              elevation: 8,
              selectedLabelStyle: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
              unselectedLabelStyle: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 11.sp,
              ),
            ),
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFFE23744),
              secondary: Colors.white,
              surface: Colors.grey[900]!,
              background: Colors.black,
              onPrimary: Colors.white,
              onSecondary: Colors.black,
              onSurface: Colors.white,
              onBackground: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
