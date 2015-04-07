module Slate
  class Checklist < BaseProxy

    APP_ID = 'slate'
    APP_NAME = 'Slate'

    include ClassLogger
    include Cache::UserCacheExpiry
    include Proxies::Mockable

    def initialize(options = {})
      super(Settings.slate_checklist_proxy, options)
      initialize_mocks if @fake
    end

    def get
      internal_response = self.class.smart_fetch_from_cache(id: @uid) do
        get_internal
      end
      if internal_response[:noStudentId] || internal_response[:statusCode] < 400
        internal_response
      else
        {
          errored: true
        }
      end
    end

    private

    def get_internal
      url = @settings.base_url
      logger.info "Fake = #{@fake}; Making request to #{url} on behalf of user #{@uid}; cache expiration #{self.class.expires_in}"
      request_options = {
        basic_auth: {
          username: @settings.username,
          password: @settings.password
        },
        query: {
          uid: @uid
        }
      }
      response = get_response(url, request_options)
      logger.debug "Remote server status #{response.code}, Body = #{response.body}"
      {
        statusCode: response.code,
        feed: response.parsed_response
      }
    end

    def mock_json
      xml = MultiXml.parse File.read(Rails.root.join('fixtures', 'xml', 'slate_checklist_feed.xml'))
      xml.to_json
    end

    def mock_request
      # Webmock match criteria need an adjustment because of basic authentication.
      feed_uri = URI.parse(@settings.base_url)
      {
        method: :any,
        uri: /.*#{feed_uri.hostname}#{feed_uri.path}.*/
      }
    end

  end
end
