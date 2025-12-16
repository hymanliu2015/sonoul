-- Add new columns for Suno integration to the existing songs table
-- We use 'add column if not exists' to be safe.

alter table songs 
add column if not exists prompt text,
add column if not exists style text,
add column if not exists tags text[],
add column if not exists instrumental boolean default false,
add column if not exists status text default 'pending', -- pending, processing, completed, failed
add column if not exists task_id text,
add column if not exists meta jsonb default '{}'::jsonb,
add column if not exists video_url text,
add column if not exists duration float;

-- Ensure RLS is enabled (just in case)
alter table songs enable row level security;

-- If you don't have the Webhook setup yet, remember to do that in the Dashboard!
