import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/product_section_provider.dart';
import '../../models/product.dart';

class AdminProductSectionAssignmentScreen extends StatefulWidget {
  final Product product;

  const AdminProductSectionAssignmentScreen({
    super.key,
    required this.product,
  });

  @override
  State<AdminProductSectionAssignmentScreen> createState() => _AdminProductSectionAssignmentScreenState();
}

class _AdminProductSectionAssignmentScreenState extends State<AdminProductSectionAssignmentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1F26),
        elevation: 0,
        title: const Text('Assign to Sections'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer2<ProductSectionProvider, ProductProvider>(
        builder: (context, sectionProvider, productProvider, child) {
          // Get the current product state from the provider
          final currentProduct = productProvider.products.firstWhere(
            (p) => p.id == widget.product.id,
            orElse: () => widget.product,
          );

          if (sectionProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6B73FF),
              ),
            );
          }

          if (sectionProvider.sections.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 80,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No sections available',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create sections first',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Product Info Header
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B73FF), Color(0xFF000DFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        currentProduct.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[800],
                          child: const Icon(Icons.image, color: Colors.white54),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentProduct.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${currentProduct.sectionIds.length} sections',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Sections List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sectionProvider.sections.length,
                  itemBuilder: (context, index) {
                    final section = sectionProvider.sections[index];
                    final isAssigned = currentProduct.sectionIds.contains(section.id);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1F26),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isAssigned
                              ? const Color(0xFF6B73FF)
                              : Colors.grey[800]!,
                          width: isAssigned ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isAssigned
                                  ? [const Color(0xFF6B73FF), const Color(0xFF000DFF)]
                                  : [Colors.grey[700]!, Colors.grey[800]!],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isAssigned ? Icons.check_circle : Icons.category,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          section.name,
                          style: TextStyle(
                            color: isAssigned ? Colors.white : Colors.grey[400],
                            fontWeight: isAssigned ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: section.description.isNotEmpty
                            ? Text(
                                section.description,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: Switch(
                          value: isAssigned,
                          onChanged: section.isActive
                              ? (value) async {
                                  await productProvider.toggleProductSection(
                                    currentProduct.id,
                                    section.id,
                                  );
                                }
                              : null,
                          activeColor: const Color(0xFF6B73FF),
                        ),
                        onTap: section.isActive
                            ? () async {
                                await productProvider.toggleProductSection(
                                  currentProduct.id,
                                  section.id,
                                );
                              }
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
