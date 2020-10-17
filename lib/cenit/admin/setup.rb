module Cenit
  module Admin

    setup do
      if (default_uri = ENV["#{self}:default_uri"].presence)
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