# name: QQ connect
# about: Authenticate with discourse with qq connect.
# version: 0.3.1
# authors: Erick Guan
# url: https://github.com/fantasticfears/qq_connect

gem 'omniauth-qq', '0.3.0'

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

register_css <<CSS

.btn-social.qq_connect:before {
  font-family: FontAwesome;
  content: "\\f1d6";
}

CSS
