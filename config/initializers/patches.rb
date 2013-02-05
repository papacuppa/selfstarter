# Patching MySQL:
# 
require 'mysql'
 
class Mysql::Result
  def encode(value, encoding = "utf-8")
    String === value ? value.force_encoding(encoding) : value
  end
  
  def each_utf8(&block)
    each_orig do |row|
      yield row.map {|col| encode(col) }
    end
  end
  alias each_orig each
  alias each each_utf8
 
  def each_hash_utf8(&block)
    each_hash_orig do |row|
      row.each {|k, v| row[k] = encode(v) }
      yield(row)
    end
  end
  alias each_hash_orig each_hash
  alias each_hash each_hash_utf8
end
 
# Patching ActionController:
# 
module ActionController
  class Request
    private
    def normalize_parameters_with_force_encoding(value)
      (_value = normalize_parameters_without_force_encoding(value)).respond_to?(:force_encoding) ? 
         _value.force_encoding(Encoding::UTF_8) : _value
    end
    alias_method_chain :normalize_parameters, :force_encoding
  end
end