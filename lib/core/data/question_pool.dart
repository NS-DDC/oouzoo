import 'dart:math';

enum QuestionCategory { love, memory, future, fun, deep }

class QuestionEntry {
  final int id;
  final String question;
  final QuestionCategory category;

  const QuestionEntry({
    required this.id,
    required this.question,
    required this.category,
  });
}

/// Returns today's question ID (same for both partners using date seed).
///
/// Both partners will see the same question on the same day because the seed
/// is derived purely from the current date (YYYYMMDD).
int getTodayQuestionId() {
  final today = DateTime.now();
  final seed = today.year * 10000 + today.month * 100 + today.day;
  final random = Random(seed);
  return questionPool[random.nextInt(questionPool.length)].id;
}

const List<QuestionEntry> questionPool = [
  // ──────────────────────────────────────────────
  // love (사랑) — 20 questions
  // ──────────────────────────────────────────────
  QuestionEntry(
    id: 1,
    question: '나를 처음 좋아하게 된 순간이 언제였어?',
    category: QuestionCategory.love,
  ),
  QuestionEntry(
    id: 2,
    question: '내가 할 때 가장 설레는 행동은 뭐야?',
    category: QuestionCategory.love,
  ),
  QuestionEntry(
    id: 3,
    question: '우리 사이에서 가장 좋아하는 스킨십은?',
    category: QuestionCategory.love,
  ),
  QuestionEntry(
    id: 4,
    question: '사랑한다는 말 대신 다른 표현을 한다면 뭐라고 할래?',
    category: QuestionCategory.love,
  ),
  QuestionEntry(
    id: 5,
    question: '내가 없는 하루를 상상하면 어떤 느낌이야?',
    category: QuestionCategory.love,
  ),
  QuestionEntry(
    id: 6,
    question: '나한테 반한 포인트 3가지를 말해줄 수 있어?',
    category: QuestionCategory.love,
  ),
  QuestionEntry(
    id: 7,
    question: '우리 커플만의 사랑 표현 방식이 있다면 뭘까?',
    category: QuestionCategory.love,
  ),
  QuestionEntry(
    id: 8,
    question: '내가 해준 말 중에 가장 감동받은 말은?',
    category: QuestionCategory.love,
  ),
  QuestionEntry(
    id: 9,
    question: '연애하면서 나 때문에 심장이 뛴 적 있어? 언제?',
    category: QuestionCategory.love,
  ),
  QuestionEntry(
    id: 10,
    question: '나의 어떤 모습이 가장 사랑스러워?',
    category: QuestionCategory.love,
  ),
  QuestionEntry(
    id: 11,
    question: '지금 이 순간 나한테 하고 싶은 말이 있다면?',
    category: QuestionCategory.love,
  ),
  QuestionEntry(
    id: 12,
    question: '우리가 함께 늙어가는 모습을 상상하면 어때?',
    category: QuestionCategory.love,
  ),
  QuestionEntry(
    id: 13,
    question: '내 목소리가 가장 좋을 때는 언제야?',
    category: QuestionCategory.love,
  ),
  QuestionEntry(
    id: 14,
    question: '나를 동물에 비유하면 뭐라고 생각해? 이유는?',
    category: QuestionCategory.love,
  ),
  QuestionEntry(
    id: 15,
    question: '내가 옆에 있을 때 가장 편안한 순간은?',
    category: QuestionCategory.love,
  ),
  QuestionEntry(
    id: 16,
    question: '우리 관계를 색깔로 표현하면 무슨 색일까?',
    category: QuestionCategory.love,
  ),
  QuestionEntry(
    id: 17,
    question: '나한테 고마운 점 하나만 말해줄래?',
    category: QuestionCategory.love,
  ),
  QuestionEntry(
    id: 18,
    question: '내가 모르는 나의 매력이 있다면 뭘까?',
    category: QuestionCategory.love,
  ),
  QuestionEntry(
    id: 19,
    question: '우리 사랑을 노래 한 곡으로 표현하면 뭘까?',
    category: QuestionCategory.love,
  ),
  QuestionEntry(
    id: 20,
    question: '나한테 꼭 해주고 싶은 말이 있다면?',
    category: QuestionCategory.love,
  ),

  // ──────────────────────────────────────────────
  // memory (추억) — 20 questions
  // ──────────────────────────────────────────────
  QuestionEntry(
    id: 21,
    question: '우리의 첫 만남 날, 어떤 인상을 받았어?',
    category: QuestionCategory.memory,
  ),
  QuestionEntry(
    id: 22,
    question: '처음 손 잡았을 때 기분이 어땠어?',
    category: QuestionCategory.memory,
  ),
  QuestionEntry(
    id: 23,
    question: '우리 첫 데이트에서 가장 기억나는 장면은?',
    category: QuestionCategory.memory,
  ),
  QuestionEntry(
    id: 24,
    question: '함께한 여행 중 가장 좋았던 곳은 어디야?',
    category: QuestionCategory.memory,
  ),
  QuestionEntry(
    id: 25,
    question: '우리가 가장 많이 웃었던 순간이 언제야?',
    category: QuestionCategory.memory,
  ),
  QuestionEntry(
    id: 26,
    question: '같이 먹은 음식 중 가장 맛있었던 건 뭐야?',
    category: QuestionCategory.memory,
  ),
  QuestionEntry(
    id: 27,
    question: '내가 처음 울었을 때 어떤 생각이 들었어?',
    category: QuestionCategory.memory,
  ),
  QuestionEntry(
    id: 28,
    question: '우리의 기념일 중 가장 특별했던 날은?',
    category: QuestionCategory.memory,
  ),
  QuestionEntry(
    id: 29,
    question: '함께 본 영화 중 가장 기억에 남는 건?',
    category: QuestionCategory.memory,
  ),
  QuestionEntry(
    id: 30,
    question: '우리가 처음 싸웠을 때 기억나? 무슨 느낌이었어?',
    category: QuestionCategory.memory,
  ),
  QuestionEntry(
    id: 31,
    question: '내가 해준 서프라이즈 중 가장 좋았던 건?',
    category: QuestionCategory.memory,
  ),
  QuestionEntry(
    id: 32,
    question: '비 오는 날 우리만의 특별한 추억이 있어?',
    category: QuestionCategory.memory,
  ),
  QuestionEntry(
    id: 33,
    question: '처음으로 서로의 친구를 만났을 때 어땠어?',
    category: QuestionCategory.memory,
  ),
  QuestionEntry(
    id: 34,
    question: '우리가 함께 도전했던 것 중 가장 재밌었던 건?',
    category: QuestionCategory.memory,
  ),
  QuestionEntry(
    id: 35,
    question: '사귀기 전에 나한테 어떤 첫인상을 가졌어?',
    category: QuestionCategory.memory,
  ),
  QuestionEntry(
    id: 36,
    question: '우리 사진 중 가장 좋아하는 사진은 어떤 거야?',
    category: QuestionCategory.memory,
  ),
  QuestionEntry(
    id: 37,
    question: '나랑 처음 통화했을 때 기억나? 무슨 얘기 했어?',
    category: QuestionCategory.memory,
  ),
  QuestionEntry(
    id: 38,
    question: '우리가 밤새 이야기한 적 있어? 무슨 얘기였어?',
    category: QuestionCategory.memory,
  ),
  QuestionEntry(
    id: 39,
    question: '나한테 받은 선물 중 가장 기억에 남는 건?',
    category: QuestionCategory.memory,
  ),
  QuestionEntry(
    id: 40,
    question: '우리 관계에서 가장 성장했다고 느낀 순간은?',
    category: QuestionCategory.memory,
  ),

  // ──────────────────────────────────────────────
  // future (미래) — 20 questions
  // ──────────────────────────────────────────────
  QuestionEntry(
    id: 41,
    question: '5년 후 우리는 어떤 모습일 것 같아?',
    category: QuestionCategory.future,
  ),
  QuestionEntry(
    id: 42,
    question: '같이 꼭 가보고 싶은 나라가 있어?',
    category: QuestionCategory.future,
  ),
  QuestionEntry(
    id: 43,
    question: '우리만의 집이 생긴다면 어떤 분위기였으면 좋겠어?',
    category: QuestionCategory.future,
  ),
  QuestionEntry(
    id: 44,
    question: '같이 도전해 보고 싶은 취미가 있어?',
    category: QuestionCategory.future,
  ),
  QuestionEntry(
    id: 45,
    question: '나이 들어서도 꼭 함께 하고 싶은 것은?',
    category: QuestionCategory.future,
  ),
  QuestionEntry(
    id: 46,
    question: '우리 결혼식은 어떤 느낌이었으면 좋겠어?',
    category: QuestionCategory.future,
  ),
  QuestionEntry(
    id: 47,
    question: '아이가 생긴다면 어떤 부모가 되고 싶어?',
    category: QuestionCategory.future,
  ),
  QuestionEntry(
    id: 48,
    question: '은퇴 후에 어디서 살고 싶어?',
    category: QuestionCategory.future,
  ),
  QuestionEntry(
    id: 49,
    question: '같이 이루고 싶은 버킷 리스트가 있어?',
    category: QuestionCategory.future,
  ),
  QuestionEntry(
    id: 50,
    question: '다음 기념일에 뭘 하고 싶어?',
    category: QuestionCategory.future,
  ),
  QuestionEntry(
    id: 51,
    question: '10년 후에도 같이 하고 있을 것 같은 습관은?',
    category: QuestionCategory.future,
  ),
  QuestionEntry(
    id: 52,
    question: '우리 커플 여행 버킷리스트 1순위는?',
    category: QuestionCategory.future,
  ),
  QuestionEntry(
    id: 53,
    question: '같이 살게 되면 꼭 지키고 싶은 규칙이 있어?',
    category: QuestionCategory.future,
  ),
  QuestionEntry(
    id: 54,
    question: '우리가 함께 운영하는 가게가 있다면 어떤 가게일까?',
    category: QuestionCategory.future,
  ),
  QuestionEntry(
    id: 55,
    question: '반려동물을 키운다면 어떤 동물이 좋아?',
    category: QuestionCategory.future,
  ),
  QuestionEntry(
    id: 56,
    question: '이번 달 안에 같이 하고 싶은 것 하나만?',
    category: QuestionCategory.future,
  ),
  QuestionEntry(
    id: 57,
    question: '우리 아이에게 꼭 알려주고 싶은 가치관이 있다면?',
    category: QuestionCategory.future,
  ),
  QuestionEntry(
    id: 58,
    question: '같이 배우고 싶은 것이 있다면 뭐야?',
    category: QuestionCategory.future,
  ),
  QuestionEntry(
    id: 59,
    question: '미래의 우리에게 편지를 쓴다면 뭐라고 쓸래?',
    category: QuestionCategory.future,
  ),
  QuestionEntry(
    id: 60,
    question: '우리만의 전통으로 만들고 싶은 것이 있어?',
    category: QuestionCategory.future,
  ),

  // ──────────────────────────────────────────────
  // fun (재미) — 20 questions
  // ──────────────────────────────────────────────
  QuestionEntry(
    id: 61,
    question: '나를 이모지 하나로 표현하면 뭐야?',
    category: QuestionCategory.fun,
  ),
  QuestionEntry(
    id: 62,
    question: '내가 몰래 하는 귀여운 습관이 있다면?',
    category: QuestionCategory.fun,
  ),
  QuestionEntry(
    id: 63,
    question: '우리 커플이 무인도에 간다면 뭘 가져갈래?',
    category: QuestionCategory.fun,
  ),
  QuestionEntry(
    id: 64,
    question: '나랑 몸이 바뀐다면 제일 먼저 뭘 할 거야?',
    category: QuestionCategory.fun,
  ),
  QuestionEntry(
    id: 65,
    question: '내가 요리사라면 어떤 음식을 잘 만들 것 같아?',
    category: QuestionCategory.fun,
  ),
  QuestionEntry(
    id: 66,
    question: '우리 커플을 드라마 장르로 표현하면?',
    category: QuestionCategory.fun,
  ),
  QuestionEntry(
    id: 67,
    question: '내가 갑자기 슈퍼히어로가 되면 어떤 능력일 것 같아?',
    category: QuestionCategory.fun,
  ),
  QuestionEntry(
    id: 68,
    question: '우리 중 좀비 아포칼립스에서 더 오래 살아남을 사람은?',
    category: QuestionCategory.fun,
  ),
  QuestionEntry(
    id: 69,
    question: '내가 연예인이라면 어떤 타입의 연예인일 것 같아?',
    category: QuestionCategory.fun,
  ),
  QuestionEntry(
    id: 70,
    question: '우리 커플 MBTI 궁합이 어떤 것 같아?',
    category: QuestionCategory.fun,
  ),
  QuestionEntry(
    id: 71,
    question: '나한테 별명을 새로 지어준다면 뭘로 할 거야?',
    category: QuestionCategory.fun,
  ),
  QuestionEntry(
    id: 72,
    question: '내가 동화 속 캐릭터라면 누구일 것 같아?',
    category: QuestionCategory.fun,
  ),
  QuestionEntry(
    id: 73,
    question: '100만 원이 갑자기 생기면 우리 뭐 할래?',
    category: QuestionCategory.fun,
  ),
  QuestionEntry(
    id: 74,
    question: '내 잠버릇 중 가장 웃긴 건 뭐야?',
    category: QuestionCategory.fun,
  ),
  QuestionEntry(
    id: 75,
    question: '우리 중 요리 대결하면 누가 이길까?',
    category: QuestionCategory.fun,
  ),
  QuestionEntry(
    id: 76,
    question: '나를 음식에 비유하면 어떤 음식이야?',
    category: QuestionCategory.fun,
  ),
  QuestionEntry(
    id: 77,
    question: '타임머신이 있다면 우리의 어떤 순간으로 돌아갈래?',
    category: QuestionCategory.fun,
  ),
  QuestionEntry(
    id: 78,
    question: '내가 모르는 나의 웃긴 습관이 있어?',
    category: QuestionCategory.fun,
  ),
  QuestionEntry(
    id: 79,
    question: '우리 커플 유튜브 채널을 만든다면 컨셉은?',
    category: QuestionCategory.fun,
  ),
  QuestionEntry(
    id: 80,
    question: '내가 하루 동안 투명인간이 되면 뭘 할 것 같아?',
    category: QuestionCategory.fun,
  ),

  // ──────────────────────────────────────────────
  // deep (깊은 대화) — 20 questions
  // ──────────────────────────────────────────────
  QuestionEntry(
    id: 81,
    question: '사랑이란 뭐라고 생각해?',
    category: QuestionCategory.deep,
  ),
  QuestionEntry(
    id: 82,
    question: '연인 사이에서 가장 중요한 가치는 뭘까?',
    category: QuestionCategory.deep,
  ),
  QuestionEntry(
    id: 83,
    question: '나한테 솔직하게 말 못 한 적이 있어?',
    category: QuestionCategory.deep,
  ),
  QuestionEntry(
    id: 84,
    question: '우리 관계에서 가장 힘들었던 시기는 언제였어?',
    category: QuestionCategory.deep,
  ),
  QuestionEntry(
    id: 85,
    question: '나를 만나고 나서 달라진 점이 있다면?',
    category: QuestionCategory.deep,
  ),
  QuestionEntry(
    id: 86,
    question: '좋은 관계를 유지하려면 가장 필요한 것은 뭘까?',
    category: QuestionCategory.deep,
  ),
  QuestionEntry(
    id: 87,
    question: '지금 가장 고민인 것은 뭐야? 내가 도울 수 있을까?',
    category: QuestionCategory.deep,
  ),
  QuestionEntry(
    id: 88,
    question: '혼자만의 시간과 함께하는 시간 중 뭐가 더 필요해?',
    category: QuestionCategory.deep,
  ),
  QuestionEntry(
    id: 89,
    question: '우리 사이에 개선하고 싶은 점이 있다면?',
    category: QuestionCategory.deep,
  ),
  QuestionEntry(
    id: 90,
    question: '행복의 기준이 뭐야? 지금 행복해?',
    category: QuestionCategory.deep,
  ),
  QuestionEntry(
    id: 91,
    question: '나한테 서운했지만 말하지 못한 적이 있어?',
    category: QuestionCategory.deep,
  ),
  QuestionEntry(
    id: 92,
    question: '인생에서 후회하는 것이 있다면 뭐야?',
    category: QuestionCategory.deep,
  ),
  QuestionEntry(
    id: 93,
    question: '가장 두려운 것은 뭐야? 그 이유는?',
    category: QuestionCategory.deep,
  ),
  QuestionEntry(
    id: 94,
    question: '나에게 가장 감사한 순간은 언제였어?',
    category: QuestionCategory.deep,
  ),
  QuestionEntry(
    id: 95,
    question: '우리가 위기를 겪는다면 어떻게 극복하고 싶어?',
    category: QuestionCategory.deep,
  ),
  QuestionEntry(
    id: 96,
    question: '사람은 변할 수 있다고 생각해?',
    category: QuestionCategory.deep,
  ),
  QuestionEntry(
    id: 97,
    question: '용서한다는 건 어떤 의미라고 생각해?',
    category: QuestionCategory.deep,
  ),
  QuestionEntry(
    id: 98,
    question: '우리 관계에서 내가 꼭 알아줬으면 하는 것은?',
    category: QuestionCategory.deep,
  ),
  QuestionEntry(
    id: 99,
    question: '지금의 내가 1년 전의 나에게 해주고 싶은 말은?',
    category: QuestionCategory.deep,
  ),
  QuestionEntry(
    id: 100,
    question: '진정한 사랑은 어떤 모습이라고 생각해?',
    category: QuestionCategory.deep,
  ),
];
