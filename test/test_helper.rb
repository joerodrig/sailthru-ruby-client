require 'minitest/autorun'
require 'minitest/pride'
require 'webmock/minitest'
require 'uri'
require 'json'
# require 'fakeweb'

require 'sailthru'

class Minitest::Test

  include Sailthru::Helpers

  # def setup
  #   FakeWeb.clean_registry
  # end

  def fixture_file(filename)
    return '' if filename == ''
    File.read(fixture_file_path(filename))
  end

  def fixture_file_path(filename)
    File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
  end

  def sailthru_api_base_url(url)
    url
  end

  def sailthru_api_call_url(url, action)
    url += '/' if !url.end_with?('/')
    sailthru_api_base_url(url + action)
  end

  def stub_get(url, filename, headers={})
    stub_request(:get, URI.parse(url)).
      with(body: fixture_file(filename), headers: { :content_type => 'application/json' })
  end

  def stub_delete(url, filename, headers={})
    stub_request(:delete, URI.parse(url)).
      with(body: fixture_file(filename), headers: { :content_type => 'application/json' })
  end

  def stub_post(url, filename, req)
    stub_request(:post, URI.parse(url)).
      with(req).
      to_return(status: 200, body: filename, headers: { :content_type => 'application/json' })
    # stub_request(:post, "http://api.sailthru.com/purchase").
    #   with(
    #     body: {"api_key"=>"my_api_key", "format"=>"json", "json"=>"{\"email\":\"praj@sailthru.com\",\"items\":[{\"qty\":22,\"title\":\"High-Impact Water Bottle\",\"price\":1099,\"id\":\"234\",\"url\":\"http://example.com/234/high-impact-water-bottle\"},{\"qty\":2,\"title\":\"Lorem Ispum\",\"price\":500,\"id\":\"2304\",\"url\":\"http://example.com/2304/lorem-ispum\"}]}", "sig"=>"3843951a6aa178c9db1aab51ffe0db9a"},
    #     headers: {
    #           'Accept'=>'*/*',
    #           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    #           'Content-Type'=>'application/x-www-form-urlencoded',
    #           'User-Agent'=>'Sailthru API Ruby Client 4.3.0'
    #     }).
    #   to_return(status: 200, body: "", headers: {})
  end

  def stub_exception(url, filename)
    stub_request(:any, URI.parse(url)).to_raise(StandardError)
  end

  def create_query_string(secret, params)
    params['sig'] = get_signature_hash(params, secret)
    params.map{ |key, value| "#{CGI::escape(key.to_s)}=#{CGI::escape(value.to_s)}" }.join("&")
  end

  def create_json_payload(api_key, secret, params)
      data = {}
      data['api_key'] = api_key
      data['format'] = 'json'
      data['json'] = params.to_json
      data['sig'] = get_signature_hash(data, secret)
      data.map{ |key, value| "#{CGI::escape(key.to_s)}=#{CGI::escape(value.to_s)}" }.join("&")
  end

  def get_rate_info_headers(limit, remaining, reset)
      {
              :x_rate_limit_limit => limit,
              :x_rate_limit_remaining => remaining,
              :x_rate_limit_reset => reset
      }
  end

end
