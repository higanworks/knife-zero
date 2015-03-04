clearing :on

guard :shell do
  watch(%r{^(?:test|lib)/.+\.rb$}) { `ruby test/run_test.rb -v --notify` }
end
