class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /orders
  # GET /orders.json
  def sales
    @orders = Order.all.where(seller_id: current_user.id).order("created_at DESC")
  end
  
  def purchases
    @orders = Order.all.where(buyer_id: current_user.id).order("created_at DESC")
  end
  
  # GET /orders/new
  def new
    @order = Order.new
    @listing = Listing.find(params[:listing_id])
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    @order.buyer_id = current_user.id
    @listing = Listing.find(params[:listing_id])
    @order.listing_id = @listing.id
    @seller = @listing.user
    @order.seller_id = @seller.id
    
    Stripe.api_key = ENV["stripe_api_key"]
    token = params[:stripeToken]
    puts token
    
    begin
      charge = Stripe::Charge.create(
        :amount => (@listing.price * 100).floor, # Amount in cents
        :currency => "usd",
        :source => token,
        :description => "Example charge"
        )
      flash[:notice] = "Thanks for ordering!"
    rescue Stripe::CardError => e
      flash[:danger] = e.message
    end

    respond_to do |format|
      if @order.save
        format.html { redirect_to root_url }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:address, :city, :state)
    end
end
