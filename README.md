Concurrent data processing
===

My annotations/implementations/studies surrounding concurrency/parallelism on elixir/erlang.

> Some examples and citations extracted from: Concurrent data processing in elixir from pragprog (by Svilen Gospodinov)

### Example projects
[Sender - Send email using genserver as example](sender/)

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

### About the erlang/elixir "Let it Crash"

> When discussing error handling for Elixir, the phrase let it crash is often used.
As a result, some people assume that let it crash means that Erlang and Elixir
developers don’t do any error handling, which is not the case. Pattern
matching and the `with` macro in Elixir make working with `{:ok, result}` and `{:error,
msg}` tuples easy, and this approach is widely used in the community. Elixir
also has try and rescue for catching exceptions, similarly to try and catch in
other languages.

> However, as much as we try as engineers, we know that errors can happen.
This often leads to something called defensive programming. It describes the
practice of relentlessly trying to cover every single possible scenario for failure,
even when some scenarios are very unlikely to happen, and not worth dealing
with.

> Erlang and Elixir take a different approach to defensive programming. Since
all code runs in processes and processes that are lightweight, they focus on
how the system can recover from crashes versus how to prevent all crashes.
You can choose to allow a part (or even the whole) of the application to crash
and restart, but handle other errors yourself. This shift in thinking and software
design is the reason why Erlang became famous for its reliability and
scalability.
