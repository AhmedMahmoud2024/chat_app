 import 'package:local_auth/local_auth.dart';
  import 'package:local_auth_android/local_auth_android.dart';
 class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();
//is device support biometric 
Future<bool> isDeviceSupported() async {
return await auth.isDeviceSupported();
}
//check implementation
Future<bool> authenticate() async {
try{
  bool authenticated = await auth.authenticate(
    localizedReason: 'Please authenticate biometric to access the app',
  authMessages: const <AuthMessages>[
    AndroidAuthMessages(
      signInTitle: 'Biometric Authentication required',
    )
  ]
  
  );
  
  return authenticated;
}catch(e){
print(e.toString());
return false ;
}
}
}