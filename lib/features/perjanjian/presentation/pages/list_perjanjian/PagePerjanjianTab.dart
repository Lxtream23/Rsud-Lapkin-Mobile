import 'package:flutter/material.dart';
import 'page_list_perjanjian.dart';

class PagePerjanjianTab extends StatefulWidget {
  const PagePerjanjianTab({super.key});

  @override
  State<PagePerjanjianTab> createState() => _PagePerjanjianTabState();
}

class _PagePerjanjianTabState extends State<PagePerjanjianTab> {
  int _index = 0;

  final titles = [
    'Semua Perjanjian',
    'Perjanjian Proses',
    'Perjanjian Disetujui',
    'Perjanjian Ditolak',
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          //centerTitle: true,
          title: Text(titles[_index]),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Semua'),
              Tab(text: 'Proses'),
              Tab(text: 'Disetujui'),
              Tab(text: 'Ditolak'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PageListPerjanjian(status: null),
            PageListPerjanjian(status: 'Proses'),
            PageListPerjanjian(status: 'Disetujui'),
            PageListPerjanjian(status: 'Ditolak'),
          ],
        ),
      ),
    );
  }
}
