defmodule BlockTest do
  @moduledoc """
  Implements some basic tests to initially verify blocks persistence.
  In the future, we should determine some potential issues with the
  implementation and test against them, especially for the diff.
  """
  use ExUnit.Case
  use Plug.Test

  Ecto.Adapters.SQL.Sandbox.mode(Notefish.Repo, :manual)

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Notefish.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Notefish.Repo, {:shared, self()})

    {:ok, user, space} = User.create("john.doe@gmail.com", "john.doe", "123")

    IO.inspect user

    {:ok, token} = Notefish.Auth.generate_token(user, "test", false)

    note =
      Note.changeset(
        %Note{},
        %{
          :title => "My Note",
          :space_id => space.id
        })
      |> Notefish.Repo.insert!(returning: true)
      |> Notefish.Repo.preload(:space)

    blocks =
      Enum.map([1, 2, 3], fn i ->
        Block.changeset(
          %Block{},
          %{
            :space_id => space.id,
            :note_id => note.id,
            :rank => i * 25, # 25, 50, 75
            :body => "Some block body #{i}"
          })
        |> Notefish.Repo.insert!(returning: true)
        |> Notefish.Repo.preload([:space, :note])
      end)

    note = Notefish.Repo.preload(note, :blocks)

    IO.inspect note

    [
      user: user, 
      token: token, 
      space: space,
      note: note,
      blocks: blocks
    ]
  end

  test "GET /note: existing note is returned correctly", context do
    %{
      token: token,
      space: space,
      note: note
    } = context

    conn =
      conn(:get, "/note/#{note.id}")
      |> put_req_header("authorization", "Bearer #{token}")
      |> Notefish.ApiRouter.call(%{})

    assert conn.status == 200
    ["ok", fetched] = Jason.decode!(conn.resp_body) 

    # metadata is correct
    assert note.id == fetched["id"]
    assert note.title == fetched["title"]
    assert note.space_id == fetched["space_id"]
    # blocks are returned correctly
    assert (note.blocks |> Enum.count()) == (fetched["blocks"] |> Enum.count())

    nB0 = note.blocks |> Enum.at(0)
    nB1 = note.blocks |> Enum.at(1)
    fB0 = fetched["blocks"] |> Enum.at(0)
    fB1 = fetched["blocks"] |> Enum.at(1)
    assert nB0.body == fB0.body
    assert nB1.body == fB1.body
  end

  test "PUT /note: persists & returns note and blocks correctly", context do
    %{
      token: token,
      space: space,
      note: note
    } = context

    data = %{
      "blocks" => [
        %{
          "body" => "Body of block 1 [[My Note]]",
          "tags" => ["a", "b", "c"],
          "refs" => [note.id],
        },
        %{ # child block
          "body" => "Body of block 2",
          "parent" => 0 # since we don't have ids, refer to parent by index
        }
      ],
      "space" => space.id,
      "title" => "New Note Title"
    }

    conn =
      conn(:put, "/note")
      |> put_req_header("authorization", "Bearer #{token}")
      |> Map.put(:body_params, data)
      |> Notefish.ApiRouter.call(%{})

    assert conn.status == 200
    ["ok", created_note] = Jason.decode!(conn.resp_body)

    %{"id" => id} = created_note
    assert id != nil

    conn =
      conn(:get, "/note/" <> id <> "?blocks=true")
      |> put_req_header("authorization", "Bearer #{token}")
      |> Notefish.ApiRouter.call(%{})
    
    assert conn.status == 200
    ["ok", fetched] = Jason.decode!(conn.resp_body)

    # metadata is correct
    assert data["id"] == id
    assert data["space"] == fetched["space"]
    # blocks are returned
    assert data["blocks"][0]["body"] == fetched["blocks"][0]["body"]
    assert data["blocks"][1]["body"] == fetched["blocks"][1]["body"]
  end

  test "PUT /note: updates a note with blocks correctly", %{token: token, note: note} do
    new_data = %{
      "id" => note.id, # update
      "blocks" => [
        %{
          "body" => "Body of block 1 [[My Note]]",
          "tags" => ["a", "b", "c"],
          "refs" => [note.id]
        },
        %{ # child block
          "body" => "Body of block 2",
          "parent" => 0 # since we don't have ids, refer to parent by index
        }
      ]
    }

    conn =
      conn(:put, "/note")
      |> put_req_header("authorization", "Bearer #{token}")
      |> Map.put(:body_params, new_data)
        |> Notefish.ApiRouter.call(%{})

    assert conn.status == 200
    ["ok", %{}] = Jason.decode!(conn.resp_body)

    conn =
      conn(:get, "/note/" <> note.id <> "?blocks=true")
      |> put_req_header("authorization", "Bearer #{token}")
      |> Notefish.ApiRouter.call(%{})
    
    assert conn.status == 200
    ["ok", got_note] = Jason.decode!(conn.resp_body)

    # metadata is correct
    assert new_data["id"] == note.id
    assert new_data["space"] == got_note["space"]
    # blocks are returned
    assert new_data["blocks"][0]["body"] == got_note["blocks"][0]["body"]
    # block children are returned
    assert new_data["blocks"][1]["body"] == got_note["blocks"][1]["body"]
    # parent id is correct
    assert new_data["blocks"][1]["parent"] == got_note["blocks"][0]["id"]
  end

  test "PUT /note: updates a note with diff correctly", context do
    %{
      token: token,
      note: note,
      blocks: blocks
    } = context

    diff =
      [
        %{"op" => "amend",
          "id" => blocks |> Enum.at(0) |> Map.get(:id),
          "body" => "Updated body 1"},
        %{"op" => "delete",
          "id" => blocks |> Enum.at(0) |> Map.get(:id)},
        %{"op" => "insert",
          "rank" => 50,
          "body" => "New note body"}
      ]

    conn =
      conn(:put, "/note")
      |> put_req_header("authorization", "Bearer #{token}")
      |> Map.put(:body_params, %{
        "id" => note.id,
        "title" => "New Note Title",
        "diff" => diff
      })
      |> Notefish.ApiRouter.call(%{})
    assert conn.status == 200
    ["ok", %{}] = Jason.decode!(conn.resp_body)

    conn =
      conn(:get, "/note/" <> note.id <> "?blocks=true")
      |> put_req_header("authorization", "Bearer #{token}")
      |> Notefish.ApiRouter.call(%{})
    assert conn.status == 200
    ["ok", edited] = Jason.decode!(conn.resp_body)
    %{"blocks" => new_blocks} = edited

    # block 1 amended
    assert new_blocks[0]["body"] == diff[0]["body"]
    # block 2 deleted
    assert new_blocks[1]["id"] != blocks[1]["id"]
    # block 2 replaced
    assert new_blocks[1]["body"] == diff[2]["body"]
    # last block unchanged
    assert new_blocks[2]["id"] == blocks[3]["id"]
    assert new_blocks[2]["body"] == blocks[3]["body"]
  end

  test "DELETE /note: deletes note successfully", %{token: token, note: note} do
    # (sanity check) verify note is present
    conn =
      conn(:get, "/note/" <> note.id)
      |> put_req_header("authorization", "Bearer #{token}")
      |> Notefish.ApiRouter.call(%{})
    assert conn.status == 200
    ["ok", %{}] = Jason.decode!(conn.resp_body)

    conn =
      conn(:delete, "/note/" <> note.id)
      |> put_req_header("authorization", "Bearer #{token}")
      |> Notefish.ApiRouter.call(%{})
    assert conn.status == 200
    ["ok", "deleted"] = Jason.decode!(conn.resp_body)

    conn =
      conn(:get, "/note/" <> note.id)
      |> put_req_header("authorization", "Bearer #{token}")
      |> Notefish.ApiRouter.call(%{})
    assert conn.status == 401
    ["error", "not_found"] = Jason.decode!(conn.resp_body)
  end
end

