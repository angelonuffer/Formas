require './lib/widget.rb'

describe "Signup action" do
  it "needs to match confirmation password" do
    ws = mock()
    redis = mock()
    redis.stub!(:lrange).with("users", 0, -1).and_return([])
    error_box = ErrorBox.new ws, "The passwords are not identical"
    ws.stub!(:send).with("document.body.innerHTML += '#{error_box}'")
    ws.stub!(:send).with("$('#error_box').fadeIn('slow')")
    ws.stub!(:send).with("$('div#signup_form input[type=password]').css('background-color', 'red')")
    signup_form = SignupForm.new ws, Hash.new, redis
    signup_form.signup "username", "completename", "name@domain.com", "password", "not_matched_password"
  end
  it "needs to have an unused username" do
    redis = mock()
    redis.stub!(:lrange).with("users", 0, -1).and_return(["username"])
    ws = mock()
    error_box = ErrorBox.new ws, "Username already exists"
    ws.stub!(:send).with("document.body.innerHTML += '#{error_box}'")
    ws.stub!(:send).with("$('#error_box').fadeIn('slow')")
    ws.stub!(:send).with("$('div#signup_form input[name=username]').css('background-color', 'red')")
    signup_form = SignupForm.new ws, Hash.new, redis
    signup_form.signup "username", "completename", "name@domain.com", "password", "password"
  end
end
