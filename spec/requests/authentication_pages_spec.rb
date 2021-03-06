require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_content('Sign in') }
    it { should have_title('Sign in') }
  end

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_title('Sign in') }
      it { should have_selector('div.alert.alert-error', text: 'Invalid') }

      describe "after visiting the Home page" do
      	before { click_link "Home" }

      	it { should_not have_selector('div.alert.alert-error') }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

      it { should have_title(user.name) }
      it { should have_link('Users',       href: users_path) }
      it { should have_link('Profile',     href: user_path(user)) }
      it { should have_link('Settings',    href: edit_user_path(user)) }
      it { should have_link('Sign out',    href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe "followed by signout - should not have particular links" do
      	before { click_link "Sign out" }
      	it { should have_link("Sign in") }
        it { should_not have_link('Profile') }
        it { should_not have_link('Settings') }
      end
    end
  end

  describe "Authorization" do

    describe "For non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "visiting the following page" do
        before { visit following_user_path(user) }
        it { should have_title('Sign in') }
      end

      describe "visiting the followers page" do
        before { visit followers_user_path(user) }
        it { should have_title('Sign in') }
      end

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email", with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "it should come back to edit page" do
          it { should have_title("Edit User") }
        end

        describe "when signing in again" do
          before do
            delete signout_path
            visit signin_path
            fill_in "Email",    with: user.email
            fill_in "Password", with: user.password
            click_button "Sign in"
          end
          it "should render the default page" do
            expect(page).to have_title(user.name)
          end
        end
      end
      
      describe "In user_controller" do
        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_title("Sign in") }
        end

        describe "submitting to the update action" do
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_title("Sign in") }
        end
      end

      describe " In the microposts controller" do

        describe "submitting to the create action" do
          before { post microposts_path }
          specify { expect(response).to redirect_to(signin_path) }
        end
        
        describe "submitting to the destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end

      describe "In relationships controller - submitting POST" do
        before { post relationships_path }
        specify { expect(response).to redirect_to(signin_path) }
      end

      describe "In relationships controller - submitting DESTROY" do
        before { delete relationship_path(1) }
        specify { expect(response).to redirect_to(signin_path ) }
      end
    end

    describe "As wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user, no_capybara: true }

      describe "visiting the wrong user's edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_title(full_title('Edit user')) }
      end

      describe "issuing a patch request for the wrong user" do
        before { patch user_path(wrong_user) }
        specify { expect(response).to redirect_to(root_path) }
      end
    end

    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin, no_capybara: true }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { expect(response).to redirect_to(root_path) }
      end
    end

    describe "as an admin user" do
      let(:admin) { FactoryGirl.create(:admin) }
      before do
       signin_path admin, no_capybara: true
      end

      it "should not be able to delete itself " do
        expect { delete user_path(admin) }.not_to change(User, :count)
      end
    end
  end
end