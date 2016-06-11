require "sinatra"
require "sinatra/reloader" if development?

enable	:sessions
Word_list = File.open("./public/5desk.txt", "r").readlines

get '/' do
	if session[:game_over] == true || session[:word] == nil
		redirect to("/newgame")
	end
	variables
	check_game_status
	erb :main
end

get '/win' do
	if session[:word_array] != session[:answer_array]
		redirect to('/lose')
	end 
	variables
	session[:game_over] = true
	erb :win
end

get '/lose' do 
	variables
	session[:game_over] = true
	erb :lose
end

post '/' do
	check_response(params["GUESS"])
	redirect to("/")
end

get '/newgame' do
	session[:word] = select_word_from_list(Word_list)
	session[:word_array] = word_to_array(session[:word])
	session[:answer_array] = create_answer_array(session[:word])
	session[:used_letters] = []
	session[:turns_remaining] = 7
	session[:game_over] = false
	redirect to('/')
end

helpers do
	def variables 
		@word = session[:word]
		@word_array = session[:word_array]
		@answer_array = session[:answer_array] 
		@used_letters = session[:used_letters]
		@turns_remaining = session[:turns_remaining]
	end
	def check_game_status
		if session[:word_array] == session[:answer_array]
			redirect to('/win')
		elsif session[:turns_remaining] == 0
			redirect to('/lose')	
		end
	end

	def select_word_from_list(word_list)
		word = word_list[rand(word_list.length)]
		if !word.length.between?(7,14)
		    select_word_from_list(word_list)
		else
		    word[0..-3]
		end
	end 

	def word_to_array(word)
		new_word = word.scan(/./)
		new_word[0].downcase!
		new_word
	end

	def create_answer_array(word)
		answer_array = []
		word.length.times do
			answer_array.push("")
		end
		answer_array
	end

	def check_response(letter)
		correct_response = false
		if session[:used_letters].include?(letter)
			#they've already guessed this letter
			return
		end
		session[:word_array].each_with_index do |l,i|
			if letter == l 
				session[:answer_array][i] = letter
				correct_response = true
			end 
		end
		unless correct_response 
			session[:used_letters].push(letter)
			session[:turns_remaining] -= 1
			# puts "uh oh! that letter is not in the puzzle!"
		end
	end
end
