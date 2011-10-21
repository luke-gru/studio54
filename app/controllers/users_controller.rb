class UsersController < LazyController

  before_action :index do |obj|
    @second_user = 'me'
  end

  def index
    run_callbacks __method__ do
      @user = User.find(1)
    end
  end

  def all
    @users = User.all
  end

  def find_by
    @user = User.find_by({:name => "andrew", :id => 5}, :composite => 'OR')
  end

  def new
    @user = User.new
  end

  def create(params)
    @user = User.new params[:user]
    @user.save
  end

end

