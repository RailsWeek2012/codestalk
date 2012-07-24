class LibrariesController < ApplicationController

  before_filter :require_login!

  def new
  end

  def edit
  end

  def show
    @library = Library.find(params[:id])
    #@snippet = Snippet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @library }
    end
  end

  def require_login!
    unless user_signed_in?
      redirect_to login_path,
                  alert: "Bitte melden Sie sich zuerst an."
    end
  end
end
