import 'package:chatter_chatapp/Data/reposetory/auth_repository.dart';
import 'package:chatter_chatapp/Data/reposetory/chat_repository.dart';
import 'package:chatter_chatapp/Data/reposetory/contact_repository.dart';
import 'package:chatter_chatapp/Logic/cubit/auth/auth_cubit.dart';
import 'package:chatter_chatapp/Logic/cubit/chat/chat_cubit.dart';
import 'package:chatter_chatapp/router/app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:chatter_chatapp/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

final getIt = GetIt.instance;

Future<void> setupserviceLocator() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  getIt.registerLazySingleton(() => AppRouter());
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => AuthReposatory());
  getIt.registerLazySingleton(()=> ContactRepository());
  getIt.registerLazySingleton(() => AuthCubit(authReposatory: AuthReposatory()));

  getIt.registerFactory(() => ChatCubit(chatRepository: ChatRepository(), currentUserId: getIt<FirebaseAuth>().currentUser!.uid,));   
  getIt.registerLazySingleton(() => ChatRepository());

  

}