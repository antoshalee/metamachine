## Metamachine

It uses the similar DSL as most of ruby state machine do. The only thing what we don't do: we don't change a state itself.

### What?
The main idea behind this is to provide maximum of flexibility. There is a billion ways to change a state.
You can persist or not persist, use database transactions, send emails before or after, write logs etc.
Usually state machine libraries perform state transition and provide callbacks for you. We avoid callbacks at all.

Our job is just a validation of initial state and making sure that you eventually run transition _by yourself_ and change a state to the needed one.

### Why do I still need any state machine?

1. Having a map of events and state transitions in one place is a great visualisation of business workflow
2. It provides states validation and neat helpers for you.

## Setup

1. Include `Metamachine` module into your class.
2. Pass the state reader to `metamachine` call. We don't write a state but we definitely have to read it in order to validate it for you.
3. Define states, events and transitions using DSL
4. Implement your own runner. Inside `run` block you must change an object state.


```ruby
class Post
  include Metamachine

  metamachine(:status) do
    state :draft, :published

    event :publish do
      transition from: :draft, to: :published
    end

    event :archive do
      transition from: :published, to: :archived
    end

    # Minimal implementation to make transitions work
    run do |transition|
      transition.target.status = transition.state_to
    end
  end
end

post = Post.new
post.publish
```

This is how we execute a contract. You define `run` block and change a state explicitly inside.
After block execution, new state will be validated, and exception will be raised if you did that improperly.

Please note you are not permitted to call other transitions on your object within `run` block. It throws `NestedTransitionsError`

## Pre-validation

You are able to pre-validate result by your own in the middle of `run` execution. This can be useful to rollback transactions. Take a look on a more complex example below. Here we delegate transition execution to service objects.

```ruby

# Define runner
run do |transition, object|
  "Transitions::#{transition.event.camelize}".constantize.call(transition)
end

# Implementation of specific transition
class Transitions::Publish do
  def initialize(transition)
    @transition = transition
  end

  class << self
    def call(transition)
      ActiveRecord::Base.transaction do
        transition.target.update!(status: 'published', published_at: Time.now)

        # Pre-validate this to be able to rollback transaction
        transition.validate_result!

        do_other_stuff_within_transaction
      end

      send_email_to event.params[:author]
      and_do_a_lot_of_other_stuff
    end
  end
end

# we are able to run event with hash parameters
post.request(author: user)

```

## Inspect transition

```ruby
transition.event       # => 'publish'
transition.target      # => #<Post>
transition.params      # => { author: #<User> }
transition.state_from  # => 'draft'
transition.state_to    # => 'published'
```

