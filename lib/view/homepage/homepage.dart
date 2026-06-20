import 'package:flutter/material.dart';
import 'package:wc_26/core/const/app_color.dart';
import 'package:wc_26/core/const/app_image.dart';
import 'package:wc_26/prediction_service.dart';
import 'package:wc_26/view/homepage/widgets/drop_down.dart';
import 'package:wc_26/view/homepage/widgets/on_predict_pressed.dart';
import 'package:wc_26/view/homepage/widgets/result_card.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final PredictionService _predictionService = PredictionService();
  bool isLoading = true;
  Map<String, double>? predictionResults;
  String? selectedTeamA;
  String? selectedTeamB;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    await _predictionService.loadCSVData();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColor.background,
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    AppImage.cup,
                    fit: BoxFit.contain,
                    height: 250,
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "توقع المباراة",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "توقع نتائج المباراة بناء على البيانات التاريخية",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: CustomDropDown(
                        teamList: _predictionService.teamList,
                        isTeamA: true,
                        selectedTeamA: selectedTeamA,
                        selectedTeamB: selectedTeamB,
                        onChanged: (value) {
                          setState(() {
                            selectedTeamA = value;
                          });
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          "ضد",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: CustomDropDown(
                        teamList: _predictionService.teamList,
                        isTeamA: false,
                        selectedTeamA: selectedTeamA,
                        selectedTeamB: selectedTeamB,
                        onChanged: (value) {
                          setState(() {
                            selectedTeamB = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    onPressed:
                        () => onPredictPressed(
                          context: context,
                          teamA: selectedTeamA ?? "",
                          teamB: selectedTeamB ?? "",
                          onSuccess: () {
                            setState(() {
                              predictionResults = _predictionService
                                  .predictMatch(selectedTeamA!, selectedTeamB!);
                            });
                          },
                        ),
                    child: const Text("توقع المباراة"),
                  ),
                ),
                const SizedBox(height: 32),

                if (predictionResults != null)
                  ResultCard(
                    predictionResults: predictionResults,
                    selectedTeamA: selectedTeamA,
                    selectedTeamB: selectedTeamB,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
