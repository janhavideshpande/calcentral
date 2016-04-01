module CampusSolutions
  class HoldsController < CampusSolutionsController
    include AllowDelegateViewAs

    def get
      render json: CampusSolutions::MyHolds.from_session(session).get_feed_as_json
    end

  end
end
