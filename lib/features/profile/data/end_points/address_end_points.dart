class AddressEndPoints{
  static String listAllAddress() => "/patient/addresses";
  static String createAddress = "/patient//addresses";
  static String updateAddress({required String id}) => "/patient/addresses/$id";
  static String deleteAddress({required String id}) => "/patient/addresses/$id";
  static String showAddress({required String id}) => "/patient/addresses/$id";
}
