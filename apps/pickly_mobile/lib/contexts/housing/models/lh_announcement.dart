/// LH API 응답 모델
class LhAnnouncement {
  final String panId; // 공고 ID
  final String panNm; // 공고명
  final String uppAisTpCdNm; // 공급유형
  final String cnpCdNm; // 지역
  final String hshldCo; // 공급호수
  final String rcritPblancDe; // 모집공고일
  final String subscrptRceptBgnde; // 청약시작일
  final String subscrptRceptEndde; // 청약종료일
  final String przwnerPresnatnDe; // 당첨자발표일

  LhAnnouncement({
    required this.panId,
    required this.panNm,
    required this.uppAisTpCdNm,
    required this.cnpCdNm,
    required this.hshldCo,
    required this.rcritPblancDe,
    required this.subscrptRceptBgnde,
    required this.subscrptRceptEndde,
    required this.przwnerPresnatnDe,
  });

  factory LhAnnouncement.fromJson(Map<String, dynamic> json) {
    return LhAnnouncement(
      panId: json['PAN_ID'] ?? '',
      panNm: json['PAN_NM'] ?? '',
      uppAisTpCdNm: json['UPP_AIS_TP_CD_NM'] ?? '',
      cnpCdNm: json['CNP_CD_NM'] ?? '',
      hshldCo: json['HSHLD_CO'] ?? '0',
      rcritPblancDe: json['RCRIT_PBLANC_DE'] ?? '',
      subscrptRceptBgnde: json['SUBSCRPT_RCEPT_BGNDE'] ?? '',
      subscrptRceptEndde: json['SUBSCRPT_RCEPT_ENDDE'] ?? '',
      przwnerPresnatnDe: json['PRZWNER_PRESNATN_DE'] ?? '',
    );
  }

  /// LH 데이터를 Supabase 구조로 변환
  Map<String, dynamic> toSupabaseFormat() {
    return {
      'title': panNm,
      'subtitle': _calculateDaysRemaining(),
      'category': '주거',
      'source': 'LH',
      'source_id': panId,
      'raw_data': {
        'PAN_ID': panId,
        'PAN_NM': panNm,
        'UPP_AIS_TP_CD_NM': uppAisTpCdNm,
        'CNP_CD_NM': cnpCdNm,
        'HSHLD_CO': hshldCo,
        'RCRIT_PBLANC_DE': rcritPblancDe,
        'SUBSCRPT_RCEPT_BGNDE': subscrptRceptBgnde,
        'SUBSCRPT_RCEPT_ENDDE': subscrptRceptEndde,
        'PRZWNER_PRESNATN_DE': przwnerPresnatnDe,
      },
      'display_config': _generateCommonSections(),
      'housing_types': _generateDefaultHousingTypes(),
      'status': 'active',
    };
  }

  String _calculateDaysRemaining() {
    try {
      final endDate = DateTime.parse(subscrptRceptEndde);
      final now = DateTime.now();
      final diff = endDate.difference(now).inDays;

      if (diff > 0) {
        return '공고 마감까지 $diff일 남았어요';
      } else if (diff == 0) {
        return '오늘 마감이에요!';
      } else {
        return '마감되었습니다';
      }
    } catch (e) {
      return '';
    }
  }

  Map<String, dynamic> _generateCommonSections() {
    return {
      'commonSections': [
        {
          'type': 'basic_info',
          'title': '기본 정보',
          'icon': 'info',
          'enabled': true,
          'order': 1,
          'fields': [
            {
              'key': 'source',
              'label': '공급 기관',
              'value': 'LH $uppAisTpCdNm',
              'visible': true,
              'order': 1
            },
            {
              'key': 'category',
              'label': '카테고리',
              'value': uppAisTpCdNm,
              'visible': true,
              'order': 2
            },
          ],
        },
        {
          'type': 'schedule',
          'title': '일정',
          'icon': 'calendar_today',
          'enabled': true,
          'order': 2,
          'fields': [
            {
              'key': 'apply_period',
              'label': '접수 기간',
              'value': _formatDateRange(subscrptRceptBgnde, subscrptRceptEndde),
              'visible': true,
              'order': 1
            },
            {
              'key': 'announcement_date',
              'label': '당첨자 발표',
              'value': _formatDate(przwnerPresnatnDe),
              'visible': true,
              'order': 2
            },
          ],
        },
        {
          'type': 'property',
          'title': '단지 정보',
          'icon': 'apartment',
          'enabled': true,
          'order': 3,
          'fields': [
            {
              'key': 'name',
              'label': '단지명',
              'value': panNm,
              'visible': true,
              'order': 1
            },
            {
              'key': 'region',
              'label': '지역',
              'value': cnpCdNm,
              'visible': true,
              'order': 2
            },
            {
              'key': 'total_supply',
              'label': '총 공급호수',
              'value': '$hshldCo호',
              'visible': true,
              'order': 3
            },
          ],
        },
      ],
    };
  }

  List<Map<String, dynamic>> _generateDefaultHousingTypes() {
    // 기본 청년 타입 자동 생성
    return [
      {
        'id': 'auto-youth-${DateTime.now().millisecondsSinceEpoch}',
        'area': 16,
        'areaLabel': '16㎡ (약 5평)',
        'type': '타입 자동생성',
        'targetGroup': '청년',
        'tabLabel': '청년형',
        'order': 1,
        'floorPlanImage': '',
        'sections': [
          {
            'type': 'eligibility',
            'title': '신청 자격',
            'icon': 'person',
            'enabled': true,
            'order': 1,
            'fields': [
              {
                'key': 'age',
                'label': '연령',
                'value': '만 19세 ~ 39세',
                'visible': true,
                'order': 1
              },
              {
                'key': 'residence',
                'label': '거주',
                'value': '$cnpCdNm 거주자',
                'visible': true,
                'order': 2
              },
              {
                'key': 'housing',
                'label': '주택',
                'value': '무주택',
                'visible': true,
                'order': 3
              },
            ],
          },
          {
            'type': 'income',
            'title': '소득 기준',
            'icon': 'attach_money',
            'enabled': true,
            'order': 2,
            'description': '전년도 도시근로자 가구당 월평균 소득 기준',
            'fields': [
              {
                'key': 'household_income',
                'label': '가구 소득',
                'value': '전년도 도시근로자 월평균 소득 100% 이하',
                'detail': '1인 가구: 4,445,807원',
                'visible': true,
                'order': 1
              },
              {
                'key': 'personal_income',
                'label': '본인 소득',
                'value': '전년도 도시근로자 월평균 소득 70% 이하',
                'detail': '1인 가구: 3,112,065원',
                'visible': true,
                'order': 2
              },
              {
                'key': 'asset',
                'label': '자산',
                'value': '총자산 2억 8,800만원 이하',
                'detail': '부동산, 금융자산 등 합산',
                'visible': true,
                'order': 3
              },
              {
                'key': 'car',
                'label': '자동차',
                'value': '자동차 가액 3,683만원 이하',
                'detail': '차량 1대 기준',
                'visible': true,
                'order': 4
              },
            ],
          },
          {
            'type': 'pricing',
            'title': '공급 조건',
            'icon': 'home',
            'enabled': true,
            'order': 3,
            'fields': [
              {
                'key': 'supply_count',
                'label': '공급호수',
                'value': hshldCo,
                'visible': true,
                'order': 1
              },
              {
                'key': 'note',
                'label': '안내',
                'value': '임대료는 백오피스에서 수정해주세요',
                'visible': true,
                'order': 2
              },
            ],
          },
        ],
      },
    ];
  }

  String _formatDate(String date) {
    try {
      if (date.length == 8) {
        return '${date.substring(0, 4)}.${date.substring(4, 6)}.${date.substring(6, 8)}';
      }
    } catch (e) {
      // ignore
    }
    return date;
  }

  String _formatDateRange(String start, String end) {
    return '${_formatDate(start)} - ${_formatDate(end)}';
  }
}
