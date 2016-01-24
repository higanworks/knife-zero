myitem = Chef::EncryptedDataBagItem.load("mybag", "myitem")

file "/tmp/data_v3" do
  content myitem['mydata']
end
