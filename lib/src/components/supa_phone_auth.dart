import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:supabase_auth_ui/src/utils/constants.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

/// UI component to create a phone + password signin/ signup form
class SupaPhoneAuth extends StatefulWidget {

  /// Method to be called when the auth action is success
  final void Function(AuthResponse response) onSuccess;

  /// Method to be called when the auth action threw an excepction
  final void Function(Object error)? onError;

  const SupaPhoneAuth({
    Key? key,
    required this.onSuccess,
    this.onError,
  }) : super(key: key);

  @override
  State<SupaPhoneAuth> createState() => _SupaPhoneAuthState();
}

class _SupaPhoneAuthState extends State<SupaPhoneAuth> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPass = TextEditingController();

  final _formKey2 = GlobalKey<FormState>();  
  final _code = TextEditingController();

  bool isVerifying = false;
  var phoneNum = '';

  bool _forgotPassword = false;
  var isSigningIn = true;

  var maskFormatter = new MaskTextInputFormatter(
    mask: '+# (###) ###-####', 
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy
  );

  var maskFormatter2 = new MaskTextInputFormatter(
            mask: '######',
            filter: { "#": RegExp(r'[0-9]') },
            type: MaskAutoCompletionType.eager
          );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        if (!(isVerifying)) ...[
          if (!(_forgotPassword)) ...[
            TextFormField(
              keyboardType: TextInputType.phone,
              inputFormatters: [maskFormatter],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is required';
                } else if (!RegExp(r'^\+1 \(\d{3}\) \d{3}-\d{4}$').hasMatch(value)) {
                  return 'Invalid phone number';
                }
                return null;
              },
              decoration: const InputDecoration(
                // prefixIcon: Icon(Icons.phone),
                label: Text('Phone Number'),
              ),
              controller: _phone,
            ),

            spacer(16),

            if (!(isSigningIn)) ...[
              TextFormField(
                validator:Validators.compose([
                    Validators.required('Password is required'),
                    Validators.patternString(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$', 'Password must have:\n\t•\t1 Uppercase\n\t•\t1 Lowercase\n\t•\t1 Number\n\t•\t8 Characters Long')]),
                decoration: const InputDecoration(
                  // prefixIcon: Icon(Icons.key_rounded),
                  label: Text('Password'),
                ),
                obscureText: true,
                controller: _password,
              ),

              spacer(16),

              TextFormField(
                validator: (value) {
                  if (value==null || value.isEmpty){
                    return "Confirm password required";
                  }
                  else if (value!=_password.text){
                    return "Passwords do not match";
                  }  
                  else {
                    return null;
                  }            
                },
                decoration: const InputDecoration(
                  label: Text('Confirm Password'),
                ),
                obscureText: true,
                controller: _confirmPass,
              ),
            ],

            if (isSigningIn) ... [
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password required';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  label: Text('Password'),
                ),
                obscureText: true,
                controller: _password,
              ),
            ],
          
            spacer(16),

            ElevatedButton(
              child: Text(
                isSigningIn ? 'Sign In' : 'Sign Up',
              ),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                try {
                  if (isSigningIn) {
                    final response = await supabase.auth.signInWithPassword(
                      phone: '+'+maskFormatter.getUnmaskedText(),
                      password: _password.text,
                    );
                    widget.onSuccess(response);
                  } else {
                    final response = await supabase.auth.signUp(
                          phone: '+'+maskFormatter.getUnmaskedText(), 
                          password: _password.text
                        );
                    if (!mounted) return;
                    // widget.onSuccess(response);
                    setState(() {
                      isVerifying = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Check text for SMS verification."),
                      )
                    );
                  }
                } on AuthException catch (error) {
                  if (widget.onError == null) {
                    context.showErrorSnackBar(error.message);
                  } else {
                    widget.onError?.call(error);
                  }
                } catch (error) {
                  if (widget.onError == null) {
                    context.showErrorSnackBar(
                      'Unexpected error has occurred: $error');
                  } else {
                    widget.onError?.call(error);
                  }
                }
                setState(() {
                  _phone.text = '';
                  phoneNum = '';
                  _password.text = '';
                  _confirmPass.text = '';
                });
              },
            ),

          spacer(16),

          if (isSigningIn)... [
            TextButton(
              onPressed: () {
                setState(() {
                  _forgotPassword = true;
                });
              },
              child: const Text('Forgot your password?'),
            ),
            TextButton(
              child: const Text(
                'Don\'t have an account? Sign up',
                // style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                setState(() {
                    isSigningIn = !isSigningIn;
                    _forgotPassword = false;
                  });
              },
            ),
          ],

          if (!(isSigningIn)) ... [
            TextButton(
                child: const Text(
                  'Already have an account? Sign in',
                ),
                onPressed: () {
                  setState(() {
                    isSigningIn = !isSigningIn;
                    _forgotPassword = false;
                  });
                },
              ),
          ],
        ],

          spacer(16),

          if (_forgotPassword) ...[
            TextFormField(
              keyboardType: TextInputType.phone,
              inputFormatters: [maskFormatter],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is required';
                } else if (!RegExp(r'^\+1 \(\d{3}\) \d{3}-\d{4}$').hasMatch(value)) {
                  return 'Invalid phone number';
                }
                return null;
              },
              decoration: const InputDecoration(
                // prefixIcon: Icon(Icons.phone),
                label: Text('Phone Number'),
              ),
              controller: _phone,
            ),

            spacer(16),

            ElevatedButton(
              onPressed: () async {
                try {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  // phoneNum = '+'+maskFormatter.getUnmaskedText();
                  // await supabase.auth.resetPasswordForEmail(email);
                  // widget.onPasswordResetEmailSent?.call();
                } on AuthException catch (error) {
                  widget.onError?.call(error);
                } catch (error) {
                  widget.onError?.call(error);
                }
              },
              child: const Text('Send password reset via SMS'),
            ),

            spacer(16),

            TextButton(
              onPressed: () {
                setState(() {
                  _forgotPassword = false;
                });
              },
              child: const Text('Back to Sign in'),
            ),
          ],
        ],

        if (isVerifying) ... [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [maskFormatter2],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the one time code sent';
                    }
                    return null;  
                  },
                  decoration: const InputDecoration(
                    label: Text('Verification Code'),
                  ),
                  controller: _code,
                ),
                spacer(16),
                ElevatedButton(
                  child: const Text(
                    'Verify Phone',
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    try {
                      final response = await supabase.auth.verifyOTP(
                        phone: phoneNum,
                        token: _code.text,
                        type: OtpType.sms,
                      );
                      widget.onSuccess(response);
                    } on AuthException catch (error) {
                      if (widget.onError == null) {
                        context.showErrorSnackBar(error.message);
                      } else {
                        widget.onError?.call(error);
                      }
                    } catch (error) {
                      if (widget.onError == null) {
                        context.showErrorSnackBar(
                            'Unexpected error has occurred: $error');
                      } else {
                        widget.onError?.call(error);
                      }
                    }
                    if (mounted) {
                      setState(() {
                        _code.text = '';
                      });
                    }
                  },
                ),
                spacer(10),

                TextButton(
                    child: const Text(
                      'Take me back to Sign up',
                    ),
                    onPressed: () {
                      setState(() {
                        isSigningIn = false;
                        isVerifying = false;
                        //Navigator
                      });      
                    },
                  ),
              ],
            ),
          )
        ]
      ]),
    );
  }
}