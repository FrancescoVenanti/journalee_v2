import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journalee/features/shared/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import '../features/auth/screens/auth_screen.dart';
import '../features/journal/screens/journals_screens.dart';
import '../features/entries/screens/entries_screen.dart';
import '../features/entries/screens/create_entry_screen.dart';
import '../features/entries/screens/view_entry_screen.dart';
import '../features/auth/providers/auth_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/auth',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.value != null;
      final isAuthRoute = state.matchedLocation == '/auth';

      // If still loading, don't redirect yet
      if (authState.isLoading) {
        return null;
      }

      if (!isAuthenticated && !isAuthRoute) {
        return '/auth';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/journals';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/journals',
        pageBuilder: (context, state) {
          final isGoingBack = state.uri.queryParameters['goback'] == 'true';

          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: const JournalsScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              if (isGoingBack) {
                // Slide from left when going back from entries
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              } else {
                // Default transition (fade) for other cases
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              }
            },
          );
        },
      ),
      GoRoute(
        path: '/entries/:journalId',
        pageBuilder: (context, state) {
          final journalId = state.pathParameters['journalId']!;
          final isGoingBack = state.uri.queryParameters['goback'] == 'true';

          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: EntriesScreen(journalId: journalId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              if (isGoingBack) {
                // Slide from left when going back from create entry
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              } else {
                // Normal forward transition (slide from right)
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              }
            },
          );
        },
      ),
      GoRoute(
        path: '/create-entry/:journalId',
        pageBuilder: (context, state) {
          final journalId = state.pathParameters['journalId']!;
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: CreateEntryScreen(journalId: journalId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              // Slide from bottom for create entry screen
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                )),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/view-entry/:journalId/:entryId',
        pageBuilder: (context, state) {
          final journalId = state.pathParameters['journalId']!;
          final entryId = state.pathParameters['entryId']!;
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: ViewEntryScreen(journalId: journalId, entryId: entryId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              // Slide from right for view entry screen
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                )),
                child: child,
              );
            },
          );
        },
      ),
    ],
  );
});

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<UserModel?>>(
      authProvider,
      (previous, next) {
        if (previous?.value != next.value) {
          notifyListeners();
        }
      },
    );
  }

  final Ref _ref;
}
