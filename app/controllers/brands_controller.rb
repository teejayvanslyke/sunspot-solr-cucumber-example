class BrandsController < ApplicationController

  def index
    render json: Brand.search { fulltext(params[:q]) }.results.to_json(root: false)
  end

end

