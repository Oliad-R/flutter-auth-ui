import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import 'constants.dart';

class PhoneSignUp extends StatelessWidget {
  const PhoneSignUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Phone Sign Up'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SupaPhoneAuth(
              authAction: SupaAuthAction.signUp,
              onSuccess: (response) {
                // Navigator.of(context).pushReplacementNamed('/verify_phone');
              },
            ),
            // TextButton(
            //   child: const Text(
            //     'Already have an account? Sign In',
            //   ),
            //   onPressed: () {
            //     Navigator.of(context).pushNamed('/phone_sign_in');
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
