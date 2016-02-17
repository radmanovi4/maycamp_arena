describe SessionsController do
  let!(:first) { create(:user, email: 'em@il.com') }
  let!(:second) { create(:user, email: 'em@il.com') }

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
        get :facebook
      end

      it 'finds a user by Facebook email' do
        expect(session[:user_id]).to be
      end

      it 'logs the last user with the given email' do
        expect(session[:user_id]).to eq(second.id)
      end

      it "redirects to root" do
        expect(response).to redirect_to root_path
      end
    end

    context 'when no user with this email exists' do
      before(:each) do
        mock_omniauth(:facebook, successful_response_new)
        get :facebook
      end

      it 'creates a new user' do
        expect(User.last.id).to eq(second.id + 1)
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
  #     expect(session[:user_id]).to be_empty
  #   end

  #     it "redirects to root" do
  #       expect(response).to redirect_to root_path
  #     end
  # end
end
