Concurrent data processing
===

My annotations/implementations/studies surrounding concurrency/parallelism on elixir/erlang

### Task

#### Speeding up processes preventing ordered results on stream
- The default behaviour of *Task.async_stream* is return the results in same order they are passed to the stream. This can cause a "slow down" result since the stream will wait for slow processes results:

example 1
```elixir
defmodule Sender do
  def notify_all(emails) do
    emails
    |> Task.async_stream(&send_email/1)
    |> Enum.to_list()
  end
end

# call -> Sender.notify_all([
#  "a@mail.com",
#  "b@mail.com",
#  "c@mail.com"
# ])
```

In this case if the first elem in list stuck in some part the result can be slowly than:

```elixir
defmodule Sender do
  def notify_all(emails) do
    emails
    |> Task.async_stream(&send_email/1, ordered: false) # Here the ordered key prevents the stream slow down, ignoring the "wait" processes in order
    |> Enum.to_list()
  end
end

# call -> Sender.notify_all([
#  "a@mail.com",
#  "b@mail.com",
#  "c@mail.com"
# ])
```
