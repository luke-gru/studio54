class UsersController < LazyController
  def index
    @user = User.find(1)
  end
end

