#!/usr/bin/ruby 
require 'optparse'
require 'net/http'
require 'json'
require 'httpclient'
require 'pp'

API_BASE_URL = "https://stg.deploygate.com"
#API_BASE_URL = "http://localhost:3000"
#API_BASE_URL = "http://picora.us:8080"
SETTING_FILE = ENV["HOME"] + "/.dgate"
$settings = {
  'name' => "",
  'token' => ""
}


def post_request(path,params)
  url = API_BASE_URL + path
  client = HTTPClient.new
  extheaders = []
  api_token = $settings['token']
  unless api_token.nil?
    extheaders.push(['AUTHORIZATION',api_token])
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
  api_token = $settings['token']
  unless api_token.nil?
    extheaders.push(['AUTHORIZATION',api_token])
  end
#params = {'token' => api_token}
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
  $settings = JSON.parse(data)
end

def do_create_session
  print "Email: "
  STDOUT.flush
  email = $stdin.gets.chop
  system "stty -echo"
  print "Password: "
  STDOUT.flush
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
  $settings['token'] = login_res['api_token']
  $settings['name'] = login_res['name']
  do_save_settings
  return true
end

def do_check_session
  check_res = get_request('/api/sessions/user',{})
  if check_res.nil?
    print "Your session was expired or invalid.\n"
    exit unless  do_create_session
    check_res = get_request('/api/sessions/user',{})
  end
  $settings['name'] = check_res['name']
  return true
end

def do_push_file
  message = $message || ''
  file_path = nil
  target_user = nil
  if ARGV[2].nil?
    target_user = $settings['name']
    file_path = ARGV[1]
  else
    target_user = ARGV[1]
    file_path = ARGV[2]
  end
  if file_path.nil? || !File.exist?(file_path)
    print "target file is not found.\n"
    exit
  end
  push_res = nil
  open(file_path) do |file|
    push_res = post_request(
        sprintf("/api/users/%s/apps",target_user),
        { :file => file , :message => message}
        )
  end
  if push_res.nil?
    print "Sorry, push operation was faild.\n"
    exit
  end
  web_url =  sprintf("%s/users/%s/apps/%s",
      API_BASE_URL,target_user,push_res['package_name'])
  #if first app, start to share.
  if push_res['revision'] == 1
    share_res = post_request(
        sprintf(
          "/api/users/%s/apps/%s/share",
          target_user,push_res['package_name']),{}
        )
    if !share_res['secret'].nil?
      web_url += sprintf("?key=%s",share_res['secret'])
    end
  else
    if !push_res['secret'].nil?
      web_url += sprintf("?key=%s",push_res['secret'])
    end
  end
  print "Push app file successful!\n"
  print "\n"
  print "Name :\t\t" + push_res['name'] + "\n"
  print "Owner :\t\t" + push_res['user']['name'] + "\n"
  print "Package :\t" + push_res['package_name'] + "\n"
  print "Revision :\t" + push_res['revision'].to_s + "\n"
  print "URL :\t\t" + web_url
  print "\n\n"
  if(!$open_with_browser.nil? || push_res['revision'] == 1)
    system "open " + web_url
  end
end

def do_help_show
  print "help===========\n"
  exit
end

### options
OptionParser.new do |option|
  Version = "0.0.1"
  option.on('-m [ PUSH MESSAGE ]','push message'){ |message| $message = message }
  option.on('-h','--help','show this message'){ do_help_show }
  option.on('-o','--open','open with browser (Mac OS only)'){ $open_with_browser = true }
  begin
    option.parse!
  rescue
    print "Invalid option.\n";
    do_help_show
    exit
  end
end

#### main
do_load_settings
command = ARGV[0]

if command.nil?
  print "Please set dgate command.\n"
  exit
end

# logout
if command == 'logout'
  $settings['token'] = ''
  do_save_settings
  print "Session is deleted.\n"
  exit
end

# login
if $settings['token'].nil? || $settings['token'] == ""
  do_create_session
else
  do_check_session
end

if command == 'push'
  if ARGV[1].nil?
    print "Please set target app file.\n"
    exit
  end
  do_push_file
end
