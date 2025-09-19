
import 'dart:async';

// import 'package:chatter_chatapp/Data/models/user_model.dart';
import 'package:chatter_chatapp/Data/reposetory/auth_repository.dart';
import 'package:chatter_chatapp/Logic/cubit/auth/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthReposatory _authReposatory;
  StreamSubscription<User?>? _authStateSubscription;

  AuthCubit({
    required AuthReposatory authReposatory,
  })  : _authReposatory = authReposatory,
        super(const AuthState()) {
    _init();
  }

  void _init() {
    emit(state.copyWith(status: AuthStatus.initial));
    _authStateSubscription = _authReposatory.authStateChanges.listen((user) async {
      if (user != null) {
        try {
          final userData = await _authReposatory.getUserData(user.uid);
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: userData,
          ));
        } catch (e) {
          emit(state.copyWith(
            status: AuthStatus.error,
            error: e.toString(),
          ));
        }
      } else {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
        ));
      }
    });
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final user = await _authReposatory.signIn(
        email: email,
        password: password,
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> signUp({
    required String fullName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final user = await _authReposatory.signUp(
        fullName: fullName,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> signOut() async {
    try {
      await _authReposatory.signOut();
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}