# vi:tw=0:et:ts=2

class Invoice < ActiveRecord::Base

  has_many :people

  def Invoice.pay_period_start_date 
    today = Date.today
    if today.mday <= 15
      start_date = Date.new(today.year, today.month, 1)
    else
      start_date = Date.new(today.year, today.month, 15)
    end
    return start_date
  end 

  def Invoice.pay_period_end_date
    today = Date.today
    if today.mday <= 15
      end_date = Date.new(today.year, today.month, 15)
    else
      end_date = Date.new(today.year, today.month, -1)
    end
    return end_date
  end

end
