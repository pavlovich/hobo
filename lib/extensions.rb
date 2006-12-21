################################################################
# instance_exec (coming to Ruby in 1.9)
# Like instance_eval but supports block arguments
# From http://eigenclass.org/hiki.rb?bounded+space+instance_exec
# With thanks to Mauricio Fernandez
################################################################
class Object

#  module InstanceExecHelper; end
#  include InstanceExecHelper
#  def instance_exec(*args, &block)
#    begin
#      old_critical, Thread.critical = Thread.critical, true
#      n = 0
#      n += 1 while respond_to?(mname="__instance_exec#{n}")
#      InstanceExecHelper.module_eval{ define_method(mname, &block) }
#    ensure
#      Thread.critical = old_critical
#    end
#    begin
#      ret = send(mname, *args)
#    ensure
#      InstanceExecHelper.module_eval{ remove_method(mname) } rescue nil
#    end
#    ret
#  end

  def is_in?(array)
    array.include?(self)
  end

  def not_in?(array)
    not array.include?(self)
  end
end

module Enumerable

  def omap(method = nil, &b)
    if method
      map(&method)
    else
      map {|x| x.instance_eval(&b)}
    end
  end

  def oselect(method = nil, &b)
    if method
      select(&method)
    else
      select {|x| x.instance_eval(&b)}
    end
  end

  def ofind(method=nil, &b)
    if method
      find(&method)
    else
      find {|x| x.instance_eval(&b)}
    end
  end

  def search(not_found=nil)
    each do |x|
      val = yield(x)
      return val if val
    end
    not_found
  end

  def oany?(method=nil, &b)
    if method
      any?(&method)
    else
      any? {|x| x.instance_eval(&b)}
    end
  end

  def oall?(method=nil, &b)
    if method
      all?(&method)
    else
      all? {|x| x.instance_eval(&b)}
    end
  end

  def every(proc)
    map(&proc)
  end

end

class Hash

  def self.build(array)
    array.inject({}) do |res, x|
      k, v = yield x
      res[k] = v
      res
    end
  end

  def select_hash(new_keys=nil, &b)
    res = {}
    if b
      each {|k,v| res[k] = v if yield(k,v) }
    else
      new_keys.each {|k| res[k] = self[k] if self.has_key?(k)}
    end
    res
  end

  #alias_method :hobo_original_reject, :reject
  def rejectX(keys=nil, &b)
    if b
      hobo_original_reject(&b)
    else
      res = {}.update(self) # can't use dup because it breaks with symbols
      keys.each {|k| res.delete(k)}
      res
    end
  end

  def partition_hash(keys=nil, &b)
    yes = {}
    no = {}
    each do |k,v|
      q = b ? yield(k,v) : keys.include?(k)
      if q
        yes[k] = v
      else
        no[k] = v
      end
    end
    [yes, no]
  end

end

###################################################
# Fix pp dumps - these break sometimes without this
###################################################
require 'pp'
module PP::ObjectMixin

  alias_method :orig_pretty_print, :pretty_print
  def pretty_print(q)
    orig_pretty_print(q)
  rescue
    "[#PP-ERROR#]"
  end

end

