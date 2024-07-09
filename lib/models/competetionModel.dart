class Competetion {
  Map<String, dynamic> rank;

  Competetion({required this.rank});

  Map<String, dynamic> toMap() {
    return {
      'rank': rank,
    };
  }

  factory Competetion.fromFirestore(Map<String, dynamic> firestoreData) {
    return Competetion(
      rank: firestoreData['rank'] as Map<String, dynamic>,
    );
  }
}
