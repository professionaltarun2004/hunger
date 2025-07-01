import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final User? currentUser;
  final String? errorMessage;

  AuthState({this.currentUser, this.errorMessage});

  AuthState copyWith({User? currentUser, String? errorMessage}) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _init();
  }

  final _supabase = Supabase.instance.client;

  void _init() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final User? user = data.session?.user;
      debugPrint('Auth State Changed: User is ${user != null ? user.id : 'null'}');
      state = state.copyWith(currentUser: user, errorMessage: null);

      if (user != null) {
        // Ensure a profile exists in the 'users' table
        await _createUserProfile(user);
      }
    });
  }

  Future<void> _createUserProfile(User user) async {
    try {
      debugPrint('Attempting to create user profile for user ID: ${user.id}');
      // Check if the user already exists in your 'users' table
      final response = await _supabase.from('users').select().eq('id', user.id);

      if (response.isEmpty) {
        debugPrint('User profile not found for ${user.id}. Creating new entry.');
        // User does not exist, create a new entry
        await _supabase.from('users').insert({
          'id': user.id,
          'email': user.email,
          'name': user.userMetadata?['full_name'] ?? user.email?.split('@').first ?? 'User',
          'is_veg_only': false, // Default value
        });
        debugPrint('User profile created successfully for ${user.id}');
      } else {
        debugPrint('User profile already exists for ${user.id}.');
      }
    } catch (e, stackTrace) {
      debugPrint('Error in _createUserProfile for user ID ${user.id}: $e');
      debugPrint('Stack Trace: $stackTrace');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(errorMessage: null);
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            'com.example.hunger://login-callback', // Should already be updated
      );
      // _createUserProfile will be called by onAuthStateChange listener
    } on AuthException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(errorMessage: 'An unexpected error occurred: $e');
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      state = state.copyWith(errorMessage: null);
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // _createUserProfile will be called by onAuthStateChange listener
    } on AuthException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(errorMessage: 'An unexpected error occurred: $e');
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      state = state.copyWith(errorMessage: null);
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        debugPrint('Sign up successful for user ID: ${res.user!.id}. Calling _createUserProfile.');
        await _createUserProfile(res.user!); // Create profile after sign-up
      }
      // Optional: If you want to automatically sign in after sign up:
      // await _supabase.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(errorMessage: 'An unexpected error occurred: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      state = AuthState(); // Reset state after sign out
    } on AuthException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(errorMessage: 'An unexpected error occurred: $e');
    }
  }
}
