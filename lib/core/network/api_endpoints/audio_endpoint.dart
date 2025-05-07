

import 'package:test_widget/core/constants/constants.dart';

class AudioEndpoints {
  static const String getallAudio= "$port/$modulePath/Audio/all";
  static const String filestructure= "$port/$modulePath/FileExplorer/filestructure";
  static const String completedFiles= "$port/$modulePath/FileExplorer/completed-files"; 
  static const String getbyprocessedGuid= "$port/$modulePath/FileExplorer/GetbyprocessedGuid/"; 


 // "http://localhost:/api/Audio/all"




  static const String updateGenericMedicineUrl = "$port/$modulePath/GenericMedicine/update";
  static String fetchGenericMedicineUrl(int id) => "$port/$modulePath/GenericMedicine/$id";
  static String updateComposition = "$port/$modulePath/GenericMedicine/compositions/update";
  static String addSpmCategories = "$port/$modulePath/GenericMedicine/spm-category-details";
  static String deleteSpmCategories = "$port/$modulePath/GenericMedicine/spm-category-details";
  static String addDosageForm = "$port/$modulePath/DosageFormDetail/create-generic-medicine-detail";
  static String updateDosageForm = "$port/$modulePath/DosageFormDetail/update-generic-medicine-detail";
  static String addBrand = "$port/$modulePath/DosageFormDetail/add-brand-name";
  //update the brand
  static String editBrand = "$port/$modulePath/DosageFormDetail/update-brand-name";
  //
  static String removeBrand = "$port/$modulePath/DosageFormDetail/delete-brand-by-id";
  static String removeDosageForm(int id) => "$port/$modulePath/DosageFormDetail/delete-dosage-form/$id";
  static String saveGenericMedicine(int id) => "$port/$modulePath/GenericMedicine/save-generic-medicine/$id";
}
