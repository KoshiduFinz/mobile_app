import 'interest_tag.dart';

class MockInterests {
  static List<InterestTag> getMyInterests() {
    return [
      InterestTag(id: '1', name: '#music', soulsCount: 0, isSelected: true),
      InterestTag(id: '2', name: '#movies', soulsCount: 0, isSelected: true),
      InterestTag(id: '3', name: '#gaming', soulsCount: 0, isSelected: true),
      InterestTag(id: '4', name: '#games', soulsCount: 0, isSelected: true),
      InterestTag(id: '5', name: '#technology', soulsCount: 0, isSelected: true),
      InterestTag(id: '6', name: '#leo', soulsCount: 0, isSelected: true),
      InterestTag(id: '7', name: '#dating', soulsCount: 0, isSelected: true),
      InterestTag(id: '8', name: '#longtermrelationship', soulsCount: 0, isSelected: true),
      InterestTag(id: '9', name: '#single', soulsCount: 0, isSelected: true),
    ];
  }

  static List<InterestTag> getOtherInterests() {
    return [
      InterestTag(id: '10', name: '#singing', soulsCount: 1570000),
      InterestTag(id: '11', name: '#action', soulsCount: 1560000),
      InterestTag(id: '12', name: '#animation', soulsCount: 1450000),
      InterestTag(id: '13', name: '#drawing', soulsCount: 1430000),
      InterestTag(id: '14', name: '#boardgames', soulsCount: 1420000),
      InterestTag(id: '15', name: '#crime', soulsCount: 1300000),
      InterestTag(id: '16', name: '#writing', soulsCount: 1270000),
      InterestTag(id: '17', name: '#languages', soulsCount: 1270000),
      InterestTag(id: '18', name: '#philosophy', soulsCount: 1190000),
      InterestTag(id: '19', name: '#universe', soulsCount: 1190000),
      InterestTag(id: '20', name: '#photography', soulsCount: 1150000),
      InterestTag(id: '21', name: '#travel', soulsCount: 1120000),
      InterestTag(id: '22', name: '#cooking', soulsCount: 1100000),
      InterestTag(id: '23', name: '#fitness', soulsCount: 1080000),
      InterestTag(id: '24', name: '#reading', soulsCount: 1050000),
    ];
  }

  static String formatSoulsCount(int count) {
    if (count >= 1000000) {
      final millions = count / 1000000;
      return '${millions.toStringAsFixed(2)}M';
    } else if (count >= 1000) {
      final thousands = count / 1000;
      return '${thousands.toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

