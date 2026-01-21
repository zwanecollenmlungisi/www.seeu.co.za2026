-- Drop a specific trigger
DROP TRIGGER IF EXISTS on_like_created ON likes;

-- Drop trigger function (cascades to all triggers using it)
DROP FUNCTION IF EXISTS check_and_create_match() CASCADE;