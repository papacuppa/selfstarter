# -*- encoding : utf-8 -*-
class PreorderController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :webhook

  def index
  end

  def checkout
  end

  def prefill
    @user  = User.find_or_create_by_email!(params[:email])
    @order = Order.prefill!(name: Settings.product_name, price: Settings.price, quantity: params[:quantity].to_i, user_id: @user.id)

    go_url = GoCardless.new_pre_authorization_url(amount: @order.total_price, name: @order.name, interval_unit: 'month
      ', interval_length: 3, user: { email: @user.email }, state: @order.uuid)
    redirect_to go_url
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

  def share
    @order = Order.find_by_uuid(params[:uuid])
  end

  def webhook
    webhook_data = params[:payload]

    if GoCardless.webhook_valid?(webhook_data)
      if webhook_data[:resource_type] == 'pre_authorization' && webhook_data[:action] == 'cancelled'
        @order = Order.find_by_token webhook_data['pre_authorizations'].first[:id]
        @order.cancel! if @order.present?
      end
    else
      # log the error
    end

    render nothing: true, status: 200
  end
end
