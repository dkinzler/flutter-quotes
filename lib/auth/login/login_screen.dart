import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_quotes/auth/auth_cubit.dart';
import 'package:flutter_quotes/auth/login/login_cubit.dart';
import 'package:flutter_quotes/auth/login/tip.dart';
import 'package:flutter_quotes/keys.dart';
import 'package:flutter_quotes/theme/theme.dart';
import 'package:flutter_quotes/widgets/error.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var padding = context.layout == Layout.mobile
        ? context.insets.paddingM
        : context.insets.paddingL;

    return BlocProvider<LoginCubit>(
      create: (context) => LoginCubit(
        authCubit: context.read<AuthCubit>(),
      ),
      child: Scaffold(
        floatingActionButton: const LoginTipButton(),
        body: Center(
          child: Padding(
            padding: padding,
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var padding = context.layout == Layout.mobile
        ? context.insets.allScaled(
            24.0,
          )
        : context.insets.symmetricScaled(
            horizontal: 32.0,
            vertical: 48.0,
          );

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          //limit the width of the form, e.g. on desktop we wouldn't want the form to span the whole width of the screen
          maxWidth: 500 * context.appTheme.scale,
        ),
        child: Card(
          child: Padding(
            padding: padding,
            child: FormBuilder(
              key: _formKey,
              child: BlocBuilder<LoginCubit, LoginState>(
                //we don't need to rebuild when email or password fields of the state change
                buildWhen: (previous, current) =>
                    previous.loginInProgress != current.loginInProgress ||
                    previous.loginResult != current.loginResult,
                builder: (context, state) {
                  var loginCubit = context.read<LoginCubit>();

                  Widget? errorMessage;
                  if (state.loginResult == LoginResult.error) {
                    errorMessage = const ErrorText(text: 'Login failed');
                  }

                  Widget child;
                  var buttonTextStyle = context.theme.textTheme.titleLarge;
                  var buttonPadding = context.insets.paddingS;
                  var childHeight = (buttonTextStyle!.fontSize! *
                              (buttonTextStyle.height ?? 1.0) +
                          buttonPadding.vertical) *
                      1.25 *
                      MediaQuery.textScaleFactorOf(context);

                  if (state.loginInProgress) {
                    child = const Center(child: CircularProgressIndicator());
                  } else {
                    child = ElevatedButton(
                      key: const ValueKey(AppKey.loginButton),
                      onPressed: () {
                        _formKey.currentState!.save();
                        if (_formKey.currentState!.validate()) {
                          loginCubit.login();
                        }
                      },
                      child: Padding(
                        padding: buttonPadding,
                        child: Text(
                          'Login',
                          style: buttonTextStyle,
                        ),
                      ),
                    );
                  }

                  child = SizedBox(
                    height: childHeight,
                    child: child,
                  );

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FormBuilderTextField(
                        key: const ValueKey(AppKey.loginEmailTextField),
                        name: 'email',
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), hintText: 'Email'),
                        autovalidateMode: AutovalidateMode.disabled,
                        onChanged: (value) => loginCubit.setEmail(value ?? ''),
                        keyboardType: TextInputType.emailAddress,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                              errorText: 'Please enter your email'),
                          FormBuilderValidators.email(
                              errorText: 'Invalid email'),
                        ]),
                      ),
                      SizedBox(height: context.sizes.spaceM),
                      FormBuilderTextField(
                        key: const ValueKey(AppKey.loginPasswordTextField),
                        name: 'password',
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), hintText: 'Password'),
                        autovalidateMode: AutovalidateMode.disabled,
                        onChanged: (value) =>
                            loginCubit.setPassword(value ?? ''),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                              errorText: 'Please enter your password'),
                        ]),
                        onSubmitted: (value) {
                          _formKey.currentState?.fields['password']?.validate();
                        },
                      ),
                      SizedBox(height: context.sizes.spaceL),
                      if (errorMessage != null) ...[
                        errorMessage,
                        SizedBox(height: context.sizes.spaceM),
                      ],
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: child,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
