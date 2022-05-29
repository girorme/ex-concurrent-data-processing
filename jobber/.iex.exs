good_job = fn ->
  Process.sleep(60_000)
  {:ok, []}
  end

bad_job = fn ->
  Process.sleep(3000)
  :error
end

doomed_job = fn ->
  Process.sleep(3000)
  raise "Boom!"
end
