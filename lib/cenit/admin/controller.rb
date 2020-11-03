module Cenit
  module Admin

    controller do

      get '/' do
        default_oauth_callback_uri = "#{::Cenit.homepage}#{::Cenit.oauth_path}/callback"
        uris = redirect_uris - [default_oauth_callback_uri]
        if uris.size == 1
          uri =  URI.parse(uris[0])
          new_query_ar = URI.decode_www_form(String(uri.query)) << ['cenitHost', Cenit.homepage]
          uri.query = URI.encode_www_form(new_query_ar)
          redirect_to uri.to_s
        end
      end

      get '/authorization/:id' do

        error = status = nil
        if (auth = Setup::Authorization.where(id: params[:id]).first)
          token = auth.metadata['redirect_token']
          if token == params[:redirect_token]
            if (redirect_uri = auth.metadata['redirect_uri'])
              if auth.authorized?
                code = Code.create_from_json(metadata: { auth_id: auth.id.to_s })
                redirect_uri = "#{redirect_uri}?code=#{URI.encode(code.value)}"
                if (state = auth.metadata['state'])
                  redirect_uri = "#{redirect_uri}&state=#{URI.encode(state)}"
                end
                redirect_to redirect_uri
              else
                redirect_to redirect_uri + '?error=' + URI.encode('Not authorized')
              end
            else
              error = 'Invalid authorization state'
              status = :not_acceptable
            end
          else
            error = 'Invalid access'
            status = :not_acceptable
          end
        else
          error = 'Authorization not found'
          status = :not_found
        end
        if error
          render json: { error: error}, status: status
        end
      end

      get '/authorize' do
        if (redirect_uri = params[:redirect_uri]) && redirect_uris.include?(redirect_uri)
          auth = app.create_authorization!(
            namespace: app.namespace,
            scopes: 'openid profile email session_access multi_tenant create read update delete digest',
            metadata: { redirect_uri: redirect_uri, state: params[:state] }
          )
          authorize(auth)
        else
          render json: { error: "Invalid redirect_uri param: #{redirect_uri}" }, status: :bad_request
        end
      end

      post '/config' do
        access_token = request.headers['Authorization'].to_s.split(' ')[1].to_s
        if (user_id = app.user_id_for(access_token))
          user_id = user_id.to_s
          data =
            begin
              JSON.parse(request.body.read)
            rescue
              {}
            end
          if data.is_a?(Hash)
            if (tenant_id = data['tenant_id']).is_a?(String)
              config = Config.find_or_create_by(user_id: user_id, tenant_id: tenant_id)
              config.data = config.data.merge(data)
              if config.save
                render json: config.data
              else
                render json: { error: config.errors.full_messages }, status: :unprocessable_entity
              end
            else
              render json: { error: 'Invalid Tenant ID' }, status: :bad_request
            end
          else
            render json: { error: 'Invalid payload' }, status: :bad_request
          end
        else
          render json: { error: 'Invalid code' }, status: :unauthorized
        end
      end

      post '/token' do
        auth = nil
        value = request.body.read
        if (code = Code.where(value: value).first) && code.active?
          auth = Setup::Authorization.where(id: code.metadata['auth_id']).first
          code.destroy
        end
        if auth
          render json: {
            access_token: auth.access_token,
            expiration_date: (auth.authorized_at || Time.now) + (auth.token_span || 0),
            id_token: auth.id_token
          }
          auth.destroy
        else
          render json: { error: 'Invalid code' }, status: :unauthorized
        end
      end
    end

  end
end