import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ey_testapp/cubits/airport_cubit.dart';
import 'package:flutter_ey_testapp/data/api/dio_client.dart';
import 'package:flutter_ey_testapp/data/repositories/airport_repository.dart';
import 'package:flutter_ey_testapp/screens/home_screen.dart';
import 'package:flutter_ey_testapp/services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage (Hive)
  final localStorageService = LocalStorageService();
  await localStorageService.initializeHive();

  runApp(MyApp(localStorageService: localStorageService));
}

class MyApp extends StatelessWidget {
  final LocalStorageService localStorageService;

  const MyApp({super.key, required this.localStorageService});

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    final dioClient = DioClient();
    final airportRepository = AirportRepository(dioClient: dioClient);

    return MaterialApp(
      title: 'Airport Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => AirportCubit(
          airportRepository: airportRepository,
          localStorageService: localStorageService,
        ),
        child: const HomeScreen(),
      ),
    );
  }
}
