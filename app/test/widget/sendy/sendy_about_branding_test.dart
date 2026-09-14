import 'package:flutter_test/flutter_test.dart';
import 'package:localsend_app/config/sendy/sendy_identity.dart';

void main() {
  test('French About heading names Sendy', () {
    expect(SendyIdentity.aboutTitle('À propos de LocalSend'), 'À propos de Sendy');
  });
  test('Brand substitution preserves the rest of the localized heading', () {
    expect(SendyIdentity.aboutTitle('About LocalSend'), 'About Sendy');
    expect(SendyIdentity.aboutTitle('Über LocalSend'), 'Über Sendy');
    expect(SendyIdentity.aboutTitle('À propos'), 'À propos');
    expect(SendyIdentity.aboutTitle('About Sendy'), 'About Sendy');
    expect(SendyIdentity.aboutTitle('About localsend'), 'About Sendy');
  });
  test('The Sendy developer label is consistent between pages', () {
    expect(SendyIdentity.developerLabel(french: true), 'Développé par Metoushela Walker');
    expect(SendyIdentity.developerLabel(french: false), 'Developed by Metoushela Walker');
  });
}
