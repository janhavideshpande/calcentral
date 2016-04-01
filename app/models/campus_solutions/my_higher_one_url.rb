module CampusSolutions
  class MyHigherOneUrl < UserSpecificModel

    include ClassLogger
    include Cache::LiveUpdatesEnabled
    include Cache::FreshenOnWarm
    include Cache::JsonAddedCacher
    include CampusSolutions::SirFeatureFlagged

    def get_feed_internal
      return {} unless is_feature_enabled
      proxy_args = {
        user_id: @uid,
        delegate_uid: @options[:delegate_uid]
      }
      CampusSolutions::HigherOneUrl.new(proxy_args).get
    end

  end
end
