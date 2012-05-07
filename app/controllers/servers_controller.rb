class ServersController < ApplicationController
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
    @server = Server.find(params[:id])
  end

  # POST /servers
  # POST /servers.json
  def create
    @server = compute.create_server(params[:server])

    respond_to do |format|
      if @server.saves
        format.html { redirect_to servers_path, :notice => 'Server was successfully created.' }
        format.json { render :json => @server, :status => :created, :location => @server }
      else
        format.html { render :action => "new" }
        format.json { render :json => @server.errors, :status => :unprocessable_entity }
      end
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
