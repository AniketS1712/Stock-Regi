import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_register/colors.dart';
import 'package:stock_register/providers/raw_material_provider.dart';
import 'package:stock_register/models/current_raw_material_model.dart';
import 'package:stock_register/utils/routes.dart';
import 'package:stock_register/widgets/raw_material_group.dart';

class RawMaterialList extends StatefulWidget {
  const RawMaterialList({super.key});

  @override
  State<RawMaterialList> createState() => _RawMaterialListState();
}

class _RawMaterialListState extends State<RawMaterialList> {
  final Map<String, bool> _expandedGroups = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<RawMaterialProvider>(
      builder: (context, provider, _) {
        final stock = provider.currentStock;

        // Group by materialName + unit
        final grouped = <String, List<CurrentRawMaterialModel>>{};
        for (final item in stock) {
          final key = "${item.materialName}_${item.materialUnit.name}";
          grouped.putIfAbsent(key, () => []).add(item);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Purchases Available",
              style: TextStyle(
                color: night,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [deepBrown, whisteria, whisteria, skyBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ),
            centerTitle: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            elevation: 3,
          ),
          body: grouped.isEmpty
              ? const Center(
                  child: Text(
                    "No raw materials found.",
                    style: TextStyle(color: night, fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView.builder(
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final entry = grouped.entries.elementAt(index);
                      return RawMaterialGroup(
                        groupKey: entry.key,
                        materials: entry.value,
                        isExpanded: _expandedGroups[entry.key] ?? false,
                        onToggle: () {
                          setState(() {
                            _expandedGroups[entry.key] =
                                !(_expandedGroups[entry.key] ?? false);
                          });
                        },
                      );
                    },
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: skyBlue,
            onPressed: () {
              Navigator.pushNamed(context, Routes.rawMaterialForm);
            },
            child: const Icon(Icons.add, color: night),
          ),
        );
      },
    );
  }
}
