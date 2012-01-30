# vi:tw=0:et:ts=2

class PaymentType < ActiveRecord::Base
  
  # make a dropdown box to stuff into a view. name should usually be overridden
  # to something like "payment_type_id[#{@object.id}]".
  def PaymentType.dropdown(name="payment_type_id", selected="Check")
    return_me = "<select name =\"#{name}\">"
    PaymentType.name_id_array.each do |pt|
      return_me.concat("<option value=\"#{pt.last}\" #{pt.last == selected ? "selected=\"selected\"" : ""} >")
      return_me.concat(pt.first)
      return_me.concat("</option>")
    end
    return_me.concat("</select>")

    return return_me
  end
  
  def PaymentType.name_id_array
    return PaymentType.find(:all).collect {|s| [s.name, s.id]}
  end
end
