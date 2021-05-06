import 'package:bloc/bloc.dart';
import 'package:umbrella_manager/app/app.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_manager/core/app_toast.dart';
import 'package:umbrella_manager/core/models/user.dart';
import 'package:umbrella_manager/core/repositories/auth_repository.dart';

part 'login_state.dart';

enum LoginStatus { Authenticated, Unauthenticated, Uninitialized }

loadView(context, route) async {
  await Future.delayed(const Duration(seconds: 1), () {
    Navigator.pushNamedAndRemoveUntil(
        context, route, (Route<dynamic> route) => false);
  });
}

class LoginCubit extends Cubit<LoginState> {
  User user;
  final AuthRepository repository;
  LoginStatus status;

  LoginCubit(this.repository) : super(LoginState()) {
    loginOnStartUp();
  }

  Future<void> loginOnStartUp() async {
    emit(LoginState(
        loading: false, user: null, status: LoginStatus.Uninitialized));
    user = await repository.getUser();
    if (user != null) {
      emit(LoginState(
          user: user, status: LoginStatus.Authenticated, loading: false));
    } else {
      emit(LoginState(
          user: null, status: LoginStatus.Unauthenticated, loading: false));
    }
  }

  Future<void> login({Key key, String email, String password}) async {
    emit(LoginState(user: user, status: status, loading: true));
    user = await repository.authenticate(email: email, password: password);

    if (user != null) {
      await repository.persistUser(user);
      emit(LoginState(
          user: user, status: LoginStatus.Authenticated, loading: false));
    } else {
      showToastTop(
          message: 'Credenziali errate!',
          bgColor: Theme.of(navigatorKey.currentContext).backgroundColor);
      emit(LoginState(
          user: null, status: LoginStatus.Unauthenticated, loading: false));
    }
  }

  Future<void> logout() async {
    emit(LoginState(user: user, status: status, loading: true));
    await repository.deleteUser();
    emit(LoginState(
        user: null, status: LoginStatus.Unauthenticated, loading: false));
  }

  bool isAuth() {
    if (user != null && status == LoginStatus.Authenticated) {
      return true;
    }
    return false;
  }
}
