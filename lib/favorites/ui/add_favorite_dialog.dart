import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_sample/favorites/bloc/add_favorite_cubit.dart';
import 'package:flutter_sample/theme/theme.dart';

class AddFavoriteDialog extends StatefulWidget {
  const AddFavoriteDialog({Key? key}) : super(key: key);

  @override
  State<AddFavoriteDialog> createState() => _AddFavoriteDialogState();
}

class _AddFavoriteDialogState extends State<AddFavoriteDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final AddFavoriteCubit _addFavoriteCubit;

  @override
  void initState() {
    super.initState();
    _addFavoriteCubit = context.read<AddFavoriteCubit>();
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
            name: 'quote',
            initialValue: _addFavoriteCubit.state.quote,
            onChanged: (value) => _addFavoriteCubit.setQuote(value ?? ''),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: context.sizes.spaceM),
          FormBuilderTextField(
            name: 'author',
            initialValue: _addFavoriteCubit.state.author,
            onChanged: (value) => _addFavoriteCubit.setAuthor(value ?? ''),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: context.sizes.spaceM),
          Builder(
            builder: (context) {
              var cubit = context.watch<AddFavoriteCubit>();
              var state = cubit.state;

              List<Widget> children = state.tags.map<Widget>((tag) => InputChip(
                label: Text(tag),
                onDeleted: () => cubit.removeTag(tag),
                isEnabled: !state.submitInProgress,
              )).toList();
              children.add(InputChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add),
                    Text('Add'),
                  ],
                ),
                isEnabled: !state.submitInProgress,
                //TODO fix this, open a dialog?
                onPressed: () => cubit.addTag(Random().nextInt(1000).toString()),
              ));

              return Wrap(
                spacing: context.sizes.spaceS,
                runSpacing: context.sizes.spaceS,
                children: children,
              );
            }
          ),
          SizedBox(height: context.sizes.spaceM),
          Builder(
            builder: (context) {
              var cubit = context.watch<AddFavoriteCubit>();
              var state = cubit.state;

              Widget? errorMessage;
              if(state.submitResult == false) {
                errorMessage = const Text('Submit failed');
              }

              Widget child;
              if(state.submitInProgress) {
                child = const Center(child: CircularProgressIndicator());
              } else {
                child = ElevatedButton(
                  onPressed: () async {
                    _formKey.currentState!.save();
                    if(_formKey.currentState!.validate()) {
                      var success = await cubit.submit();
                      if(success) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: const Text('Add'),
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