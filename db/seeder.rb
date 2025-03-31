require 'sqlite3'
require 'bcrypt'

class Seeder
  
  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS users')
    db.execute('DROP TABLE IF EXISTS questions')
    db.execute('DROP TABLE IF EXISTS choices')
  end

  def self.create_tables
    db.execute('CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      password VARCHAR(255) NOT NULL
    )')
    db.execute('CREATE TABLE questions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      question TEXT NOT NULL
    )')
    db.execute('CREATE TABLE choices (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      question_id INTEGER,
      choice_text TEXT NOT NULL,
      is_correct BOOLEAN NOT NULL,
      FOREIGN KEY (question_id) REFERENCES questions(id)
    )')
  end

  def self.populate_tables
    password_hashed = BCrypt::Password.create("admin")
    db.execute('INSERT INTO users (username, password) VALUES (?, ?)', ["admin", password_hashed])

    questions = [
      { question: "Vad är den maximala hastigheten på en motorväg?", choices: ["90 km/h", "110 km/h", "120 km/h", "130 km/h"], correct_choice: "130 km/h" },
      { question: "Vilket vägmärke betyder förbud mot att stanna?", choices: ["Cirkulationsplats", "Stoppmärke", "Förbud mot att stanna och parkera", "Ingen genomfart"], correct_choice: "Förbud mot att stanna och parkera" }
    ]

    questions.each do |q|
      db.execute('INSERT INTO questions (question) VALUES (?)', [q[:question]])
      question_id = db.last_insert_row_id

      q[:choices].each do |choice|
        is_correct = choice == q[:correct_choice] ? 1 : 0
        db.execute('INSERT INTO choices (question_id, choice_text, is_correct) VALUES (?, ?, ?)', [question_id, choice, is_correct])
      end
    end
  end

  private
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/score.sqlite')
    @db.results_as_hash = true
    @db
  end
end

Seeder.seed!
