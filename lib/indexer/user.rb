class Indexer::User < Indexer::Base

  private

  def get_resources(user_id)
    user = User.find(user_id)

    { User => [user] }
  end
end