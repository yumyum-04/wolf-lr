-- 1) Supabase SQL Editor에서 전체 실행하세요.
create extension if not exists pgcrypto;

create table if not exists public.members (
  id uuid primary key default gen_random_uuid(),
  page_no int not null check (page_no between 1 and 11),
  sort_order int not null,
  name text not null default '',
  photo_url text,
  created_at timestamptz not null default now(),
  unique(page_no, sort_order)
);

create table if not exists public.responses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  member_id uuid not null references public.members(id) on delete cascade,
  choice text check (choice in ('L','R') or choice is null),
  reason varchar(150) not null default '',
  updated_at timestamptz not null default now(),
  unique(user_id, member_id)
);

alter table public.members enable row level security;
alter table public.responses enable row level security;

-- 누구나 인물 목록과 사진을 볼 수 있습니다.
create policy "members are visible to everyone"
on public.members for select to anon, authenticated using (true);

-- 제작자 권한(role=admin)이 있는 계정만 인물 정보를 변경할 수 있습니다.
create policy "admins can insert members"
on public.members for insert to authenticated
with check ((auth.jwt()->'app_metadata'->>'role') = 'admin');
create policy "admins can update members"
on public.members for update to authenticated
using ((auth.jwt()->'app_metadata'->>'role') = 'admin')
with check ((auth.jwt()->'app_metadata'->>'role') = 'admin');
create policy "admins can delete members"
on public.members for delete to authenticated
using ((auth.jwt()->'app_metadata'->>'role') = 'admin');

-- 참여자는 본인 계정의 답변만 읽고 작성/수정할 수 있습니다.
create policy "users read own responses"
on public.responses for select to authenticated using (auth.uid() = user_id);
create policy "users insert own responses"
on public.responses for insert to authenticated with check (auth.uid() = user_id);
create policy "users update own responses"
on public.responses for update to authenticated
using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 프로필 이미지 저장소
insert into storage.buckets (id,name,public)
values ('member-photos','member-photos',true)
on conflict (id) do nothing;

create policy "public can view member photos"
on storage.objects for select to public
using (bucket_id = 'member-photos');

create policy "admins upload member photos"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'member-photos'
  and (auth.jwt()->'app_metadata'->>'role') = 'admin'
);
create policy "admins update member photos"
on storage.objects for update to authenticated
using (
  bucket_id = 'member-photos'
  and (auth.jwt()->'app_metadata'->>'role') = 'admin'
)
with check (
  bucket_id = 'member-photos'
  and (auth.jwt()->'app_metadata'->>'role') = 'admin'
);

-- 2) Supabase Authentication에서 Email 계정을 만든 뒤,
-- 아래 SQL에서 이메일을 본인 제작자 이메일로 바꾸어 실행하세요.
-- UPDATE auth.users
-- SET raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"admin"}'::jsonb
-- WHERE email = 'YOUR-ADMIN-EMAIL@example.com';

-- 3) Authentication > Providers에서 Anonymous Sign-Ins를 활성화하세요.
