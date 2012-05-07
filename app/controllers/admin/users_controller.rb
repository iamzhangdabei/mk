class Admin::UsersController < Admin::ApplicationController
  before_filter :login_required
  require_role "admin"
  def index
    @users = User.all
  end
end