import 'package:chat_app/Features/Chat/data/dataSource/chat_remote_data_source.dart';
import 'package:chat_app/Features/Chat/data/repositories/chat_repository_impl.dart';
import 'package:chat_app/Features/Chat/domain/repositories/chat_repository.dart';
import 'package:chat_app/Features/Chat/domain/usecases/get_messages_use_case.dart';
import 'package:chat_app/Features/Chat/domain/usecases/send_message_use_case.dart';
import 'package:chat_app/Features/Chat/presentation/bloc/chat_bloc.dart';
import 'package:chat_app/Features/recents%20Screen/data/dataSources/remote_recents_data_source.dart';
import 'package:chat_app/Features/recents%20Screen/data/repositories/recents_repository_impl.dart';
import 'package:chat_app/Features/recents%20Screen/domain/services/call_log_filtering_service.dart';
import 'package:chat_app/Features/recents%20Screen/domain/services/format_service.dart';
import 'package:chat_app/Features/recents%20Screen/domain/useCases/delete_call_log_usecase.dart';
import 'package:chat_app/Features/recents%20Screen/domain/useCases/filter_call_logs_usecase.dart';
import 'package:chat_app/Features/recents%20Screen/domain/useCases/get_call_logs_usecase.dart';
import 'package:chat_app/Features/recents%20Screen/presentation/bloc/recents_bloc.dart';
import 'package:chat_app/Features/recents%20Screen/repositories/recents_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(
    () => http.Client()
  );
  sl.registerLazySingleton(()=>
  FirebaseAuth.instance
  );
  sl.registerLazySingleton(()=>
  FirebaseFirestore.instance
  );
   sl.registerLazySingleton<ChatRemoteDataSource>(
    ()=>ChatRemoteDataSourceImpl(firestore:sl())
  );
  sl.registerLazySingleton<RemoteRecentsDataSource>(
    () => RemoteRecentsDataSourceImpl(client: sl())
  );

  sl.registerLazySingleton<RecentsRepository>(
    () => RecentsRepositoryImpl(remoteRecentsDataSource: sl())
  );

 

  /// Use cases
  sl.registerLazySingleton(
    () => GetCallLogsUseCase(sl())
  );

  sl.registerLazySingleton(
    () => FilterCallLogsUseCase()
  );

  sl.registerLazySingleton(
    () => DeleteCallLogUseCase(sl())
  );

  /// Services
  sl.registerLazySingleton(
    () => FormatService()
  );

  sl.registerLazySingleton(
    () => CallLogFilteringService()
  );

  /// BLoC
  sl.registerFactory(
    () => RecentsBloc(
      getCallLogsUsecase: sl(),
      filterCallLogsUseCase: sl(),
      deleteCallLogUseCase: sl(),
    )
  );
//chat screen

//repository

sl.registerLazySingleton<ChatRepository>(
  ()=>ChatRepositoryImpl(remoteDataSource: sl())
);
//usecase
  sl.registerLazySingleton(
 ()=> GetMessagesUseCase(sl())
  );
    sl.registerLazySingleton(
  ()=> SendMessageUseCase(sl())
  );

  sl.registerFactory(()=>ChatBloc(
    getMessagesUseCase:sl(),
    sendMessageUseCase:sl(),
  ));
}
