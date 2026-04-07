import 'package:flutter/material.dart';
import 'app.dart';
import 'injection_container.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDependencies();

  final authBloc = getIt<AuthBloc>();
  authBloc.add(CheckAuthStatusEvent());

  runApp(const App());
}
