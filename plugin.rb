# name: QQ connect
# about: Authenticate with discourse with qq connect.
# version: 0.4.0
# author: Erick Guan

# inline gem omniauth-qq
require 'omniauth/strategies/oauth2'

class OmniAuth::Strategies::QQConnect < OmniAuth::Strategies::OAuth2
  option :name, "qq_connect"

  option :client_options, {
                          :site => 'https://graph.qq.com/oauth2.0/',
                          :authorize_url => '/oauth2.0/authorize',
                          :token_url => "/oauth2.0/token"
                        }

  option :token_params, {
                        :state => 'foobar',
                        :parse => :query
                      }

  uid do
    @uid ||= begin
      access_token.options[:mode] = :query
      access_token.options[:param_name] = :access_token
      # Response Example: "callback( {\"client_id\":\"11111\",\"openid\":\"000000FFFF\"} );\n"
      response = access_token.get('/oauth2.0/me')
      #TODO handle error case
      matched = response.body.match(/"openid":"(?<openid>\w+)"/)
      matched[:openid]
    end
  end

  info do
    {
      :nickname => raw_info['nickname'],
      :name => raw_info['nickname'],
      :image => raw_info['figureurl_1'],
    }
  end

  extra do
    {
      :raw_info => raw_info
    }
  end

  def raw_info
    @raw_info ||= begin
                    #TODO handle error case
                    #TODO make info request url configurable
      client.request(:get, "https://graph.qq.com/user/get_user_info", :params => {
                           :format => :json,
                           :openid => uid,
                           :oauth_consumer_key => options[:client_id],
                           :access_token => access_token.token
                         }, :parse => :json).parsed
    end
  end
end

OmniAuth.config.add_camelization('qq_connect', 'QQConnect')

# Discourse plugin
class QQAuthenticator < ::Auth::Authenticator

  def name
    'qq_connect'
  end

  def after_authenticate(auth_token)
    result = Auth::Result.new

    data = auth_token[:info]
    raw_info = auth_token[:extra][:raw_info]
    name = data['nickname']
    username = data['name']
    qq_uid = auth_token[:uid]

    current_info = ::PluginStore.get('qq', "qq_uid_#{qq_uid}")

    result.user =
      if current_info
        User.where(id: current_info[:user_id]).first
      end

    result.name = name
    result.username = username
    result.extra_data = { qq_uid: qq_uid, raw_info: raw_info }

    result
  end

  def after_create_account(user, auth)
    qq_uid = auth[:extra_data][:qq_uid]
    ::PluginStore.set('qq', "qq_uid_#{qq_uid}", {user_id: user.id})
  end

  def register_middleware(omniauth)
    omniauth.provider :qq_connect, :setup => lambda { |env|
      strategy = env['omniauth.strategy']
      strategy.options[:client_id] = SiteSetting.qq_connect_client_id
      strategy.options[:client_secret] = SiteSetting.qq_connect_client_secret
    }
  end
end

auth_provider :frame_width => 760,
              :frame_height => 500,
              :authenticator => QQAuthenticator.new,
              :background_color => '#51b7ec'

register_css <<EOF
.btn-social.qq_connect:before {
  font-family: FontAwesome;
  content: "\\f1d6";
}
EOF
