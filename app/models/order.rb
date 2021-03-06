# == Schema Information
#
# Table name: orders
#
#  token           :string(255)
#  transaction_id  :string(255)
#  address_one     :string(255)
#  address_two     :string(255)
#  city            :string(255)
#  state           :string(255)
#  zip             :string(255)
#  country         :string(255)
#  status          :string(255)
#  number          :string(255)
#  uuid            :string(255)      primary key
#  user_id         :string(255)
#  price           :decimal(, )
#  shipping        :decimal(, )
#  tracking_number :string(255)
#  phone           :string(255)
#  name            :string(255)
#  expiration      :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  quantity        :integer
#

class Order < ActiveRecord::Base
  attr_accessible :address_one, :address_two, :city, :country, :number, :state, :status, :token, :transaction_id, :zip, :shipping, :tracking_number, :name, :price, :phone, :expiration
  attr_readonly :uuid
  before_validation :generate_uuid!, :on => :create
  belongs_to :user
  self.primary_key = 'uuid'

  validates_presence_of :name, :price, :user_id, :quantity

  scope :authorized, where("token != ? OR token != ?", "", nil)
  scope :charged, where("transaction_id != ? OR transaction_id != ?", "", nil)
  scope :not_charged, where("transaction_id IS NULL")

  def total_price
    price * quantity
  end

  def pre_authorization
    GoCardless::PreAuthorization.find(token)
  end

  def charge!
    self.transaction_id = pre_authorization.create_bill(name: name, amount: total_price).id
    self.status = 'charged'
    save!
  end

  def cancel!
    self.token = nil
    self.status = 'cancelled'
    save!
  end

  ### State related methods ###

  def inactive!
    self.update_column(:status, 'inactive')
  end

  def active!
    self.update_column(:status, 'active')
  end

  def cancelled!
    self.update_column(:status, 'cancelled')
  end

  def charged!
    self.update_column(:status, 'charged')
  end

  ### State related methods ###

  # This is where we create our Caller Reference for Amazon Payments, and prefill some other information.
  def self.prefill!(options = {})
    @order          = Order.new
    @order.name     = options[:name]
    @order.user_id  = options[:user_id]
    @order.price    = options[:price]
    @order.quantity = options[:quantity]
    @order.number   = Order.next_order_number
    @order.save! && @order.inactive!

    @order
  end

  # After authenticating with Amazon, we get the rest of the details
  # def self.postfill!(options = {})
  #   @order = Order.find_by_uuid!(options[:callerReference])
  #   @order.token             = options[:tokenID]
  #   if @order.token.present?
  #     @order.address_one     = options[:addressLine1]
  #     @order.address_two     = options[:addressLine2]
  #     @order.city            = options[:city]
  #     @order.state           = options[:state]
  #     @order.status          = options[:status]
  #     @order.zip             = options[:zip]
  #     @order.phone           = options[:phoneNumber]
  #     @order.country         = options[:country]
  #     @order.expiration      = Date.parse(options[:expiry])
  #     @order.save!

  #     @order
  #   end
  # end

  def self.postfill!(options = {})
    @order = Order.find_by_uuid!(options[:state])
    @order.token = options[:resource_id]

    if @order.token.present?
      @order.save! && @order.active!
      @order
    end
  end

  def self.next_order_number
    if Order.count > 0
      Order.order("number DESC").limit(1).first.number.to_i + 1
    else
      1
    end
  end

  def generate_uuid!
    begin
      self.uuid = SecureRandom.hex(16)
    end while Order.find_by_uuid(self.uuid).present?
  end

  # Implement these three methods to
  def self.goal
    Settings.project_goal
  end

  def self.percent
    (Order.current.to_f / Order.goal.to_f) * 100.to_f
  end

  # See what it looks like when you have some backers! Drop in a number instead of Order.count
  def self.current
    Order.authorized.count
  end

  def self.revenue
    Order.authorized.sum(&:total_price)
  end

  def self.charge_backers!
    Order.authorized.not_charged.map(&:charge!)
  end
end
