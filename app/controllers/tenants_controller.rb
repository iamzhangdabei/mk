class TenantsController < ApplicationController
  before_filter :login_required
  # GET /tenants
  # GET /tenants.json
  def index
    @tenants = keystone.tenants

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @tenants }
    end
  end
def edit_users
  
end
  # GET /tenants/1
  # GET /tenants/1.json
  def show
    @tenant = keystone.get_tenant(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @tenant }
    end
  end

  # GET /tenants/new
  # GET /tenants/new.json
  def new
   # @tenant = Tenant.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @tenant }
    end
  end

  # GET /tenants/1/edit
  def edit
    @tenant =  keystone.get_tenant(params[:id])
  end

  # POST /tenants
  # POST /tenants.json
  def create
    @tenant = keystone.create_tenant({:name=>params[:name],:description=>params[:description],:enabled=>params[:enabled]})
    respond_to do |format|
     
        format.html { redirect_to @tenant, :notice => 'Tenant was successfully created.' }
        format.json { render :json => @tenant, :status => :created, :location => @tenant }
     
    end
  end

  # PUT /tenants/1
  # PUT /tenants/1.json
  def update
    keystone.update_tenant({:id=>params[:id],:name=>params[:name],:description=>params[:description],:enabled=>params[:enabled]})
    respond_to do |format|
        format.html { redirect_to tenants_path, :notice => 'Tenant was successfully updated.' }
        format.json { head :ok }
    end
  end

  # DELETE /tenants/1
  # DELETE /tenants/1.json
  def destroy
     
    keystone.delete_tenant(keystone.get_tenant(params[:id])[:id])

    respond_to do |format|
      format.html { redirect_to tenants_url }
      format.json { head :ok }
    end
  end
end
