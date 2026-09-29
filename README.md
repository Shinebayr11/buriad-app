# Буриад үг

Буриад хэл, аман өвийг хадгалж түгээх Flutter апп.

## Боломжууд

- Supabase Auth ашигласан бүртгэл, нэвтрэлт, и-мэйл баталгаажуулалт
- Баталгаатай Буриад үгийн сан
- Үг таах болон ой тогтоолтын тоглоом
- Өгүүллэгийн жагсаалт, аудио тоглуулах боломж
- Админ эрхтэй хэрэглэгчийн үг нэмэх, засах, устгах хэсэг

## Технологи

- Flutter, Dart
- Supabase Auth
- SharedPreferences, JSON
- AudioPlayers, File Picker, Share Plus, URL Launcher
- Flutter Test

## Төслийн бүтэц

- Үндсэн хавтас — одоогийн Flutter апп
- `legacy-web/` — Vite дээрх хуучин HTML прототип

## Flutter апп ажиллуулах

```bash
flutter pub get
flutter run
```

Supabase тохиргоог [`supabase.env.example.json`](supabase.env.example.json)-ийн
загвараар үүсгэнэ. Нууц тохиргооны файл Git-д орохгүй.

## Хуучин веб прототип ажиллуулах

```bash
cd legacy-web
npm install
npm run dev
```

## Тест

```bash
flutter test
```
