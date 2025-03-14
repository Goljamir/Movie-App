import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const SearchField({
    super.key,
    required this.controller,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: 'Search movies',
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.search, color: Colors.black54),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.black54),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(30),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}

class FilterRow extends StatelessWidget {
  final String? selectedGenre;
  final String? selectedYear;
  final List<String> availableGenres;
  final List<String> availableYears;
  final Function(String?) onGenreChanged;
  final Function(String?) onYearChanged;
  final VoidCallback onClearFilters;

  const FilterRow({
    super.key,
    required this.selectedGenre,
    required this.selectedYear,
    required this.availableGenres,
    required this.availableYears,
    required this.onGenreChanged,
    required this.onYearChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          _buildDropdownButton<String>(
            value: selectedGenre,
            hint: "Select Genre",
            items: availableGenres,
            onChanged: onGenreChanged,
          ),
          const SizedBox(width: 10),
          _buildDropdownButton<String>(
            value: selectedYear,
            hint: "Select Year",
            items: availableYears,
            onChanged: onYearChanged,
          ),
          if (selectedGenre != null || selectedYear != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: onClearFilters,
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownButton<T>({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Expanded(
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint),
        isExpanded: true,
        onChanged: onChanged,
        items: items.isEmpty
            ? [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text("Loading..."),
                )
              ]
            : items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
      ),
    );
  }
}
