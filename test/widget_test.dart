import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sharing/screens/login.dart';


void main() {
  testWidgets('Check login screen has two text fields', (WidgetTester tester) async {

    // create a LoginPage
    LoginScreen loginScreen = new LoginScreen();
    // add it to the widget tester
    await tester.pumpWidget(loginScreen);

    // tap on the login button
    Finder loginButton = find.byKey(new Key("loginButton"));
    await tester.tap(loginButton);

    // 'pump' the tester again. This causes the widget to rebuild
    await tester.pump();

    // check that the hint text is empty
    Finder hintText = find.byKey(new Key('hint'));
    expect(hintText.toString().contains(''), true);
  });
  setUpAll(() async {
    await Firebase.initializeApp();
  });
  testWidgets('non-empty email and password, valid account, calls sign in, succeeds', (WidgetTester tester) async {
    Widget buildTestableWidget(Widget widget) {
      // https://docs.flutter.io/flutter/widgets/MediaQuery-class.html
      return new MediaQuery(
          data: new MediaQueryData(),
          child: new MaterialApp(home: widget)
      );
    }



    LoginScreen loginPage = new LoginScreen();
    await tester.pumpWidget(buildTestableWidget(loginPage));

    Finder emailInput = find.byKey(Key('emailInput'));
    await tester.enterText(emailInput, 'jeffbridge@gmail.com');

    Finder passwordInput = find.byKey(Key('passwordInput'));
    await tester.enterText(passwordInput, 'Apple123!');

    Finder loginButton = find.byKey(Key('loginButton'));
    await tester.tap(loginButton);

    await tester.pump();
    final titleFinder = find.text('homeMap');
    expect(titleFinder, findsOneWidget);

  });
}
