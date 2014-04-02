require_relative 'spec_helper'

class SampleClass 

  def one_param(str)
    str 
  end

  def two_params(one, two)
    return [one,two].join(",")
  end

  def param_and_splat(one, *values)
    return "#{one.to_s},#{values.join(",")}"
  end

  def taking_a_proc(&block)
    block.yield
  end

  def taking_a_param_and_proc(param, &block)
    block_given? ? yield(param) : param
  end

  def taking_a_param_and_block(param)
    block_given? ? yield(param) : param
  end
end

describe Substituter do

  it ".parameters_to_definition correctly creates the message definition" do
    parameters_example = [[:req, :a], [:opt, :b], [:rest, :c], [:block, :e]]
    Substituter.parameters_to_definition(parameters_example).join(',').must_equal "a,b=nil,*c,&d"
  end

  it ".sub properly allows us to inject a proc to substitute a class instance method " do
    myproc = Proc.new { |original_method, *args|
      "Proc knows original = #{original_method.call(*args)}"
    }
    Substituter.sub(SampleClass, :one_param, myproc)
    SampleClass.new.one_param("Cool").must_equal "Proc knows original = Cool"
    Substituter.clear SampleClass, :one_param
  end

  it ".sub will not allow you to substitute the same method twice" do
    myproc = Proc.new { |original_method, *args|
      "Proc knows original = #{original_method.call(*args)}"
    }
    Substituter.sub SampleClass, :one_param, myproc
    lambda { Substituter.sub SampleClass, :one_param, myproc }.must_raise(StandardError)
    Substituter.clear SampleClass, :one_param
  end

  it ".sub handles two params properly" do
    myproc = Proc.new { |original_method, *args|
      "Proc knows original = #{original_method.call(*args)}"
    }
    Substituter.sub SampleClass, :two_params, myproc
    SampleClass.new.two_params("one","two").must_equal "Proc knows original = one,two"
    Substituter.clear SampleClass, :two_params
  end
  
  it ".sub handles param and splat" do
    myproc = Proc.new { |original_method, *args|
      "Proc knows original = #{original_method.call(*args)}"
    }
    Substituter.sub SampleClass, :param_and_splat, myproc
    SampleClass.new.param_and_splat(:something,"two","three").must_equal "Proc knows original = something,two,three"
    Substituter.clear SampleClass, :param_and_splat
  end

  it ".sub handles taking a block" do
    myproc = Proc.new { |original_method, *args|
      "Proc knows original = #{original_method.call(&args[0])}"
    }
    Substituter.sub SampleClass, :taking_a_proc, myproc
    SampleClass.new.taking_a_proc(&Proc.new{"block value"}).must_equal "Proc knows original = block value"
    Substituter.clear SampleClass, :taking_a_proc
  end

  it ".sub handles a param and a proc" do
    myproc = Proc.new { |original_method, *args|
      "Proc knows original = #{original_method.call(args[0], &args[1])}"
    }
    Substituter.sub SampleClass, :taking_a_param_and_proc, myproc
    SampleClass.new.taking_a_param_and_proc("my param"){|p| "block value and #{p}"}.must_equal "Proc knows original = block value and my param"
    Substituter.clear SampleClass, :taking_a_param_and_proc
  end

  it ".sub handles a param and a block" do
    myproc = Proc.new { |original_method, *args|
      "Proc knows original = #{original_method.call(args[0], &args[1])}"
    }
    Substituter.sub SampleClass, :taking_a_param_and_block, myproc
    SampleClass.new.taking_a_param_and_block("my param"){|p| "block value and #{p}"}.must_equal "Proc knows original = block value and my param"
    Substituter.clear SampleClass, :taking_a_param_and_block
  end

  it ".sub String#to_s" do
    myproc = Proc.new { |original_method, *args|
      "Proc knows original = #{original_method.call(*args)}"
    }
    Substituter.sub String, :to_s, myproc
    String.new("my string").to_s.must_equal "Proc knows original = my string"
    Substituter.clear String, :to_s
    String.new("my string").to_s.must_equal "my string"
  end

  it ".sub String#index" do
    myproc = Proc.new { |original_method, *args|
      "Proc knows original = #{original_method.call(*args[0])}"
    }
    Substituter.sub String, :index, myproc
    String.new("my string").index("my").must_equal("Proc knows original = 0")
    Substituter.clear String, :index
  end

  it ".sub String#gsub" do
    myproc = Proc.new { |original_method, *args|
      "Proc knows original = #{original_method.call(*args[0])}"
    }
    Substituter.sub String, :gsub, myproc
    String.new("my string").gsub("my", "our").must_equal("Proc knows original = our string")
    Substituter.clear String, :gsub
  end

  it ".sub Object.instance_of?" do
    myproc = Proc.new { |original_method, *args|
      "Proc knows original = #{original_method.call(*args[0])}"
    }
    Substituter.sub Object, :instance_of?, myproc
    Object.new().instance_of?(Array).must_equal("Proc knows original = false")
    Substituter.clear Object, :instance_of?
  end



end
