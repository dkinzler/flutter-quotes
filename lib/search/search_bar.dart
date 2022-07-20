import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/search/actions.dart';
import 'package:flutter_sample/search/search_cubit.dart';
import 'package:flutter_sample/theme/theme.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final _searchFieldController = TextEditingController();

  //TODO how to keep this in sync with SearchCubit
  //e.g. if we initiate a search for a tag with a press on a tag

  @override
  Widget build(BuildContext context) {
    return Card(
      //color: Color.fromARGB(0xFF, 0x9A, 0xAE, 0xBB),
      color: context.theme.colorScheme.secondary,
      child: Padding(
        padding: context.insets.paddingM,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchFieldController,
            ),
            SizedBox(height: context.sizes.spaceM),
            ElevatedButton(
              onPressed: (){
                var query = _searchFieldController.text;
                if(query.isNotEmpty) {
                  Actions.invoke<SearchIntent>(context, SearchIntent(
                    gotoSearchScreen: false,
                    query: query,
                  ));
                }
              },
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}