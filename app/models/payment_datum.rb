class PaymentDatum < ApplicationRecord

  paginates_per 20

  def status_view
    if status
      :success
    else
      :fail
    end
  end
    
end
