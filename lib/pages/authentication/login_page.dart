import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/validate_values.dart';
import '../../logic/auth_app_state.dart';
import '../../logic/tuya_handler.dart';
import '../../model/country_code.dart';
import '../../widgets/my_alert_dialog.dart';
import '../../widgets/my_text_field.dart';
import 'sign_up_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // print(loadingProvider.isLoading);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(height: 180, padding: const EdgeInsets.all(12), child: const Icon(Icons.hail_rounded, size: 120)),
              const SizedBox(
                width: 450,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20),
                  child: LoginForm(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white),
                    children: [
                      const TextSpan(text: 'No account? '),
                      TextSpan(
                        text: 'Sign up.',
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final ValidateValues _validateValues = ValidateValues();

  final _formKey = GlobalKey<FormState>();
  final _forgotPassFormKey = GlobalKey<FormState>();
  String? _password;
  String? _email;
  String? _forgotPassEmail;
  final CountryCode _countryCode = CountryCode(country: "Denmark", code: 45);

  Future<void> _loginWithEmail(String email, String password, String countryCode) async {
    showMyLoadingDialog(context);
    await context.read<AuthAppState>().loginWithEmail(email, password, countryCode, () {
      if (mounted) {
        Navigator.pop(context);
        // Navigator.push(context, MaterialPageRoute(builder: (context) => ));
      }
    }, (message) {
      if (mounted) {
        Navigator.pop(context);
        showMyDialog(context, 'Error', message: message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          MyTextFieldWidget(
            initialValue: _countryCode.country,
            icon: const Icon(Icons.language),
            autofillHints: const [AutofillHints.email],
            labelText: 'Country',
            readOnly: true,
            isRequired: false,
            // onTap: () async {
            //   CountryCode? code = await Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const AlphabetListSelector(),
            //         fullscreenDialog: true,
            //       ));
            //   if (code != null) {
            //     _countryCode = code;
            //   }
            //   setState(() {});
            // },
            setValue: (_) {},
            validate: (value) => null,
          ),
          MyTextFieldWidget(
            icon: const Icon(Icons.person),
            autofillHints: const [AutofillHints.email],
            labelText: 'E-mail',
            textInputType: TextInputType.emailAddress,
            isRequired: false,
            setValue: (value) => _email = value,
            validate: (value) => _validateValues.validateEmail(value),
          ),
          MyTextFieldWidget(
            icon: const Icon(Icons.lock),
            autofillHints: const [AutofillHints.password],
            labelText: 'Password',
            isRequired: false,
            obscureText: true,
            textCapitalization: TextCapitalization.none,
            setValue: (value) => _password = value,
            validate: (value) => _validateValues.validatePassword(value),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 30,
              child: TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text('Forgot password?'),
                onPressed: () {
                  showMyDialog(
                    context,
                    'Forgot Password?',
                    cancelText: 'Cancel',
                    confirmText: 'Send',
                    infoDialog: false,
                    widgetContent: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Form(
                        key: _forgotPassFormKey,
                        child: Column(
                          children: [
                            const Text(
                              'Not recieved an e-mail?\nCheck your spam filter.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                            const Text('Send Reset Password E-mail'),
                            MyTextFieldWidget(
                              autofillHints: const [AutofillHints.email],
                              icon: const Icon(Icons.person),
                              color: Colors.grey[850],
                              labelText: 'E-mail',
                              textInputType: TextInputType.emailAddress,
                              isRequired: false,
                              setValue: (value) => _forgotPassEmail = value,
                              validate: (value) => _validateValues.validateEmail(value),
                            ),
                          ],
                        ),
                      ),
                    ),
                    myOnPressed: () {
                      if (_forgotPassFormKey.currentState!.validate()) {
                        _forgotPassFormKey.currentState!.save();
                        // showMyLoadingDialog(context);
                      }
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              child: const Text('Login'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _loginWithEmail(_email!, _password!, _countryCode.code.toString());
                }
              },
            ),
          ),
          const SizedBox(height: 10)
        ],
      ),
    );
  }
}
