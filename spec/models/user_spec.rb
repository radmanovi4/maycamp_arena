describe User do
  let(:user) { create(:user) }
  describe '#full_tasks' do
    it "should return zero if there are no runs" do
      expect(user.full_tasks).to be_zero
    end

    it "should return there is one task with full points" do
      create(:run, user: user, status: "ok wa wa wa wa")
      run_with_points = create(:run, user: user, status: "ok ok ok ok ok")
      create(:run, user: user, status: "ok ok ok ok ok", problem: run_with_points.problem)

      expect(user.full_tasks).to eq(1)
    end
  end

  describe '#maycamp' do
    let(:maycamp_user) { create(:user, provider: :maycamp) }
    let(:facebook_user) { create(:user, provider: :facebook) }

    it "comprehends both users with maycamp and empty provider" do
      expect(User.maycamp).to eq([user, maycamp_user])
    end
  end

  describe '#find_or_create_by_provider_email' do
    let!(:facebook_user) { create(:user, email: 'em@il.com', provider: :facebook) }
    let!(:maycamp_user) { create(:user, email: 'em@il.com', provider: :maycamp) }

    context 'when user with this email exists' do
      it 'finds the accout by email related to the specified provider' do
        user = User.find_or_create_by_provider_email(:facebook, 'em@il.com')

        expect(user).to eq(facebook_user)
      end

      it 'finds the last user with maycamp account if no facebook account exists' do
        first = create(:user, email: 'n@w.com')
        second = create(:user, email: 'n@w.com')

        user = User.find_or_create_by_provider_email(:facebook, 'n@w.com')
        expect(user).to eq(second)
      end
    end

    context 'when no user with this email exosts' do
      before(:each) do
        @user = User.find_or_create_by_provider_email(:facebook, 'n@w.com')
      end

      it 'creates user if email not found' do
        expect(User.last).to eq(@user)
      end

      it 'sets user\'s email correctly' do
        expect(@user.email).to eq('n@w.com')
      end

      it 'sets user\'s provider correctly' do
        expect(@user.provider).to eq('facebook')
      end
    end
  end
end
