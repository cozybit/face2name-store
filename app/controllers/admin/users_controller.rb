class Admin::UsersController < ApplicationController  # GET /events
  # GET /admin/users
  # GET /admin/users.xml
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end
end
