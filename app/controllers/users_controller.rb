class UsersController < ApplicationController
  before_action :signed_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  
  def index
    @users = User.paginate(page: params[:page])
  end

  def show
  	@user = User.find(params[:id])
  end

  def new
    if signed_in?
      redirect_to root_path
    else
	    @user = User.new
    end
  end

  def create
    if signed_in?
      redirect_to root_path
    else
      @user = User.new(user_params) 
      if @user.save
        sign_in @user
        flash[:success] = "Welcome to the Sample App!"
        redirect_to @user
      else
        render 'new'
      end
    end
  end

  def edit
    #@user = User.find(params[:id])
  end

  def update
    #@user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile Updated!"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.admin?
      flash[:error] = "Cannot delete an admin! Please delete an non admin"
    else
      User.find(params[:id]).destroy
      flash[:success] = "User deleted!"
    end
    redirect_to users_url
  end

  private

  	def user_params
  		params.require(:user).permit(:name, :email,
  			:password, :password_confirmation)
  	end

    #Before filters
    def signed_in_user
      unless signed_in?
        storage_location
        redirect_to signin_url, notice: "Please sign in."
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
