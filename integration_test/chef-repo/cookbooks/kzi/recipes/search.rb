all_nodes = search(:node, "name:*")

file '/tmp/nodes' do
  content all_nodes.to_s
end
