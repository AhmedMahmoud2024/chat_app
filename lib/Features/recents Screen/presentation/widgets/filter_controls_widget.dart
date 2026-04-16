import 'package:flutter/material.dart';

/// Widget for displaying filter controls (search bar + filter chips)
/// Provides UI for filtering call logs by type and search query
class FilterControlsWidget extends StatelessWidget {
  final String selectedFilter;
  final String searchQuery;
  final Function(String) onFilterChanged;
  final Function(String) onSearchChanged;
  final Function() onClearSearch;

  const FilterControlsWidget({
    super.key,
    required this.selectedFilter,
    required this.searchQuery,
    required this.onFilterChanged,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Search Bar
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey[100],
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search calls...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: onClearSearch,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),

        /// Filter Chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Audio', 'audio'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Video', 'video'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build a filter chip button
  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        onFilterChanged(value);
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.blue[100],
      side: BorderSide(
        color: isSelected ? Colors.blue : Colors.grey[300]!,
      ),
    );
  }
}
