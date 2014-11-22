# class SharedFoldersController < ApplicationController
#   def index
#     @title = "Users"
#     @Users = User.all
#     render 'Users/index'
#   end
#
#   def new
#     @title = pat(:new_title, :model => 'User')
#     @User = User.new
#     render 'Users/new'
#   end
#
#   def create
#     @User = User.new(params[:User])
#     if @User.save
#       @title = pat(:create_title, :model => "User #{@User.id}")
#       flash[:success] = pat(:create_success, :model => 'User')
#       params[:save_and_continue] ? redirect(url(:Users, :index)) : redirect(url(:Users, :edit, :id => @User.id))
#     else
#       @title = pat(:create_title, :model => 'User')
#       flash.now[:error] = pat(:create_error, :model => 'User')
#       render 'Users/new'
#     end
#   end
#
#   def edit
#     @title = pat(:edit_title, :model => "User #{params[:id]}")
#     @User = User.get(params[:id])
#     if @User
#       render 'Users/edit'
#     else
#       flash[:warning] = pat(:create_error, :model => 'User', :id => "#{params[:id]}")
#       halt 404
#     end
#   end
#
#   def update
#     @title = pat(:update_title, :model => "User #{params[:id]}")
#     @User = User.get(params[:id])
#     if @User
#       if @User.update(params[:User])
#         flash[:success] = pat(:update_success, :model => 'User', :id =>  "#{params[:id]}")
#         params[:save_and_continue] ?
#             redirect(url(:Users, :index)) :
#             redirect(url(:Users, :edit, :id => @User.id))
#       else
#         flash.now[:error] = pat(:update_error, :model => 'User')
#         render 'Users/edit'
#       end
#     else
#       flash[:warning] = pat(:update_warning, :model => 'User', :id => "#{params[:id]}")
#       halt 404
#     end
#   end
#
#   def destroy
#     @title = "Users"
#     User = User.get(params[:id])
#     if User
#       if User != current_user && User.destroy
#         flash[:success] = pat(:delete_success, :model => 'User', :id => "#{params[:id]}")
#       else
#         flash[:error] = pat(:delete_error, :model => 'User')
#       end
#       redirect url(:Users, :index)
#     else
#       flash[:warning] = pat(:delete_warning, :model => 'User', :id => "#{params[:id]}")
#       halt 404
#     end
#   end
#
#   def destroy_many
#     @title = "Users"
#     unless params[:User_ids]
#       flash[:error] = pat(:destroy_many_error, :model => 'User')
#       redirect(url(:Users, :index))
#     end
#     ids = params[:User_ids].split(',').map(&:strip)
#     Users = User.all(:id => ids)
#
#     if Users.include? current_user
#       flash[:error] = pat(:delete_error, :model => 'User')
#     elsif Users.destroy
#
#       flash[:success] = pat(:destroy_many_success, :model => 'Users', :ids => "#{ids.to_sentence}")
#     end
#     redirect url(:Users, :index)
#   end
#
# end
