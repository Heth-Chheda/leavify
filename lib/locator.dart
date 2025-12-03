import 'package:get_it/get_it.dart';
import 'package:leavify/base/base_view_model.dart';
import 'package:leavify/features/Authentication/viewmodel/login_view_model.dart';
import 'package:leavify/features/Home/viewmodel/announcements_view_model.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:leavify/features/Leave/viewModel/leave_view_model.dart';
import 'package:leavify/features/profile/viewmodel/profile_view_model.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => BaseViewModel());
  locator.registerLazySingleton(() => HomeViewModel());
  locator.registerLazySingleton(() => ProfileViewModel());
  locator.registerLazySingleton(() => AnnouncementViewModel());
  locator.registerLazySingleton(() => LeaveViewModel());
  locator.registerLazySingleton(() => LoginViewModel());
}
