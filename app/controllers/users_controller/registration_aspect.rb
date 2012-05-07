module UsersController::RegistrationAspect
  #extend ActiveSupport::Concern

  #module InstanceMethods
    def new
      #session[:return_to] = request.referer
      @user = User.new
      render :layout => 'onecolumn'
    end

    def create
      #logout_keeping_session!

      @user = User.new(params[:user])
  #    if params[:invitation_code]
  #      code = InvitationCode.find_by_code(params[:invitation_code].upcase.gsub(/\W/, ''))
  #    end

  #    unless code
  #      flash[:error] = '无效的邀请码'
  #      return render :action => :new
  #    end
  #
  #    if code.consumer_id
  #      flash[:error] = '邀请码已被使用'
  #      return render :action => :new
  #    end
      @user.remember_token = ''
      #@user.state = 'active'
      if @user.valid?
        @user.register!
        unless params[:group_id].blank?
          @user.join_group(Group.find(params[:group_id]))
        end
        unless params[:user_id].blank?
           User.find(params[:user_id]).make_salary('invite',Date.today)
        end
        respond_to do |format|
          format.any(:html, :mobile, :wml) do
            #redirect_to :controller => 'my', :action => 'index'
          end
          format.json do
            render :json => @user, :status => :created, :loction => @user
          end
        end
        @user_session = UserSession.new(:login => @user.login, :password => @user.password)
        if @user_session.save
          @user = @current_user = @user_session.record
        else
          redirect_to login_path
        end
      else
        flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
        respond_to do |format|
          format.any(:html, :mobile, :wml) do
            render :action => 'new', :layout => 'onecolumn'
          end
          format.json do
            render :json => @user.errors, :status => :unprocessable_entity
          end
        end
      end

    end
    def activate
      #logout_keeping_session!
      @user = User.find_using_perishable_token(params[:activation_code], 1.week)
      case
      when (!params[:activation_code].blank?) && @user && !@user.active?
        @user.activate!
        flash[:notice] = "激活成功！<br />您现在可以登录网站了。"
        redirect_to login_path
      when params[:activation_code].blank?
        flash[:error] = "激活码有误，请点击激活邮件中的激活链接。"
        redirect_back_or_default('/')
      else
        flash[:error]  = "激活码已经过期，您可能已经激活成功，请尝试登录网站。如果无法登录，请重新注册。"
        redirect_back_or_default('/')
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

    def check_invitation_code
      code=params[:invitation_code].upcase.gsub(/\W/, '')
      code=InvitationCode.find :first,:conditions => ["code='#{code}'"]
      if code && !code.consumer_id
        return render  :text=> "激活码可以使用"
      else
        return render  :text=> "无效的激活码"
      end
    end
  #end
end
