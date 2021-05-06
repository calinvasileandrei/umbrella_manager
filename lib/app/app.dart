// Copyright (c) 2021, Calin Vasile Andrei
// www.calinandrei.com
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/material.dart';
import 'package:umbrella_manager/core/app_constants.dart';
import 'package:umbrella_manager/core/app_theme/app_theme.dart';
import 'package:umbrella_manager/core/app_theme/cubit/theme_cubit.dart';
import 'package:umbrella_manager/core/repositories/auth_repository.dart';
import 'package:umbrella_manager/pages/login/cubit/login_cubit.dart';
import 'package:umbrella_manager/pages/login/view/login_page.dart';
import 'package:umbrella_manager/pages/splash_screen/view/splash_screen_page.dart';
import 'package:umbrella_manager/routing/router.dart' as router;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umbrella_manager/tad_widgets/view/tab_bar/tab_bar_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class AppInitializer extends StatelessWidget {
  final AuthRepository authRepository = AuthRepository();
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
        BlocProvider<LoginCubit>(
          create: (context) => LoginCubit(authRepository),
        ),
      ],
      child: ScreenUtilInit(
          allowFontScaling: false,
          designSize: Size(1125, 2436),
          builder: () => const App()),
    );
  }
}

class App extends StatefulWidget {
  const App({Key key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  bool activeSplashScreen= true;

  ///Start 2 seconds await for the splashscreen
  initSplashScreen() async{
    await Future.delayed(const Duration(seconds: 1), (){
      setState(() {
        activeSplashScreen = false;
      });
    });
  }

  @override
  void initState() {
    initSplashScreen();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  ///Listen for theme changes
  @override
  void didChangePlatformBrightness() {
    context.read<ThemeCubit>().updateAppTheme();
    super.didChangePlatformBrightness();
  }

  ///Dispose the listener for the theme changes
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return  MaterialApp(
              title: appName,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: context.select((ThemeCubit themeCubit) => themeCubit.state.themeMode),
              onGenerateRoute: router.generateRoute,
              navigatorKey: navigatorKey,
              home: AnimatedSwitcher(
                        duration: Duration(milliseconds: 500),
                        child:_buildUI(state,context)
                      ),
            );
      },
    );
  }


  Widget _buildUI(LoginState state, BuildContext context){
    //If the user is uninitialized (Retrieving the data of the user is an async method) or the splashscreen has not finished
    if (state.status == LoginStatus.Uninitialized || activeSplashScreen) {
      return SplashScreenPage();
      //If the user successfully authenticated
    } else if (state.status == LoginStatus.Authenticated) {
      return  TabBarController();
    } else {
      //If the user has to login
      return LoginPage();
    }

  }
}
