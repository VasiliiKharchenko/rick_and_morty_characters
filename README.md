Ссылка на тестовое задание: https://disk.yandex.ru/i/J9ldF10NLGp-Vg
# Rick & Morty Characters

Flutter-приложение для просмотра персонажей вселенной «Rick and Morty». Реализованы пагинация, оффлайн‑кэш в SQLite, избранное и отладочный модуль перехвата HTTP(S)‑трафика (Charles/Proxyman/Fiddler).

## Стек
- Flutter 3.x, Dart 3.x
- State: `flutter_bloc` (BLoC, Cubit)
- HTTP: `dio` + логирование + конфигурируемый `IOHttpClientAdapter`
- Хранилище: `sqflite` (SQLite), `path`
- UI: Material, `BottomNavigationBar` + `IndexedStack`, `ThemeMode`

## Возможности
- Загрузка `/character?page=N` с бесконечной прокруткой и остановкой на последней странице
- Offline‑first: чтение из БД, фоновый рефреш при появлении сети
- Избранное с мгновенным UI‑откликом и сохранением в SQLite
- Вкладка Favorites с сортировкой по имени/статусу
- Тёмная/светлая темы
- Debug‑экран «HTTP Proxy Debug» для проксирования нового трафика без перезапуска

## Архитектура
- `data/`
  - `remote/` — `RickAndMortyApiClient` (Dio)
  - `local/` — `SqfliteCharactersDao`, `SqfliteFavoritesDao`
  - `repositories/` — `CharactersRepository`, `FavoritesRepository` (offline‑first)
- `domain/` — модели, DTO, use‑cases
- `presentation/` — BLoC-и и экраны

## Быстрый старт
```bash
flutter pub get
flutter run
```
По умолчанию прокси выключен, трафик идёт напрямую.

## Оффлайн и кэш
- `characters` — кэш страниц; `favorites` — список ID избранного
- При отсутствии сети UI строится из кэша; при восстановлении — подгрузка свежих страниц в фоне

## Избранное
- Тап по звезде мгновенно меняет состояние (оптимистический апдейт)
- Избранное отражается в списке и на вкладке Favorites; есть сортировка

## HTTP Proxy Debug
Модуль доступен только в debug. Позволяет направить новый трафик через прокси, затрагивая:
- `dio` (через `applyProxyToDio`)
- любой `dart:io` `HttpClient` (через `HttpOverrides.global`)

Как открыть экран: длинный тап по заголовку AppBar («Rick & Morty Characters»).

На экране:
- Enable Proxy (вкл/выкл)
- Host и Port
- «Применить» — сразу настраивает `HttpOverrides.global` и текущий экземпляр `Dio`

Замечания:
- По умолчанию прокси отключён. Включается либо на экране, либо флагами запуска.
- Для HTTPS на Android в debug включён `badCertificateCallback` (только в отладке) — нужен корневой сертификат перехватчика. В релизе перехват отключён.

Запуск с флагами (опционально, для корректного снифинга трафика изначально надо настроить эмулятор или мобильное устройство в ином случае если не принять сертификаты доверенные данная фича работать не будет):
```bash
flutter run \
  --dart-define=PROXY_ENABLED=true \
  --dart-define=PROXY_HOST=192.168.0.2 \
  --dart-define=PROXY_PORT=8888
```

## Схема БД (v1)
```
characters(
  id INTEGER PRIMARY KEY,
  name TEXT,
  status TEXT,
  species TEXT,
  location_name TEXT,
  image TEXT,
  json TEXT NOT NULL
)

favorites(
  character_id INTEGER PRIMARY KEY REFERENCES characters(id) ON DELETE CASCADE
)
```

## Проверки
- Пагинация без дубликатов, остановка на последней странице
- Тоггл избранного сохраняется и отражается на обоих экранах
- Оффлайн — показ кэша; после восстановления сети — обновление
- Навигация — два таба, состояние сохраняет `IndexedStack`
- Темы переключаются через `ThemeMode`
