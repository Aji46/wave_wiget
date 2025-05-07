// import 'package:get_it/get_it.dart';
// import 'package:medicine_search_engine/core/network/dio_client/client_switcher.dart';
// import 'package:medicine_search_engine/core/network/service/api_service.dart';
// import 'package:medicine_search_engine/core/network/service/dio_api_service.dart';
// import 'package:medicine_search_engine/core/services/shared_preferences_service.dart';
// import 'package:medicine_search_engine/core/session/session_manager_factory.dart';
// import 'package:medicine_search_engine/features/dosage_form/data/repository/dosage_form_repo_imp.dart';
// import 'package:medicine_search_engine/features/dosage_form/domain/repository/dosage_form_repo.dart';
// import 'package:medicine_search_engine/features/dosage_form/domain/usecases/dosage_form_usecases.dart';
// import 'package:medicine_search_engine/features/dosage_form/presentation/view_model/dosage_form_cubit.dart';
// import 'package:medicine_search_engine/features/generic_form/data/repository/generic_medicine_repo_imp.dart';
// import 'package:medicine_search_engine/features/generic_form/domain/repository/generic_medicine_repository.dart';
// import 'package:medicine_search_engine/features/generic_form/domain/usecases/generic_medicine_usecases.dart';
// import 'package:medicine_search_engine/features/generic_form/presentation/view_model/generic_form_cubit.dart';
// import 'package:medicine_search_engine/features/ingredient/data/repository/ingredient_repo_imp.dart';
// import 'package:medicine_search_engine/features/ingredient/domain/repository/ingredient_repository.dart';
// import 'package:medicine_search_engine/features/ingredient/domain/usecases/ingredient_usecases.dart';
// import 'package:medicine_search_engine/features/ingredient/presentation/view_model/ingredients_cubit.dart';
// import 'package:medicine_search_engine/features/init/presentation/view_model/init_cubit.dart';
// import 'package:medicine_search_engine/features/spm_category/data/repository/spm_category_repo_imp.dart';
// import 'package:medicine_search_engine/features/spm_category/domain/repository/spm_category_repository.dart';
// import 'package:medicine_search_engine/features/spm_category/domain/usecases/spm_category_usecases.dart';
// import 'package:medicine_search_engine/features/spm_category/presentation/view_model/spm_category_cubit.dart';
// import 'package:medicine_search_engine/features/therapeutic_main_category/data/repositories/thera_main_category_repo_imp.dart';
// import 'package:medicine_search_engine/features/therapeutic_main_category/domain/repositories/ts_main_catogory_repository.dart';
// import 'package:medicine_search_engine/features/therapeutic_main_category/domain/usecases/ts_main_catogory_usecases.dart';
// import 'package:medicine_search_engine/features/therapeutic_main_category/presentation/view_model/thera_main_catogory_cubit.dart';
// import 'package:medicine_search_engine/features/therapeutic_sub_category/data/repositories/thera_sub_category_repo_imp.dart';
// import 'package:medicine_search_engine/features/therapeutic_sub_category/domain/repositories/thera_sub_catogory_repository.dart';
// import 'package:medicine_search_engine/features/therapeutic_sub_category/domain/usecases/thera_sub_category_usecases.dart';
// import 'package:medicine_search_engine/features/therapeutic_sub_category/presentation/view_model/thera_sub_category_cubit.dart';
// import 'package:medicine_search_engine/features/unit_master/data/repository/unit_masrt_repo_imp.dart';
// import 'package:medicine_search_engine/features/unit_master/domain/repository/unit_master_repository.dart';
// import 'package:medicine_search_engine/features/unit_master/domain/usecases/unit_master_usecases.dart';
// import 'package:medicine_search_engine/features/unit_master/presentation/view_model/unit_master_cubit.dart';
// import 'package:medicine_search_engine/shared/widgets/snackbar.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:test_widget/core/network/dio_client/web_dio_client.dart';
// import 'package:test_widget/core/session/local_session_manager.dart';

// Future<void> injectDependencies() async {
//   final serviceLocator = GetIt.I;
//   final sessionManager = SessionManagerImpl();
//   sessionManager.printPlatform();
//   final dioClinet = DioClientImpl();

//   final prefs = await SharedPreferences.getInstance();
//   final sharedPreferenceService = SharedPreferencesService(prefs);

//   // Helper function to register repositories as lazy singletons
//   void registerRepository<TRepo extends Object, TImpl extends TRepo>(TImpl Function(IApiService) factory) {
//     serviceLocator.registerLazySingleton<TRepo>(() => factory(GetIt.I<IApiService>()));
//   }

// // Helper function to register use cases as lazy singletons
//   void registerUseCase<TUseCase extends Object, TRepo extends Object>(TUseCase Function(TRepo) factory) {
//     serviceLocator.registerLazySingleton<TUseCase>(() => factory(GetIt.I<TRepo>()));
//   }

// // Helper function to register cubits as factories (since Cubits are usually short-lived)
//   void registerCubit<TCubit extends Object, TUseCase extends Object>(TCubit Function(TUseCase) factory) {
//     serviceLocator.registerLazySingleton<TCubit>(() => factory(GetIt.I<TUseCase>()));
//   }

//   // Register core services
//   serviceLocator.registerSingleton<NotificationManager>(NotificationManager());
//   serviceLocator.registerFactory<IApiService>(() => DioApiService(dioClinet));

//   // Register repositories
//   registerRepository<DosageFormRepository, DosageFormRepoImp>((api) => DosageFormRepoImp(apiService: api));

//   registerRepository<SpmCatogoryRepository, SpmCatogoryRepoImp>((api) => SpmCatogoryRepoImp(apiService: api));
//   registerRepository<TheraSubCategoryRepository, TheraSubCategoryRepoImp>((api) => TheraSubCategoryRepoImp(apiService: api));
//   registerRepository<TsMainCatogoryRepository, TheraMainCategoryRepoImp>((api) => TheraMainCategoryRepoImp(apiService: api));
//   registerRepository<IngredientRepository, IngredientRepoImp>((api) => IngredientRepoImp(apiService: api));
//   registerRepository<UnitMasterRepository, UnitMasterRepoImp>((api) => UnitMasterRepoImp(apiService: api));
//   registerRepository<GenericMedicineRepository, GenericMedicineRepoImp>((api) => GenericMedicineRepoImp(apiService: api));

//   //registerRepository<PermissionRepository, PermissionsRepostoryImpl>((api) => PermissionsRepostoryImpl(apiService: api));

//   // Register use cases
//   registerUseCase<SpmCatogoryUsecases, SpmCatogoryRepository>((repo) => SpmCatogoryUsecases(repository: repo));
//   registerUseCase<TheraSubCategoryUsecases, TheraSubCategoryRepository>((repo) => TheraSubCategoryUsecases(repository: repo));
//   registerUseCase<TsMainCatogoryUsecases, TsMainCatogoryRepository>((repo) => TsMainCatogoryUsecases(repository: repo));
//   registerUseCase<DosageFormUsecases, DosageFormRepository>((repo) => DosageFormUsecases(repository: repo));
//   registerUseCase<IngredientUsecases, IngredientRepository>((repo) => IngredientUsecases(repository: repo));
//   registerUseCase<UnitMasterUsecases, UnitMasterRepository>((repo) => UnitMasterUsecases(repository: repo));
//   registerUseCase<GenericMedicineUseCases, GenericMedicineRepository>((repo) => GenericMedicineUseCases(repository: repo));

//   //registerUseCase<PermissionUsecase, PermissionRepository>((repo) => PermissionUsecase(repository: repo));

//   // Register cubits
//   registerCubit<SpmCategoryCubit, SpmCatogoryUsecases>((useCase) => SpmCategoryCubit(useCase));
//   registerCubit<TheraSubCategoryCubit, TheraSubCategoryUsecases>((useCase) => TheraSubCategoryCubit(useCase));
//   registerCubit<TheraMainCatogoryCubit, TsMainCatogoryUsecases>((useCase) => TheraMainCatogoryCubit(useCase));
//   registerCubit<DosageFormCubit, DosageFormUsecases>((useCase) => DosageFormCubit(useCase));
//   registerCubit<IngredientCubit, IngredientUsecases>((useCase) => IngredientCubit(useCase));
//   registerCubit<UnitMasterCubit, UnitMasterUsecases>((useCase) => UnitMasterCubit(useCase));
//   registerCubit<GenericFormCubit, GenericMedicineUseCases>((useCase) => GenericFormCubit(
//       dosageFormUsecases: serviceLocator<DosageFormUsecases>(),
//       ingredientUsecases: serviceLocator<IngredientUsecases>(),
//       spmCatogoryUsecases: serviceLocator<SpmCatogoryUsecases>(),
//       theraSubCategoryUsecases: serviceLocator<TheraSubCategoryUsecases>(),
//       tsMainCatogoryUsecases: serviceLocator<TsMainCatogoryUsecases>(),
//       unitMasterUsecases: serviceLocator<UnitMasterUsecases>(),
//       useCases: useCase));

//   // registerCubit<PermissionCubit, PermissionUsecase>((useCase) => PermissionCubit(useCase));

//   // Specialized registrations
//   serviceLocator.registerFactory<InitCubit>(() => InitCubit());
//   // serviceLocator.registerFactory<GenericFormCubit>(() => GenericFormCubit(repository: serviceLocator<GenericMedicineRepository>(),useCases: serviceLocator<GenericMedicineUseCases>()));
//   // serviceLocator.registerFactory<GenericMedicineRepository>(() => GenericMedicineRepoImp(apiService: serviceLocator<IApiService>()));
// }
