# vim:tw=0:et:ts=2:

class ResultType < ActiveRecord::Base

  def ResultType.name_id_array
    return ResultType.find(:all).collect {|s| [s.name, s.id]}
  end

end
