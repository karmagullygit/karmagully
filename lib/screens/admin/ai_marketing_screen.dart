import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_marketing_provider.dart';
import '../../utils/responsive_utils.dart';

class AIMarketingScreen extends StatefulWidget {
  const AIMarketingScreen({super.key});

  @override
  State<AIMarketingScreen> createState() => _AIMarketingScreenState();
}

class _AIMarketingScreenState extends State<AIMarketingScreen> {
  final _businessController = TextEditingController(text: 'Anime Metal Posters');
  final _audienceController = TextEditingController(text: 'Anime fans, collectors, interior decor enthusiasts');
  final _budgetController = TextEditingController(text: 'low');
  final _goalController = TextEditingController(text: 'Drive sales and build email list');

  final List<String> _allChannels = [
    'Instagram',
    'TikTok',
    'Etsy',
    'Shopify',
    'Email',
    'Facebook',
    'X',
    'Influencer'
  ];
  final Set<String> _selectedChannels = {'Instagram', 'TikTok', 'Etsy'};

  @override
  void dispose() {
    _businessController.dispose();
    _audienceController.dispose();
    _budgetController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _onGenerate() async {
    final provider = Provider.of<AIMarketingProvider>(context, listen: false);
    await provider.generatePlan(
      businessName: _businessController.text.trim(),
      audience: _audienceController.text.trim(),
      budgetRange: _budgetController.text.trim().toLowerCase(),
      primaryGoal: _goalController.text.trim(),
      channels: _selectedChannels.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveUtils.getVerticalSpacing(context);
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Marketing Assistant'),
      ),
      body: Consumer<AIMarketingProvider>(
        builder: (context, ai, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: spacing,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick inputs', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _businessController,
                  decoration: const InputDecoration(labelText: 'Business / Brand name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _audienceController,
                  decoration: const InputDecoration(labelText: 'Target audience (comma separated)'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _budgetController,
                        decoration: const InputDecoration(labelText: 'Budget (e.g. low / medium / high or ₹100)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _goalController,
                        decoration: const InputDecoration(labelText: 'Primary goal'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Channels', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allChannels.map((c) {
                    final selected = _selectedChannels.contains(c);
                    return FilterChip(
                      label: Text(c),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selectedChannels.add(c);
                          } else {
                            _selectedChannels.remove(c);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: ai.loading ? null : _onGenerate,
                      icon: ai.loading ? const SizedBox.shrink() : const Icon(Icons.auto_fix_high),
                      label: ai.loading ? const Text('Generating...') : const Text('Generate Plan'),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedChannels.clear();
                          _selectedChannels.addAll(['Instagram', 'TikTok', 'Etsy']);
                        });
                      },
                      child: const Text('Reset Channels'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                if (ai.error != null) ...[
                  Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('Error: ${ai.error}'),
                    ),
                  ),
                ],

                if (ai.plan != null) ...[
                  Text('Suggested Plan', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _buildPlanSection(context, 'Summary', () {
                    return Text('A tailored plan for \"${ai.plan!['businessName']}\" focusing on ${ai.plan!['audience']}.');
                  }),
                  const SizedBox(height: 8),
                  _buildPlanSection(context, 'Channels & Tactics', () {
                    final channels = ai.plan!['channels'] as Map<String, dynamic>;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: channels.entries.map((e) {
                        final tactics = (e.value as List).cast<String>();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              ...tactics.map((t) => Text('• $t')).toList(),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 8),
                  _buildPlanSection(context, 'Ad Copy Examples', () {
                    final ad = (ai.plan!['adCopies'] as List).cast<String>();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ad.map((a) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('• $a'),
                      )).toList(),
                    );
                  }),
                  const SizedBox(height: 8),
                  _buildPlanSection(context, 'Pricing & Promotions', () {
                    final pricing = (ai.plan!['pricingAndPromotions'] as List).cast<String>();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: pricing.map((p) => Text('• $p')).toList(),
                    );
                  }),
                  const SizedBox(height: 8),
                  _buildPlanSection(context, 'Timeline & KPIs', () {
                    final timeline = (ai.plan!['timeline'] as List).cast<String>();
                    final kpis = (ai.plan!['kpis'] as List).cast<String>();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...timeline.map((t) => Text('• $t')),
                        const SizedBox(height: 8),
                        Text('KPIs', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ...kpis.map((k) => Text('• $k')),
                      ],
                    );
                  }),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Copy plan to clipboard or export — simple convenience (mock)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Plan copied to clipboard (mock)')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Plan'),
                  ),
                ],

                if (ai.loading && ai.plan == null) ...[
                  const SizedBox(height: 40),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanSection(BuildContext context, String title, Widget Function() builder) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            builder(),
          ],
        ),
      ),
    );
  }
}
