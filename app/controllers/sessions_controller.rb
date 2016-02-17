# encoding: utf-8

# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  layout "main"

  # render new.rhtml
  def new
  end

  def create
    user = User.authenticate(params[:login], params[:password])
    handle_login(user, params[:login])
  end

  def destroy
    logoff
    # flash[:notice] = "Вие излязохте успешно от системата."
    redirect_to root_path
  end

  def facebook
    response = request.env['omniauth.auth']

    if response.is_a?(Hash)
      email = response.info.email
      user = User.find_or_create_by_provider_email(:facebook,
                                                   email,
                                                   response.info.name,
                                                   response.uid)

      handle_login(user, email)
    else
      handle_provider_failure(:facebook)
    end
  end

  def failure
    handle_provider_failure(request.env['omniauth.strategy'].name)
  end

  private

  def handle_login(user, login)
    if user
      handle_success(user)
    else
      handle_failure(login)
    end
  end

  def handle_success(user)
    self.current_user = user

    if session[:back]
      back_path = session[:back]
      session[:back] = nil
      redirect_to back_path
    else
      redirect_to root_path
    end
  end

  def handle_provider_failure(provider)
    handle_failure(nil, provider.capitalize)
  end

  def handle_failure(login = nil, provider = nil)
    if login
      user_from_external = User.from_external_provider_only(login)

      flash.now[:error] = user_from_external ?
        "Потребител с имейл #{login} е регистриран през "\
        "#{user_from_external.provider.capitalize}" :

        "Неуспешно влизане с потребителско име '#{login}'"

      logger.warn "Failed login for '#{login}' from #{request.remote_ip} at #{Time.now.utc}"
      @login = login
    else
      flash.now[:error] = "Неуспешно влизане с #{provider}"
    end

    @remember_me = params[:remember_me]
    render :action => 'new'
  end
end
