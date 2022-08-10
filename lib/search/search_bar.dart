import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/search/actions.dart';
import 'package:flutter_sample/search/search_cubit.dart';
import 'package:flutter_sample/theme/theme.dart';

/* TODO
We could show search suggestions using the Autocomplete widget.
The suggestions could e.g. be based on tags from the user's favorites.

We would probably have to use the RawAutocomplete widget though, since the constructor
of Autocomplete does not accept a TextEditingController and we need to create our own
controller to keep in sync with the search cubit.
*/

class SearchBar extends StatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final _searchFieldController = TextEditingController();
  late final StreamSubscription _searchCubitSubscription;

  @override
  void initState() {
    super.initState();
    //update text field with actual query from search cubit
    //e.g. we can also initiate a search without the text field by tapping a tag of a quote
    //however the text field should then show the tag as text
    var searchCubit = context.read<SearchCubit>();
    _searchCubitSubscription = searchCubit.stream.listen((s) {
      var query = s.query;
      if (query != _searchFieldController.text) {
        _searchFieldController.text = query;
      }
    });
    //need to initially update text field once
    //if the search cubit state was already updated with a new query before the search screen is opened
    //the listener above won't notice
    if (searchCubit.state.query != _searchFieldController.text) {
      _searchFieldController.text = searchCubit.state.query;
    }
  }

  @override
  void dispose() {
    _searchCubitSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        //on larger screens, e.g. desktop the search bar shouldn't fill the entire screen width
        maxWidth: context.sizes.scaled(600),
        maxHeight: 100,
      ),
      child: Card(
        child: Padding(
          padding: context.insets.paddingS,
          /*
            TODO
            We use a table to make the search button the same height as the text field,
            this is not easily possible with a Row widget. The cleanest solution would probably be using a CustomMultiChildLayout.
          */
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(),
              1: IntrinsicColumnWidth(),
              2: IntrinsicColumnWidth(),
            },
            children: [
              TableRow(
                children: [
                  TextField(
                    controller: _searchFieldController,
                    //onSubmitted is called when the user presses the enter key on desktop
                    //or the "done"/"search" button of the on-screen keyboard on mobile
                    onSubmitted: (String value) => Actions.invoke<SearchIntent>(
                        context,
                        SearchIntent(
                          query: value,
                        )),
                    textInputAction: TextInputAction.search,
                    textAlignVertical: TextAlignVertical.center,
                    style: context.theme.textTheme.titleMedium,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      contentPadding: context.insets.paddingS,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchFieldController.clear(),
                      ),
                    ),
                  ),
                  SizedBox(width: context.sizes.spaceS),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.fill,
                    child: ElevatedButton(
                      onPressed: () {
                        var query = _searchFieldController.text;
                        if (query.isNotEmpty) {
                          Actions.invoke<SearchIntent>(
                              context,
                              SearchIntent(
                                query: query,
                              ));
                        }
                      },
                      child: const Icon(Icons.search),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
