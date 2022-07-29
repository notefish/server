defmodule Notefish.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
	# These functions act to map a series of consecutive integers to
	# random-looking string ids via pseudo-encryption. The benefit is that
	# it is difficult to subtly change an id and get a new id that exists
	# in the database. Plus, it looks cooler in URLs.

	# Resources:
	# - https://wiki.postgresql.org/wiki/Pseudo_encrypt_constrained_to_an_arbitrary_range
	# - https://stackoverflow.com/a/12590064 (modified)
    execute """
    CREATE OR REPLACE FUNCTION pseudo_encrypt_24(VALUE int) returns int AS $$
    DECLARE
    l1 int;
    l2 int;
    r1 int;
    r2 int;
    i int:=0;
    BEGIN
     l1:= (VALUE >> 12) & (4096-1);
     r1:= VALUE & (4096-1);
     WHILE i < 3 LOOP
       l2 := r1;
       r2 := l1 # ((((1366 * r1 + 150889) % 714025) / 714025.0) * (4096-1))::int;
       l1 := l2;
       r1 := r2;
       i := i + 1;
     END LOOP;
     RETURN ((l1 << 12) + r1);
    END;
    $$ LANGUAGE plpgsql strict immutable;
    """
    execute """
    CREATE OR REPLACE FUNCTION bounded_pseudo_encrypt(VALUE int) returns int AS $$
    DECLARE
    max int:=10000000;
    BEGIN
      loop
        value := pseudo_encrypt_24(value);
        exit when value <= max;
      end loop;
      return value;
    END
    $$ LANGUAGE plpgsql strict immutable;
    """
    execute """
    CREATE OR REPLACE FUNCTION string_pseudo_encrypt(VALUE bigint) RETURNS text
        LANGUAGE plpgsql IMMUTABLE STRICT AS $$
    DECLARE
     n bigint:=bounded_pseudo_encrypt(value, 10000000)::bigint * 3221;
     alphabet text:='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
     base int:=length(alphabet); 
     _n bigint:=abs(n);
     output text:='';
    BEGIN
     LOOP
       output := output || substr(alphabet, 1+(_n%base)::int, 1);
       _n := _n / base; 
       EXIT WHEN _n=0;
     END LOOP;
     RETURN output;
    END $$
    """

	execute "CREATE SEQUENCE IF NOT EXISTS nf_serial;"

    create table(:users, primary_key: false) do
	  add :id, :text, primary_key: true, default: fragment("string_pseudo_encrypt(nextval('nf_serial'))")
      add :email, :text, null: false
      add :username, :text, null: false
      add :hashed_password, :text, null: false

      timestamps(default: fragment("current_date"))
    end

	create unique_index(:users, :id)
    create unique_index(:users, :email)
    create unique_index(:users, :username)

    create table(:auth_tokens, primary_key: false) do
      add :user_id, references(:users, type: :text)
      add :token, :text, null: false
      add :device_name, :text, null: false

      add :expires_at, :naive_datetime, null: false
      add :created_at, :naive_datetime, default: fragment("current_date")
    end

    create unique_index(:auth_tokens, [:user_id, :token])
  end
end
