#!/usr/bin/env ruby
require 'json'
require 'yaml'
require 'optparse'

##
# Description:
# Helper script for convert json to swagger yaml
#
# Usage: json_to_yml.rb [options]
#   -h, --help                       Show this help message
#   -r, --root ROOT                  The name of the json root
#   -j, --json JSON                  Json body

options = {}
OptionParser.new do |parser|
  parser.banner = 'Usage: json_to_yml.rb [options]'

  parser.on('-h', '--help', 'Show this help message') do
    puts parser
    exit(0)
  end

  parser.on('-r', '--root ROOT', 'The name of the json root') do |v|
    options[:root] = v
  end
  parser.on('-j', '--json JSON', 'Json body') do |v|
    options[:json] = v
  end
end.parse!

def parse_hash(hash = {})
  new_hash = {}
  hash.each do |k, v|
    out_type = case v
                 when TrueClass, FalseClass
                   {type: :boolean}
                 when Numeric
                   {type: :integer}
                 when Array
                   if v.first.is_a? Hash
                     item_hash = parse_hash(v.first)
                     {type: :array, items: {type: :object, properties: item_hash}}
                   elsif v.first.is_a? Numeric
                     {type: :array, items: {type: :integer}}
                   end
                 when Hash
                   new_hash[k] = {type: :object, properties: parse_hash(hash[k])} if hash[k]
                 when NilClass
                   k.to_s.end_with?('_id') ? {type: :integer} : {type: :string}
                 else
                   {type: :string}
               end
    new_hash[k] = out_type
  end
  new_hash
end

options[:json] = STDIN.read unless options[:json]

hash = parse_hash JSON.parse(options.fetch(:json, {}), {symbolize_names: true, allow_nan: true})
hash = {options[:root] => {type: :object, properties: hash}} if options[:root]

json = JSON.load(hash.to_json)
yaml = YAML.dump(json)
print yaml