class PartyFacade < SimpleDelegator

  def initialize(user)
    super(Party.find_by(users: user))
    @user = user
  end
end
