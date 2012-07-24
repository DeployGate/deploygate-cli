#!/usr/bin/ruby 
require 'net/http'
require 'json'
require 'pp'

API_BASE_URL = "http://localhost:3000"
$settings = {
  :token => ""
}

def post_request(path,params)
  uri = URI(API_BASE_URL + path)
  req = Net::HTTP::Post.new(uri.path)
  api_token = $settings[:token]
  unless api_token.nil?
    req['HTTP_AUTHORIZATION'] = api_token
  end 
  unless params.nil?
    req.set_form_data(params)
  end
  res = Net::HTTP.start(uri.host, uri.port) do |http|
    http.request(req)
  end
  return nil unless res.code == "200"
  res_object = JSON.parse(res.body)
  pp res_object['error'].to_s
  return nil if res_object['error'] == true
  return res_object['results']
end
if ARGV[0].nil?
  print "please read command guide.\n"
  exit
end


if $settings[:token].nil? || $settings[:token] == ""
  #login
  print "Email:"
  email = $stdin.gets.chop
  print "Password:"
  password = $stdin.gets.chop
  login_res = post_request(
    '/api/sessions',{
      'email' => email, 
      'password' => password
    })
  if login_res.nil?
    print "Invalid email or password.\n"
    exit
  end
  $settings[:token] = login_res['api_token'] 
end

if ARGV[0] == "push"
  
end





login_res = post_request(
    '/api/sessions',{
      'email' => 'kyoro@hakamastyle.net', 
      'password' => 'hoge'
    })





