#!/usr/bin/env ruby
require 'json'
require 'yaml'
require 'optparse'

##
# Description:
# Helper script for translate json to swagger yaml
#
# Usage example:
#
# $ curl https://indexing.googleapis.com/v3/urlNotifications/metadata | ruby json_to_swagger.rb
# ---
# error:
#     type: object
# properties:
#     code:
#     type: integer
# message:
#     type: string
# status:
#     type: string
#
# Or
# $  ruby json_to_swagger.rb -r RootObj -j '{"m":"hello","arr_obj":[{"field":"msg"},{"c":2}],"ids":[1,2],"active":true,"obj":{"n":"Dart","some_id":null}}'
# ---
# RootObj:
#     type: object
# properties:
#     m:
#     type: string
# arr_obj:
#     type: array
# items:
#     type: object
# properties:
#     field:
#     type: string
# ids:
#     type: array
# items:
#     type: integer
# active:
#     type: boolean
# obj:
#     type: object
# properties:
#     n:
#     type: string
# some_id:
#     type: integer



options = {}
OptionParser.new do |parser|
  parser.banner = 'Usage: json_to_yml.rb [options]'

  parser.on('-h', '--help', 'Show this help message') do
    puts parser
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
                    { type: :boolean }
                  when Numeric
                    { type: :integer }
                  when Array
                    if v.first.is_a? Hash
                      item_hash = parse_hash(v.first)
                      { type: :array, items: { type: :object, properties: item_hash } }
                    elsif v.first.is_a? Numeric
                      { type: :array, items: { type: :integer } }
                    end
                  when Hash
                    new_hash[k] = { type: :object, properties: parse_hash(hash[k]) } if hash[k]
                  when NilClass
                    k.to_s.end_with?('_id') ? { type: :integer } : {type: :string }
                  else
                    { type: :string }
                end
    new_hash[k] = out_type
  end
  new_hash
end

hash = parse_hash JSON.parse(options.fetch(:json, {}), {symbolize_names: true, allow_nan: true})
hash = { options[:root] => { type: :object, properties: hash } } if options[:root]

json = JSON.load(hash.to_json)
yaml = YAML.dump(json)
print yaml