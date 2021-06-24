import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sharing/services/formValidation.dart';
import 'package:ride_sharing/assist/assistant.dart';

void main(){
  group('Validation', () {
    final validation = FormValidation();

    test('Email Test', () {
      expect(validation.validateEmail(""), "Empty Email");
      expect(validation.validateEmail("name.1"), "Not Valid");
      expect(validation.validateEmail('name@email.com'), "Valid");
    });

    test('Password Test', () {
      expect(validation.validatePassword(""), "Empty Password");
      expect(validation.validatePassword("word"), "Too Short");
      expect(validation.validatePassword('password'), "Valid");
    });

  });

}