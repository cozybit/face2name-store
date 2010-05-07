class BundlesController < ApplicationController
  before_filter :authenticate_user!

  # GET /bundles
  # GET /bundles.xml
  def index
    @bundles = Bundle.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bundles }
    end
  end
=begin

  # GET /bundles/1
  # GET /bundles/1.xml
  def show
    @bundle = Bundle.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bundle }
    end
  end

  # GET /bundles/new
  # GET /bundles/new.xml
  def new
    @bundle = Bundle.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bundle }
    end
  end

  # GET /bundles/1/edit
  def edit
    @bundle = Bundle.find(params[:id])
  end

  # POST /bundles
  # POST /bundles.xml
  def create
    @bundle = Bundle.new(params[:bundle])

    respond_to do |format|
      if @bundle.save
        format.html { redirect_to(@bundle, :notice => 'Bundle was successfully created.') }
        format.xml  { render :xml => @bundle, :status => :created, :location => @bundle }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bundle.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bundles/1
  # PUT /bundles/1.xml
  def update
    @bundle = Bundle.find(params[:id])

    respond_to do |format|
      if @bundle.update_attributes(params[:bundle])
        format.html { redirect_to(@bundle, :notice => 'Bundle was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bundle.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bundles/1
  # DELETE /bundles/1.xml
  def destroy
    @bundle = Bundle.find(params[:id])
    @bundle.destroy

    respond_to do |format|
      format.html { redirect_to(bundles_url) }
      format.xml  { head :ok }
    end
  end
=end
end
