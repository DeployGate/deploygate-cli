#!/usr/bin/ruby 
require 'net/http'
require 'json'
require 'httpclient'
require "readline"
require 'pp'

API_BASE_URL = "http://localhost:3000"
SETTING_FILE = ENV["HOME"] + "/.dgate"
$settings = {
  :token => "aa"
}


def post_request(path,params)
  url = API_BASE_URL + path
  client = HTTPClient.new
  extheaders = []
  api_token = $settings[:token]
  unless api_token.nil?
    extheaders.push(['HTTP_AUTHORIZATION',api_token])
  end
  res = client.post(url,params,extheaders)
  return nil unless res.status_code == 200
  res_object = JSON.parse(res.body)
  return nil if res_object['error'] == true
  return res_object['results']
end

def get_request(path,params)
  url = API_BASE_URL + path
  client = HTTPClient.new
  extheaders = []
  api_token = $settings[:token]
  unless api_token.nil?
    extheaders.push(['HTTP_AUTHORIZATION',api_token])
  end
  res = client.get(url,params,extheaders)
  return nil unless res.status_code == 200
  res_object = JSON.parse(res.body)
  return nil if res_object['error'] == true
  return res_object['results']
end

def do_save_settings
  data = JSON.generate($settings)
  file = open(SETTING_FILE,"w+")
  file.print data
  file.close
end

def do_load_settings
  return nil unless File.exist?(SETTING_FILE)
  file = open(SETTING_FILE)
  data = file.read
  file.close
  pp data
  $settings = JSON.parse(data)
end

def do_create_session
  print "Email:"
  email = $stdin.gets.chop
  system "stty -echo"
  print "Password:"
  password = $stdin.gets.chop
  print "\n"
  system "stty echo"
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
  do_save_settings
  return true
end

def do_check_session
  check_res = get_request('/api/sessions/user',{})
  if check_res.nil?
    print "Your session was expired or invalid.\n"
    exit unless  do_create_session
  end
  return true
end


## main
do_load_settings

command = ARGV[0]

if command.nil?
  print "Please set dgate command.\n"
  exit
end


if $settings[:token].nil? || $settings[:token] == ""
  do_create_session
else
  do_check_session
end

if ARGV[0] == "push"
  
end









