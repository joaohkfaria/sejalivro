class UsersController < ApplicationController

  # Método que define o que ocorre quando abre-se a tela para cadastrar usuário
  # GET /users/register
  def new
    @user = User.new
    1.times { @user.addresses.build}
  end

  def logout
    cookies.delete :waiting_for_payment

    sign_out :user
    redirect_to root_path
  end

  # POST /users
  # POST /users.json
  def create
    # Convertendo genero inteiro
    params[:user][:gender] = params[:user][:gender].to_i

    # Build nos parametros
    @user = User.new(user_params)
    @user.addresses = []

    if params[:user]["birth_date(1i)"] != '' && params[:user]["birth_date(2i)"] != '' && params[:user]["birth_date(3i)"] != ''
      @user.birth_date = Date.new(params[:user]["birth_date(1i)"].to_i,params[:user]["birth_date(2i)"].to_i,params[:user]["birth_date(3i)"].to_i)
    end

    respond_to do |format|
      if valid_address(user_params) && @user.save
        @user.addresses.build(user_params[:addresses_attributes]["0"])
        @user.save

        format.html { redirect_to new_user_session_path, notice: 'Usuário criado!' }
        format.json { render new_user_session_path, status: :created, location: @user }
      else
        1.times { @user.addresses.build}
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def valid_address(params)
    result = true

    if params[:addresses_attributes]["0"][:country].empty?
      @user.errors.add(:country, "não pode ficar em branco.")
      result = false
    end
    if params[:addresses_attributes]["0"][:city].empty?
      @user.errors.add(:city, "não pode ficar em branco.")
      result = false
    end
    if params[:addresses_attributes]["0"][:state].empty?
      @user.errors.add(:state, "não pode ficar em branco.")
      result = false
    end
    if params[:addresses_attributes]["0"][:quarter].empty?
      @user.errors.add(:quarter, "não pode ficar em branco.")
      result = false
    end
    if params[:addresses_attributes]["0"][:zipcode].empty?
      @user.errors.add(:zipcode, "não pode ficar em branco.")
      result = false
    end
    if params[:addresses_attributes]["0"][:street].empty?
      @user.errors.add(:street, "não pode ficar em branco.")
      result = false
    end

    result
  end

  def update
    # Convertendo genero inteiro
    params[:user][:gender] = params[:user][:gender].to_i

    # Build nos parametros
    @user = User.find(params[:id])        

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to action: :profile }
        format.json { render action: :profile, status: :created, location: @user }
      else
        format.html { render action: :profile }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # Método que define o que ocorre quando abre-se a tela de perfil
  # GET /profile/:id
  def profile
    if user_signed_in? && current_user.id.to_s == params[:id]
      @user = User.find(params[:id])
      @user_signatures = @user.signatures
      @periodicity = Periodicity.all
      @user_addresses = @user.addresses
      @user_books = @user.user_books
    else
      redirect_to root_path
    end
  end

  def my_books
    if user_signed_in? && current_user.id.to_s == params[:id]
      @user = User.find(params[:id])
      @user_books = @user.user_books
      @user_prefs = @user.user_preferences
    else
      redirect_to root_path
    end
  end

  def delete_user
    sign_out :user

    Signature.where(user_id: params[:id].to_i).destroy_all
    CreditCard.where(user_id: params[:id].to_i).destroy_all
    Address.where(user_id: params[:id].to_i).destroy_all

    User.delete(params[:id].to_i)

    redirect_to root_path
  end

  def index
    redirect_to new_user_path
  end

  def edit
    @user = User.find(params[:id])

    if @user.nil?
      redirect_to action: :profile
    end    
  end

  def destroy
    #precisa implementar 
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :cpf, :email, :login, :birth_date, :gender, :password, :password_confirmation, :addresses_attributes => [ :zipcode, :city, :country, :state, :complement, :street, :quarter])
    end
end