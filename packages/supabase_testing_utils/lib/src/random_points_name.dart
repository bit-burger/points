import 'package:faker/faker.dart';

extension RandomPointsName on Faker {
  String randomPointsName() {
    late String name;
    do {
      name = person.firstName().toLowerCase();
    } while (name.length > 8);
    return name;
  }
}
