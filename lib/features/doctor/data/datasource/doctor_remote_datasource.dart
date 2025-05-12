import 'package:medizen_app/base/services/network/network_client.dart';


abstract class DoctorRemoteDataSource {
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final NetworkClient networkClient;

  DoctorRemoteDataSourceImpl({required this.networkClient});

}
