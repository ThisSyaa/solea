import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/product_search.dart';

/// Kolom pencarian dengan rekomendasi (dropdown) saat mengetik.
/// Memanggil [onSubmit] saat pengguna menekan Enter atau memilih rekomendasi.
class NavSearchField extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  final String initialText;
  final bool autofocus;

  const NavSearchField({
    super.key,
    required this.onSubmit,
    this.initialText = '',
    this.autofocus = true,
  });

  @override
  State<NavSearchField> createState() => _NavSearchFieldState();
}

class _NavSearchFieldState extends State<NavSearchField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Item pertama = teks yang diketik (Cari "..."), sisanya rekomendasi.
  Iterable<String> _options(TextEditingValue value) {
    final query = value.text.trim();
    if (query.isEmpty) return const Iterable<String>.empty();

    return [query, ...ProductSearch.suggestions(query)];
  }

  void _submit(String value) {
    final query = value.trim();
    if (query.isEmpty) return;

    _focusNode.unfocus();
    widget.onSubmit(query);
  }

  OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldWidth = constraints.maxWidth;

        return RawAutocomplete<String>(
          textEditingController: _controller,
          focusNode: _focusNode,
          optionsBuilder: _options,
          onSelected: _submit,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: widget.autofocus,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onFieldSubmitted(),
              style: const TextStyle(fontSize: 14, color: AppColors.ink),
              decoration: InputDecoration(
                hintText: 'Cari sepatu atau kategori',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                ),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppColors.muted,
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();

                    return IconButton(
                      tooltip: 'Hapus',
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: AppColors.muted,
                      onPressed: controller.clear,
                    );
                  },
                ),
                border: _border(AppColors.line),
                enabledBorder: _border(AppColors.line),
                focusedBorder: _border(AppColors.forest, 1.4),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            final items = options.toList();

            return Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Material(
                  elevation: 6,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 380),
                    child: SizedBox(
                      width: fieldWidth,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final option = items[index];
                          final highlighted =
                              AutocompleteHighlightedOption.of(context) ==
                              index;

                          return InkWell(
                            onTap: () => onSelected(option),
                            child: Container(
                              color: highlighted ? AppColors.sand : null,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    index == 0
                                        ? Icons.search_rounded
                                        : Icons.north_west_rounded,
                                    size: 18,
                                    color: AppColors.muted,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      index == 0 ? 'Cari "$option"' : option,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.ink,
                                        fontWeight: index == 0
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
