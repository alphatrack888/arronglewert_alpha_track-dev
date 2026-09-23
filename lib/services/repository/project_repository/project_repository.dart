import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/screens/home_screen/models/all_project_models.dart';
import 'package:alpha_track/screens/home_screen/models/single_project_model.dart';
import 'package:alpha_track/services/api/api_services.dart';

import '../../storage_services/storage_services.dart';

class ProjectRepository {
  ApiServices apiServices = ApiServices.instance;
  StorageServices storageServices = StorageServices.instance;
  

  //! Get all project
  Future<AllProjectModel> getAllProject() async {
    try {
      final token = await storageServices.getAccessToken();
      final response = await apiServices.apiGetServices(
        ApiUrls.allProject,
        statusCode: 200,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response != null) {
        return AllProjectModel.fromJson(response);
      }
      return AllProjectModel();
    } catch (e) {
      return AllProjectModel();
    }
  }

  //! Get Single Project
  Future<SingleProjectModel> getSingleProject(String id) async {
    try {
      final response = await apiServices.apiGetServices(
        ApiUrls.singleProject + id,
        statusCode: 200,
      );
      if (response != null) {
        return SingleProjectModel.fromJson(response);
      }
      return SingleProjectModel();
    } catch (e) {
      return SingleProjectModel();
    }
  }

  
}