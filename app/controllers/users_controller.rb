class UsersController < ApplicationController
  def index
    @users = current_admin_connection.tenants

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @tenants }
    end
  end
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_back_or_default :back
    else
      render :action => :new
    end
  end
  
  def show
    @user = @current_user
  end

  def edit
    @user = @current_user
  end
  
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
  def check
    if params[:check_name] == "login"
      check_login
    else
      check_email
     end
   end
    def check_login
      user=User.find_by_login(params[:check_area])
      if !user
        return render  :json=>{:success_message=>"可以使用"}
      else
        return render  :json=> {:error_message=>"用户名已经被使用"}
      end
    end

    def check_email
      user=User.find_by_email(params[:check_area])
      if user
        return render  :json=> {:error_message=>"邮箱已经被使用"}
      else
        return render  :json=> {:success_message=>"可以使用"}
      end
    end
end
