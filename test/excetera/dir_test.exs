defmodule ExceteraTest.DirTest do
  use ExUnit.Case

  import ExceteraTest.Helpers

  setup_all do
    cleanup("/dir_test")
  end

  setup do
    on_exit fn -> cleanup("/dir_test") end
  end

  test "list directory" do
    assert Excetera.lsdir("/dir_test/dir") == {:error, "Key not found"}

    Excetera.set "/dir_test/a", "1"
    Excetera.set "/dir_test/dir/b", "2"
    Excetera.set "/dir_test/dir/c", "3"
    Excetera.set "/dir_test/dir/d/e", "4"
    Excetera.set "/dir_test/dir/d/f", "5"

    assert {:error, "Not a directory"} = Excetera.lsdir("/dir_test/a")
    assert_raise Excetera.KeyError, "lsdir /dir_test/a: Not a directory", fn ->
      Excetera.lsdir!("/dir_test/a")
    end

    assert Excetera.lsdir("/dir_test/dir") ==
           {:ok, %{"b" => "2", "c" => "3", "d" => %{}}}
    assert Excetera.lsdir("/dir_test/dir", recursive: true) ==
           {:ok, %{"b" => "2", "c" => "3", "d" => %{"e" => "4", "f" => "5"}}}
  end

  test "put dir" do
    assert Excetera.fetch("/dir_test/ord") == {:error, "Key not found"}

    {:ok, key1} = Excetera.put "/dir_test/ord", "hello"
    key2 = Excetera.put! "/dir_test/ord", "world"

    assert {:error, "Not a directory"} = Excetera.put "/dir_test/ord/"<>key1, "hi"
    assert_raise Excetera.KeyError, "put /dir_test/ord/#{key2}: Not a directory", fn ->
      Excetera.put! "/dir_test/ord/"<>key2, "hi"
    end

    assert "hello" = Excetera.fetch!("/dir_test/ord/"<>key1)
    assert "world" = Excetera.fetch!("/dir_test/ord/"<>key2)
  end

  test "in-order keys" do
    assert Excetera.lsdir("/dir_test/ord") == {:error, "Key not found"}

    key1 = Excetera.put! "/dir_test/ord", "hello"
    key2 = Excetera.put! "/dir_test/ord", "world"
    key3 = Excetera.put! "/dir_test/ord/sub", "it's"
    key4 = Excetera.put! "/dir_test/ord/sub", "me"

    map = [{key1, "hello"}, {key2, "world"}, {"sub", %{}}] |> Enum.into(%{})
    assert Excetera.lsdir("/dir_test/ord") == {:ok, map}

    listing = [{key1, "hello"}, {key2, "world"}, {"sub", []}]
    assert Excetera.lsdir("/dir_test/ord", sorted: true) == {:ok, listing}

    rec_listing = [
      {key1, "hello"}, {key2, "world"}, {"sub", [{key3, "it's"}, {key4, "me"}]}
    ]
    assert Excetera.lsdir("/dir_test/ord", sorted: true, recursive: true) ==
           {:ok, rec_listing}
  end

  test "empty dir" do
    assert Excetera.lsdir("/dir_test/empty") == {:error, "Key not found"}

    key1 = Excetera.put! "/dir_test/empty", "hello"
    key2 = Excetera.put! "/dir_test/empty", "world"
    map = %{key1 => "hello", key2 => "world"}
    assert Excetera.fetch("/dir_test/empty", dir: true) == {:ok, map}

    :ok = Excetera.delete "/dir_test/empty/#{key1}"
    :ok = Excetera.delete "/dir_test/empty/#{key2}"

    assert Excetera.fetch("/dir_test/empty", dir: true) == {:ok, %{}}
    assert Excetera.lsdir("/dir_test/empty", sorted: true, recursive: true) == {:ok, []}
    assert Excetera.lsdir("/dir_test/empty", recursive: true) == {:ok, %{}}

  end

  test "create and delete" do
    assert Excetera.lsdir("/dir_test/dir") == {:error, "Key not found"}

    assert :ok = Excetera.mkdir("/dir_test/dir")
    assert {:error, "Key already exists"} = Excetera.mkdir("/dir_test/dir")
    assert_raise Excetera.KeyError, "mkdir /dir_test/dir: Key already exists", fn ->
      Excetera.mkdir!("/dir_test/dir")
    end

    assert {:error, "Not a file"} = Excetera.delete("/dir_test/dir")
    assert :ok = Excetera.rmdir("/dir_test/dir")

    Excetera.set "/dir_test/a/b", "hi"

    assert {:error, "Not a file"} = Excetera.delete("/dir_test/a")
    assert {:error, "Directory not empty"} = Excetera.rmdir("/dir_test/a")
    assert_raise Excetera.KeyError, "rmdir /dir_test/a: Directory not empty", fn ->
      Excetera.rmdir!("/dir_test/a")
    end

    assert :ok = Excetera.delete("/dir_test/a", recursive: true)
    assert Excetera.lsdir("/dir_test/a") == {:error, "Key not found"}

    Excetera.set "/dir_test/a/b", "hi"
    assert Excetera.fetch!("/dir_test/a/b") == "hi"
    assert :ok = Excetera.rmdir("/dir_test/a", recursive: true)
    assert Excetera.lsdir("/dir_test/a") == {:error, "Key not found"}
  end
end
