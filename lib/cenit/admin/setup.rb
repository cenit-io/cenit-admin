module Cenit
  module Admin

    DEFAULT_CLOUD_URL = 'http://cenit-admin.s3-website-us-west-2.amazonaws.com'

    setup do
      app = self.app
      if (default_uri = ENV["#{self}:default_uri"].presence || DEFAULT_CLOUD_URL)
        config = app.configuration
        redirect_uris = config.redirect_uris || []
        unless redirect_uris.include?(default_uri)
          redirect_uris << default_uri
          config.redirect_uris = redirect_uris
          app.save
        end
      end
      puts("#{self}:redirect_uris", JSON.pretty_generate(app.configuration.redirect_uris))
    end
  end
end