class UsersController < ApplicationController
  before_filter :authenticate_admin!

  def index
    @users = User.order('email')

    respond_to do |format|
      format.html # index.html.haml
      format.xml  { render :xml => @users }
    end
  end

  def update
    user = User.find(params[:id])
    user.is_unlimited = params[:user].fetch(:is_unlimited, user.is_unlimited)

    respond_to do |format|
      if user.update_attributes!(params[:user])
        format.json do
          render_json_response(:ok)
        end
        format.html { redirect_to(user, :notice => 'Event was successfully updated.') }
        format.xml  { head :ok }
      else
        format.json { render :json => 'failure' } if request.xhr?
        format.html { render :action => "edit" }
        format.xml  { render :xml => user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  private

  def authenticate_admin!
    authenticate_user!
    if current_user and current_user.role != 'admin'
      redirect_to '/403.html', :status => 403
    end
  end
end