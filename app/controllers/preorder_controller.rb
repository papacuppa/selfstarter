class PreorderController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :ipn

  def index
    flash[:error] = 'ABC'
  end

  def checkout
  end

  def prefill
    @user  = User.find_or_create_by_email!(params[:email])
    @order = Order.prefill!(name: Settings.product_name, price: Settings.price, quantity: params[:quantity].to_i, user_id: @user.id)

    go_url = GoCardless.new_pre_authorization_url(amount: @order.total_price, name: @order.name, interval_unit: 'month
      ', interval_length: 1, user: { email: @user.email }, state: @order.uuid)
    redirect_to go_url

    # This is where all the magic happens. We create a multi-use token with Amazon, letting us charge the user's Amazon account
    # Then, if they confirm the payment, Amazon POSTs us their shipping details and phone number
    # From there, we save it, and voila, we got ourselves a preorder!
    # @pipeline = AmazonFlexPay.multi_use_pipeline(@order.uuid, :transaction_amount => Settings.price, :global_amount_limit => Settings.charge_limit, :collect_shipping_address => "True", :payment_reason => Settings.payment_description)
    # redirect_to @pipeline.url("#{request.scheme}://#{request.host}/preorder/postfill")
  end

  def confirm
    begin
      GoCardless.confirm_resource params
      @order = Order.postfill!(params)

      if @order.present?
        redirect_to action: :share, uuid: @order.uuid
      else
        redirect_to root_path
      end
    rescue Exception => e
      redirect_to root_path
    end    
  end

  def postfill
    unless params[:callerReference].blank?
      @order = Order.postfill!(params)
    end
    # "A" means the user cancelled the preorder before clicking "Confirm" on Amazon Payments.
    if params['status'] != 'A' && @order.present?
      redirect_to :action => :share, :uuid => @order.uuid
    else
      redirect_to root_url
    end
  end

  def share
    @order = Order.find_by_uuid(params[:uuid])
  end

  def ipn
  end
end
