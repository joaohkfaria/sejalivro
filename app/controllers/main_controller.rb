class MainController < ApplicationController
  layout "application"

  def index
    @categories = Category.all
  end
end
