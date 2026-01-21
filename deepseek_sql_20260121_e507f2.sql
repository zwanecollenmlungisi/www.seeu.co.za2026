-- Disable a specific trigger
ALTER TABLE profiles DISABLE TRIGGER update_profile_score;

-- Enable a trigger
ALTER TABLE profiles ENABLE TRIGGER update_profile_score;

-- Disable all triggers on a table
ALTER TABLE matches DISABLE TRIGGER ALL;

-- Enable all triggers on a table
ALTER TABLE matches ENABLE TRIGGER ALL;