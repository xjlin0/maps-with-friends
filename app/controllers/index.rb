# =========================
# Index
# =========================
get '/' do

  erb :index
end

# =========================
# Make a Friend Marker
# =========================
post '/' do
  @friend = Friend.find_or_initialize_by(name: params[:name])
  @friend.update_attributes(location: params[:location])
  if @friend.location != nil
    content_type :json
    if @friend.save
      @friendship = Friendship.create(friend_id: @friend.id, user_id: current_user.id)
      {name: @friend.name, location: @friend.location}.to_json
    else
      {error: "Friend did not save"}.to_json
    end
  end
end


# =========================
# Populate Map from User's friends
# =========================
get '/locations' do
  @user = User.find_by(id: session[:user_id])
  @friendships = @user.friendships
  @friends = []
  @friendships.each do |friendship|
    @friends << Friend.find_by(id: friendship.friend_id)
  end
  p @friends.each { |f| f.name }
  content_type :json
  # @friends.each do |friend|
  #   friend = {name: friend.name, location: friend.location}
  #   friends_and_locations << friend
  # end
  # friends_and_locations.to_json
  @friends.to_json
end

# =========================
# Register
# =========================
get '/register' do

  erb :register
end

post '/register' do
  user = User.new(params[:user])
    if user.save
      redirect '/login'
    else
      erb :register
    end
end

# =========================
# Login
# =========================
get '/login' do

  erb :login
end

post '/login' do
  @user = User.find_by(email: params[:user][:email])
  if @user && @user.password == params[:user][:password]
    session[:user_id] = @user.id
    redirect '/'
  else
    erb :login
  end
end

# =========================
# Logout
# =========================
delete '/logout' do
  session[:user_id] = nil
  redirect '/'
end