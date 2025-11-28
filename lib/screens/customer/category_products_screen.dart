import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../providers/product_provider.dart';
import '../../providers/theme_provider.dart';
import '../../constants/app_colors.dart';
import '../../widgets/product_card.dart';

class CategoryProductsScreen extends StatefulWidget {
  final Category category;

  const CategoryProductsScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(isDarkMode),
          appBar: AppBar(
            title: Text(widget.category.name),
            backgroundColor: Color(int.parse(widget.category.colorCode.replaceFirst('#', '0xff'))),
            foregroundColor: Colors.white,
          ),
          body: Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              if (productProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Filter products by category
              final categoryProducts = productProvider.products
                  .where((product) => product.category == widget.category.name)
                  .toList();

              if (categoryProducts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Color(int.parse(widget.category.colorCode.replaceFirst('#', '0xff'))).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 50,
                          color: Color(int.parse(widget.category.colorCode.replaceFirst('#', '0xff'))),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No products found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextColor(isDarkMode),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No products available in ${widget.category.name} category yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.getTextColor(isDarkMode).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: categoryProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: categoryProducts[index]);
                },
              );
            },
          ),
        );
      },
    );
  }
}