defmodule LearnEcto.Service.User do
  @moduledoc false

  alias LearnEcto.Context.User

  def create(user) do
    User.upsert(user)
  end

  def update(user_id, user) do
    User.upsert(Map.put(user, :id, user_id))
  end

  def update_email(user_id, email) do
    User.upsert(%{id: user_id, email: email})
  end

  def update_name(user_id, name) do
    User.upsert(%{id: user_id, name: name})
  end

  def get(user_id) do
    User.get(user_id)
  end

  # __end_of_module__
end
