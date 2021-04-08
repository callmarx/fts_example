class AddTsvectorToArticle < ActiveRecord::Migration[6.1]
  def up
    add_column :articles, :tsv, :tsvector
    add_index :articles, :tsv, using: :gin

    # create a unaccent and portuguese text search configuration
    execute <<-SQL
      CREATE TEXT SEARCH CONFIGURATION custom_pt (COPY = pg_catalog.portuguese);
      ALTER TEXT SEARCH CONFIGURATION custom_pt
      ALTER MAPPING
      FOR hword, hword_part, word
      WITH unaccent, portuguese_stem;
    SQL

    # create updated trigger using the new text search configuration for tsv and update existing tsv
    execute <<-SQL
      CREATE TRIGGER articles_tsvector_update BEFORE INSERT OR UPDATE
      ON articles FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger(
        tsv, 'public.custom_pt', title, content
      );

      UPDATE articles SET tsv = (to_tsvector('public.custom_pt', title || content));
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER articles_tsvector_update
      ON articles;

      DROP TEXT SEARCH CONFIGURATION custom_pt;
    SQL

    remove_index :articles, :tsv
    remove_column :articles, :tsv
  end
end
