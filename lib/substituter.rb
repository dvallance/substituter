require "substituter/version"

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

    def get_proc method
      @stored_procs[method]
    end

    def parameters_to_definition array
      # req     -required argument
      # opt     -optional argument
      # rest    -rest of arguments as array
      # keyreq  -reguired key argument (2.1+)
      # key     -key argument
      # keyrest -rest of key arguments as Hash
      # block   -block parameter
      definition = []
      alphabit = ("a".."z").to_a
      array.each_with_index do |param_definition, count|
        case param_definition[0]
        when :req
          definition << alphabit[count] 
        when :opt
          definition << "#{alphabit[count]}=nil"
        when :rest
          definition << "*#{alphabit[count]}"
        when :block
          definition << "&#{alphabit[count]}"
        end
      end
      definition
    end

    def prefix(method)
      @method_rename_prefix + method.to_s
    end

    def sub klass, method, aproc
      if substituted_methods(klass).include? method
        raise StandardError, "Already substituted"
      end 

      params_definition = parameters_to_definition(klass.instance_method(method).parameters)
      klass.class_eval %Q(
        include Substituter unless ancestors.select{|obj| obj.class == Module}.include?(Substituter)
        alias_method :#{prefix(method)}, :#{method.to_s}
        def #{method.to_s}(#{params_definition.join(',')})
          proc_caller(__method__, *(local_variables.collect{|p| eval(p.to_s) })) 
        end
      ), __FILE__, __LINE__
      substituted_method klass, method, aproc 
    end

    def substituted_method(klass, method, aproc)
      @handled_methods[klass.to_s] = [] unless @handled_methods[klass.to_s].is_a? Array
      @handled_methods[klass.to_s] << method
      Substituter.stored_procs[method] = aproc
    end

    def substituted_methods(klass)
      @handled_methods[klass.to_s].nil? ? [] : @handled_methods[klass.to_s]
    end
  end

  #instance methods below

  def proc_caller(method, *args)
    stored_proc = Substituter.get_proc(method)
    stored_proc.call(method("#{Substituter.prefix(method)}".to_sym), *args)
  end

end
