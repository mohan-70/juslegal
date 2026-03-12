import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/authority_card.dart';
import '../core/constants/app_config.dart';

class AuthoritiesScreen extends StatelessWidget {
  const AuthoritiesScreen({super.key});

  void _onAction(Map<String, String> a) async {
    final contact = a['contact']!;
    final action = a['action']!;

    if (action == 'Call Now') {
      final Uri tel = Uri(scheme: 'tel', path: contact);
      if (await canLaunchUrl(tel)) await launchUrl(tel);
    } else if (action == 'File Online') {
      final Uri url = Uri.parse('https://$contact');
      if (await canLaunchUrl(url)) await launchUrl(url);
    } else if (action == 'Find Nearest') {
      final Uri maps = Uri.parse(
          '${AppConfig.googleMapsUrl}/${Uri.encodeComponent(a['name']!)}');
      if (await canLaunchUrl(maps)) await launchUrl(maps);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authorities = [
      {
        'name': 'National Consumer Helpline',
        'contact': '1800-11-4000',
        'purpose': 'All consumer complaints',
        'action': 'Call Now'
      },
      {
        'name': 'Cyber Crime Portal',
        'contact': 'cybercrime.gov.in',
        'purpose': 'Online fraud, UPI fraud',
        'action': 'File Online'
      },
      {
        'name': 'RBI Complaint Portal',
        'contact': 'cms.rbi.org.in',
        'purpose': 'Banking & payment issues',
        'action': 'File Online'
      },
      {
        'name': 'DGCA',
        'contact': 'dgca.gov.in',
        'purpose': 'Flight complaints',
        'action': 'File Online'
      },
      {
        'name': 'TRAI Consumer Portal',
        'contact': 'trai.gov.in',
        'purpose': 'Telecom & internet issues',
        'action': 'File Online'
      },
      {
        'name': 'FSSAI',
        'contact': 'fssai.gov.in',
        'purpose': 'Food quality complaints',
        'action': 'File Online'
      },
      {
        'name': 'Medical Council of India',
        'contact': 'mciindia.org',
        'purpose': 'Hospital & doctor complaints',
        'action': 'File Online'
      },
      {
        'name': 'Traffic Police (Local)',
        'contact': 'Find Nearest',
        'purpose': 'Challan disputes',
        'action': 'Find Nearest'
      },
      {
        'name': 'District Consumer Commission',
        'contact': 'Find Nearest',
        'purpose': 'Formal consumer court filing',
        'action': 'Find Nearest'
      },
      {
        'name': 'Education Regulatory Authority',
        'contact': 'File Online',
        'purpose': 'School/college complaints',
        'action': 'File Online'
      },
      {
        'name': 'State Consumer Commission',
        'contact': '1800-11-4000',
        'purpose': 'State-level consumer issues',
        'action': 'Call Now'
      },
      {
        'name': 'RTO Office',
        'contact': '1800-11-4000',
        'purpose': 'Vehicle & license issues',
        'action': 'Find Nearest'
      },
      {
        'name': 'Police Helpline',
        'contact': '100',
        'purpose': 'Emergency complaints',
        'action': 'Call Now'
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Authorities'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: authorities.length,
        itemBuilder: (context, index) {
          final a = authorities[index];
          return AuthorityCard(
            name: a['name']!,
            contact: a['contact']!,
            purpose: a['purpose']!,
            action: a['action']!,
            onAction: () => _onAction(a),
          );
        },
      ),
    );
  }
}
