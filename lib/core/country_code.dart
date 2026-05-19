class CountryCode {
  final String name;
  final String code;
  final String countryCode;
  final int mobileLength;
  final RegExp? regex;

  CountryCode({
    required this.name,
    required this.code,
    required this.countryCode,
    required this.mobileLength,
    this.regex,
  });
}

final List<CountryCode> countryList = [
  CountryCode(
    name: "Afghanistan",
    code: "+93",
    countryCode: "AF",
    mobileLength: 9,
    regex: RegExp(r'^\d{9}$'),
  ),
  CountryCode(
    name: "Albania",
    code: "+355",
    countryCode: "AL",
    mobileLength: 9,
    regex: RegExp(r'^\d{9}$'),
  ),
  CountryCode(
    name: "Algeria",
    code: "+213",
    countryCode: "DZ",
    mobileLength: 9,
  ),
  CountryCode(
    name: "Andorra",
    code: "+376",
    countryCode: "AD",
    mobileLength: 6,
  ),
  CountryCode(name: "Angola", code: "+244", countryCode: "AO", mobileLength: 9),
  CountryCode(
    name: "Argentina",
    code: "+54",
    countryCode: "AR",
    mobileLength: 10,
  ),
  CountryCode(
    name: "Armenia",
    code: "+374",
    countryCode: "AM",
    mobileLength: 8,
  ),
  CountryCode(
    name: "Australia",
    code: "+61",
    countryCode: "AU",
    mobileLength: 9,
  ),
  CountryCode(
    name: "Austria",
    code: "+43",
    countryCode: "AT",
    mobileLength: 10,
  ),
  CountryCode(
    name: "Azerbaijan",
    code: "+994",
    countryCode: "AZ",
    mobileLength: 9,
  ),
  CountryCode(
    name: "Bahrain",
    code: "+973",
    countryCode: "BH",
    mobileLength: 8,
  ),
  CountryCode(
    name: "Bangladesh",
    code: "+880",
    countryCode: "BD",
    mobileLength: 10,
  ),
  CountryCode(
    name: "Belarus",
    code: "+375",
    countryCode: "BY",
    mobileLength: 9,
  ),
  CountryCode(name: "Belgium", code: "+32", countryCode: "BE", mobileLength: 9),
  CountryCode(name: "Bhutan", code: "+975", countryCode: "BT", mobileLength: 8),
  CountryCode(
    name: "Bolivia",
    code: "+591",
    countryCode: "BO",
    mobileLength: 8,
  ),
  CountryCode(
    name: "Bosnia and Herzegovina",
    code: "+387",
    countryCode: "BA",
    mobileLength: 8,
  ),
  CountryCode(
    name: "Botswana",
    code: "+267",
    countryCode: "BW",
    mobileLength: 8,
  ),
  CountryCode(name: "Brazil", code: "+55", countryCode: "BR", mobileLength: 11),
  CountryCode(name: "Brunei", code: "+673", countryCode: "BN", mobileLength: 7),

  // Example with regex
  CountryCode(
    name: "India",
    code: "+91",
    countryCode: "IN",
    mobileLength: 10,
    regex: RegExp(r'^[6-9]\d{9}$'),
  ),

  CountryCode(
    name: "Pakistan",
    code: "+92",
    countryCode: "PK",
    mobileLength: 10,
    regex: RegExp(r'^3\d{9}$'),
  ),

  CountryCode(
    name: "Saudi Arabia",
    code: "+966",
    countryCode: "SA",
    mobileLength: 9,
    regex: RegExp(r'^5\d{8}$'),
  ),

  CountryCode(
    name: "United Arab Emirates",
    code: "+971",
    countryCode: "AE",
    mobileLength: 9,
    regex: RegExp(r'^5\d{8}$'),
  ),

  CountryCode(
    name: "United Kingdom",
    code: "+44",
    countryCode: "GB",
    mobileLength: 10,
    regex: RegExp(r'^\d{10}$'),
  ),

  CountryCode(
    name: "United States",
    code: "+1",
    countryCode: "US",
    mobileLength: 10,
    regex: RegExp(r'^\d{10}$'),
  ),
];
