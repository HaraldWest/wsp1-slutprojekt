require "sinatra"
require "sqlite3"
require "bcrypt"

class App < Sinatra::Base

  def db
    return @db if @db
    @db = SQLite3::Database.new("db/score.sqlite")
    @db.results_as_hash = true
    return @db
  end

  get '/' do
    redirect '/index'
  end

  get '/index' do
    erb :index
  end

  get '/login' do
    erb :login
  end

  get '/register' do
    erb :register
  end

  post '/register' do
    username = params[:username]
    password = params[:password]
  
    user = db.execute("SELECT * FROM users WHERE username = ?", [username]).first
    if user
      @error = "Användarnamn finns redan. Vänligen välj ett annat."
      erb :register
    else
      password_hash = BCrypt::Password.create(password)
      db.execute("INSERT INTO users (username, password) VALUES (?, ?)", [username, password_hash])
      redirect '/login'
    end
  end

  post '/login' do
    username = params[:username]
    password = params[:password]

    user = db.execute("SELECT * FROM users WHERE username = ?", username).first

    if user && BCrypt::Password.new(user['password']) == password
      session[:user_id] = user['id']
      redirect '/'
    else
      @error = "Invalid username or password"
      erb :login
    end
  end

  get '/logout' do
    session.clear  
    redirect '/'
  end

  get '/quiz' do
    redirect '/login' unless session[:user_id]  # Redirect to login if not logged in

    @questions = db.execute('SELECT * FROM questions')
  
    @questions.each do |question|
      question['choices'] = db.execute('SELECT * FROM choices WHERE question_id = ?', [question['id']])
    end
  
    erb :quiz
  end

  post '/submit_quiz' do
    @score = 0
    @total_questions = params.keys.size
  
    params.each do |question_id, selected_choice_id|
      correct_choice = db.execute('SELECT * FROM choices WHERE question_id = ? AND is_correct = 1', [question_id]).first
      @score += 1 if correct_choice && correct_choice['id'] == selected_choice_id.to_i
    end
  
    erb :results
  end

  
  get '/admin' do
    @questions = db.execute("SELECT * FROM questions")
    erb :admin
  end

  get '/admin/add_question' do
    erb :add_question
  end

  post '/admin/add_question' do
    question_text = params[:question]
    alt1 = params[:alt1]
    alt2 = params[:alt2]
    correct_answer = params[:correct_answer]

    db.execute("INSERT INTO questions (question) VALUES (?)", [question_text])

    question_id = db.last_insert_row_id

    db.execute("INSERT INTO choices (question_id, choice_text, is_correct) VALUES (?, ?, ?)", [question_id, alt1, alt1 == correct_answer ? 1 : 0])
    db.execute("INSERT INTO choices (question_id, choice_text, is_correct) VALUES (?, ?, ?)", [question_id, alt2, alt2 == correct_answer ? 1 : 0])

    redirect '/admin'
  end

  get '/admin/edit/:id' do
    @question = db.execute("SELECT * FROM questions WHERE id = ?", [params[:id]]).first
    @choices = db.execute("SELECT * FROM choices WHERE question_id = ?", [params[:id]])
    erb :edit_question
  end

  post '/admin/edit/:id' do
    question_id = params[:id]
    new_question_text = params[:question]
    db.execute("UPDATE questions SET question = ? WHERE id = ?", [new_question_text, question_id])

    db.execute("DELETE FROM choices WHERE question_id = ?", [question_id])

    alt1 = params[:alt1]
    alt2 = params[:alt2]
    correct_answer = params[:correct_answer]

    db.execute("INSERT INTO choices (question_id, choice_text, is_correct) VALUES (?, ?, ?)", [question_id, alt1, alt1 == correct_answer ? 1 : 0])
    db.execute("INSERT INTO choices (question_id, choice_text, is_correct) VALUES (?, ?, ?)", [question_id, alt2, alt2 == correct_answer ? 1 : 0])

    redirect '/admin'
  end

  post '/admin/delete/:id' do
    question_id = params[:id]

    db.execute("DELETE FROM choices WHERE question_id = ?", [question_id])

    db.execute("DELETE FROM questions WHERE id = ?", [question_id])

    redirect '/admin'
  end

  configure do
    enable :sessions
    set :session_secret, SecureRandom.hex(64)
  end
end
