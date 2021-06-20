module Cenit
  module Admin

    controller do

      get '/' do
        default_oauth_callback_uri = "#{::Cenit.homepage}#{::Cenit.oauth_path}/callback"
        @uris = uris = (redirect_uris - [default_oauth_callback_uri]).map do |uri|
          uri = URI.parse(uri)
          new_query_ar = URI.decode_www_form(String(uri.query)) << ['cenitHost', Cenit.homepage]
          uri.query = URI.encode_www_form(new_query_ar)
          uri
        end
        if uris.length == 1
          redirect_to uris[0].to_s
        end
      end

      get '/build_in_types' do
        unless (build_ins = Setup::BuildInDataType.build_ins[:cache])
          User.with_super_access do
            build_ins = []
            Setup::BuildInDataType.each do |build_in|
              dt = build_in.model.data_type
              build_ins << dt.to_hash(viewport: '{_id namespace name title _type schema}')
            end
          end
          Setup::BuildInDataType.build_ins[:cache] = build_ins
        end
        render json: build_ins
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

      get '/meta_config' do
        render json: app.configuration.meta_config || {}
      end
    end

  end
end