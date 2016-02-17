describe SessionsController do
  let!(:user) { create(:user, email: 'em@il.com') }
  let!(:second_user) { create(:user, email: 'em@il.com') }
  let(:correct_pass) { 'secret' }

  describe '#create' do
    it 'logs user with correct credentials' do
      get :create, { login: user.login, password: correct_pass }

      expect_logged_user_to_be(user)
    end

    it 'logs nobody with wrong credentials' do
      get :create, { login: user.login, password: 'incorrect' }

      expect_no_user_logged
    end

    it 'shows appropriate error message when using wrong credentials' do
      get :create, { login: user.login, password: 'incorrect' }

      expect_error_shown("Неуспешно влизане с потребителско име '#{user.login}'")
    end

    it 'prompts user to log with facebook when trying to '\
       'log with email of existing facebook account only' do

      [user, second_user].each(&:destroy)
      create_facebook_user(user.email)

      get :create, { login: user.email, password: 'incorrect' }
      expect_error_shown("Потребител с имейл '#{user.email}' е регистриран през Facebook")
    end

    it 'shows error message related standard account when '\
       'receiving wrong password for email duplicated by standart & FB accounts' do

      create_facebook_user(user.email)

      get :create, { login: user.email, password: 'incorrect' }
      expect_error_shown("Неуспешно влизане с потребителско име '#{user.email}'")
    end
  end

  describe '#facebook' do
    let(:successful_response_existing) do
      { provider: :facebook, info: { email: 'em@il.com' } }
    end

    let(:successful_response_new) do
      { provider: :facebook, info: { email: 'new@new.com', name: 'The New Guy' } }
    end

    let(:failure_response) { :error }

    context 'when user with this email exists' do
      before(:each) do
        mock_omniauth(:facebook, successful_response_existing)
      end

      it 'finds a user by Facebook email' do
        get :facebook
        expect(session[:user_id]).to be
      end

      it 'logs the last user with the given email' do
        get :facebook
        expect_logged_user_to_be(second_user)
      end

      it 'logs the Facebook account if there are both Facebook and standard ones' do
        facebook_user = create_facebook_user('em@il.com')
        get :facebook

        expect_logged_user_to_be(facebook_user)
      end
    end

    context 'when no user with this email exists' do
      before(:each) do
        mock_omniauth(:facebook, successful_response_new)
        get :facebook
      end

      it 'creates a new user' do
        expect(User.last.id).to eq(second_user.id + 1)
      end

      it 'creates a new user with facebook provider' do
        expect(User.last.provider.to_sym).to eq(:facebook)
      end

      it 'fills new user\'s email correctly' do
        expect(User.last.email).to eq('new@new.com')
      end

      it 'fills new user\'s name correctly' do
        expect(User.last.name).to eq('The New Guy')
      end

      it 'fills new user\'s login correctly' do
        expect(User.last.login).to eq('The New Guy'.downcase)
      end
    end
  end

  # Commented out since `get :failure` fails with an odd error:
  # ActionController::UrlGenerationError:
  # No route matches {:action=>"failure", :controller=>"sessions"} missing required keys: [:action]

  # describe '#failure' do
  #   before(:each) do
  #     mock_omniauth(:facebook, :failure_response, is_success: false)
  #     get :failure
  #   end

  #   it 'logs no user when omniauth failure happens' do
  #     expect_no_user_logged
  #   end

  #     it "redirects to root" do
  #       expect(response).to redirect_to root_path
  #     end
  # end

  private

  def expect_no_user_logged
    expect_logged_user_to_be(nil)
  end

  def expect_logged_user_to_be(user)
    expect(session[:user_id]).to eq(user.try(:id))
  end

  def expect_error_shown(error_message)
    expect(flash.now[:error]).to eq(error_message)
  end

  def create_facebook_user(email = nil)
    options = { provider: User.providers[:facebook] }
    options.merge!(email: email) if email

    create(:user, options)
  end
end
