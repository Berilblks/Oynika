import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/features/games/charades/data/charades_repository.dart';
import 'package:oynika/features/games/charades/domain/charades_models.dart';

void main() {
  final source =
      File('assets/data/sessiz_sinema_cards.json').readAsStringSync();
  final rows = (jsonDecode(source) as List).cast<Map<String, dynamic>>();
  final cards = CharadesRepository.decode(source);
  final references =
      (jsonDecode(File('docs/charades_title_sources.json').readAsStringSync())
              as List)
          .cast<Map<String, dynamic>>();
  final baseline =
      (jsonDecode(
                File(
                  'test/fixtures/charades_phase4_cards.json',
                ).readAsStringSync(),
              )
              as List)
          .cast<Map<String, dynamic>>();
  final previousIdentities =
      (jsonDecode(
            File(
              'test/fixtures/charades_phase4_identities.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>);
  // Approved Phase 4.1 scope; any other card must remain byte-for-field equal.
  const renames = {
    'charades-244': ('Yeni Hayat', 'wikidata:Q213411'),
    'charades-450': ('Gizli Dosyalar', 'tvmaze:430'),
    'charades-472': ('Kardeşler Takımı', 'tvmaze:465'),
  };
  const replacements = {
    'charades-027': ('Felekten Bir Gece', 'Orta', 'wikidata:Q219315', 'Film'),
    'charades-044': ('Kutsal Damacana', 'Kolay', 'wikidata:Q12810477', 'Film'),
    'charades-045': ('Eyyvah Eyvah', 'Kolay', 'wikidata:Q5423075', 'Film'),
    'charades-046': (
      'Aşk Tesadüfleri Sever',
      'Orta',
      'wikidata:Q4808148',
      'Film',
    ),
    'charades-234': (
      'Maymunlar Cehennemi',
      'Kolay',
      'wikidata:Q469624',
      'Film',
    ),
    'charades-241': ('Ölümlü Dünya', 'Kolay', 'wikidata:Q47520467', 'Film'),
    'charades-407': ('Ruhsar', 'Orta', 'tvmaze:94093', 'Dizi'),
    'charades-408': ('Çılgın Bediş', 'Orta', 'wikidata:Q6101177', 'Dizi'),
    'charades-410': ('Cennet Mahallesi', 'Kolay', 'tvmaze:60030', 'Dizi'),
    'charades-412': ('Hayat Şarkısı', 'Orta', 'tvmaze:15471', 'Dizi'),
    'charades-421': ('Küçük Ağa', 'Kolay', 'tvmaze:35823', 'Dizi'),
    'charades-422': ('Yılan Hikayesi', 'Kolay', 'tvmaze:54429', 'Dizi'),
    'charades-463': (
      'Bir İstanbul Masalı',
      'Orta',
      'wikidata:Q3556357',
      'Dizi',
    ),
    'charades-465': ('Sefirin Kızı', 'Orta', 'tvmaze:45360', 'Dizi'),
    'charades-475': ('Küçük Sırlar', 'Kolay', 'tvmaze:18868', 'Dizi'),
    'charades-482': ('Gönül Dağı', 'Kolay', 'tvmaze:51098', 'Dizi'),
    'charades-492': ('Adanalı', 'Orta', 'tvmaze:18901', 'Dizi'),
    'charades-496': ('Kardeşlerim', 'Kolay', 'tvmaze:53620', 'Dizi'),
  };
  test(
    'Faz 4.1 yalnız onaylanan 21 kartı değiştirir, diğer 479 kart korunur',
    () {
      expect(baseline, hasLength(500));
      final changed = <String>{};
      for (var i = 0; i < rows.length; i++) {
        final id = rows[i]['id'] as String;
        expect(id, baseline[i]['id']);
        expect(rows[i]['category'], baseline[i]['category']);
        if (!renames.containsKey(id) && !replacements.containsKey(id)) {
          expect(rows[i], baseline[i], reason: id);
          expect(references[i]['identity'], previousIdentities[id], reason: id);
        } else {
          expect(rows[i]['title'], isNot(baseline[i]['title']));
          changed.add(id);
        }
      }
      expect(changed, {...renames.keys, ...replacements.keys});
    },
  );
  test('Üç Türkçe ad düzeltmesinde kimlik, kategori ve zorluk korunur', () {
    for (final entry in renames.entries) {
      final i = rows.indexWhere((r) => r['id'] == entry.key);
      expect(rows[i], {...baseline[i], 'title': entry.value.$1});
      expect(references[i]['identity'], entry.value.$2);
      expect(references[i]['identity'], previousIdentities[entry.key]);
    }
  });
  test(
    '18 yeni yapım kendi kimliği, kaynağı ve anlatım zorluğuyla kayıtlı',
    () {
      final imdbIds = <String>{};
      final currentIdentities = references.map((r) => r['identity']).toSet();
      for (final entry in replacements.entries) {
        final i = rows.indexWhere((r) => r['id'] == entry.key);
        final expected = entry.value;
        final reference = references[i];
        expect(rows[i]['title'], expected.$1);
        expect(rows[i]['difficulty'], expected.$2);
        expect(rows[i]['category'], expected.$4);
        expect(reference['identity'], expected.$3);
        expect(
          currentIdentities,
          isNot(contains(previousIdentities[entry.key])),
        );
        expect(reference['verificationSource'], startsWith('https://'));
        expect(reference['year'], isA<int>());
        expect(reference['imdbId'], matches(RegExp(r'^tt\d+$')));
        expect(imdbIds.add(reference['imdbId'] as String), isTrue);
        expect(reference['aliases'], contains(rows[i]['title']));
        expect(reference['aliases'], contains(reference['canonicalTitle']));
      }
      final ape = references.singleWhere((r) => r['id'] == 'charades-234');
      expect(ape['year'], 2001);
      expect(ape['imdbId'], 'tt0133152');
      final aga = references.singleWhere((r) => r['id'] == 'charades-421');
      expect(aga['year'], 2014);
      expect(aga['imdbId'], 'tt3776084');
    },
  );
  test('Türkçe ve kanonik adlar farklı yapımlarda tekrar etmez', () {
    final owners = <String, String>{};
    String aliasKey(String name) =>
        turkishKey(name).replaceAll(RegExp(r'[^a-z0-9çğıöşü]'), '');
    for (final reference in references) {
      final id = reference['id'] as String;
      final aliases = {
        reference['title'] as String,
        reference['canonicalTitle'] as String,
        ...?((reference['aliases'] as List?)?.cast<String>()),
      };
      for (final name in aliases) {
        final key = aliasKey(name);
        expect(key, isNotEmpty);
        expect(owners[key] ?? id, id, reason: '$name: ${owners[key]} / $id');
        owners[key] = id;
      }
    }
  });
  test('Tam 500 kart: 300 Film ve 200 Dizi, başka kategori yok', () {
    expect(cards, hasLength(500));
    expect(cards.where((c) => c.category == 'Film'), hasLength(300));
    expect(cards.where((c) => c.category == 'Dizi'), hasLength(200));
    expect(cards.map((c) => c.category).toSet(), {'Film', 'Dizi'});
  });
  test('ID ve Türkçe normalleştirilmiş yapım adları benzersiz', () {
    expect(cards.map((c) => c.id).toSet(), hasLength(500));
    expect(cards.map((c) => turkishKey(c.title)).toSet(), hasLength(500));
    for (var i = 0; i < cards.length; i++) {
      expect(cards[i].id, 'charades-${(i + 1).toString().padLeft(3, '0')}');
    }
  });
  test(
    'JSON yalnızca ID, yapım adı, Film/Dizi kategorisi ve zorluk içerir',
    () {
      for (final row in rows) {
        expect(row.keys.toSet(), {'id', 'title', 'category', 'difficulty'});
        expect(row.values.every((v) => v is String), isTrue);
        expect(['Kolay', 'Orta', 'Zor'], contains(row['difficulty']));
        for (final value in row.values.cast<String>()) {
          expect(value, value.trim());
          expect(value, isNotEmpty);
          expect(
            RegExp(
              r'[\u0000-\u001f\u200b-\u200f\uFEFF\uFFFD\u0370-\u052f]',
            ).hasMatch(value),
            isFalse,
          );
          expect(value.contains(RegExp(r'\s{2,}')), isFalse);
        }
      }
    },
  );
  test('Her kartın ayrı yapım kimliği ve denetlenebilir kaynak kaydı vardır', () {
    expect(references, hasLength(500));
    expect(references.map((r) => r['identity']).toSet(), hasLength(500));
    for (var i = 0; i < cards.length; i++) {
      final reference = references[i];
      expect(reference['id'], cards[i].id);
      expect(reference['title'], cards[i].title);
      expect(reference['category'], cards[i].category);
      expect(reference['canonicalTitle'], isNotEmpty);
      expect(
        reference['identity'],
        matches(RegExp(r'^(wikidata:Q\d+|tvmaze:\d+)$')),
      );
      expect(
        reference['source'],
        matches(
          RegExp(
            r'^https://(www\.wikidata\.org/wiki/Q\d+|www\.tvmaze\.com/shows/\d+/)',
          ),
        ),
      );
    }
  });
  test(
    'Aynı film farklı adla iki kart değildir; serinin bağımsız filmleri ayrıdır',
    () {
      final godfathers =
          cards
              .where((c) => ['Baba', 'Baba II', 'Baba III'].contains(c.title))
              .toList();
      expect(godfathers, hasLength(3));
      final ids =
          references
              .where((r) => godfathers.any((c) => c.id == r['id']))
              .map((r) => r['identity'])
              .toSet();
      expect(ids, hasLength(3));
      expect(cards.where((c) => c.title == 'Can Dostum'), hasLength(1));
      expect(cards.where((c) => c.title == 'Can Dostum (2011)'), hasLength(1));
    },
  );
  test('Eksik, fazladan alanlı veya başka kategori içeren kart reddedilir', () {
    final row = {
      'id': 'x',
      'title': 'Film',
      'category': 'Film',
      'difficulty': 'Kolay',
    };
    for (final bad in [
      <String, dynamic>{...row}..remove('title'),
      {...row, 'forbidden': []},
      {...row, 'category': 'Hayvanlar'},
      {...row, 'title': 7},
    ]) {
      expect(
        () => CharadesRepository.decode(jsonEncode([bad])),
        throwsFormatException,
      );
    }
    expect(() => CharadesRepository.decode('[]'), throwsFormatException);
    expect(
      () => CharadesRepository.decode(jsonEncode([row, row])),
      throwsFormatException,
    );
  });
}
