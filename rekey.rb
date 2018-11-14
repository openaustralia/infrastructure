#!/usr/bin/ruby

# Usage: ./rekey.rb > new.yaml; cp new.yaml group_vars/righttoknow.yaml

INFILE="group_vars/ec2.yml"
NEWID="ec2"

require 'psych'
data = Psych.load_file(INFILE)

data.each_pair { | key, value |
  if value =~ /.*ANSIBLE_VAULT.*/
    decrypted = `echo '#{value}' | ansible-vault decrypt`
    decrypted = decrypted.strip
    rekeyed = `echo -n '#{decrypted}' | ansible-vault --encrypt-vault-id #{NEWID} encrypt_string --stdin-name #{key}` 
    $stdout.puts rekeyed
  else
    $stdout.puts Psych.dump_stream( {key => value} ).gsub!(/---\n/, "")
  end
}
