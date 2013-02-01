GoCardless.account_details = {
  app_id: Settings.app_id,
  app_secret: Settings.app_secret,
  token: Settings.token,
  merchant_id: Settings.merchant_id
}

GoCardless.environment = :sandbox unless Rails.env.production?