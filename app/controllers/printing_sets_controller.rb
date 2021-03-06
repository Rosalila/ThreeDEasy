class PrintingSetsController < ApplicationController
  before_action :set_printing_set, only: [:show, :edit, :update, :destroy]

  # GET /printing_sets
  # GET /printing_sets.json
  def index
    update_cupon params[:cupon_code]

    @printing_sets = PrintingSet.all.reverse
  end

  def show_item_by_name
    update_cupon params[:cupon_code]

    @printing_set = PrintingSet.find_by_id(params[:printing_set_id])
    @printing_hub = @printing_set.printing_hub
    @printable = Printable.new
    @printing_set_image = PrintingSetImage.new
    @user_has_printing_set = (current_user and current_user.has_printing_set @printing_set)
    @cupon = @printing_set.get_cupon @cupon_code

    options = {
      filter_html:     true,
      hard_wrap:       true,
      link_attributes: { rel: 'nofollow', target: "_blank" },
      space_after_headers: true,
      fenced_code_blocks: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    @markdown = Redcarpet::Markdown.new(renderer, extensions = {})
  end

  # GET /printing_sets/1
  # GET /printing_sets/1.json
  def show
    redirect_to show_item_by_name_path(@printing_set.id_and_paramterized_name)
  end

  # GET /printing_sets/new
  def new
    @printing_set = PrintingSet.new
  end

  # GET /printing_sets/1/edit
  def edit
  end

  # POST /printing_sets
  # POST /printing_sets.json
  def create
    @printing_set = PrintingSet.new(printing_set_params)

    if !current_user.has_printing_hub(@printing_set.printing_hub)
      return
    end

    respond_to do |format|
      if @printing_set.save
        format.html { redirect_to printing_hub_admin_show_path(@printing_set.printing_hub), notice: 'Printing set was successfully created.' }
        format.json { render :show, status: :created, location: @printing_set }
      else
        format.html { render :new }
        format.json { render json: @printing_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /printing_sets/1
  # PATCH/PUT /printing_sets/1.json
  def update
		if !current_user.has_printing_set @printing_set
      return
    end

    respond_to do |format|
      if @printing_set.update(printing_set_params)
        format.html { redirect_to @printing_set, notice: 'Printing set was successfully updated.' }
        format.json { render :show, status: :ok, location: @printing_set }
      else
        format.html { render :edit }
        format.json { render json: @printing_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /printing_sets/1
  # DELETE /printing_sets/1.json
  def destroy
    return
    hub_id = @printing_set.printing_hub_id
    @printing_set.destroy
    respond_to do |format|
      format.html { redirect_to printing_hub_path(hub_id), notice: 'Printing set was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_printing_set
      @printing_set = PrintingSet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def printing_set_params
      params.require(:printing_set).permit(:name, :printing_hub_id, :doges, :description, :image, :grams)
    end
end
