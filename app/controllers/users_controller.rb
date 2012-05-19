class UsersController < ApplicationController
  before_filter :login_required
  def index
    if params[:tenant_id] 
       @users = keystone.get_users_for_tenant(params[:tenant_id])
    else
          @users = keystone.users
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @tenants }
    end
  end
  def roles
  if  (params[:tenant_id] && params[:id])
   @roles = keystone.get_user_roles_for_tenant(params[:id],params[:tenant_id])
  end
  end
  def new
    @user = User.new
  end
   {"authenticity_token"=>
    "tet8RxJVJa7TsUuYk/snz/FrPdG/HfWY94DCyLa4doY=",
     "enabled"=>"yes", 
     "name"=>"asdf", 
     "tenantId"=>"2d5145ccf4b34cbbaa5e9a5059123f48", 
     "commit"=>"submit", "password_confirm"=>"[FILTERED]", 
     "password"=>"[FILTERED]", "
     email"=>"asdf",
      "utf8"=>"✓"}

  def create
    if params[:password] == params[:password_confirm] 
      keystone.create_user(:name=>params[:name],:email=>params[:email],:password=>params[:password],:tenantId=>params[:tenantId],:enabled=>true)
    end
    redirect_to users_path
  end
  def destroy
    keystone.delete_user(params[:id])
    redirect_to users_path
  end
  def show
    @user = keystone.get_user(params[:id])
  end

  def edit
    @user = keystone.get_user(params[:id])
  end
  
  def update
     keystone.update_user(:id=>params[:id],:name=>params[:name],:email=>params[:email],:password=>params[:password],:tenantId=>params[:tenantId],:enabled=>true)
     redirect_to users_path
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
