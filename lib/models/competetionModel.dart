class Competition {
  Map<String, dynamic> rank;

  Competition({required this.rank});

  Map<String, dynamic> toMap() {
    return {
      'rank': rank,
    };
  }

  factory Competition.fromFirestore(Map<String, dynamic> firestoreData) {
    return Competition(
      rank: firestoreData['rank'] as Map<String, dynamic>,
    );
  }
}
