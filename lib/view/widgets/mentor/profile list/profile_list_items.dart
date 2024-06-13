import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phloem_mentors/view/const/icon/icon_const.dart';
import 'package:phloem_mentors/view/screens/mentor/profile/app%20info/mentor_app_info.dart';
import 'package:phloem_mentors/view/screens/mentor/profile/privacy%20policy/mentor_privacy_policy.dart';
import 'package:phloem_mentors/view/screens/mentor/profile/terms%20and%20conditions/mentor_terms.dart';
import 'profile_list_tile.dart';

class ProfileList extends StatelessWidget {
  const ProfileList({super.key});

  Future<String> _fetchVersionInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileListTile(
          leading: FIcons.infoIcon,
          title: 'App Info',
          trailing: FIcons.forwardArrowIcon,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppInfo()),
            );
          },
        ),
        ProfileListTile(
          leading: FIcons.termsIcon,
          title: 'Terms and Conditions',
          trailing: FIcons.forwardArrowIcon,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Terms()),
            );
          },
        ),
        ProfileListTile(
          leading: FIcons.pPolicyIcon,
          title: 'Privacy Policy',
          trailing: FIcons.forwardArrowIcon,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivacyPolicy()),
            );
          },
        ),
        const SizedBox(height: 70),
        FutureBuilder<String>(
                    future: _fetchVersionInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error fetching version'));
                      } else {
                        return ListTile(
                          subtitle: Center(
                            child: Text('Version: ${snapshot.data}',
                                style: const TextStyle(fontSize: 16.0)),
                          ),
                        );
                      }
                    },
                  ),
      ],
    );
  }
}