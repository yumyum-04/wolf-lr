# 늑페스 왼른 취향표

GitHub Pages에 배포할 수 있는 정적 웹사이트입니다.

## 들어 있는 기능
- 총 11페이지, 1페이지 4명 + 2~11페이지 각 9명 = 94명
- 제작자 로그인 후 이름/사진 등록 및 수정
- 참여자는 왼(L)/른(R) 선택과 사유(최대 150자) 작성
- Supabase를 이용한 참여자별 답변 저장
- 현재 페이지 PNG 내보내기
- 모바일 반응형 화면

## 1. Supabase 준비
1. https://supabase.com 에서 새 프로젝트를 만듭니다.
2. SQL Editor에 `supabase-schema.sql` 내용을 붙여넣고 실행합니다.
3. Authentication > Providers에서 **Anonymous Sign-Ins**를 활성화합니다.
4. Authentication에서 제작자용 Email 계정을 생성합니다.
5. SQL Editor에서 아래 구문을 실행합니다. 이메일은 본인 이메일로 변경하세요.

```sql
UPDATE auth.users
SET raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"admin"}'::jsonb
WHERE email = '본인 이메일';
```

6. Project Settings > API에서 Project URL과 anon/public key를 복사합니다.
7. `config.js`의 `SUPABASE_URL`, `SUPABASE_ANON_KEY`에 입력합니다.

## 2. GitHub에 올리기
저장소 `yumyum-04/wolf-lr`의 루트에 `index.html`, `config.js`, `supabase-schema.sql`, `README.md`를 업로드합니다.

## 3. GitHub Pages 켜기
1. 저장소 Settings > Pages로 이동합니다.
2. Build and deployment에서 Deploy from a branch를 선택합니다.
3. Branch: `main`, Folder: `/ (root)`를 선택하고 Save합니다.
4. 잠시 기다린 뒤 `https://yumyum-04.github.io/wolf-lr/`에서 확인합니다.

## 사용 방법
- 제작자는 우측 상단 `제작자 로그인`으로 로그인합니다.
- 첫 실행 때 `94명 기본 칸 만들기`를 한 번 누릅니다.
- 페이지별 인물 이름과 사진을 등록합니다.
- 참여자는 로그인 없이 페이지를 이동하며 왼/른과 사유를 작성하고 `작성 내용 저장`을 누릅니다.
- `현재 페이지 PNG 저장`으로 참고 이미지 스타일의 결과 이미지를 저장합니다.

## 주의
- Supabase 설정 전에는 화면 미리보기와 이 기기 안의 임시 저장만 동작합니다.
- 실제 공동 사용/저장에는 Supabase 설정이 필요합니다.
- Supabase anon key는 브라우저에 공개되는 키이므로 반드시 위 SQL의 RLS 정책을 유지하세요.
- 참여자의 응답은 Supabase 익명 계정별로 분리됩니다. 브라우저 데이터 삭제 시 익명 계정 세션을 잃을 수 있으므로 제출 전 PNG 저장을 권장합니다.
