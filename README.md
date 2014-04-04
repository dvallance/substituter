# Substituter

Substituter is designed to easily override an existing class instance method with a provided Proc. The existing method is renamed and a reference is kept to this original method so that the new Proc that is executed will be able to call the original method and has access to its parameters.

## Installation

Add this line to your application's Gemfile:

    gem 'substituter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install substituter

## Usage

```ruby 
my_proc = Proc.new{|original_method,*args|
  "My proc info and original methods value = #{original_method.call(*args)}"
}

Substituter.sub String, :to_s, my_proc
puts String.new("So Cool!")

#returns "My proc info and original methods value = So Cool!" 

#to restore the original method just clear the substitute
Substituter.clear String, :to_s

```

## *args gottcha's

Generally calling `original_method.call(*args)` will work unless the original method is called with a Proc object as a parameter of with an implicit block.

Note: an _implicit_ _block_ will be turned into a Proc object and appended to the args array.

When the _args_ array contains a Proc object the splat operator can not be used when passing to the _original_method.call_. You have to specify the _&_ operator on the Proc parameter.

```ruby
# our sample class with a method to substitute
class Sample
  def taking_a_param_and_block(param)
    block_given? yield(param) : param
  end
end

# our proc we will substitute in for the original method
my_proc = Proc.new{|original_method,*args|
  #here we explicitly pass in the arguments, making sure to add '&' to the proc object
  "My proc info and original methods value = #{original_method.call(args[0], args[1])}"
}

Substituter.sub Sample, :taking_a_param_and_block, my_proc

Sample.new.taking_a_param_and_block("Hello") do |param|
  "#{param} World"
end

#returns "My proc info and original methods value = Hello World!" 

#see the spec/substituter_spec.rb for examples

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
