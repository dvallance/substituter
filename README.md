# Substituter

Substituter is designed to easily substitute an existing class instance method with a provided Proc. The existing method is renamed and a reference is kept to this original method so that the new Proc that is executed will be able to call the original method and has access to its parameters.

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
puts String.new("So Cool!").to_s

#returns "My proc info and original methods value = So Cool!" 

#to restore the original method just clear the substitute
Substituter.clear String, :to_s

```

## *args gottcha's

Generally calling `original_method.call(*args)` will work unless args contains a Proc object, which it will if the orginal method is called with a proc parameter or a block.

Note: an _implicit_ _block_ will be turned into a Proc object and appended to the args array.

Proc objects must be passed with the _&_ operator prepended manually.

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
  "My proc info and original methods value = #{original_method.call(args[0], &args[1])}"
}

Substituter.sub Sample, :taking_a_param_and_block, my_proc

Sample.new.taking_a_param_and_block("Hello") do |param|
  "#{param} World"
end

#returns "My proc info and original methods value = Hello World!" 


#to see a list of all substituted methods
Substituter.ls

##-> {"String" => [:to_s]}


#see the spec/substituter_spec.rb for examples

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
