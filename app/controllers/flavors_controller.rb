class FlavorsController < ApplicationController
  # GET /flavors
  # GET /flavors.json
  def index
    @flavors = compute.list_flavors

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @flavors }
    end
  end

  # GET /flavors/1
  # GET /flavors/1.json
  def show
    @flavor = compute.get_flavor(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @flavor }
    end
  end

  # GET /flavors/new
  # GET /flavors/new.json
  def new
    @flavor = Flavor.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @flavor }
    end
  end

  # GET /flavors/1/edit
  def edit
    @flavor = Flavor.find(params[:id])
  end

  # POST /flavors
  # POST /flavors.json
  def create
    @flavor = Flavor.new(params[:flavor])

    respond_to do |format|
      if @flavor.save
        format.html { redirect_to @flavor, :notice => 'Flavor was successfully created.' }
        format.json { render :json => @flavor, :status => :created, :location => @flavor }
      else
        format.html { render :action => "new" }
        format.json { render :json => @flavor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /flavors/1
  # PUT /flavors/1.json
  def update
    @flavor = Flavor.find(params[:id])

    respond_to do |format|
      if @flavor.update_attributes(params[:flavor])
        format.html { redirect_to @flavor, :notice => 'Flavor was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @flavor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /flavors/1
  # DELETE /flavors/1.json
  def destroy
    @flavor = Flavor.find(params[:id])
    @flavor.destroy

    respond_to do |format|
      format.html { redirect_to flavors_url }
      format.json { head :ok }
    end
  end
end
