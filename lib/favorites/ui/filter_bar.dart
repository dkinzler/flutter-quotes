import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/favorites/filter/filter.dart';
import 'package:flutter_sample/theme/theme.dart';

class FilterBar extends StatefulWidget {
  const FilterBar({Key? key}) : super(key: key);

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  final _searchFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //TODO remove listener or not necessary? google this
    _searchFieldController.addListener(() {
      context
          .read<FilteredFavoritesBloc>()
          .add(SearchTermChanged(searchTerm: _searchFieldController.text));
    });
  }

  @override
  Widget build(BuildContext context) {
    var state = context.watch<FilteredFavoritesBloc>().state;
    var sort = state.sortOrder;

    List<Widget> children = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              controller: _searchFieldController,
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          PopupMenuButton<SortOrder>(
            initialValue: sort,
            onSelected: ((value) {
              context
                  .read<FilteredFavoritesBloc>()
                  .add(SortOrderChanged(sortOrder: value));
            }),
            itemBuilder: (context) => <PopupMenuEntry<SortOrder>>[
              const PopupMenuItem<SortOrder>(
                value: SortOrder.newest,
                child: Text('Newest'),
              ),
              const PopupMenuItem<SortOrder>(
                value: SortOrder.oldest,
                child: Text('Oldest'),
              ),
            ],
            child: Text(
              sort == SortOrder.newest ? 'Sort by: newest' : 'Sort by: oldest',
            ),
          ),
        ],
      ),
    ];

    var searchTerm = state.filters.searchTerm;
    if (searchTerm.isNotEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
        ),
        child: Center(
          child: Text('Showing results for "$searchTerm"'),
        ),
      ));
    }

    var tags = state.filters.tags;
    if (tags.isNotEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Wrap(
          spacing: context.sizes.spaceS,
          runSpacing: context.sizes.spaceS,
          children: tags
              .map<Widget>((t) => InputChip(
                    label: Text(t),
                    onDeleted: () {
                      context
                          .read<FilteredFavoritesBloc>()
                          .add(FilterTagRemoved(tag: t));
                    },
                  ))
              .toList(),
        ),
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
