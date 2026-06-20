import 'package:flutter/material.dart';
import 'package:wc_26/core/const/app_color.dart';

class CustomDropDown extends StatelessWidget {
  const CustomDropDown({
    super.key,
    required this.isTeamA,
    required this.selectedTeamA,
    required this.selectedTeamB,
    required this.teamList, // 💡 استقبل القائمة جاهزة هنا
    required this.onChanged,
  });

  final bool isTeamA;
  final String? selectedTeamA;
  final String? selectedTeamB;
  final List<String> teamList; // تعريف القائمة
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: isTeamA ? selectedTeamA : selectedTeamB,
          hint: Text(
            isTeamA ? "A فريق " : "B فريق ",
            style: const TextStyle(color: Colors.white54, fontSize: 15),
          ),
          dropdownColor: AppColor.background,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.amber),
          items:
              teamList.map((String team) {
                // استخدام القائمة الممررة
                return DropdownMenuItem<String>(
                  value: team,
                  child: Text(
                    team,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
