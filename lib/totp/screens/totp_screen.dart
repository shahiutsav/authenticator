import 'package:authenticator/totp/widgets/totp_code_card.dart';
import 'package:flutter/material.dart';

class TOTPScreen extends StatelessWidget {
  const TOTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Expanded(
          child: Center(
            child: TOTPCodeCard(),
          ),
        )
      ],
    );
  }
}
