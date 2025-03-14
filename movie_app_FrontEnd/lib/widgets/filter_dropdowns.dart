import 'package:flutter/material.dart';

class FilterDropdowns extends StatelessWidget {
  final List<String> allGenres;
  final List<String> allYears;
  final String? selectedGenre;
  final String? selectedYear;
  final Function(String?) onGenreChanged;
  final Function(String?) onYearChanged;

  const FilterDropdowns({
    super.key,
    required this.allGenres,
    required this.allYears,
    required this.selectedGenre,
    required this.selectedYear,
    required this.onGenreChanged,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              value: selectedGenre,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Genres'),
                ),
                ...allGenres.map((genre) => DropdownMenuItem<String>(
                      value: genre,
                      child: Text(genre),
                    )),
              ],
              onChanged: onGenreChanged,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              value: selectedYear,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Years'),
                ),
                ...allYears.map((year) => DropdownMenuItem<String>(
                      value: year,
                      child: Text(year),
                    )),
              ],
              onChanged: onYearChanged,
            ),
          ),
        ],
      ),
    );
  }
}
