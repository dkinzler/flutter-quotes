import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_sample/auth/auth_cubit.dart';
import 'package:flutter_sample/auth/login/login_cubit.dart';
import 'package:flutter_sample/theme/theme.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (context) => LoginCubit(
        authCubit: context.read<AuthCubit>(),
      ),
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: context.insets.paddingM,
            child: const LoginForm(),
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
  final _formKey = GlobalKey<FormBuilderState>();
  late final LoginCubit _loginCubit;

  @override
  void initState() {
    super.initState();
    _loginCubit = context.read<LoginCubit>();
  }

  @override
  Widget build(BuildContext context) {
    //TODO align within the scroll view?
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          //limit the width of the form, e.g. on desktop we wouldn't want the form to span the whole width of the screen
          maxWidth: 400 * context.appTheme.scale,
        ),
        child: Card(
          child: Padding(
            padding: context.insets.paddingM,
            child: FormBuilder(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FormBuilderTextField(
                    name: 'email',
                    //disable text field while login is in progress
                    //this isn't stricly necessary
                    enabled: context.select<LoginCubit, bool>((c) => !c.state.loginInProgress),
                    initialValue: _loginCubit.state.email,
                    onChanged: (value) => _loginCubit.setEmail(value ?? ''),
                    keyboardType: TextInputType.emailAddress,
                    //onTap: () => _loginCubit.resetResult(),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Please enter your email'),
                      FormBuilderValidators.email(errorText: 'Invalid email'),
                    ]),
                  ),
                  SizedBox(height: context.sizes.spaceM),
                  FormBuilderTextField(
                    name: 'password',
                    enabled: context.select<LoginCubit, bool>((c) => !c.state.loginInProgress),
                    initialValue: _loginCubit.state.password,
                    onChanged: (value) => _loginCubit.setPassword(value ?? ''),
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    //onTap: () => _loginCubit.resetResult(),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: 'Please enter your password'),
                    ]),
                  ),
                  SizedBox(height: context.sizes.spaceM),
                  Builder(
                    builder: (context) {
                      var cubit = context.watch<LoginCubit>();
                      var state = cubit.state;
                
                      Widget? errorMessage;
                      if(state.loginResult == LoginResult.error) {
                        errorMessage = const Text('Login failed');
                      }
                
                      Widget child;
                      if(state.loginInProgress) {
                        child = const Center(child: CircularProgressIndicator());
                      } else {
                        child = ElevatedButton(
                          onPressed: () {
                            _formKey.currentState!.save();
                            if(_formKey.currentState!.validate()) {
                              cubit.login();
                            }
                          },
                          child: Padding(
                            padding: context.insets.paddingM,
                            child: Text(
                              'Login',
                              style: context.theme.textTheme.labelLarge,
                            ),
                          ),
                        );
                      }
                
                      //TODO right now this changes height when moving from button to progressindicator, how to avoid this?
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if(errorMessage != null) ...[
                            errorMessage,
                            SizedBox(height: context.sizes.spaceM),
                          ],
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: child,
                          ),
                        ],
                      );
                    }
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}