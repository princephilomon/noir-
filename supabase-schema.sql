-- Run this once in your Supabase project's SQL Editor
-- (Dashboard → SQL Editor → New query → paste → Run)

create table orders (
  id uuid primary key default gen_random_uuid(),
  order_no text not null,
  table_number text not null,
  guest_name text not null default 'Guest',
  items jsonb not null,           -- array of {name, variantLabel, unitPrice, qty}
  total numeric not null,
  status text not null default 'placed',  -- placed | preparing | ready | served | paid
  payment_method text,            -- null | cash | card | online
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Keep updated_at fresh on every change
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger orders_updated_at
before update on orders
for each row execute function set_updated_at();

-- Enable Realtime for this table
alter publication supabase_realtime add table orders;

-- Allow anon read/write (fine for a single-restaurant internal tool;
-- tighten this with real auth before exposing publicly at scale)
alter table orders enable row level security;

create policy "Allow all access to orders"
on orders for all
using (true)
with check (true);
