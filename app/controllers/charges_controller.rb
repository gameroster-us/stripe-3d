require "stripe"

class ChargesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @price = params[:price]
  end

  def create
    Stripe.api_key = 'sk_test_51MazEpAtaSHqtwmKOZiRQSoi8iBLOMjSA0GSXdONnIBz4HpvGNtepJZYfLSTfrOex8WdYTjgbOzDaH4gYFlTdiw800sfWciFUx'    
    begin
      intent = Stripe::PaymentIntent.create(
        payment_method: params[:payment_method_id],
        amount: params[:amount],
        currency: 'usd',
        return_url: "#{ENV['HOST']}/success",
        confirmation_method: 'manual',
        confirm: true,
      )
    rescue Stripe::CardError => e
      return [200, { error: e.message }.to_json]
    end
    generate_response(intent)
  end

  def generate_response(intent)
    if intent.next_action.type == "redirect_to_url" && intent.status == 'requires_action'
      render json: {
        url: intent.next_action['redirect_to_url']['url']
      }.to_json
    else
      PaymentDatum.create(payment_token: intent.id, amount:intent.amount/100.0)
      render json: { url: "#{ENV['HOST']}/fail" }.to_json 
    end
  end

  def success
    begin
    intent = Stripe::PaymentIntent.retrieve(params['payment_intent'])
    if intent.status == 'requires_confirmation'
      intent = Stripe::PaymentIntent.confirm(
        params['payment_intent']
      )
    end
    rescue Stripe::CardError => e
      puts "A payment error occurred: #{e.error.message}"
    rescue Stripe::InvalidRequestError => e
      puts "An invalid request occurred."
    rescue Stripe::StripeError => e
      puts "Another problem occurred, maybe unrelated to Stripe."
    else
      puts "No error."
    end
    if intent.status == "succeeded"
      PaymentDatum.create(payment_token: intent.id, amount:intent.amount/100.0 , status: true)
    else
      PaymentDatum.create(payment_token: intent.id, amount:intent.amount/100.0)
      redirect_to "#{ENV['HOST']}/fail"
    end
  end

  def fail
  end

  def payment_data
    @payment_data = PaymentDatum.order(created_at: :desc).page(params[:page])
  end
end