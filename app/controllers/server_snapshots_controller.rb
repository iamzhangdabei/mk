class ServerSnapshotsController < ApplicationController
# GET /snapshots
  # GET /snapshots.json
  def index
    @snapshots = glance.images.select{|c| c["properties"]["image_type"]=="snapshot"}

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @snapshots }
    end
  end

  # GET /snapshots/1
  # GET /snapshots/1.json
  def show
    @snapshot = compute.get_snapshot(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @snapshot }
    end
  end

  # GET /snapshots/new
  # GET /snapshots/new.json
  def new
    @snapshot = Snapshot.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @snapshot }
    end
  end

  # GET /snapshots/1/edit
  def edit
    @snapshot = compute.get_snapshot(params[:id])
  end

  # POST /snapshots
  # POST /snapshots.json
  def create
    compute.create_snapshot({"volume_id"=>params[:volume_id],"force"=>false,"display_name"=>params["display_name"],"display_description"=>params["display_description"]})
    respond_to do |format|
        format.html { redirect_to snapshots_url, :notice => 'Snapshot was successfully created.' }
        format.json { render :json => @snapshot, :status => :created, :location => @snapshot }
    end
  end

  # PUT /snapshots/1
  # PUT /snapshots/1.json
  def update
    @snapshot = Snapshot.find(params[:id])

    respond_to do |format|
      if @snapshot.update_attributes(params[:snapshot])
        format.html { redirect_to @snapshot, :notice => 'Snapshot was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @snapshot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /snapshots/1
  # DELETE /snapshots/1.json
  def destroy
     compute.delete_snapshot(params[:id])

    respond_to do |format|
      format.html { redirect_to snapshots_url }
      format.json { head :ok }
    end
  end
end