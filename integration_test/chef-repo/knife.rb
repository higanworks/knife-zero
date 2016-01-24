local_mode true
chef_repo_path "."
data_bag_encrypt_version 3
knife[:secret_file] = 'encrypted_data_bag_secret'

if ENV['POLICY_MODE']
  use_policyfile true
  versioned_cookbooks true
  policy_document_native_api false
end
