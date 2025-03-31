require "sqlite3"

DB = SQLite3::Database.new "scores.db"
DB.results_as_hash = true

# Rensa quiz-tabellen
DB.execute("DELETE FROM quizzes")

# Lägg till frågor
DB.execute("INSERT INTO quizzes (question, option_a, option_b, option_c, correct_answer) VALUES
  ('Vad betyder en röd stoppskylt?', 'Stanna alltid', 'Sakta ner', 'Fortsätt', 'A'),
  ('Vad är maxhastighet i tätbebyggt område?', '30 km/h', '50 km/h', '70 km/h', 'B'),
  ('Vilket ljus ska du använda vid dimma?', 'Helljus', 'Dimljus', 'Släckt ljus', 'B')
")

puts "Databasen är seedad!"
