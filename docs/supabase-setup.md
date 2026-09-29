# Supabase Auth тохиргоо

## 1. Төсөл ба түлхүүр

1. Supabase Dashboard-д төсөл үүсгэнэ.
2. `Authentication → Providers → Email` хэсэгт и-мэйл, нууц үгийн нэвтрэлтийг идэвхтэй байлгана.
3. И-мэйл баталгаажуулалтыг ашиглах бол `Confirm email`-ийг асаана. Бүртгүүлсний дараа хэрэглэгч баталгаажуулах холбоос авна.
4. Төслийн `Connect` цонхноос Project URL болон Publishable key-г авна.
5. `supabase.env.example.json`-ийг `supabase.env.json` нэрээр хуулж, хоёр утгыг солино. `supabase.env.json` git-д орохгүй.

## 2. И-мэйлийн буцах холбоос

1. Supabase Dashboard-ийн `Authentication → URL Configuration` хэсгийг нээнэ.
2. `Additional Redirect URLs` жагсаалтад `buriadug://login-callback/` утгыг нэмнэ.
3. И-мэйл баталгаажуулах холбоосыг бүртгэл хийсэн утсан дээрээ нээнэ. Апп автоматаар нээгдэж, Supabase session үүсгэнэ.

Хуучин `localhost:3000` холбоос эсвэл хугацаа дууссан холбоос ажиллахгүй. Аппын бүртгэлийн дэлгэц дээрх `Баталгаажуулах и-мэйлийг дахин илгээх` товчоор шинэ холбоос авна.

`service_role` болон secret key-г утасны аппад хэзээ ч оруулахгүй. Клиент аппад зөвхөн Publishable key ашиглана.

## 3. Ажиллуулах

```sh
flutter run --dart-define-from-file=supabase.env.json
```

iPhone-д нүүр дэлгэцээс нээх release хувилбар:

```sh
flutter run --release --dart-define-from-file=supabase.env.json -d DEVICE_ID
```

Тохиргоо дутуу үед апп бүртгэлгүй горимоор нээгдэх боловч нэвтрэх, бүртгүүлэх товч `Supabase тохиргоо хийгдээгүй байна` гэж мэдэгдэнэ.

## 4. Админ эрх

Апп админ эрхийг `auth.users.raw_app_meta_data` доторх `user_role: admin` утгаас уншина. Хэрэглэгч өөрөө засаж чаддаг `raw_user_meta_data`-г эрхийн шалгалтад ашиглахгүй.

Админ болгох хэрэглэгч эхлээд бүртгүүлсэн байна. Дараа нь Supabase SQL Editor-д төслийн эзэмшигч тухайн и-мэйлийг зориуд зааж дараах командыг ажиллуулна:

```sql
update auth.users
set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb)
  || jsonb_build_object('user_role', 'admin')
where email = 'ADMIN_EMAIL';
```

Эрх өөрчилсний дараа хэрэглэгч гараад дахин нэвтэрч шинэ session авна.

## 5. Серверийн хамгаалалт

Одоогийн үгийн сан төхөөрөмжийн `SharedPreferences`-д хадгалагдаж байна. Үгийг Supabase хүснэгт рүү шилжүүлэх үед хүснэгтэд RLS идэвхжүүлж, бичих бүх policy-г `app_metadata.user_role = admin` нөхцөлөөр сервер талд хаана. Зөвхөн UI дээр админ товч нуух нь дангаараа аюулгүй байдлын хамгаалалт биш.
