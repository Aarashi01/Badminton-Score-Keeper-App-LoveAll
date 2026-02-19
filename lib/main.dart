import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/match_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const BadmintonScoreApp());
}

class BadmintonScoreApp extends StatelessWidget {
  const BadmintonScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MatchProvider(),
      child: MaterialApp.router(
        title: 'Badminton Score Keeper',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppColors.bg,
          useMaterial3: true,
          cardTheme: CardThemeData(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surfaceAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 1),
            ),
          ),
          segmentedButtonTheme: SegmentedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primary.withValues(alpha: 0.12);
                }
                return AppColors.surfaceAlt;
              }),
              foregroundColor: WidgetStateProperty.all(AppColors.textPrimary),
              side: WidgetStateProperty.all(BorderSide.none),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          dividerColor: AppColors.line,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
