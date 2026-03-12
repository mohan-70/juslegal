import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_config.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: AppConfig.supportEmail,
      query: 'subject=Feedback for ${AppConfig.appName}',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('PREFERENCES'),
          ListTile(
            title: const Text('Language'),
            subtitle: const Text('English / Hindi (Phase 2)'),
            trailing: Switch(value: false, onChanged: (v) {}),
          ),
          const Divider(),
          _buildSectionHeader('APP INFO'),
          ListTile(
              title: const Text('App Name'), 
              subtitle: Text(AppConfig.appName)),
          ListTile(
              title: const Text('Version'), 
              subtitle: Text(AppConfig.appVersion)),
          ListTile(
              title: const Text('Build Number'), 
              subtitle: Text(AppConfig.appBuildNumber)),
          const Divider(),
          _buildSectionHeader('LEGAL'),
          ListTile(
            title: const Text('Privacy Policy'),
            onTap: () => _launchURL(AppConfig.privacyPolicyUrl),
          ),
          ListTile(
            title: const Text('Terms of Service'),
            onTap: () => _launchURL(AppConfig.termsOfServiceUrl),
          ),
          ListTile(
            title: const Text('Website'),
            onTap: () => _launchURL(AppConfig.websiteUrl),
          ),
          ListTile(
            title: const Text('Legal Disclaimer'),
            subtitle: Text(AppStrings.onboardingDisclaimer),
          ),
          const Divider(),
          _buildSectionHeader('SUPPORT'),
          ListTile(
            title: const Text('Send Feedback'),
            subtitle: const Text('support@juslegal.app'),
            onTap: _launchEmail,
          ),
          ListTile(
            title: const Text('Rate JusLegal'),
            onTap: () => _launchURL(
                'https://play.google.com/store/apps/details?id=com.juslegal.app'),
          ),
          ListTile(
            title: const Text('Contact Support'),
            subtitle: Text(AppConfig.supportEmail),
            onTap: _launchEmail,
          ),
          const Divider(),
          _buildSectionHeader('UPGRADE'),
          Card(
            color: AppColors.primary.withOpacity(0.05),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.primary.withOpacity(0.1))),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Row(
                children: [
                  const Text('JusLegal Pro',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text('Coming Soon',
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              subtitle: const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                    'Unlimited letters, priority analysis, lawyer consultation access — ₹99/month'),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              '© 2024 JusLegal India',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.primary.withOpacity(0.6),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
