# vim:tw=0:et:ts=2:

class Filter
  attr_accessor :name, :display_name, :type, :op_vals, :sql, :blank_enabled, :substring

  # provide ActiveRecord::Base-style initialization (via a hash)
  def initialize(attr_hash = nil)
    if ! attr_hash.nil?
      attr_hash.keys.each do |k|
        self.send("#{k}=", attr_hash[k])
      end
    end
  end

  def label_name
    return "filter_#{self.name}"
  end

  def Filter.new_school_id_filter
    return Filter.new( {
      :name => "school_id", 
      :display_name => "School", 
      :type => "select", 
      :op_vals => School.name_id_array, 
      :sql => "school_id = :school_id", 
      :blank_enabled => true }) 
  end

  def Filter.new_name_filter
    return Filter.new( {
      :name => "name", 
      :display_name => "Name", 
      :type => "text", 
      :substring => true,
      :sql => "(fname LIKE :name OR lname LIKE :name)" })
  end

  def Filter.new_email_filter
    return Filter.new( {
      :name => "email", 
      :display_name => "Email", 
      :type => "text",
      :substring => true,
      :sql => "email LIKE :email" })
  end
  
  def Filter.condition_sql(filters, values)
    sql = ""

    
    filters.each do |f|
      if values[f.label_name] && ! values[f.label_name].empty?
        sql.concat(" AND ") unless sql.empty?
        if ! f.sql.nil?
          # have to tweak the regex stuff here because otherwise it gets
          # escaped wrong by the :conditions interpolation later
          sql.concat(
            f.sql.gsub(
              /(\W):#{f.name}(\W?)/, 
              '\1' + ActiveRecord::Base.sanitize((f.substring ? '%' : "") + values[f.label_name] + (f.substring ? '%' : "")) + '\2'))
        else
          # sneaky error reporting if Filter's sql attr is not set
          sql.concat("\"#{f.label_name}\" = \"#{f.label_name}\"")
        end
      end
    end

    # this will get passed to a :conditions hash for Model.find, which freaks
    # out if it doesn't get a value. hence, check a sql tautology if no other
    # filter is set.
    sql = "true = true" if sql.empty?

    return sql
  end
  
end
