class ServersController < ApplicationController
  before_filter :login_required
  # GET /servers
  # GET /servers.json
  def index
    @servers = compute.servers

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @servers }
    end
  end

  # GET /servers/1
  # GET /servers/1.json
  def show
    @server =  compute.get_server(params[:id])
    @server_detail = compute.get_server_detail(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @server }
    end
  end

  # GET /servers/new
  # GET /servers/new.json
  def new
    @server = Server.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @server }
    end
  end

  # GET /servers/1/edit
  def edit
    @server = compute.get_server(params[:id])
  end

  # POST /servers
  # POST /servers.json
  def create
    #:name        => 'NewServer',
      #        :imageRef    => 'http://172.19.0.3/v1.1/images/3',
      #        :flavorRef   => 'http://172.19.0.3/v1.1/flavors/1',
      #        :metadata    => {'Racker' => 'Fanatical'},
      #        :personality => {'/home/bob/wedding.jpg' => '/root/wedding.jpg'})
    @server = compute.create_server(:name=>params[:name],:imageRef=>params[:imageRef],:flavorRef=>params[:flavorRef])

    respond_to do |format|

        format.html { redirect_to servers_path, :notice => 'Server was successfully created.' }
        format.json { render :json => @server, :status => :created, :location => @server }
    end
  end

  # PUT /servers/1
  # PUT /servers/1.json
  def update
    @server = compute.get_server(params[:id]).update(params[:server])
    respond_to do |format|
      if @server.update_attributes(params[:server])
        format.html { redirect_to @server, :notice => 'Server was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @server.errors, :status => :unprocessable_entity }
      end
    end
  end
  def create_snapshot
    @server = compute.get_server_detail(params[:id])
  end
def make_snapshot
  @server = compute.get_server(params[:id]).create_image(:name => params[:name])
   redirect_to server_snapshots_path
end
  # DELETE /servers/1
  # DELETE /servers/1.json
  def destroy
    @server = compute.get_server(params[:id])
    @server.delete!

    respond_to do |format|
      format.html { redirect_to servers_url }
      format.json { head :ok }
    end
  end
end
