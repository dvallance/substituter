require "substituter/version"
def Hijack(klass, method, &aproc)
  Substituter.sub(klass, method, &aproc)
end

module Substituter

  @handled_methods = {}
  @stored_procs = {}
  @method_rename_prefix = "substituted_"

  class << self
    attr_accessor :stored_procs

    def clear(klass, method)
      klass.class_eval %Q(
        remove_method method
        alias_method :#{method.to_s}, :#{prefix(method)}
        remove_method :#{prefix(method)}
      ), __FILE__, __LINE__
      @handled_methods[klass.to_s].delete(method)
    end

    def get_proc klass, method
      @stored_procs[klass.to_s + method.to_s]
    end

    def prefix(method)
      @method_rename_prefix + method.to_s
    end

    def sub klass, method, &aproc
      if substituted_methods(klass).include? method
        raise StandardError, "Already substituted"
      end 

      klass.class_eval %Q(
        include Substituter unless ancestors.select{|obj| obj.class == Module}.include?(Substituter)
        alias_method :#{prefix(method)}, :#{method.to_s}
        def #{method.to_s}(*args)
          if block_given?
            proc_caller(self.class, __method__, *(args << Proc.new))
          else
            proc_caller(self.class, __method__, *args) 
          end
        end
      ), __FILE__, __LINE__
      substituted_method klass, method, &aproc 
    end

    def substituted_method(klass, method, &aproc)
      @handled_methods[klass.to_s] = [] unless @handled_methods[klass.to_s].is_a? Array
      @handled_methods[klass.to_s] << method
      Substituter.stored_procs[klass.to_s + method.to_s] = aproc
    end

    def substituted_methods(klass)
      @handled_methods[klass.to_s].nil? ? [] : @handled_methods[klass.to_s]
    end
  end

  #instance methods below

  def proc_caller(klass, method, *args)
    stored_proc = Substituter.get_proc(klass, method)
    stored_proc.call(method("#{Substituter.prefix(method)}".to_sym), *args)
  end

end
