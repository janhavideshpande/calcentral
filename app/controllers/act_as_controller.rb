class ActAsController < ApplicationController

  include ClassLogger

  skip_before_filter :check_reauthentication, :only => [:stop_act_as]

  def initialize(options = {})
    @act_as_session_key = options[:act_as_session_key] || 'original_user_id'
  end

  def start
    uid_param = params['uid']
    act_as_authorization uid_param
    return redirect_to root_path unless valid_params? uid_param
    logger.warn "Start: #{current_user.real_user_id} act as #{uid_param}"
    session[@act_as_session_key] = session['user_id'] unless session[@act_as_session_key]
    session['user_id'] = User::AuthenticationValidator.new(uid_param).validated_user_id
    # TODO Mimic '/uid_error' redirect for nulled session user IDs.

    # Post-processing
    after_successful_start(session, params)
    render :nothing => true, :status => 204
  end

  def stop
    return redirect_to root_path unless session['user_id'] && session[@act_as_session_key]

    # TODO: We might have to be aggressive with cache invalidation.
    Cache::UserCacheExpiry.notify session['user_id']
    logger.warn "Stop: #{session[@act_as_session_key]} act as #{session['user_id']}"
    session['user_id'] = session[@act_as_session_key]
    session[@act_as_session_key] = nil

    render :nothing => true, :status => 204
  end

  private

  def act_as_authorization(uid_param)
    authorize current_user, :can_view_as?
  end

  def after_successful_start(session, params)
    # This makes sure the most recently viewed user is at the top of the list
    original_uid = session[@act_as_session_key]
    uid_to_store = params['uid']
    User::StoredUsers.delete_recent_uid(original_uid, uid_to_store)
    User::StoredUsers.store_recent_uid(original_uid, uid_to_store)
  end

  def valid_params?(act_as_uid)
    if act_as_uid.blank?
      logger.warn "User #{current_user.real_user_id} FAILED to login to #{act_as_uid}, cannot be blank!"
      return false
    end

    # Ensure that uids are numeric
    begin
      Integer(act_as_uid, 10)
    rescue ArgumentError
      logger.warn "User #{current_user.user_id} FAILED to login to #{act_as_uid}, values must be integers"
      return false
    end

    # Ensure uid is in our database
    if Settings.features.cs_profile
      ldap_uid = CalnetCrosswalk::ByUid.new(user_id: act_as_uid).lookup_ldap_uid
      if ldap_uid.blank?
        logger.warn "User #{current_user.real_user_id} FAILED to login to #{act_as_uid}, act_as_uid not found"
        return false
      end
    else
      if CampusOracle::Queries.find_people_by_uid(act_as_uid).blank?
        logger.warn "User #{current_user.real_user_id} FAILED to login to #{act_as_uid}, act_as_uid not found"
        return false
      end
    end
    true
  end

end
