import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButtonBar extends StatelessWidget {
  final VoidCallback onRegister;
  final VoidCallback onSignIn;
  final bool isLoginSelected;

  const CustomButtonBar({
    super.key,
    required this.onRegister,
    required this.onSignIn,
    required this.isLoginSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: isLoginSelected
                ? MediaQuery.of(context).size.width / 2 - 24 - 24
                : 0,
            child: Container(
              width: MediaQuery.of(context).size.width / 2 - 48,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
            ),
          ),
          Row(
            children: [
              _buildButton("Kayıt Ol", !isLoginSelected, onRegister),
              _buildButton("Giriş Yap", isLoginSelected, onSignIn),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.blue.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.grey.shade600,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}
