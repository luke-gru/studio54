class UsersController < LazyController

  def index
    @user = User.find(1)
  end

  def find_by
    @user = User.find_by('OR', :name => "luke", :id => 5)
  end

  def new
    @user = User.new
  end

  def create(params)
    @user = User.new params[:user]
    if @user.save
    else
    end
  end

end

