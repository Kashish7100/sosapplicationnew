import 'package:flutter/material.dart';

class SearchInputDelegate extends SliverPersistentHeaderDelegate {

  final Function(String) onSearchTextChanged;

  SearchInputDelegate({required this.onSearchTextChanged});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search...',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          prefixIcon: Icon(Icons.search),
          contentPadding: EdgeInsets.symmetric(vertical: 5.0),
        ),
        onChanged: onSearchTextChanged,
      ),
    );
  }

  @override
  double get maxExtent => 60.0;

  @override
  double get minExtent => 60.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
