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

1. You can define machine with `Metamachine.register` call
2. Pass the state reader to `metamachine` call. We don't write a state but we definitely have to read it in order to validate it for you.
2. Define state_reader, states, events and transitions using DSL
4. Implement your own runner which executes contract. Implement `run` block which changes an object state.

```ruby

Metamachine.register('post_machine') do
  state_reader :status

  states :draft, :published

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

post = Post.new(status: 'draft')

Metamachine::Registry['post_machine'].run(post, :publish)
```

More convinient way would be to define dispatch method directly on your model class. Just extend it with `Metamachine::Mixin`.


```ruby
class Post
  extend Metamachine::Mixin

  metamachine do
    state_reader :status
    states :draft, :published

    event :publish do
      transition from: :draft, to: :published
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

## Explicit contract call

You are able to access `Contract` instance and run it on any object including the original target.
Note that metamachine do it implicitly for you and wraps `run` by contract.
But you also allowed to run it explicitly at any point of `run` execution. This operation is safe since it doesn't mutate anything but just validates precondition(initial status) and postcondition(result status).
This can be useful if you want to force exceptions to be raised in order to rollback database transaction.

```ruby

run do |transition, object|
  ActiveRecord::Base.transaction do
    transition.contract.call!(object) do
      object.update!(status: transition.state_to)
    end

    write_log
  end
end

```

## Inspect transition

```ruby
transition.event       # => 'publish'
transition.target      # => #<Post>
transition.params      # => { author: #<User> }
transition.state_from  # => 'draft'
transition.state_to    # => 'published'
```

