require "sinatra"
require "sinatra/reloader" if development?

enable	:sessions
Word_list = File.open("./public/5desk.txt", "r").readlines

get '/' do
	@word = session[:word]
	@word_array = session[:word_array]
	@answer_array = session[:answer_array] 
	erb :main
end

post '/' do
	check_response(GUESS)
end

get '/newgame' do
	session[:word] = select_word_from_list(Word_list)
	session[:word_array] = word_to_array(session[:word])
	session[:answer_array] = create_answer_array(session[:word])
	session[:used_letters] = []
	redirect to('/')
end

helpers do
	def select_word_from_list(word_list)
		word = word_list[rand(word_list.length)]
		if !word.length.between?(7,14)
		    select_word_from_list(word_list)
		else
		    word
		end
	end 

	def word_to_array(word)
		new_word = word.scan(/./)
		new_word[0].downcase!
		new_word = new_word[0..-2]
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
		if @used_letters.include?(letter)
			#they've already guessed this letter
		end
		@word.each_with_index do |l,i|
			if letter == l 
				@answer_array[i] = letter
				correct_response = true
			end 
		end
		unless correct_response 
			@used_letters.push(letter)
			@turns_remaining -= 1
			puts "uh oh! that letter is not in the puzzle!"
		end
	end
end
