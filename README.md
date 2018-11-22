## DIY SM

It uses the similar DSL as most of ruby state machine do. The only thing what we don't do: we don't change a state itself.

### WAT?
The main idea behind this is to provide maximum of flexibility. There is a billion ways to change a state.
You can persist or not persist, use database transactions, send emails before or after, write logs etc.
Usually state machine libraries perform state transition and provide callbacks for you. We avoid callbacks at all.

Our job is just a validation of initial state and making sure that you eventually run transition _by yourself_ and change a state to the needed one.

### Why do I still need any state machine?

1. Having a map of events and state transitions in one place is a great visualisation of business workflow
2. It provides states validation and neat helpers for you.

## Setup

1. Include `DIYSM` module into your class.
2. Pass the state reader to `diy_sm` call. We don't write a state but we definitely have to read it in order to validate it for you.
3. Define states, events and transitions using DSL
4. Implement method `handle_sm_event`. Inside this method you must call `event#transition`.


```ruby
class Post
  include DIYSM

  diy_sm(:status) do
    state :draft, :published

    event :publish do
      transition from: :draft, to: :published
    end

    event :archive do
      transition from: :published, to: :archived
    end
  end

  def handle_sm_event(event)
    # Minimal implementation to make transitions work
    event.transition do
      self.status = event.expected_state
    end
  end
end
```

This is how we execute a contract. You call `#transition` and change a state inside a block.
In the end of block, new state will be validated, and exception will be raised if you did that improperly.

Such approach allows you to use database transaction and rollback them. Take a look on a more complex example below. Here we delegate transition execution to service objects.

```ruby

def handle_sm_event(event)
  "Transitions::#{event.to_s.camelize}".constantize.call(event)
end

# Implementation of specific transition
class Transitions::Publish do
  class << self
    def call(event)
      post = event.object

      ActiveRecord::Base.transaction do
        event.transition do
          post.update!(status: 'published', published_at: Time.now)
        end

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

## Inspect event

```ruby
event.to_s            # => 'publish'
event.object          # => #<Post>
event.params          # => { author: #<User> }
event.initial_state   # => 'draft'
event.expected_state  # => 'published'
```

