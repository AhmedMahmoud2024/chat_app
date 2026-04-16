import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver{
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    // TODO: implement onChange
    super.onChange(bloc, change);
    log('Change in ${bloc.runtimeType}: $change');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    // TODO: implement onError
    log('Error in ${bloc.runtimeType}: $error');
    super.onError(bloc, error, stackTrace);
   
  }
}