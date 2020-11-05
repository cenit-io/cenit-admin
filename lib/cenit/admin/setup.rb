module Cenit
  module Admin

    DEFAULT_CLOUD_URL = 'http://cenit-admin.s3-website-us-west-2.amazonaws.com'

    setup do
      if (default_uri = ENV["#{self}:default_uri"].presence || DEFAULT_CLOUD_URL)
        app = self.app
        config = app.configuration
        redirect_uris = config.redirect_uris || []
        unless redirect_uris.include?(default_uri)
          redirect_uris << default_uri
          config.redirect_uris = redirect_uris
          app.save
        end
      end
    end
  end
end