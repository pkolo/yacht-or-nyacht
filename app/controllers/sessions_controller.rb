get '/login' do
  erb :'sessions/new'
end

post '/login' do
  @user = User.find_by(name: params[:username]).try(:authenticate, params[:password])
  if @user
    login
    redirect '/'
  else
    @errors = ["Email/password does not match"]
    erb :'sessions/new'
  end
end

get '/logout' do
  logout
  redirect '/'
end
