import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/favorites/bloc/favorites_cubit.dart';
import 'package:flutter_sample/favorites/filter/filter.dart';
import 'package:flutter_sample/theme/theme.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var state = context.watch<FilteredFavoritesBloc>().state;

    Widget? searchInfoWidget;
    var searchTerm = state.filters.searchTerm;
    if (searchTerm.isNotEmpty) {
      searchInfoWidget = Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
        ),
        child: Center(
          child: Text('Showing results for "$searchTerm"'),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: context.sizes.scaled(600),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FilterSearchTextField(),
          Padding(
            padding: context.insets.symmetricScaled(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(child: FilterTagsWidget()),
                FilterSortButton(),
              ],
            ),
          ),
          if (searchInfoWidget != null) searchInfoWidget,
        ],
      ),
    );
  }
}

class FilterSearchTextField extends StatefulWidget {
  const FilterSearchTextField({Key? key}) : super(key: key);

  @override
  State<FilterSearchTextField> createState() => _FilterSearchTextFieldState();
}

class _FilterSearchTextFieldState extends State<FilterSearchTextField> {
  final _searchFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchFieldController.addListener(_onSearchTermChanged);
  }

  void _onSearchTermChanged() {
    context
        .read<FilteredFavoritesBloc>()
        .add(SearchTermChanged(searchTerm: _searchFieldController.text));
  }

  @override
  void dispose() {
    _searchFieldController.removeListener(_onSearchTermChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: TextField(
        controller: _searchFieldController,
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        style: context.theme.textTheme.titleMedium,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          contentPadding: context.insets.paddingS,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => _searchFieldController.clear(),
          ),
        ),
      ),
    );
  }
}

class FilterSortButton extends StatelessWidget {
  const FilterSortButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var sort = context
        .select<FilteredFavoritesBloc, SortOrder>((b) => b.state.sortOrder);

    return PopupMenuButton<SortOrder>(
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
      child: Material(
        elevation: 8.0,
        color: context.theme.colorScheme.surface,
        child: InkWell(
          child: Padding(
            padding: context.insets.paddingS,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sort),
                SizedBox(width: context.sizes.spaceS),
                const Text('Sort'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FilterTagsWidget extends StatelessWidget {
  const FilterTagsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var tags = context.select<FilteredFavoritesBloc, List<String>>(
        (b) => b.state.filters.tags);

    var addTagChip = ActionChip(
      avatar: const Icon(Icons.add),
      label: const Text('Add tag'),
      onPressed: () => _showFilterDialog(context),
    );

    return Wrap(
      spacing: context.sizes.spaceS,
      runSpacing: context.sizes.spaceS,
      children: [
        ...tags
            .map<Widget>((t) => InputChip(
                  label: Text(t),
                  onDeleted: () {
                    context
                        .read<FilteredFavoritesBloc>()
                        .add(FilterTagRemoved(tag: t));
                  },
                ))
            .toList(),
        addTagChip,
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        //TODO could create a separate stateful widget for this that in initstate async loads the list of tags, so that this doesn't take too long

        //TODO dont listen for changes here? write a little comment about it, probably dont need to since favorites shouldnt really change while in this menu
        var favorites = context.read<FavoritesCubit>().state.favorites;
        Set<String> tags = Set<String>.from(
            favorites.expand<String>((favorite) => favorite.quote.tags));

        var selectedTags = context.select<FilteredFavoritesBloc, List<String>>(
            (b) => b.state.filters.tags);

        return AlertDialog(
          title: const Text('Select tags to filter by:'),
          actions: [
            ElevatedButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          actionsPadding: EdgeInsets.fromLTRB(
            context.sizes.spaceM,
            context.sizes.spaceS,
            context.sizes.spaceM,
            context.sizes.spaceM,
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.sizes.scaled(700),
            ),
            child: Wrap(
              spacing: context.sizes.spaceS,
              runSpacing: context.sizes.spaceS,
              children: tags
                  .map<Widget>((t) => FilterChip(
                        label: Text(t),
                        selected: selectedTags.contains(t),
                        onSelected: (selected) {
                          context.read<FilteredFavoritesBloc>().add(selected
                              ? FilterTagAdded(tag: t)
                              : FilterTagRemoved(tag: t));
                        },
                        showCheckmark: true,
                      ))
                  .toList(),
            ),
          ),
          scrollable: true,
        );
      },
    );
  }
}
