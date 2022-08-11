defmodule Debug do
  @salt Application.fetch_env!(:notefish, :bcrypt_salt)
  @hashed_password Bcrypt.Base.hash_password("123", @salt)

  import Ecto.Query

  def user do
    q = from u in User, select: u, limit: 1
    Notefish.Repo.one(q)
  end

  def users do
    q = from u in User, select: u
    Notefish.Repo.all(q)
  end

  def note do
    q = from n in Note, select: n, limit: 1
    Notefish.Repo.one(q)
  end

  def notes do
    q = from n in Note, select: n
    Notefish.Repo.all(q)
  end

  def make_user(name \\ nil) do
    #generate random string if not provided
    name =
      case name do
        nil -> for _ <- 1..5, into: "", do: <<Enum.random('abcedfg')>>
        _   -> name
      end

    result = User.create("#{name}@gmail.com", name, @hashed_password)
    with {:ok, user, _space} <- result do
      user
    else
      {:error, e} -> raise e
    end
  end

  def make_token do
    q = from u in User, select: u, limit: 1
    user = q |> Notefish.Repo.one()

    with {:ok, token} <- Notefish.Auth.generate_token(user, "testing", true) do
      token
    else
      {:error, e} -> raise e
    end
  end

  def make_note do
    q = from u in User, select: u, limit: 1
    %User{id: id} = q |> Notefish.Repo.one()
    note = %Note{title: "Some Note", space_id: id}
    with {:ok, note} <- Notefish.Repo.insert(note, returning: true) do
      note
    else
      {:error, e} -> raise e
    end
  end

  def make_blocks do
    q = from n in Note,
      select: n,
      limit: 1
    %Note{id: id, space_id: space_id} = q |> Notefish.Repo.one()
    for n <- 1..3 do
      block = %Block{space_id: space_id, note_id: id, body: "Block body #{n}", rank: n*25}
      with {:ok, block} <- block |> Notefish.Repo.insert(returning: true) do
        # use new block to carry id
        block
      else
        {:error, e} -> raise e
      end
    end
  end
end
