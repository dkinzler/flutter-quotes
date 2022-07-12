import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_sample/auth/auth_cubit.dart';
import 'package:flutter_sample/auth/login/login_cubit.dart';
import 'package:flutter_sample/theme/theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (context) => LoginCubit(
        authCubit: context.read<AuthCubit>(),
      ),
      child: const Scaffold(
        body: Center(
          child: LoginForm(),
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
    return FormBuilder(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FormBuilderTextField(
            name: 'username',
            initialValue: _loginCubit.state.username,
            onChanged: (value) => _loginCubit.setUsername(value ?? ''),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: context.sizes.spaceM),
          FormBuilderTextField(
            name: 'password',
            initialValue: _loginCubit.state.password,
            onChanged: (value) => _loginCubit.setPassword(value ?? ''),
            keyboardType: TextInputType.text,
            obscureText: true,
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
                  child: const Text('Login'),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(errorMessage != null) ...[
                    errorMessage,
                    SizedBox(height: context.sizes.spaceM),
                  ],
                  child,
                ],
              );
            }
          ),
        ],
      ),
    );
  }
}