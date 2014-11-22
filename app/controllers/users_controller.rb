class UsersController < ApplicationController
  def index
    @title = "Users"
    @users = User.all
  end

  def new
    @title = pat(:new_title, :model => 'user')
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      @title = pat(:create_title, :model => "user #{@user.id}")
      flash[:success] = pat(:create_success, :model => 'User')
      params[:save_and_continue] ? redirect(url(:users, :index)) : redirect(url(:users, :edit, :id => @user.id))
    else
      @title = pat(:create_title, :model => 'user')
      flash.now[:error] = pat(:create_error, :model => 'user')
    end
  end

  def edit
    @title = pat(:edit_title, :model => "user #{params[:id]}")
    @user = User.find(params[:id])
    unless @user
      flash[:warning] = pat(:create_error, :model => 'user', :id => "#{params[:id]}")
      render status: 404
    end
  end

  def update
    @title = pat(:update_title, :model => "user #{params[:id]}")
    @user = User.find(params[:id])
    if @user
      if @user.update(params[:user])
        flash[:success] = pat(:update_success, :model => 'User', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(users_path) :
          redirect(edit_user_path(@user.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'user')
        render 'edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'user', :id => "#{params[:id]}")
      render status: 404
    end
  end

  def destroy
    @title = "Users"
    user = User.find(params[:id])
    if user
      if user != current_user && user.destroy
        flash[:success] = pat(:delete_success, :model => 'User', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'user')
      end
      redirect users_path
    else
      flash[:warning] = pat(:delete_warning, :model => 'user', :id => "#{params[:id]}")
      render status:  404
    end
  end

  def destroy_many
    @title = "Users"
    unless params[:user_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'user')
      redirect users_path
    end
    ids = params[:user_ids].split(',').map(&:strip)
    users = User.all(:id => ids)

    if users.include? current_user
      flash[:error] = pat(:delete_error, :model => 'user')
    elsif users.destroy

      flash[:success] = pat(:destroy_many_success, :model => 'Users', :ids => "#{ids.to_sentence}")
    end
    redirect users_path
  end
end
