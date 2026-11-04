part of 'admin_customer_address_create_form.dart';

/// Controllers owned by the focused customer-address form.
final class _AdminCustomerAddressControllers {
  /// Creates empty source fields.
  _AdminCustomerAddressControllers()
      : addressName = TextEditingController(),
        line1 = TextEditingController(),
        line2 = TextEditingController(),
        postalCode = TextEditingController(),
        city = TextEditingController(),
        country = TextEditingController(),
        province = TextEditingController(),
        company = TextEditingController(),
        phone = TextEditingController();

  final TextEditingController addressName;
  final TextEditingController line1;
  final TextEditingController line2;
  final TextEditingController postalCode;
  final TextEditingController city;
  final TextEditingController country;
  final TextEditingController province;
  final TextEditingController company;
  final TextEditingController phone;

  /// Releases every field controller together.
  void dispose() {
    addressName.dispose();
    line1.dispose();
    line2.dispose();
    postalCode.dispose();
    city.dispose();
    country.dispose();
    province.dispose();
    company.dispose();
    phone.dispose();
  }
}
