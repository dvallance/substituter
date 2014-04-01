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
  "My proc can do anything and has access to the original method and its arguments. So lets call it an see its value = #{original_method.call(*args)}
}

Substituter.sub String, :to_s, my_proc
puts String.new("So Cool!")

#returns "My proc can ... an see its value = So Cool!" 

#to restore the original method just clear the substitute
Substituter.clear String, :to_s

```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
