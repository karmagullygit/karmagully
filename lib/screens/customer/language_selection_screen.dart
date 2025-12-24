import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final _searchController = TextEditingController();
  List<Map<String, String>> _filteredLanguages = LanguageProvider.supportedLanguages;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLanguages(String query) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    setState(() {
      _filteredLanguages = languageProvider.searchLanguages(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(themeProvider.isDarkMode),
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.selectLanguage,
              style: TextStyle(
                color: AppColors.getTextColor(themeProvider.isDarkMode),
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.getBackgroundColor(themeProvider.isDarkMode),
            elevation: 0,
            iconTheme: IconThemeData(
              color: AppColors.getTextColor(themeProvider.isDarkMode),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Search Bar
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.getCardBackgroundColor(themeProvider.isDarkMode),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.getBorderColor(themeProvider.isDarkMode)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterLanguages,
                    style: TextStyle(
                      color: AppColors.getTextColor(themeProvider.isDarkMode),
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.searchLanguages,
                      hintStyle: TextStyle(
                        color: AppColors.getTextSecondaryColor(themeProvider.isDarkMode),
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.getTextSecondaryColor(themeProvider.isDarkMode),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _filterLanguages('');
                              },
                              icon: Icon(
                                Icons.clear,
                                color: AppColors.getTextSecondaryColor(themeProvider.isDarkMode),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),

                // Current Language Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Row(
                    children: [
                      Text(
                        languageProvider.getCurrentLanguageFlag(),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.currentLanguage,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.getTextSecondaryColor(themeProvider.isDarkMode),
                              ),
                            ),
                            Text(
                              languageProvider.getCurrentLanguageName(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.getTextColor(themeProvider.isDarkMode),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 24,
                      ),
                    ],
                  ),
                ),

                // Languages list (scrollable)
                Expanded(
                  child: _filteredLanguages.isNotEmpty
                      ? ListView(
                          padding: const EdgeInsets.only(bottom: 16),
                          children: [
                            if (_filteredLanguages.any((lang) => lang['flag'] == '🇮🇳')) ...[
                              _buildSectionHeader('Indian Languages', themeProvider.isDarkMode),
                              ..._buildLanguageList(
                                _filteredLanguages.where((lang) => lang['flag'] == '🇮🇳').toList(),
                                languageProvider,
                                themeProvider.isDarkMode,
                              ),
                            ],
                            if (_filteredLanguages.any((lang) => lang['flag'] != '🇮🇳')) ...[
                              _buildSectionHeader('Other Languages', themeProvider.isDarkMode),
                              ..._buildLanguageList(
                                _filteredLanguages.where((lang) => lang['flag'] != '🇮🇳').toList(),
                                languageProvider,
                                themeProvider.isDarkMode,
                              ),
                            ],
                          ],
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: AppColors.getTextSecondaryColor(themeProvider.isDarkMode),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context)!.currentLanguage,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.getTextSecondaryColor(themeProvider.isDarkMode),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try searching with a different term',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.getTextSecondaryColor(themeProvider.isDarkMode),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  List<Widget> _buildLanguageList(
    List<Map<String, String>> languages,
    LanguageProvider languageProvider,
    bool isDarkMode,
  ) {
    return languages.map((language) {
      final isSelected = languageProvider.getCurrentLanguageName() == language['name'];
      
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.getCardBackgroundColor(isDarkMode),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary
                : AppColors.getBorderColor(isDarkMode),
          ),
        ),
        child: ListTile(
          leading: Text(
            language['flag']!,
            style: const TextStyle(fontSize: 24),
          ),
          title: Text(
            language['name']!,
            style: TextStyle(
              color: AppColors.getTextColor(isDarkMode),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            language['englishName']!,
            style: TextStyle(
              color: AppColors.getTextSecondaryColor(isDarkMode),
              fontSize: 12,
            ),
          ),
          trailing: isSelected
              ? Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                )
              : Icon(
                  Icons.circle_outlined,
                  color: AppColors.getTextSecondaryColor(isDarkMode),
                ),
          onTap: () async {
            await languageProvider.changeLanguage(language['code']!);
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${AppLocalizations.of(context)!.languageChanged} ${language['englishName']}'),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
              
              // Close the screen
              Navigator.of(context).pop();
            }
          },
        ),
      );
    }).toList();
  }
}