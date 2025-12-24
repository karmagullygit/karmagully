import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Who We Are', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('KarmaGully is an Indian e-commerce brand specializing in premium metal posters and pop-culture wall art. We design, source and deliver high-quality metal prints that celebrate anime and pop culture for collectors and home décor lovers.'),
            SizedBox(height: 16),
            Text('Our Mission', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('To bring durable, gallery-quality wall art to fans across India — combining striking artwork with industry-grade metal finishes so your favorite characters and moments look their best for years.'),
            SizedBox(height: 16),
            Text('Our Vision', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('To be India’s trusted destination for collectible metal posters and custom metal art, known for quality, transparency and responsive customer support.'),
            SizedBox(height: 16),
            Text('Why Metal Posters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('- Durability: Metal prints resist tearing, moisture and fading far better than paper.'),
            Text('- Premium Finish: Metal delivers vivid colors, crisp detail and a modern aesthetic (matte or glossy finishes).'),
            Text('- Longevity: Designed to keep their look for many years — ideal for collectors and gifts.'),
            Text('- Eco Advantage: Our production reduces waste from fragile paper replacements over time.'),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
