# In app/controllers/gocardless_controller.rb, within GocardlessController

def submit
  # We'll be billing everyone £10 per month in this example
  url_params = {
    :amount          => 10,
    :interval_unit   => "month",
    :interval_length => 1,
    :name            => "Premium Subscription",
    # Set the user email from the submitted value
    :user => {
      :email => params["email"]
    }
  }
  url = GoCardless.new_subscription_url(url_params)
  redirect_to url
end

# In app/controllers/gocardless_controller.rb, within GocardlessController

# Implement the confirm action
def confirm
  GoCardless.confirm_resource params
  render "gocardless/success"
rescue GoCardless::ApiError => e
  render :text => "Could not confirm new subscription. Details: #{e}"
end