class VolumesController < ApplicationController
  # GET /volumes
  # GET /volumes.json
  def index
    @volumes = compute.list_volumes(true)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @volumes }
    end
  end

  # GET /volumes/1
  # GET /volumes/1.json
  def show
    @volume = compute.get_volume(params[:id].to_i)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @volume }
    end
  end

  # GET /volumes/new
  # GET /volumes/new.json
  def new
    @volume = Volume.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @volume }
    end
  end

  # GET /volumes/1/edit
  def edit
    @volume = compute.get_volume(params[:id].to_i)
  end

  # POST /volumes
  # POST /volumes.json
  def create
    @volume = compute.co.create_volume({"size"=>params[:size],"display_name"=>params[:name],"display_description"=>params[:description]})


    respond_to do |format|
        format.html { redirect_to @volume, :notice => 'Volume was successfully created.' }
        format.json { render :json => @volume, :status => :created, :location => @volume }
    end
  end

  # PUT /volumes/1
  # PUT /volumes/1.json
  def update
    @volume = Volume.find(params[:id])

    respond_to do |format|
      if @volume.update_attributes(params[:volume])
        format.html { redirect_to @volume, :notice => 'Volume was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @volume.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /volumes/1
  # DELETE /volumes/1.json
  def destroy
    compute.delete_volume(params[:id].to_i)

    respond_to do |format|
      format.html { redirect_to volumes_url }
      format.json { head :ok }
    end
  end
end
