import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class PredictionService {
  List<List<dynamic>> allMatches = [];
  List<String> teamList = [];
  Map<String, double> teamRatings = {};

  Future<void> loadCSVData() async {
    try {
      var rawData = await rootBundle.loadString('assets/results.csv');
      List<List<dynamic>> data = const CsvToListConverter(
        fieldDelimiter: ',',
        textEndDelimiter: '\n',
        eol: '\n',
      ).convert(rawData.replaceAll('\r\n', '\n'));

      allMatches = data;
      Set<String> teams = {};

      // 1. تهيئة المنتخبات بنقاط بدائية
      for (int i = 1; i < data.length; i++) {
        if (data[i].length > 2) {
          String home = data[i][1].toString().trim();
          String away = data[i][2].toString().trim();
          if (home.isNotEmpty) {
            teams.add(home);
            teamRatings[home] = 1500.0;
          }
          if (away.isNotEmpty) {
            teams.add(away);
            teamRatings[away] = 1500.0;
          }
        }
      }
      teamList = teams.toList()..sort();

      // 2. محاكاة التاريخ بناءً على (قوة الخصم + أهمية البطولة + تاريخ المباراة)
      // 2. محاكاة التاريخ بذكاء الجيل الحالي وفارق الأهداف
      for (int i = 1; i < data.length; i++) {
        if (data[i].length > 5) {
          String dateStr = data[i][0].toString();
          String home = data[i][1].toString().trim();
          String away = data[i][2].toString().trim();
          int? homeScore = int.tryParse(data[i][3].toString());
          int? awayScore = int.tryParse(data[i][4].toString());
          String tournament = data[i][5].toString().toLowerCase();

          if (homeScore == null || awayScore == null) continue;

          double ratingA = teamRatings[home] ?? 1500.0;
          double ratingB = teamRatings[away] ?? 1500.0;

          // أ. وزن البطولة
          double kFactor = 20.0;
          if (tournament.contains('friendly'))
            kFactor = 10.0;
          else if (tournament.contains('world cup'))
            kFactor = 60.0;
          else
            kFactor = 40.0;

          // 🔥 ب. عامل الجيل الحالي: تدمير تأثير الماضي والتركيز على الحاضر
          int year = int.tryParse(dateStr.split('-')[0]) ?? 2000;
          if (year < 2000)
            kFactor *= 0.05; // المباريات القديمة جداً تأثيرها شبه معدوم (5%)
          else if (year < 2018)
            kFactor *= 0.3; // جيل ما قبل الكورونا تأثيره ضعيف (30%)
          else
            kFactor *=
                2.0; // جيل العصر الحالي (من 2018 لليوم) تأثيره مضاعف (200%)

          // 🔥 ج. بونص فارق الأهداف (النتائج الكبيرة تغير الريتينج بقوة)
          int goalDifference = (homeScore - awayScore).abs();
          if (goalDifference >= 3)
            kFactor *= 1.5; // إذا الفارق 3 أهداف أو أكثر، تزيد أهمية المباراة
          if (goalDifference >= 5) kFactor *= 2.0;

          // د. النتيجة الفعلية
          double actualScoreA =
              homeScore > awayScore
                  ? 1.0
                  : (homeScore == awayScore ? 0.5 : 0.0);

          // هـ. النتيجة المتوقعة
          double expectedScoreA =
              1.0 /
              (1.0 +
                  pow(
                    10,
                    (ratingB - ratingA) / 600.0,
                  )); // استخدمنا 600 لتنعيم الفروقات

          // و. تحديث النقاط
          teamRatings[home] =
              ratingA + kFactor * (actualScoreA - expectedScoreA);
          teamRatings[away] =
              ratingB - kFactor * (actualScoreA - expectedScoreA);
        }
      }
    } catch (e) {
      print("Error loading CSV: $e");
    }
  }

  // 3. دالة التوقع الاحترافية
  Map<String, double> predictMatch(String teamA, String teamB) {
    double ratingA = teamRatings[teamA] ?? 1500.0;
    double ratingB = teamRatings[teamB] ?? 1500.0;

    // 💡 تعديل المقياس إلى 800.0 لتنعيم الفوارق وجعلها منطقية كروياً
    double expectedA = 1.0 / (1.0 + pow(10, (ratingB - ratingA) / 800.0));
    double expectedB = 1.0 - expectedA;

    double percentageA = expectedA * 100;
    double percentageB = expectedB * 100;

    // 💡 لمسة ذكية: إذا كان الفريقين عمالقة (تقييمهم عالي جداً)، نقرب النسبة أكثر لبعضها
    if (ratingA > 1700 && ratingB > 1700) {
      // تقريب الفارق بنسبة 40% لتعكس تكافؤ مباريات القمة
      double mid = 50.0;
      percentageA = mid + (percentageA - mid) * 0.6;
      percentageB = 100.0 - percentageA;
    }

    // حماية الحدود للـ UI
    percentageA = percentageA.clamp(5.0, 95.0);
    percentageB = percentageB.clamp(5.0, 95.0);

    return {
      'teamA': double.parse(percentageA.toStringAsFixed(1)),
      'teamB': double.parse(percentageB.toStringAsFixed(1)),
    };
  }
}
