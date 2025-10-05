import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_register/colors.dart';
import 'package:stock_register/providers/production_provider.dart';
import 'package:stock_register/utils/routes.dart';
import 'package:stock_register/utils/string_capitalize.dart';

class ProductionList extends StatefulWidget {
  const ProductionList({super.key});

  @override
  State<ProductionList> createState() => _ProductionListState();
}

class _ProductionListState extends State<ProductionList> {
  final Map<String, bool> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductionProvider>(
      builder: (context, provider, _) {
        final productions = provider.productions;

        return Scaffold(
          appBar: _buildAppBar(),
          body: productions.isEmpty
              ? const Center(
                  child: Text(
                    "No production records found.",
                    style: TextStyle(color: night, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: productions.length,
                  itemBuilder: (context, i) =>
                      _buildProductionCard(context, productions[i], provider),
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: skyBlue,
            onPressed: () =>
                Navigator.of(context).pushNamed(Routes.productionForm),
            child: const Icon(Icons.add, color: night),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        "Production Records",
        style: TextStyle(
          color: night,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [skyBlue, whisteria, whisteria, deepBrown],
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
    );
  }

  Widget _buildProductionCard(
    BuildContext context,
    production,
    ProductionProvider provider,
  ) {
    final isExpanded = _expanded[production.id] ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: night.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(production, isExpanded),
          if (isExpanded) _buildExpandedDetails(context, production, provider),
        ],
      ),
    );
  }

  Widget _buildHeader(production, bool isExpanded) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: whisteria.withAlpha(60),
        child: const Icon(Icons.factory, color: night, size: 26),
      ),
      title: Text(
        "Batch: ${production.batchNumber}",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: night,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Started: ${production.startDate.toLocal().toString().split(' ')[0]}",
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Chip(
            backgroundColor: production.status == "completed"
                ? Colors.green.shade100
                : Colors.orange.shade100,
            label: Text(
              capitalize(production.status),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: production.status == "completed"
                    ? Colors.green.shade700
                    : Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: AnimatedRotation(
          duration: const Duration(milliseconds: 250),
          turns: isExpanded ? 0.5 : 0,
          child: const Icon(Icons.expand_more, color: night),
        ),
        onPressed: () {
          setState(() {
            _expanded[production.id] = !isExpanded;
          });
        },
      ),
    );
  }

  Widget _buildExpandedDetails(
    BuildContext context,
    production,
    ProductionProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whisteria.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Materials Used:",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: night,
            ),
          ),
          const SizedBox(height: 8),
          ...production.materialsUsed.map((m) => _buildMaterialRow(m)),
          const Divider(height: 24, thickness: 1),
          _buildActionRow(context, production, provider),
        ],
      ),
    );
  }

  Widget _buildMaterialRow(material) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 10, color: night),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "${capitalize(material.materialName)} • ${capitalize(material.materialType)} • ${capitalize(material.materialColor)}",
              style: const TextStyle(fontSize: 14, color: black),
            ),
          ),
          Text(
            "${material.quantityUsed} ${material.unit.toString().split('.').last}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: night,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    production,
    ProductionProvider provider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (production.status != "completed")
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: skyBlue,
              foregroundColor: white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.check_circle),
            label: const Text("Mark Completed"),
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                Routes.stockForm,
                arguments: {
                  'batchNumber': production.batchNumber,
                  'productionId': production.id,
                },
              );
              if (result == true && context.mounted) {
                await provider.markAsCompleted(production.batchNumber);
              }
            },
          )
        else
          const Text(
            "✅ Completed",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}
